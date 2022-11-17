const log_filename1 = "install_{{ date }}.log"  # log filename - date will put in there (stdout)
const log_filename2 = "install_{{ date }}_.log"  # log filename - date will put in there (stderr)
const log_dir = ".spmimagetycoon/install/logs/"  # will be in home directory

const info_dir = ".spmimagetycoon/install/"  # will be in home directory
const info_filename = "install_{{ date }}.toml"  # log filename - date will put in there (stdout)


"""
    get_log_filenames()::Tuple{String,String}

Returns the log filenames.
"""
function get_log_filenames()::Tuple{String,String}
    if !isdir(joinpath(homedir(), log_dir))
        mkpath(joinpath(homedir(), log_dir))
    end
    d = Dates.format(DATE_install, "yyyy-mm-dd_HHMMSS")
    p1 = joinpath(homedir(), log_dir, log_filename1)
    p1 = replace(p1, "{{ date }}" => d)
    p2 = joinpath(homedir(), log_dir, log_filename2)
    p2 = replace(p2, "{{ date }}" => d)
    return p1, p2
end


"""
    get_info_filename()::String

Returns the install log filename.
"""
function get_info_filename()::String
    if !isdir(joinpath(homedir(), info_dir))
        mkpath(joinpath(homedir(), info_dir))
    end
    d = Dates.format(DATE_install, "yyyy-mm-dd_HHMMSS")
    p = joinpath(homedir(), info_dir, info_filename)
    p = replace(p, "{{ date }}" => d)
    return p
end


"""
    save_info_log(data::Dict{Any,Any})::Nothing

Saves the install info log.
"""
function save_info_log(data::Dict{String,Any})::Nothing
    open(get_info_filename(), "w") do io
        TOML.print(io, data)
    end
    return nothing
end