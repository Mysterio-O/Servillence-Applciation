using System.Globalization;

namespace SurveilWin.Api.Services;

public class LocalScreenshotStorageService : IScreenshotStorageService
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfiguration _configuration;
    private readonly ILogger<LocalScreenshotStorageService> _logger;

    public LocalScreenshotStorageService(
        IWebHostEnvironment env,
        IConfiguration configuration,
        ILogger<LocalScreenshotStorageService> logger)
    {
        _env = env;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<string?> SaveBase64ScreenshotAsync(
        string? base64,
        Guid organizationId,
        Guid employeeId,
        DateTime capturedAt,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(base64)) return null;

        try
        {
            var cleaned = StripDataUriPrefix(base64);
            var bytes = Convert.FromBase64String(cleaned);

            var root = _configuration["App:ScreenshotsDir"] ?? Path.Combine("data", "screenshots");
            var absRoot = Path.IsPathRooted(root) ? root : Path.Combine(_env.ContentRootPath, root);

            var orgDir = Path.Combine(absRoot, organizationId.ToString("N", CultureInfo.InvariantCulture));
            var userDir = Path.Combine(orgDir, employeeId.ToString("N", CultureInfo.InvariantCulture));
            Directory.CreateDirectory(userDir);

            var fileName = $"{capturedAt:yyyyMMdd_HHmmssfff}_{Guid.NewGuid():N}.jpg";
            var absPath = Path.Combine(userDir, fileName);
            await File.WriteAllBytesAsync(absPath, bytes, ct);

            return Path.GetRelativePath(_env.ContentRootPath, absPath).Replace('\\', '/');
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to save screenshot payload");
            return null;
        }
    }

    private static string StripDataUriPrefix(string value)
    {
        var commaIndex = value.IndexOf(',');
        if (value.StartsWith("data:", StringComparison.OrdinalIgnoreCase) && commaIndex > 0)
            return value[(commaIndex + 1)..];

        return value;
    }
}
