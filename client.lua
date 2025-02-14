

print("Config carregado no client:", Config and "OK" or "NÃO CARREGADO")

local markers = {}
local isNearMarker = false
local blips = nil
local in_rota = false
local itemNumRoute = 1
local itemRoute = ""
local textName = "Coleta"
local MYROUTES = nil
local MYCOODS = nil
local hideMarkers = false
local route_name = nil


-- Criar markers para cada organização
Citizen.CreateThread(function()
    while not Config do
        Citizen.Wait(1000)
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
        if not hideMarkers then -- Só exibe se hideMarkers for falso
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            isNearMarker = false
            for _, marker in ipairs(markers) do
                local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, marker.coords.x, marker.coords.y, marker.coords.z)
                
                if distance < 5.0 then
                    isNearMarker = true
                    DrawMarker(21, marker.coords.x, marker.coords.y, marker.coords.z - 0.4,  0, 0, 0, 0, 180.0, 130.0, 0.7, 0.7, 0.8, 0, 255, 55, 180, 0, 0, 0, 1)
                    
                    if distance < 1.5 then
                        ShowHelpText("Pressione ~INPUT_CONTEXT~ para iniciar o farm de " .. marker.name)
                        
                        if IsControlJustPressed(0, 38) then -- Tecla "E"
                            local perm = getOrgPermission(marker.coords)
                            MYROUTES = Config.farm.routes 
                            MYCOODS = {marker.coords.x, marker.coords.y, marker.coords.z}
                            print("🔍 Iniciando checagem de permissão para:", perm)
                            TriggerServerEvent("farm:hasPermission", perm)
                        end
                    end
                end
            end
            
            if not isNearMarker then
                Citizen.Wait(500)
            end
        end
    end
end)


function getOrgPermission(coords)
    for orgType, data in pairs(Config.farm.orgType) do
        for _, org in ipairs(data.orgs) do
            if org.coords.x == coords.x and org.coords.y == coords.y and org.coords.z == coords.z then
                return org.permission
            end
        end
    end
    return nil
end

-- Exibir texto de ajuda na tela
function ShowHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

RegisterNUICallback("closeCurrentNUI", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideUI' })
    if cb then cb('ok') end
end)

RegisterNetEvent("farm:autorized")
AddEventHandler("farm:autorized", function()
    print("✔ Permissão concedida! Enviando UI.")
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "showUI", routes = MYROUTES, coords = MYCOODS })
end)

RegisterNetEvent("farm:notAutorized")
AddEventHandler("farm:notAutorized", function()
    print("❌ Permissão negada!")
    TriggerEvent("Notify", "negado", "Você não tem permissão para acessar esse blip!")
    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

RegisterNUICallback('selectRoute', function(data, cb)
    local selectedRoute = data.key
    local coords = data.coords
    local foundOrg = nil
    local farmType = nil

   
    for farmCategory, data in pairs(Config.farm.orgType) do
        for _, org in ipairs(data.orgs) do
            if org.coords.x == coords[1] and org.coords.y == coords[2] and org.coords.z == coords[3] then
                foundOrg = org
                farmType = data
                break
            end
        end
        if foundOrg then break end
    end

    if foundOrg then
        
        route_name = selectedRoute
        TriggerEvent('farm:startCollect', selectedRoute, farmType.itensFarm)
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hideUI' })
        TriggerEvent("Notify","sucesso","Você iniciou a rota ".. selectedRoute .." de farm!")
        PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    else
        print("❌ Nenhuma organização encontrada para essas coordenadas!")
        TriggerEvent("Notify", "negado", "Nenhuma organização encontrada para essas coordenadas!")
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end

    cb('ok')
end)

RegisterNetEvent('farm:startCollect')
AddEventHandler('farm:startCollect', function(routeName, itensFarm)
    if in_rota then return end
    in_rota = true
    hideMarkers = true -- 🔴 Esconde os markers
    itemNumRoute = 1 -- 🔥 Sempre começa em 1 (evita erro)
    itemRoute = routeName
    textName = 'coleta'

    local routeIndexed = Config.farm.routes[routeName]
    if not routeIndexed or #routeIndexed == 0 then
        print("❌ Erro: Rota não encontrada no Config ou está vazia!")
        in_rota = false
        hideMarkers = false -- Garante que os markers voltem
        return
    end

    print("🛤️ Iniciando farm na rota:", routeName)
    CriandoBlip(itemNumRoute, routeIndexed)

    Citizen.CreateThread(function()
        while in_rota do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)

            if itemNumRoute < 1 then itemNumRoute = 1 end -- 🔥 Se for menor que 1, ajusta

            if itemNumRoute > #routeIndexed then
                itemNumRoute = 1 -- 🔄 Reseta para o início para farm infinito
            end

            local indexedCoords = routeIndexed[itemNumRoute] 
            if indexedCoords then -- 🛑 Garante que o índice existe antes de usar
                local distance = #(pedCoords - vector3(indexedCoords.x, indexedCoords.y, indexedCoords.z))

                if distance <= 150.0 then
                    DrawMarker(22, indexedCoords.x, indexedCoords.y, indexedCoords.z + 1, 0, 0, 0, 0, 180.0, 130.0, 4.5, 4.5, 1.2, 0, 255, 55, 180, 1, 0, 0, 1)

                    if distance <= 4.0 then
                        TriggerServerEvent('farm:giveItem', itensFarm)
                        itemNumRoute = itemNumRoute + 1 -- Avança para o próximo ponto

                        RemoveBlip(blips)
                        CriandoBlip(itemNumRoute, routeIndexed)
                    end
                end
            else
                print("⚠️ Erro: indexedCoords é nil! itemNumRoute:", itemNumRoute)
                in_rota = false -- Cancela a rota se houver erro
                hideMarkers = false -- Exibe os markers novamente
            end
        end
    end)
end)




function CriandoBlip(index, routeIndexed)
    local indexedCoords = routeIndexed[index]
    if not indexedCoords then return end

    print("📍 Criando blip em:", indexedCoords.x, indexedCoords.y, indexedCoords.z)
    blips = AddBlipForCoord(indexedCoords.x, indexedCoords.y, indexedCoords.z)
    SetBlipSprite(blips, 1)
    SetBlipColour(blips, 2)
    SetBlipRoute(blips, true)
end




Citizen.CreateThread(function()
    while true do
        local time = 1000
        if in_rota then
            time = 5
            local totalRoutes = Config.farm.routes[itemRoute] and #Config.farm.routes[itemRoute] or 0

            drawTxt("~w~Aperte ~r~F7~w~ para cancelar \n" .. textName .." rota: ".. route_name ..". => Progresso: ~g~" .. itemNumRoute .. "/" .. totalRoutes, 0.170, 0.95)

            if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then -- F7
                in_rota = false
                hideMarkers = false -- 🟢 Mostra os markers novamente
                itemRoute = ""
                itemNumRoute = 0
                RemoveBlip(blips)
                TriggerEvent("Notify", "negado", "Você cancelou a rota de farm.")
            end
        end
        Citizen.Wait(time)
    end
end)



function drawTxt(text, x, y)
    SetTextFont(0)
    SetTextScale(0.3, 0.3)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end



RegisterNetEvent("farm:bagfull")
AddEventHandler("farm:bagfull",function ()

    TriggerEvent("Notify", "negado", "Você não tem espaço suficiente para coletar mais itens!")
    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

end)


RegisterNetEvent("farm:success")
AddEventHandler("farm:success",function ()
    TriggerEvent("Notify","sucesso","Você coletou o farm!")
    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)