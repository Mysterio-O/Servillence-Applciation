using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SurveilWin.Api.Data;
using SurveilWin.Api.Data.Entities;
using SurveilWin.Api.DTOs.Auth;

namespace SurveilWin.Api.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly IConfiguration _config;

    public AuthService(AppDbContext db, IConfiguration config)
    {
        _db = db;
        _config = config;
    }

    public async Task<AuthResponse?> LoginAsync(string email, string password)
    {
        var user = await _db.Users
            .Include(u => u.Organization)
            .FirstOrDefaultAsync(u => u.Email == email.ToLower() && u.IsActive);

        if (user == null || !VerifyPassword(password, user.PasswordHash))
            return null;

        return await IssueAuthResponseAsync(user, updateLastLogin: true);
    }

    public async Task<AuthResponse?> RefreshTokenAsync(string refreshToken)
    {
        if (string.IsNullOrEmpty(refreshToken)) return null;

        var now = DateTime.UtcNow;
        var hash = HashRefreshToken(refreshToken);

        var user = await _db.Users
            .Include(u => u.Organization)
            .FirstOrDefaultAsync(u =>
                u.IsActive &&
                u.RefreshTokenHash == hash &&
                u.RefreshTokenExpiresAt != null &&
                u.RefreshTokenExpiresAt > now);

        if (user == null) return null;

        return await IssueAuthResponseAsync(user);
    }

    public async Task<AuthResponse> IssueAuthResponseAsync(User user, bool updateLastLogin = false)
    {
        var now = DateTime.UtcNow;
        var refreshToken = GenerateRefreshToken();
        var refreshTokenDays = int.Parse(_config["Jwt:RefreshTokenDays"] ?? "30");

        if (updateLastLogin)
            user.LastLoginAt = now;

        user.RefreshTokenHash = HashRefreshToken(refreshToken);
        user.RefreshTokenIssuedAt = now;
        user.RefreshTokenExpiresAt = now.AddDays(refreshTokenDays);
        user.UpdatedAt = now;

        await _db.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = GenerateJwtToken(user),
            RefreshToken = refreshToken,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                Role = user.Role.ToString(),
                OrganizationId = user.OrganizationId,
                OrgName = user.Organization?.Name
            }
        };
    }

    public string GenerateJwtToken(User user)
    {
        var secret = _config["Jwt:Secret"] ?? throw new InvalidOperationException("JWT secret not configured");
        var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
            new Claim("org_id", user.OrganizationId.ToString()),
            new Claim("full_name", user.FullName)
        };

        var expiry = int.Parse(_config["Jwt:ExpiryMinutes"] ?? "60");
        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiry),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public string GenerateRefreshToken()
    {
        var bytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes);
    }

    private static string HashRefreshToken(string refreshToken)
    {
        var bytes = Encoding.UTF8.GetBytes(refreshToken);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash);
    }

    public string HashPassword(string password) => BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
    public bool VerifyPassword(string password, string hash) => BCrypt.Net.BCrypt.Verify(password, hash);
}
