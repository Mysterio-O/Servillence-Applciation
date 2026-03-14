using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Timers;
using System.Windows;
using Surveil.Agent.Services;
using Surveil.Contracts;

namespace Dashboard.Win.Views
{
    public partial class MainWindow : Window
    {
        private readonly ApiClient _api;
        private readonly CaptureService _capture = new();
        private readonly OcrService _ocr = new();
        private readonly ActivityService _activity = new();
        private readonly ScreenshotScheduler _screenshotScheduler = new();
        private readonly SemaphoreSlim _uploadLock = new(1, 1);

        private string? _currentShiftId;
        private string? _currentSessionKey;
        private System.Timers.Timer? _uiTimer;
        private DateTimeOffset _shiftStartTime;
        private CancellationTokenSource? _monitoringCts;
        private Task? _monitoringTask;
        private AgentConfig _agentConfig = new();
        private int _frameCount;
        private string _lastActiveApp = "-";
        private string _uploadStatus = "Idle";

        private readonly List<FrameUploadDto> _pendingFrames = new();
        private readonly object _pendingLock = new();
        private const int UploadBatchSize = 60;

        public MainWindow()
        {
            InitializeComponent();
            Closing += MainWindow_Closing;

            var cfgPath = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
            string apiBase = "http://localhost:8080";
            if (File.Exists(cfgPath))
            {
                try
                {
                    var doc = System.Text.Json.JsonDocument.Parse(File.ReadAllText(cfgPath));
                    if (doc.RootElement.TryGetProperty("ApiBaseUrl", out var prop))
                        apiBase = prop.GetString() ?? apiBase;
                }
                catch { }
            }

            _api = new ApiClient(apiBase);

            if (_api.LoadSavedTokens())
                ShowShiftPanel();
        }

        private void ShowLoginPanel()
        {
            LoginPanel.Visibility = Visibility.Visible;
            ShiftPanel.Visibility = Visibility.Collapsed;
            MonitoringPanel.Visibility = Visibility.Collapsed;
        }

        private void ShowShiftPanel()
        {
            LoginPanel.Visibility = Visibility.Collapsed;
            ShiftPanel.Visibility = Visibility.Visible;
            MonitoringPanel.Visibility = Visibility.Collapsed;
            UserNameText.Text = "Signed in";
            ShiftStatusText.Text = "Click 'Start Shift' to begin monitoring.";
        }

        private void ShowMonitoringPanel()
        {
            LoginPanel.Visibility = Visibility.Collapsed;
            ShiftPanel.Visibility = Visibility.Collapsed;
            MonitoringPanel.Visibility = Visibility.Visible;
            StartUiTimer();
        }

        private async void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            LoginButton.IsEnabled = false;
            LoginErrorText.Visibility = Visibility.Collapsed;
            var email = EmailBox.Text.Trim();
            var password = PasswordBox.Password;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                LoginErrorText.Text = "Please enter your email and password.";
                LoginErrorText.Visibility = Visibility.Visible;
                LoginButton.IsEnabled = true;
                return;
            }

            var ok = await _api.LoginAsync(email, password);
            if (ok)
            {
                PasswordBox.Clear();
                ShowShiftPanel();
            }
            else
            {
                LoginErrorText.Text = "Invalid email or password.";
                LoginErrorText.Visibility = Visibility.Visible;
            }
            LoginButton.IsEnabled = true;
        }

        private async void StartShiftButton_Click(object sender, RoutedEventArgs e)
        {
            StartShiftButton.IsEnabled = false;
            ShiftStatusText.Text = "Starting shift...";

            _agentConfig = await _api.GetAgentConfigAsync() ?? new AgentConfig();

            var shiftId = await _api.StartShiftAsync();
            if (shiftId == null)
            {
                ShiftStatusText.Text = "Failed to start shift. Check connection.";
                StartShiftButton.IsEnabled = true;
                return;
            }

            _currentShiftId = shiftId;
            _currentSessionKey = $"session_{DateTime.UtcNow:yyyyMMdd_HHmmss}_{Guid.NewGuid():N}";
            _shiftStartTime = DateTimeOffset.Now;
            ShowMonitoringPanel();
            AppendLog($"Shift started: {shiftId}");
            AppendLog($"Session started: {_currentSessionKey}");
            _frameCount = 0;
            _uploadStatus = "Monitoring";

            StartMonitoringLoop();
        }

        private async void EndShiftButton_Click(object sender, RoutedEventArgs e)
        {
            EndShiftButton.IsEnabled = false;
            await StopMonitoringLoopAsync();

            if (_currentShiftId != null)
            {
                await _api.EndShiftAsync(_currentShiftId);
                _currentShiftId = null;
            }

            _currentSessionKey = null;
            StopUiTimer();
            ShowShiftPanel();
            ShiftStatusText.Text = "Shift ended. Ready for next shift.";
            EndShiftButton.IsEnabled = true;
        }

        private async void LogoutButton_Click(object sender, RoutedEventArgs e)
        {
            await StopMonitoringLoopAsync();
            _api.Logout();
            ShowLoginPanel();
        }

        private void StartUiTimer()
        {
            _uiTimer = new System.Timers.Timer(1000);
            _uiTimer.Elapsed += OnUiTick;
            _uiTimer.Start();
        }

        private void StopUiTimer()
        {
            _uiTimer?.Stop();
            _uiTimer?.Dispose();
            _uiTimer = null;
        }

        private void OnUiTick(object? sender, ElapsedEventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                var elapsed = DateTimeOffset.Now - _shiftStartTime;
                ShiftTimeText.Text = $"{(int)elapsed.TotalHours:D2}:{elapsed.Minutes:D2}:{elapsed.Seconds:D2}";
            });
        }

        public void UpdateStatus(string app, int frames, string uploadStatus)
        {
            Dispatcher.Invoke(() =>
            {
                LastAppText.Text = $"Last app: {app}";
                FrameCountText.Text = $"Frames: {frames}";
                UploadStatusText.Text = $"Upload: {uploadStatus}";
            });
        }

        public void AppendLog(string message)
        {
            Dispatcher.Invoke(() =>
            {
                var ts = DateTime.Now.ToString("HH:mm:ss");
                ActivityLog.AppendText($"[{ts}] {message}\n");
                ActivityLog.ScrollToEnd();
            });
        }

        public string? CurrentShiftId => _currentShiftId;
        public ApiClient ApiClient => _api;

        private void StartMonitoringLoop()
        {
            _monitoringCts?.Cancel();
            _monitoringCts = new CancellationTokenSource();
            _monitoringTask = Task.Run(() => MonitoringLoopAsync(_monitoringCts.Token));
        }

        private async Task StopMonitoringLoopAsync()
        {
            if (_monitoringCts == null) return;

            _monitoringCts.Cancel();
            try
            {
                if (_monitoringTask != null)
                    await _monitoringTask;
            }
            catch (OperationCanceledException) { }
            catch (Exception ex)
            {
                AppendLog($"Monitor stop warning: {ex.Message}");
            }
            finally
            {
                _monitoringCts.Dispose();
                _monitoringCts = null;
                _monitoringTask = null;
            }

            await UploadBufferedFramesAsync(force: true, CancellationToken.None);
        }

        private async Task MonitoringLoopAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                try
                {
                    var processName = _capture.GetActiveProcessName();
                    if (!ShouldCaptureProcess(processName, _agentConfig))
                    {
                        await Task.Delay(GetDelayMs(isIdle: false), ct);
                        continue;
                    }

                    var (bmp, monitor) = _capture.CaptureCursorScreen();
                    if (bmp != null)
                    {
                        using (bmp)
                        {
                            var title = _capture.GetForegroundWindowTitle();
                            var isIdle = _activity.IsIdle(TimeSpan.FromSeconds(60));
                            var category = AppCategoryService.Classify(processName, title, isIdle);
                            string ocrText = string.Empty;
                            if (_agentConfig.EnableOcr)
                                ocrText = await _ocr.ExtractAsync(bmp, "eng");

                            var dto = new FrameUploadDto
                            {
                                CapturedAt = DateTime.UtcNow,
                                ActiveApp = processName,
                                WindowTitle = title,
                                AppCategory = category,
                                IsIdle = isIdle,
                                IdleReason = isIdle ? "NoInput" : null,
                                OcrText = ocrText,
                                BrowserDomain = AppCategoryService.ExtractUrlFromOcrText(ocrText),
                                MonitorIndex = monitor?.Index,
                                CursorX = _capture.GetCursorPosition().X,
                                CursorY = _capture.GetCursorPosition().Y,
                                ThumbnailBase64 = GetThumbnailBase64OrNull(bmp, category)
                            };

                            EnqueueFrame(dto);
                            _frameCount++;
                            _lastActiveApp = processName;

                            UpdateStatus(_lastActiveApp, _frameCount, _uploadStatus);
                            if (_frameCount % 20 == 0)
                                AppendLog($"Captured {_frameCount} frames");

                            await UploadBufferedFramesAsync(force: false, ct);
                            await Task.Delay(GetDelayMs(isIdle), ct);
                        }
                    }
                    else
                    {
                        await Task.Delay(GetDelayMs(isIdle: false), ct);
                    }
                }
                catch (OperationCanceledException) when (ct.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _uploadStatus = "CaptureError";
                    UpdateStatus(_lastActiveApp, _frameCount, _uploadStatus);
                    AppendLog($"Capture error: {ex.Message}");
                    await Task.Delay(1000, ct);
                }
            }
        }

        private int GetDelayMs(bool isIdle)
        {
            var fps = Math.Clamp(_agentConfig.CaptureFps <= 0 ? 1.0 : _agentConfig.CaptureFps, 0.2, 5.0);
            var delay = (int)Math.Round(1000 / fps);
            return isIdle ? delay * 2 : delay;
        }

        private bool ShouldCaptureProcess(string processName, AgentConfig cfg)
        {
            if (string.IsNullOrWhiteSpace(processName)) return false;

            var proc = processName.ToLowerInvariant();
            if (cfg.DeniedApps.Any(d => proc.Contains(d.ToLowerInvariant())))
                return false;

            if (cfg.AllowedApps.Count > 0)
                return cfg.AllowedApps.Any(a => proc.Contains(a.ToLowerInvariant()));

            return true;
        }

        private void EnqueueFrame(FrameUploadDto frame)
        {
            lock (_pendingLock)
            {
                _pendingFrames.Add(frame);
            }
        }

        private async Task UploadBufferedFramesAsync(bool force, CancellationToken ct)
        {
            if (_currentShiftId == null || _currentSessionKey == null) return;

            await _uploadLock.WaitAsync(ct);
            try
            {
                List<FrameUploadDto> batch;
                lock (_pendingLock)
                {
                    if (_pendingFrames.Count == 0) return;
                    if (!force && _pendingFrames.Count < UploadBatchSize) return;

                    var count = force ? _pendingFrames.Count : Math.Min(UploadBatchSize, _pendingFrames.Count);
                    batch = _pendingFrames.Take(count).ToList();
                    _pendingFrames.RemoveRange(0, count);
                }

                var ok = await _api.UploadFrameBatchAsync(_currentShiftId, _currentSessionKey, batch);
                if (ok)
                {
                    _uploadStatus = $"OK ({batch.Count})";
                }
                else
                {
                    lock (_pendingLock)
                    {
                        _pendingFrames.InsertRange(0, batch);
                    }
                    _uploadStatus = "Retrying";
                }

                UpdateStatus(_lastActiveApp, _frameCount, _uploadStatus);
            }
            finally
            {
                _uploadLock.Release();
            }
        }

        private string? GetThumbnailBase64OrNull(Bitmap bmp, string category)
        {
            if (!_agentConfig.EnableScreenshots) return null;
            if (!_screenshotScheduler.ShouldCapture(category, _agentConfig.ScreenshotIntervalMinutes)) return null;

            using var ms = new MemoryStream();
            bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
            return Convert.ToBase64String(ms.ToArray());
        }

        private async void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
        {
            await StopMonitoringLoopAsync();
            _api.Dispose();
        }
    }
}
