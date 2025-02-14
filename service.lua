local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-- foxzin = {}
-- Tunnel.bindInterface("havan_craft_v2",foxzin)
vRPclient = Tunnel.getInterface("vRP")
CURRENT_TYPE = nil
-- service.lua




RegisterNetEvent('farm:hasPermission')
AddEventHandler('farm:hasPermission', function(perm)
    
    local source = source 
    local user_id = vRP.getUserId(source)

    if vRP.hasPermission(user_id,perm) then
        TriggerClientEvent("farm:autorized",source)
    else
        TriggerClientEvent("farm:notAutorized",source)
    end
    

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


-- RegisterServerEvent('farm:giveItem')
-- AddEventHandler('farm:giveItem', function(itensFarm)
--     local source = source
--     local user_id = vRP.getUserId(source)

--     if not user_id then
--         print("Erro: Usuário não encontrado!")
--         return
--     end

    
--     for _, item in ipairs(itensFarm) do
--         local amount = math.random(item.minAmount, item.maxAmount)
--         vRP.giveInventoryItem(user_id, item.item, amount,true)
--         -- print("Entregue", amount, item.item, "para jogador", user_id)
--         -- TriggerClientEvent("Notify", source, "sucesso", "Você coletou " .. amount .. "x " .. item.item .. "!")


--     end

--     TriggerClientEvent("farm:success",source)

   

-- end)


RegisterServerEvent('farm:giveItem')
AddEventHandler('farm:giveItem', function(itensFarm)
    local source = source
    local user_id = vRP.getUserId(source)
    local is_bag_full = false

    if not user_id then
        return
    end

    -- Obtém os pesos do inventário e garante que são números válidos
    local currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
    local maxWeight = tonumber(vRP.getInventoryMaxWeight(user_id)) or 0

    -- Se qualquer valor for inválido, cancela a coleta
    if not currentWeight or not maxWeight then
        -- print("❌ Erro ao obter pesos para usuário:", user_id, "Pesos retornados:", currentWeight, "/", maxWeight)
        TriggerClientEvent("Notify", source, "negado", "Erro ao verificar o espaço da mochila.")
        return
    end

    -- print("🎒 Peso atual:", currentWeight, "/", maxWeight)

    -- Verifica se a mochila está cheia antes de coletar
    local coletouAlgo = false
    for _, item in ipairs(itensFarm) do
        local amount = math.random(item.minAmount, item.maxAmount)
        local itemWeight = vRP.getItemWeight(item.item) or 0

        -- Verifica se há espaço suficiente para adicionar os itens
        if currentWeight + (itemWeight * amount) <= maxWeight then
            vRP.giveInventoryItem(user_id, item.item, amount, true)
            -- print("✅ Entregue", amount, item.item, "para jogador", user_id)
            coletouAlgo = true

            -- Atualiza o peso do inventário após adicionar o item
            currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
           
        end
    end


    -- Enviar notificação de sucesso apenas se algum item foi coletado
    if coletouAlgo then
        TriggerClientEvent("farm:success", source)
    else
        TriggerClientEvent("farm:bagfull", source)
    end
end)





