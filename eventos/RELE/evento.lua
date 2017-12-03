local modulo = {}

rele = {}
rele.pin = 5
rele.switch = 6
rele.topico = config.TOPICO.."/Rele-"..config.ID

gpio.mode(rele.switch,gpio.INPUT,gpio.PULLUP)
gpio.mode(rele.pin, gpio.OUTPUT)
gpio.trig(rele.switch,"both",function() cambiar(rele.pin) end)

function cambiar(pin)
    gpio.write(pin,switch(gpio.read(pin)))
    evento.enviar()
end

function switch(x)
    if x == 1 then
        return 0
    else
        return 1
    end
end

function modulo.enviar()
    print("ACTUALIZACION RELE")
    if red.conectado then 
        app.publicar(rele.topico, tostring(gpio.read(rele.pin)), 0, 0)
    end
end

function modulo.mensaje(topico, dato)
    if dato == "1" or dato == "0" then
        gpio.write(rele.pin, dato)
    end
end

function modulo.subscribir()
    app.subscribir(rele.topico, 0)
end

function modulo.iniciar()
    evento.subscribir()
    evento.enviar()
end

return modulo
