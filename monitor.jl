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
const shotn_path = "V:\\SHOTN.txt";
const sht_path = "V:\\";
const timeout = 1; # second

function send_shotn(shotn::Int64)
     soc=UDPSocket();
     to_bytes(x) = reinterpret(UInt8, [x]);
     msg = to_bytes(shotn);
     @debug(msg)
     send(soc, ip"192.168.10.255", 8888, msg);
     send(soc, ip"192.168.10.255", 8888, b"00");
     sleep(timeout);
     return nothing;
end

function watch_shotn()
    #path::String = "\\\\192.168.101.24\\SHOTN.txt";
    shotn_file_event::FileWatching.FileEvent = watch_file(shotn_path::String, timeout::Int64);
    if shotn_file_event.changed
       open(shotn_path::String, "r") do file
            shotn::Int64 = parse(Int64, readline(file));
            sleep(0.1);
            if isfile(string(sht_path::String, "sht", shotn::Int64, ".SHT"))
                @info "ARM";
                #send_shotn(shotn::Int64);
            else
                @debug "SHT is ready";
            end
       end
       return nothing;
    elseif !shotn_file_event.timedout
       @error "WTF?"
    end
    return nothing;
end

function test()
    tmp::Int64 = 95655;
    send_shotn(tmp);
end

@info "serving...";
test();

while true
    watch_shotn();
end