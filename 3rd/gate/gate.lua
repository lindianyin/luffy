#!/usr/bin/lua

socket = require('socket')
copas = require('copas')
zklua = require("zklua")

server = socket.bind('*',7788)
print(server:getsockname())

function handler(socket)
    local socket = copas.wrap(socket)
	print("connect")
	local i = 0
    while true do
        local data = socket:receive("*l")
        if not data then
			print("close")
            break
        end
		i = i + 1
        socket:send(i .. data .. '\r\n')
		print(data)
    end
end

copas.addserver(server, handler)

copas.addthread(function()
   --print("This will print immediately, upon adding the thread. So before the loop starts")
   while true do
      copas.sleep(1) -- 1 second interval
      --print("Hello there!")
   end
end)



function zklua_my_global_watcher(zh, type, state, path, watcherctx)
    if type == zklua.ZOO_SESSION_EVENT then
        if state == zklua.ZOO_CONNECTED_STATE then
            print("Connected to zookeeper service successfully!\n");
         elseif (state == ZOO_EXPIRED_SESSION_STATE) then
            print("Zookeeper session expired!\n");
        end
    end
end

function zklua_my_local_watcher(zh, type, state, path, watcherctx)
    --print("zklua_my_local_watcher(".."type: "..type..", state: "..state..", path: "..path..")")
    --print("zklua_my_local_watcher(".."watcherctx: "..watcherctx..")")
    --ret = zklua.awget_children(zh, "/zklua", zklua_my_local_watcher,"zklua_my_local_watcher", zklua_my_stat_completion, "zklua aexists.")
    --print("zklua.aexists ret: "..ret)
end

function zklua_my_stat_completion(rc, stat, data)
    print("zklua_my_stat_completion:\n")
    print("rc: "..rc.."\tdata: "..data)
    for k,v in pairs(stat) do print(k,v) end
end
function strings_completion(rc, strings, data)
    print("zklua_my_stat_completion:\n")

end


zklua.set_log_stream("zklua.log")

zh = zklua.init("127.0.0.1:2181", zklua_my_global_watcher, 10000)

ret = zklua.awget_children(zh, "/zklua", zklua_my_local_watcher,"zklua_my_local_watcher", zklua_my_stat_completion, "zklua aexists.")
print("zklua.aexists ret: "..ret)

print("hit any key to continue...")

ret,acl,stat = zklua.get_acl(zh,"/zklua")
print("zklua.get_acl ret: "..ret)

ret = zklua.create(zh, "/zklua/gate", "gatevalue", acl, zklua.ZOO_EPHEMERAL)
print("zklua.create ret:"..ret)



copas.loop()

