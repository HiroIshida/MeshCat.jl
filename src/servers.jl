using Sockets: connect

Base.open(vis::Visualizer, args...; kw...) = open(vis.core, args...; kw...)

function wait_for_server(core::CoreVisualizer, timeout=100)
    interval = 0.25
    socket = nothing
    for i in range(0, timeout, step=interval)
        try
            socket = connect(core.host, core.port)
            sleep(interval)
            break
        catch e
            if e isa Base.IOError
                sleep(interval)
            end
        end
    end
    if socket === nothing
        error("Could not establish a connection to the visualizer.")
    else
        close(socket)
    end
end

function Base.open(core::CoreVisualizer)
    wait_for_server(core)
    open_url(url(core))
end

function open_url(url)
    try
        if Sys.iswindows()
            run(`cmd.exe /C "start $url"`)
        elseif Sys.isapple()
            run(`open $url`)
        elseif Sys.islinux()
            run(`xdg-open $url`)
        end
    catch e
        println("Could not open browser automatically: $e")
        println("Please open the following URL in your browser:")
        println(url)
    end
end
