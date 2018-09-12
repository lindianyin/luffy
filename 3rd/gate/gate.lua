#!/usr/bin/lua

socket = require('socket')
copas = require('copas')
zklua = require("zklua")
uuidx = require("luauuidx")

server = socket.bind('*',7788)
print(server:getsockname())

connections = {}

function process_command(connid,socket,argc,argv) 
	print(connid,socket,argc,argv[1],argv[2])
	if(argc==2 and argv[1] == "exec") then
		local ret =  loadstring(argv[2])()	
		socket:send(":"..ret.."\r\n")
	end	
end


function handler(socket)
    local socket = copas.wrap(socket)
	local connid = uuidx.uuid_generate_time()
	local socketdata = {socket=socket,connecttime=os.time()}
	connections[connid] = socketdata
	print("connection connect connid="..connid)
	local i = 0
	local argc = nil
	local argv = {}
	local argvlen = nil
    while true do
        local data = socket:receive("*l")
        if not data then
			print("close")
            break
        end
		--http://doc.redisfans.com/topic/protocol.html
		data = data .. "\r\n"	
		if(not argc) then 
			argc = tonumber(string.match(data,"^%*(%d+)\r\n"))	
			print("argc="..argc)
		else
			if(not argvlen) then 
				argvlen = tonumber(string.match(data,"^%$(%d+)\r\n"))		
				print("argvlen="..argvlen)
			else
				print("data="..data)
				argv[#argv+1] = string.sub(data,1,-3)
				argvlen = nil
				if(argc == #argv) then
					for k,v in pairs(argv) do 
						print(k,v)
			 		end
					process_command(connid,socket,argc,argv)
					argc = nil
					argv = {}	
					--for _,v in pairs(connections) do 
					--	v.socket:send(connid .. data)
					--end
				end	

			end
		end
    end
	connections[connid] = nil
	local connect_count = 0
	for _,v in pairs(connections) do 
		connect_count = connect_count + 1
	end	
	local online_time = os.time() - socketdata.connecttime
	print("connection close connid= ".. connid .." connect_count="..connect_count .. " online_time="..online_time)
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

