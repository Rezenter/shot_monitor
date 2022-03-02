#=
monitor:
- Julia version: 
- Author: Lasgr
- Date: 2022-03-01
=#

using LoggingExtras, Dates
using Sockets
using FileWatching

const date_format = "HH:MM:SS"
ENV["JULIA_DEBUG"] = "all";

timestamp_logger(logger) = TransformerLogger(logger) do log
  merge(log, (; message = "$(Dates.format(now(), date_format)) $(log.message)"))
end

ConsoleLogger(stdout, Logging.Debug) |> timestamp_logger |> global_logger

@debug "Debug is enabled!";

if Threads.nthreads() == 1
    @warn "Julia is running on a single thread!";
end
const path = "V:\\SHOTN.txt";
const timeout = 1; # second

function send_shotn()
     soc=UDPSocket();
     send(soc, ip"192.168.10.255", 8888, b"00");
     sleep(timeout);
end

function watch()
    #path::String = "\\\\192.168.101.24\\SHOTN.txt";
    test::FileWatching.FileEvent = watch_file(path::String, timeout);
    if test.changed
       @info "\n-----------\nShotn changed!\n--------------\n";
       open(path::String, "r") do file
             str = readline(file);
             @debug str
       end
       #check sht^ if exists => new shot. else:sht ready
       send_shotn();
       return nothing;
    elseif !test.timedout
       @error "WTF?"
    end
    return nothing;
end

@info "serving...";
while true
    watch();
end