print("Config carregado no client:", Config and "OK" or "NÃO CARREGADO")

local markers = {}
local isNearMarker = false

-- Criar markers para cada organização
Citizen.CreateThread(function()
    while not Config do
        Citizen.Wait(1000) -- Aguarda o carregamento do Config
    end
    
    for farmType, farmData in pairs(Config.farm.orgType) do
        for _, org in ipairs(farmData.orgs) do
            table.insert(markers, {
                name = org.name,
                coords = org.coords,
                permission = org.permission
            })
        end
    end
end)

-- Exibir markers dinamicamente
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        isNearMarker = false
        for _, marker in ipairs(markers) do
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, marker.coords.x, marker.coords.y, marker.coords.z)
            
            if distance < 5.0 then -- Só exibe o marker se estiver a 5 metros
                isNearMarker = true
                DrawMarker(21, marker.coords.x, marker.coords.y, marker.coords.z - 0.4, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 255, 0, 150, false, false, 2, true, nil, nil, false)
                
                if distance < 1.5 then -- Se o jogador estiver próximo, exibe mensagem
                    ShowHelpText("Pressione ~INPUT_CONTEXT~ para iniciar o farm de " .. marker.name)
                    
                    if IsControlJustPressed(0, 38) then -- Tecla "E"
                        SetNuiFocus(true, true)
                        -- SendNUIMessage({ action = "showUI", routes = Config.farm.routes })
                        SendNUIMessage({ action = "showUI", routes = Config.farm.routes,coords = {marker.coords.x, marker.coords.y, marker.coords.z} })
                        -- TriggerEvent('farm:blipClicked', marker.coords.x, marker.coords.y, marker.coords.z)

                    end
                end
            end
        end
        
        if not isNearMarker then
            Citizen.Wait(500) -- Reduz carga do loop se nenhum marker estiver próximo
        end
    end
end)

-- Exibir texto de ajuda na tela
function ShowHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end


-- fecha com ESC
RegisterNUICallback("closeCurrentNUI",function(data,cb)
    SetNuiFocus(false,false)
    SendNUIMessage({action = 'hideUI'})
    if cb then cb('ok') end
end)





RegisterNUICallback('selectRoute', function(data, cb)
    print(json.encode(data)) -- Debug para ver se está recebendo corretamente
    
    local selectedRoute = data.key  -- Nome da rota ("ROTA 7", "ROTA 1" etc.)
    local coords = data.coords  -- Coordenadas do local selecionado
    local foundOrg = nil
    local farmType = nil

    -- 🔍 Buscar a organização com as coordenadas correspondentes
    for farmCategory, data in pairs(Config.farm.orgType) do
        for _, org in ipairs(data.orgs) do
            if org.coords.x == coords[1] and org.coords.y == coords[2] and org.coords.z == coords[3] then
                foundOrg = org
                farmType = data  -- Pega os itens de farm associados
                break
            end
        end
        if foundOrg then break end
    end

    if foundOrg then
        print("Organização encontrada:", foundOrg.name)
        print("Permissão necessária:", foundOrg.permission)
        print("Itens de farm disponíveis:")
        for _, item in ipairs(farmType.itensFarm) do
            print("- Item:", item.item, "| Quantidade:", item.minAmount, "a", item.maxAmount)
        end

        -- 🚀 Iniciar a coleta da rota de farm
        TriggerEvent('farm:startCollect', selectedRoute, farmType.itensFarm)
    else
        print("Nenhuma organização encontrada para essas coordenadas!")
    end

    cb('ok')
end)


-- 🚜 **Função para iniciar a coleta**
RegisterNetEvent('farm:startCollect')
AddEventHandler('farm:startCollect', function(routeName, itensFarm)
    if in_rota then return end
    in_rota = true
    itemNumRoute = 1
    itemRoute = routeName
    textName = 'coleta'

    local routeIndexed = Config.farm.routes[routeName]
    if not routeIndexed then
        print("Erro: Rota não encontrada no Config!")
        return
    end

    CriandoBlip(itemNumRoute, routeIndexed)

    async(function()
        while in_rota do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)

            local indexedCoords = routeIndexed[itemNumRoute]
            local distance = #(pedCoords - vector3(indexedCoords.x, indexedCoords.y, indexedCoords.z))

            if distance <= 150.0 then
                local z_coords = indexedCoords.z + 1

                -- ✨ Criar marcador no local do farm
                DrawMarker(22, indexedCoords.x, indexedCoords.y, z_coords, 0, 0, 0, 0, 180.0, 130.0, 4.5, 4.5, 1.2, 0, 255, 55, 180, 1, 0, 0, 1)

                -- ✅ Coleta automática ao se aproximar
                if distance <= 4.0 then
                    -- 🚀 Solicitar item ao servidor
                    TriggerServerEvent('farm:giveItem', itensFarm)

                    -- 🔄 Atualizar para o próximo ponto
                    itemNumRoute = itemNumRoute + 1
                    if itemNumRoute > #routeIndexed then
                        print("Rota finalizada!")
                        in_rota = false
                        RemoveBlip(blips)
                        return
                    end
                    RemoveBlip(blips)
                    CriandoBlip(itemNumRoute, routeIndexed)
                end
            end
        end
    end)
end)


-- 🔵 **Criar o Blip para a rota**
function CriandoBlip(index, routeIndexed)
    local indexedCoords = routeIndexed[index]
    if not indexedCoords then return end

    blips = AddBlipForCoord(indexedCoords.x, indexedCoords.y, indexedCoords.z)
    SetBlipSprite(blips, 1)
    SetBlipColour(blips, 2)
    SetBlipRoute(blips, true)
end

