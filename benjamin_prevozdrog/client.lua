local car = Config.car
local spawnedCar = nil -- Premenná na uchovanie spawnutého auta
local markerActive = false
local markerCoords = Config.location
local interactionDistance = 1.5 -- Vzdialenosť na aktiváciu
local lastCarSpawnTime = 0 -- Čas posledného použitia príkazu /caris (v sekundách)

RegisterNetEvent("benjaminheist", function()
    local currentTime = GetGameTimer() / 1000  -- Získame aktuálny čas v sekundách
    local cooldownTime = Config.cooldownTime  -- 10 minút (600 sekúnd)

    -- Skontroluje, či je hráč v cooldown period
    if currentTime - lastCarSpawnTime < cooldownTime then
        local remainingTime = cooldownTime - (currentTime - lastCarSpawnTime)
        exports['okokNotify']:Alert('Cooldown', 'Musíš počkať ' .. math.ceil(remainingTime) .. ' sekúnd pred tým, než môžeš znovu spustiť príkaz.', 5000, 'error', true)
        lib.notify({
            title = 'Notification title',
            description = 'Notification description',
            type = 'success'
        })
        return -- Príkaz sa nevykoná, ak je cooldown ešte aktívny
    end

    -- Spawnuje vozidlo
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Spawning car
    RequestModel(car)
    while not HasModelLoaded(car) do
        Citizen.Wait(10)
    end

    spawnedCar = CreateVehicle(car, Config.Carspawn.x, Config.Carspawn.y, Config.Carspawn.z, Config.Carspawn.w, true, false)
    SetPedIntoVehicle(playerPed, spawnedCar, -1) -- Hráč automaticky nasadne do auta
    SetEntityAsMissionEntity(spawnedCar, true, true)



    -- Nastavenie waypointu
    SetNewWaypoint(markerCoords.x, markerCoords.y)
    exports['okokNotify']:Alert('Ferdinant', 'Odnes drogy na miesto ktoré máš označené na mape', 5000, 'info', true)

    -- Aktivácia markeru
    markerActive = true

    -- Uložíme čas posledného spustenia príkazu /caris
    lastCarSpawnTime = currentTime
end, false)



-- Hlavný thread na vykresľovanie markeru
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if markerActive then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, markerCoords.x, markerCoords.y, markerCoords.z)

            -- Ak je hráč v dosahu markeru, vykreslí sa
            if distance < 20.0 then
                DrawMarker(32, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 
                    0, 0, 0, 0, 0, 0, 
                    1.5, 1.5, 1.5, 
                    255, 0, 0, 150, 
                    false, true, 2, nil, nil, false)

                -- Ak je hráč veľmi blízko (v dosahu interakcie)
                if distance < interactionDistance then
                    -- Skontroluje, či je hráč v spawnutom aute
                    if IsPedInVehicle(playerPed, spawnedCar, false) then
                        exports['okokTextUI']:Open('Stlač [E] aby si odovzdal drogy', 'darkgreen', 'right', false)

                        if IsControlJustReleased(0, 38) then -- Klávesa E (38)
                            TriggerEvent("markerTriggered")
                        end
                    else
                        -- Ak hráč nie je v správnom aute, zobrazí text
                        exports['okokTextUI']:Open('Musíš byť v dodanom vozidle!', 'red', 'right', false)
                    end
                end
            else
                -- Ak je hráč ďaleko, zatvorí text UI
                exports['okokTextUI']:Close()
            end
        end
    end
end)

-- Event, ktorý sa spustí po stlačení E
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


    -- Vypnutie markeru po interakcii
    markerActive = false

    -- Možnosť odstrániť vozidlo po úspešnej doručení
    if DoesEntityExist(spawnedCar) then
        DeleteVehicle(spawnedCar)
        spawnedCar = nil
    end
end)


local npcModel = Config.npc -- Model NPC
local npcCoords = Config.npcloaction -- Súradnice NPC (x, y, z, heading)

-- Funkcia na načítanie modelu NPC
local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
end

-- Vytvorenie NPC pri spustení servera
CreateThread(function()
    LoadModel(npcModel)

    local npc = CreatePed(4, GetHashKey(npcModel), Config.npclocation.x, Config.npclocation.y, Config.npclocation.z, Config.npclocation.w, false, true)
    SetEntityInvincible(npc, true) -- NPC nemôže zomrieť
    SetBlockingOfNonTemporaryEvents(npc, true) -- NPC sa nehýbe ani neuteká
    FreezeEntityPosition(npc, true) -- NPC zostane na mieste

    -- Pridanie interakcie cez ox_target
    exports.ox_target:addLocalEntity(npc, {
        {
            name = "startbenjaminheistikdrug",
            label = "Promluviť si",
            event = "benjaminheist",
            icon = "fa-solid fa-pills",
        },
    })
end)
