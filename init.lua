-- file : init.lua
print("Iniciando...")
if pcall(function()
        config = require("config")
    end) then
    print("Iniciando Servicios...")
    evento = require("evento")
    config = require("config")  
    red = require("red")
    app = require("app")
    red.iniciar()
else
    print("Ingresando Modo Configuracion...")
    ini = require("ini")
    ini.iniciar()
end
