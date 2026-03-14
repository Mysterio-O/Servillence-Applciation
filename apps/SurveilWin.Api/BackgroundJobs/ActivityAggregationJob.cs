using Microsoft.EntityFrameworkCore;
using SurveilWin.Api.Data;
using SurveilWin.Api.Data.Entities;
using SurveilWin.Api.Services;

namespace SurveilWin.Api.BackgroundJobs;

public class ActivityAggregationJob : BackgroundService
{
    private readonly IServiceProvider _services;
    private readonly ILogger<ActivityAggregationJob> _logger;

    public ActivityAggregationJob(IServiceProvider services, ILogger<ActivityAggregationJob> logger)
    {
        _services = services;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        await BackgroundJobRunner.RunPeriodicAsync(
            TimeSpan.FromMinutes(5),
            RunOnceAsync,
            _logger,
            nameof(ActivityAggregationJob),
            ct,
            runImmediately: false);
    }

    private async Task RunOnceAsync(CancellationToken ct)
    {
        using var scope = _services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var aggregator = scope.ServiceProvider.GetRequiredService<ActivityAggregatorService>();

        var activeShifts = await db.Shifts
            .Where(s => s.Status == ShiftStatus.Active)
            .Select(s => s.Id)
            .ToListAsync(ct);

        foreach (var shiftId in activeShifts)
            await aggregator.AggregateFramesForShiftAsync(shiftId, ct);

        _logger.LogInformation("Activity aggregation completed for {Count} active shifts", activeShifts.Count);
    }
}
