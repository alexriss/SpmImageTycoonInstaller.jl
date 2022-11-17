const log_filename1 = "install_{{ date }}.log"  # log filename - date will put in there (stdout)
const log_filename2 = "install_{{ date }}_.log"  # log filename - date will put in there (stderr)
const log_dir = ".spmimagetycoon/install/"  # will be in home directory


"""
    get_log_filenames()::Tuple{String,String}

Returns the log filename.
"""
function get_log_filenames()::Tuple{String,String}
    if !isdir(joinpath(homedir(), log_dir))
        mkpath(joinpath(homedir(), log_dir))
    end
    p1 = joinpath(homedir(), log_dir, log_filename1)
    p1 = replace(p1, "{{ date }}" => Dates.format(Dates.now(), "yyyy-mm-dd_HHMMSS"))
    p2 = joinpath(homedir(), log_dir, log_filename2)
    p2 = replace(p2, "{{ date }}" => Dates.format(Dates.now(), "yyyy-mm-dd_HHMMSS"))
    return p1, p2
end
