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
                        SendNUIMessage({ action = "showUI", routes = Config.farm.routes })
                        TriggerEvent('farm:blipClicked', marker.coords.x, marker.coords.y, marker.coords.z)

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


RegisterNetEvent('farm:blipClicked')
AddEventHandler('farm:blipClicked', function(x, y, z)
    local foundOrg = nil
    local farmType = nil

    for farmCategory, data in pairs(Config.farm.orgType) do
        for _, org in ipairs(data.orgs) do
            if org.coords.x == x and org.coords.y == y and org.coords.z == z then
                foundOrg = org
                farmType = data
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
        -- Aqui você pode abrir a NUI para mostrar os detalhes da organização e farm
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "showOrgDetails",
            orgName = foundOrg.name,
            permission = foundOrg.permission,
            itens = farmType.itensFarm
        })
    else
        print("Nenhuma organização encontrada nesta coordenada!")
    end
end)
