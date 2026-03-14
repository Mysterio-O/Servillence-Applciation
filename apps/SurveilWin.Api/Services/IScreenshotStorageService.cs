namespace SurveilWin.Api.Services;

public interface IScreenshotStorageService
{
    Task<string?> SaveBase64ScreenshotAsync(string? base64, Guid organizationId, Guid employeeId, DateTime capturedAt, CancellationToken ct = default);
}
