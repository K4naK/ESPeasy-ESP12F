-- file: setup.lua
local modulo = {}

modulo.conectado = false

local function esperarIP()  
  if wifi.sta.getip()== nil then
    print("Esperando IP...")
  else
    tmr.stop(1)
    tmr.stop(2)
    tmr.stop(3)
    print("\n====================================")
    print("ID :"..config.ID)
    print("MAC: " .. wifi.ap.getmac())
    print("IP :"..wifi.sta.getip())
    print("====================================")
    modulo.conectado = true
    app.iniciar()
  end
end

local function iniciarWifi()
    if config.IP ~= "" then
        wifi.sta.setip({
          ip = config.IP,
          netmask = config.NM,
          gateway = config.GW
        })
    end
    wifi.sta.connect()
    local ssid, pwd = wifi.sta.getconfig()
    print("Conectando con Red " ..config.SSID.. ". Clave: "..config.PWD)
    tmr.alarm(1, 1*1000, 1, esperarIP)
    tmr.alarm(2, 295*1000, 1, function() file.remove("config.lua") end)
    tmr.alarm(3, 300*1000, 1, function() node.restore() node.restart() end)
end

function modulo.iniciar()  
  print("Configurando Wifi ...")
  wifi.setmode(wifi.STATION);
  iniciarWifi()
end

return modulo
