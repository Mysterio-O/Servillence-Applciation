using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SurveilWin.Api.Data;
using SurveilWin.Api.Data.Entities;
using SurveilWin.Api.DTOs.Auth;
using SurveilWin.Api.Services;

namespace SurveilWin.Api.Controllers;

[ApiController]
[Route("api/setup")]
public class SetupController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IAuthService _auth;

    public SetupController(AppDbContext db, IAuthService auth)
    {
        _db = db;
        _auth = auth;
    }

    [HttpGet("status")]
    public async Task<IActionResult> Status()
    {
        var hasUsers = await _db.Users.AnyAsync();
        return Ok(new { requiresBootstrap = !hasUsers });
    }

    [HttpPost("bootstrap")]
    public async Task<ActionResult<AuthResponse>> Bootstrap([FromBody] BootstrapSetupRequest req)
    {
        if (await _db.Users.AnyAsync())
            return Conflict(new { message = "Bootstrap is already completed." });

        if (string.IsNullOrWhiteSpace(req.OrganizationName) ||
            string.IsNullOrWhiteSpace(req.FirstName) ||
            string.IsNullOrWhiteSpace(req.LastName) ||
            string.IsNullOrWhiteSpace(req.Email) ||
            string.IsNullOrWhiteSpace(req.Password))
        {
            return BadRequest(new { message = "All fields are required." });
        }

        if (!IsValidPassword(req.Password))
            return BadRequest(new { message = "Password must be at least 8 characters with uppercase, lowercase, digit, and special character" });

        var now = DateTime.UtcNow;
        var org = new Organization
        {
            Id = Guid.NewGuid(),
            Name = req.OrganizationName.Trim(),
            Slug = BuildSlug(req.OrganizationName),
            Plan = "free",
            IsActive = true,
            CreatedAt = now,
            UpdatedAt = now
        };

        var user = new User
        {
            Id = Guid.NewGuid(),
            OrganizationId = org.Id,
            Organization = org,
            Email = req.Email.Trim().ToLowerInvariant(),
            PasswordHash = _auth.HashPassword(req.Password),
            FirstName = req.FirstName.Trim(),
            LastName = req.LastName.Trim(),
            Role = UserRole.SuperAdmin,
            IsActive = true,
            CreatedAt = now,
            UpdatedAt = now
        };

        var policy = new OrgPolicy
        {
            OrganizationId = org.Id,
            CaptureFps = 1.0m,
            EnableOcr = true,
            EnableScreenshots = false,
            ScreenshotIntervalMinutes = 5,
            ScreenshotRetentionDays = 7,
            SummaryRetentionDays = 90,
            AllowedApps = System.Text.Json.JsonSerializer.SerializeToDocument(Array.Empty<string>()),
            DeniedApps = System.Text.Json.JsonSerializer.SerializeToDocument(Array.Empty<string>()),
            ExpectedShiftHours = 8.0m,
            AutoCloseShiftAfterHours = 12,
            EnableAiSummaries = true,
            AiProvider = "ollama",
            UpdatedAt = now
        };

        _db.Organizations.Add(org);
        _db.OrgPolicies.Add(policy);
        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        var response = await _auth.IssueAuthResponseAsync(user, updateLastLogin: true);
        return Ok(response);
    }

    private static bool IsValidPassword(string pw) =>
        pw.Length >= 8 &&
        pw.Any(char.IsUpper) &&
        pw.Any(char.IsLower) &&
        pw.Any(char.IsDigit) &&
        pw.Any(c => !char.IsLetterOrDigit(c));

    private static string BuildSlug(string value)
    {
        var slug = new string(value.Trim().ToLowerInvariant()
            .Select(c => char.IsLetterOrDigit(c) ? c : '-')
            .ToArray());

        while (slug.Contains("--", StringComparison.Ordinal))
            slug = slug.Replace("--", "-", StringComparison.Ordinal);

        return slug.Trim('-');
    }
}

public class BootstrapSetupRequest
{
    public string OrganizationName { get; set; } = "";
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
}
