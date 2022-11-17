const log_filename = "install_{{ date }}.log"  # log filename - date will put in there
const log_dir = ".spmimagetycoon/install/"  # will be in home directory


"""
    get_log_filename()::String

Returns the log filename.
"""
function get_log_filename()::String
    if !isdir(joinpath(homedir(), log_dir))
        mkpath(joinpath(homedir(), log_dir))
    end
    p = joinpath(homedir(), log_dir, log_filename)
    p = replace(p, "{{ date }}" => Dates.format(Dates.now(), "yyyy-mm-dd_HHMMSS"))
    return p
end
