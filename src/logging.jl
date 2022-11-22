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
    get_last_info_filenames(n::Int=1)::Vector{String}

Get last n install-info files. If n is 0, then all install-info files are returned.
"""
function get_last_info_filenames(n::Int=1; fullpath::Bool=true)::Vector{String}
    d = joinpath(homedir(), info_dir)
    isdir(d) || return []

    info_filename_start = info_filename[begin:findfirst("{", info_filename)[1]-1]
    info_filename_end = info_filename[findlast("}", info_filename)[1]+1:end]

    files = readdir(d, sort=true, join=fullpath)
    filter!(files) do f
        endswith(f, info_filename_end) && startswith(basename(f), info_filename_start)
    end

    n > 0 && length(files) >= n && return files[end-n+1:end]
    return files
end


"""
    get_last_install_dir()::Union{Nothing,String}

Returns last installation dir.
"""
function get_last_install_dir()::Union{Nothing,String}
    files = get_last_info_filenames(1)
    data = Dict()
    if length(files) > 0
        try
            data = TOML.parsefile(files[end])
        finally
            haskey(data, "target") &&  return data["target"]
        end
    end
    return nothing
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