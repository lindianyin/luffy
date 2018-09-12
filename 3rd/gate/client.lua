#!/usr/bin/lua

socket = require('socket')
copas = require('copas')

local skt = copas.wrap(socket.tcp())
skt:settimeout(0)
copas.addthread(function()
	local ok, err = skt:connect("0.0.0.0", 7788)
	print(ok,err)
	while true do
		skt:send("*2\r\n$5\r\nhello\r\n$7\r\nwelcome\r\n")
		copas.sleep(5)
		break
		--local recv = skt:receive("*l")
		--print("recv="..recv)
	end
end)


copas.loop()

