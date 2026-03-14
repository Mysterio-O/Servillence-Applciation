namespace SurveilWin.Api.BackgroundJobs;

internal static class BackgroundJobRunner
{
    public static async Task RunPeriodicAsync(
        TimeSpan interval,
        Func<CancellationToken, Task> execute,
        ILogger logger,
        string jobName,
        CancellationToken ct,
        bool runImmediately = true)
    {
        if (interval <= TimeSpan.Zero)
            throw new ArgumentOutOfRangeException(nameof(interval), "Interval must be greater than zero.");

        if (!runImmediately)
            await Task.Delay(interval, ct);

        while (!ct.IsCancellationRequested)
        {
            try
            {
                await execute(ct);
            }
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "{JobName} failed", jobName);
            }

            await Task.Delay(interval, ct);
        }
    }
}
