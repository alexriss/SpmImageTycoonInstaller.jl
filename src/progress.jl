"""
    setup_progress_bar()::Tuple{ProgressBar,ProgressJob}

Sets up the progress bar.
"""
function setup_progress_bar()::Tuple{ProgressBar,ProgressJob}
    pbar = ProgressBar(;columns=:minimal, width=66)
    job = addjob!(pbar; description="Working...", N=10)

    return pbar, job
end


"""
    update_progress(compile_task::Task, out_stream1::IOStream, out_stream2::IOStream, out_filename1::String, out_filename2::String, out_stdout::Any)::Nothing

Analyzes the redirected STDOUT and updates the progress bar accordingly.
"""
function update_progress(compile_task::Task, out_stream1::IOStream, out_stream2::IOStream, out_filename1::String, out_filename2::String, out_stdout::Any)::Nothing
    # pbar, job = setup_progress_bar()
    date_last = Dates.now()
    
    step_number = 0
    while(!istaskdone(compile_task))
        flush(out_stream1)
        flush(out_stream2)
        out_str = read(out_filename1, String) * read(out_filename2, String)

        if step_number >= 2
            if (Dates.now() - date_last) / Millisecond(1000) > 30
                print(out_stdout, ".")
                date_last = Dates.now()
            end
        end
        if (contains(out_str, "compiling base system image")) && step_number < 4
            print(out_stdout, @italic "\nCompiling.")
            date_last = Dates.now()
            step_number = 4
        elseif (contains(out_str, "bundled artifacts")) && step_number < 3
            print(out_stdout, @italic "\nBundling.")
            date_last = Dates.now()
            step_number = 3
        elseif contains(out_str, "Activating new project") && step_number < 2
            print(out_stdout, @italic "\nGetting package.")
            date_last = Dates.now()
            step_number = 2
        elseif step_number < 1
            print(out_stdout, @italic "Setting up.")
            date_last = Dates.now()
            step_number = 1
        end

        # with(pbar) do
        #     redirect_stdio(stdout=out_stdout) do
        #         update!(job)
        #         render(pbar)
        #     end
        # end
        sleep(1)
    end

    return nothing
end


"""for testing, to remove"""
function testr()
    stdout_ = stdout
    #pbar, job = setup_progress_bar()
    render(pbar)
    redirect_stdio(stdout=devnull) do
        println("test1")
        println("test2")
        for i in 1:10
            with(pbar) do
                redirect_stdio(stdout=stdout_) do
                    update!(job)
                    render(pbar)
                end
            end
            sleep(1)
        end
    end
end