using SurveilWin.Api.Services;

namespace SurveilWin.Api.BackgroundJobs;

public class ShiftAutoCloseJob : BackgroundService
{
    private readonly IServiceProvider _services;
    private readonly ILogger<ShiftAutoCloseJob> _logger;
    private readonly IConfiguration _configuration;

    public ShiftAutoCloseJob(
        IServiceProvider services,
        ILogger<ShiftAutoCloseJob> logger,
        IConfiguration configuration)
    {
        _services = services;
        _logger = logger;
        _configuration = configuration;
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        var intervalMinutes = _configuration.GetValue<int?>("Jobs:ShiftAutoCloseIntervalMinutes") ?? 60;
        var interval = TimeSpan.FromMinutes(Math.Max(1, intervalMinutes));

        await BackgroundJobRunner.RunPeriodicAsync(
            interval,
            RunOnceAsync,
            _logger,
            nameof(ShiftAutoCloseJob),
            ct,
            runImmediately: true);
    }

    private async Task RunOnceAsync(CancellationToken ct)
    {
        using var scope = _services.CreateScope();
        var shiftService = scope.ServiceProvider.GetRequiredService<IShiftService>();
        await shiftService.AutoCloseStaleShiftsAsync();
        _logger.LogInformation("Shift auto-close job completed");
    }
}
