using SurveilWin.Api.Data.Entities;
using SurveilWin.Api.DTOs.Auth;

namespace SurveilWin.Api.Services;

public interface IAuthService
{
    Task<AuthResponse?> LoginAsync(string email, string password);
    Task<AuthResponse?> RefreshTokenAsync(string refreshToken);
    Task<AuthResponse> IssueAuthResponseAsync(User user, bool updateLastLogin = false);
    string GenerateJwtToken(User user);
    string GenerateRefreshToken();
    string HashPassword(string password);
    bool VerifyPassword(string password, string hash);
}
