local modulo = {}

topicoActualizar = "Dispositivos/Actualizar"
topicoEstado = config.TOPICO.."/Estado/"..config.ID

m = mqtt.Client(config.ID, 120, config.USUARIO,config.CLAVE)
m:lwt(topicoEstado, "0", 0, 0)
m:on("offline", function(client)
    print("REINTENTANDO CONEXION")
    tmr.alarm(6, 10000, tmr.ALARM_AUTO, function()
        app.iniciar()
    end)
end)
m:on("message", function(conn, topico, dato)
    print("MENSAJE RECIBIDO: "..topico..":"..dato)
    if dato ~= nil then
        if tostring(dato)=="1" and topico == topicoActualizar  then
            app.publicar(topicoEstado,"1",0,0)
            evento.enviar()
        else
            evento.mensaje(topico, dato)
        end
    end
end)

function modulo.publicar(topico, msj, qos, retenido)
    print("PUBLICANDO: "..topico..":"..msj)
    m:publish(topico, msj, qos, retenido, function()
        print("..OK")
    end)
end

function modulo.subscribir(topic, qos)  
    m:subscribe(topic,qos,function()
        print("SUBSCRIPCION EXITOSA: "..topic)
    end)
end

local function MQTT()
    m:connect(config.HOST, config.PUERTO, 0, function(client)
        tmr.stop(5)
        tmr.stop(6)
        print("CONEXION EXITOSA")
        app.subscribir(topicoActualizar, 0)
        app.publicar(topicoEstado,"1",0,0)
        evento.iniciar()
        evento.enviar()
    end)
end

function modulo.iniciar()
    print("CONECTANDO BROKER")
    MQTT()
    tmr.alarm(5, 15000, 1, function()
        print("CONECTANDO BROKER")
        MQTT()
    end)
end

return modulo
