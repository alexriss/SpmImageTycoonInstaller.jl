"""
    setup_progress_bar()::Tuple{ProgressBar,ProgressJob}

Sets up the progress bar.
"""
function setup_progress_bar()::Tuple{ProgressBar,ProgressJob}
    pbar = ProgressBar(;columns=:minimal, width=66)
    job = addjob!(pbar; description="Working...", N=10)

    return pbar, job
end
