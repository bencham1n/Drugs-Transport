local car = Config.car
local spawnedCar = nil 
local markerActive = false
local markerCoords = Config.location
local interactionDistance = 1.5 
local lastCarSpawnTime = 0 

RegisterNetEvent("benjaminheist", function()
    local currentTime = GetGameTimer() / 1000  
    local cooldownTime = Config.cooldownTime  

    
    if currentTime - lastCarSpawnTime < cooldownTime then
        local remainingTime = cooldownTime - (currentTime - lastCarSpawnTime)
        exports['okokNotify']:Alert('Cooldown', 'Musíš počkať ' .. math.ceil(remainingTime) .. ' sekúnd pred tým, než môžeš znovu spustiť príkaz.', 5000, 'error', true)
        lib.notify({
            title = 'Notification title',
            description = 'Notification description',
            type = 'success'
        })
        return 
    end

   
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    
    RequestModel(car)
    while not HasModelLoaded(car) do
        Citizen.Wait(10)
    end

    spawnedCar = CreateVehicle(car, Config.Carspawn.x, Config.Carspawn.y, Config.Carspawn.z, Config.Carspawn.w, true, false)
    SetPedIntoVehicle(playerPed, spawnedCar, -1) 
    SetEntityAsMissionEntity(spawnedCar, true, true)



    
    SetNewWaypoint(markerCoords.x, markerCoords.y)
    exports['okokNotify']:Alert('Ferdinant', 'Odnes drogy na miesto ktoré máš označené na mape', 5000, 'info', true)

    
    markerActive = true

    
    lastCarSpawnTime = currentTime
end, false)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if markerActive then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, markerCoords.x, markerCoords.y, markerCoords.z)

            
            if distance < 20.0 then
                DrawMarker(32, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 
                    0, 0, 0, 0, 0, 0, 
                    1.5, 1.5, 1.5, 
                    255, 0, 0, 150, 
                    false, true, 2, nil, nil, false)

                
                if distance < interactionDistance then
                   
                    if IsPedInVehicle(playerPed, spawnedCar, false) then
                        exports['okokTextUI']:Open('Stlač [E] aby si odovzdal drogy', 'darkgreen', 'right', false)

                        if IsControlJustReleased(0, 38) then 
                            TriggerEvent("markerTriggered")
                        end
                    else
                        
                        exports['okokTextUI']:Open('Musíš byť v dodanom vozidle!', 'red', 'right', false)
                    end
                end
            else
                
                exports['okokTextUI']:Close()
            end
        end
    end
end)


RegisterNetEvent("markerTriggered")
AddEventHandler("markerTriggered", function()
    TriggerServerEvent('benjaminkoodmena')
    exports['okokTextUI']:Close()
    local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police', 'sheriff'},
        coords = data.coords,
        title = '10-14 - Väčší Predaj drog',
        message = ''.. data.sex .. '  nahlásil divné auto na : ' .. data.street,
        flash = 0,
        unique_id = data.unique_id,
        sound = 1,
        blip = {
            sprite = 161,
            scale = 1.5,
            colour = 3,
            flashes = false,
            text = 'Možný predaj drog',
            time = 5,
            radius = 1,
        }
})


   
    markerActive = false

   
    if DoesEntityExist(spawnedCar) then
        DeleteVehicle(spawnedCar)
        spawnedCar = nil
    end
end)


local npcModel = Config.npc 
local npcCoords = Config.npcloaction 


local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
end


CreateThread(function()
    LoadModel(npcModel)

    local npc = CreatePed(4, GetHashKey(npcModel), Config.npclocation.x, Config.npclocation.y, Config.npclocation.z, Config.npclocation.w, false, true)
    SetEntityInvincible(npc, true) 
    SetBlockingOfNonTemporaryEvents(npc, true) 
    FreezeEntityPosition(npc, true) 

    
    exports.ox_target:addLocalEntity(npc, {
        {
            name = "startbenjaminheistikdrug",
            label = "Promluviť si",
            event = "benjaminheist",
            icon = "fa-solid fa-pills",
        },
    })
end)
