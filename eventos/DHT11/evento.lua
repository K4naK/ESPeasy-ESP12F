local modulo = {}
pinDHT = 6
segAct = 600

function modulo.enviar()
    print("ACTUALIZACION AMBIENTE")
    status, temp, humi = dht.read(pinDHT)
    if status == dht.OK then
        app.publicar(config.TOPICO.."/Temperatura-"..config.ID, tostring(temp), 0, 0)
        app.publicar(config.TOPICO.."/Humedad-"..config.ID, tostring(humi), 0, 0)
    end
end

function modulo.mensaje(topico, dato)
    print(topico..":"..dato)
end

function modulo.subscribir()
    --app.subscribir(topico, qos)
end

function modulo.iniciar()
    evento.subscribir()
    tmr.alarm(4, segAct*1000, 1, evento.enviar)
end

return modulo
