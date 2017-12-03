local modulo = {}

_GET = {}
json = ""
srv = nil;
ip, nm, gw, ssid, pwd = ""

function modulo.iniciar()
    node.restore()
	print("CONFIGURACION AP")
	local AP_CFG={}
	AP_CFG.ssid="ESP8266-"..node.chipid()
	AP_CFG.channel = 6
	AP_CFG.hidden = 0
	AP_CFG.max=4
	AP_CFG.save=false
	AP_CFG.beacon=1000
	wifi.ap.config(AP_CFG);
	wifi.setmode(wifi.STATIONAP)
	HTTPServer()
end

function HTTPServer()
	print("CONFIGURACION HTTP SERVER")
	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
		conn:on("receive", function(client,payload)
			conn:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nAccess-Control-Allow-Origin: *\n\n')
            print(payload);
			if targetHTTP(payload) == "redes" then
				wifi.sta.getap(function(t)
					local lista =  {};
                    local network = "";
                    for bssid,v in pairs(t) do
                        local ssid, rssi = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
                        network = "{\"SSID\": \""..bssid.."\",\"RSSI\": \""..rssi.."\"}"
                        table.insert(lista, network);
                    end
					local json = "{\"Redes\":[".. table.concat(lista, ",") .."]}";
					print("SSID REQUEST");
					client:send(json)
					client:close()
					collectgarbage()
					end);
				elseif string.find(targetHTTP(payload),"confInicial") then
                    local cfg =  {};
					local init = 0;
					print("INITIAL REQUEST");
					getVars(payload);
					wifi.sta.config(_GET.ssid,_GET.pass, false)
                    if _GET.ip~="" then
                        cfg.ip = _GET.ip
                        cfg.netmask = _GET.nm
                        cfg.gateway = _GET.gw
                        wifi.sta.setip(cfg)
                    end
					tmr.alarm(1,1000, 1, function() 
                        wifi.sta.connect();
                        print(wifi.sta.getip())
						if init < 10 then
							if wifi.sta.getip()==nil then
                                print("Esperando IP")
								init = init + 1;
							else
                                ssid, pwd = wifi.sta.getconfig()
								ip, nm, gw = wifi.sta.getip()
								client:send("[{\"IP\":\""..ip.."\",\"NM\":\""..nm.."\",\"GW\":\""..gw.."\"}]");
                                print("dhcp ok")
								client:close();
								collectgarbage();
								tmr.stop(1) 
							end
						else
                            print("Tiempo agotado")
    						client:send("[{\"IP\":\"\",\"NM\":\"\",\"GW\":\"\"}]");
    						client:close();
    						collectgarbage();
                            tmr.stop(1) 
						end
					end)
                elseif string.find(targetHTTP(payload),"confServer") then
                    print("SERVER REQUEST");
                    getVars(payload);
                    print(_GET.server);
                    print(_GET.port);
                    print(_GET.user);
                    print(_GET.key);
                    print(string.gsub(_GET.topic,"%%2F","/"));
local conf = [[
-- file : config.lua
local modulo = {}

modulo.HOST = "]].._GET.server..[["  
modulo.PUERTO = ]].._GET.port..[[

modulo.ID = node.chipid()
modulo.USUARIO = "]]..null(_GET.user)..[["
modulo.CLAVE = "]]..null(_GET.key)..[["
modulo.TOPICO = "]]..string.gsub(_GET.topic,"%%2F","/")..[["

modulo.SSID = "]]..ssid..[["
modulo.PWD = "]]..pwd..[["
modulo.IP = "]]..ip..[["
modulo.NM = "]]..nm..[["
modulo.GW = "]]..gw..[["

return modulo
]]
                    file.remove("config.lua")
                    if file.open("config.lua", "w+") then
                      file.write(conf)
                      file.close()
                    end
                    client:send("true")
                    client:close();
                    collectgarbage();
                    tmr.alarm(1, 5000, 1, function() node.restart() end)
				else
					print(payload);
					print("bad");
					client:send("404")
					client:close();
					collectgarbage();
				end
				end)
		end)
end

function targetHTTP(payload)
    local target;
    target = string.sub(payload,string.find(payload,"GET /")+5,string.find(payload,"HTTP/")-2)
    return target;
end

function getVars(request)
    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
    end
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=([^&]+)&*") do
            _GET[k] = v
        end
    end
end

function null(var)
    if var then
        return var
    else
        return ""
    end
end

return modulo
