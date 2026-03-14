using SurveilWin.Api.Services.AI;

namespace SurveilWin.Api.BackgroundJobs;

public class DailySummaryBatchJob : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<DailySummaryBatchJob> _logger;

    public DailySummaryBatchJob(IServiceScopeFactory scopeFactory, ILogger<DailySummaryBatchJob> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var now = DateTime.UtcNow;
            // Run at 00:30 UTC each night
            var nextRun = DateTime.UtcNow.Date.AddDays(1).AddMinutes(30);
            var delay = nextRun - now;
            if (delay < TimeSpan.Zero) delay = TimeSpan.FromMinutes(30);

            try { await Task.Delay(delay, stoppingToken); }
            catch (OperationCanceledException) { break; }

            var yesterday = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1));
            _logger.LogInformation("Running daily summary batch for {Date}", yesterday);
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var generator = scope.ServiceProvider.GetRequiredService<DailySummaryGenerator>();
                await generator.GenerateForDateAsync(yesterday, stoppingToken);
            }
            catch (Exception ex) { _logger.LogError(ex, "DailySummaryBatchJob failed for {Date}", yesterday); }
        }
    }
}
