local modulo = {}

pinPIR = 6
segAct = 10

function modulo.enviar()
    print("ACTUALIZACION PRESENCIA")
    if gpio.read(pinPIR)==1 then
        app.publicar(config.TOPICO.."/Presencia-"..config.ID, "Activo", 0, 0)
    else
        tmr.alarm(6,segAct*1000,tmr.ALARM_SINGLE,function()
            app.publicar(config.TOPICO.."/Presencia-"..config.ID, "Inactivo", 0, 0)
        end)
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
    gpio.mode(pinPIR,gpio.INPUT)
    gpio.trig(pinPIR,"both", function() 
        evento.enviar()
    end)
end

return modulo
