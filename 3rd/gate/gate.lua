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
    while true do
		--http://doc.redisfans.com/topic/protocol.html
		local argc = nil
		local argv = {}
		local argvlen = nil
        local _argc = socket:receive("*l")
        if not _argc then
			print("close")
            break
        end
		_argc = _argc .. "\r\n"
		argc = tonumber(string.match(_argc,"^%*(%d+)\r\n"))	
		print("argc="..argc)
		
		for i=1,argc do
        	local _argvlen = socket:receive("*l")
        	if not _argvlen then
				print("close")
            	break
			end
			_argvlen = _argvlen .. "\r\n"
			argvlen = tonumber(string.match(_argvlen,"^%$(%d+)\r\n"))		
			print("argvlen="..argvlen)
			local _argv = socket:receive(argvlen+2)	
			_argv = string.match(_argv,"(.*)\r\n")
			print("argv=".._argv)
			argv[#argv+1] = _argv
        end
		process_command(connid,socket,argc,argv)
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

