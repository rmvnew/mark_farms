local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-- foxzin = {}
-- Tunnel.bindInterface("havan_craft_v2",foxzin)
vRPclient = Tunnel.getInterface("vRP")
CURRENT_TYPE = nil
-- service.lua
print("Config carregado no server:", Config and "OK" or "NÃO CARREGADO")


-- Função dummy para checar permissão
function hasPermission(source, permission)
    -- Substitua por sua lógica real (ex.: utilizando exports ou funções do framework)
    return true
end

RegisterNetEvent('farm:start')
AddEventHandler('farm:start', function(routeName)
    local _source = source
    print("Evento farm:start recebido do player: " .. _source .. " para a rota: " .. routeName)
    local Config = require("config_default").Config

    local permitido = false
    -- Percorre as facções definidas para ver se o jogador tem a permissão
    for _, data in pairs(Config.farm.orgType) do
        for _, org in ipairs(data.orgs) do
            if hasPermission(_source, org.permission) then
                permitido = true
                break
            end
        end
        if permitido then break end
    end

    if not permitido then
        TriggerClientEvent('chat:addMessage', _source, { args = { '^1Farm', 'Você não possui permissão para iniciar essa rota.' } })
        print("Permissão negada para o player: " .. _source)
        return
    end

    print("Permissão concedida para o player: " .. _source)
    TriggerClientEvent('farm:startAllowed', _source, routeName)
end)

RegisterNetEvent('farm:complete')
AddEventHandler('farm:complete', function(routeName)
    local _source = source
    print("Player " .. _source .. " completou a rota " .. routeName)
    TriggerClientEvent('chat:addMessage', _source, { args = { '^2Farm', 'Rota completada com sucesso! Itens entregues.' } })
end)

RegisterNetEvent('farm:cancel')
AddEventHandler('farm:cancel', function(routeName)
    local _source = source
    print("Player " .. _source .. " cancelou a rota " .. routeName)
    TriggerClientEvent('chat:addMessage', _source, { args = { '^1Farm', 'Rota cancelada.' } })
end)


RegisterServerEvent('farm:giveItem')
AddEventHandler('farm:giveItem', function(itensFarm)
    local source = source
    local user_id = vRP.getUserId(source)

    if not user_id then
        print("Erro: Usuário não encontrado!")
        return
    end

    for _, item in ipairs(itensFarm) do
        local amount = math.random(item.minAmount, item.maxAmount)
        vRP.giveInventoryItem(user_id, item.item, amount,true)
        -- print("Entregue", amount, item.item, "para jogador", user_id)
        -- TriggerClientEvent("Notify", source, "sucesso", "Você coletou " .. amount .. "x " .. item.item .. "!")


    end
end)
