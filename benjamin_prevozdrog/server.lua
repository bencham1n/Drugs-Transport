ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("benjaminkoodmena")
AddEventHandler("benjaminkoodmena", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src) -- dostanem hracove idecko
    local odmena = Config.reward
    exports.ox_inventory:AddItem(src, odmena, Config.Amount)-- Prida jeden
    TriggerClientEvent('okokNotify:Alert', src, 'Ferninand', 'Uspešne si odovzdal drogy', 2, 'info', true)
end)



