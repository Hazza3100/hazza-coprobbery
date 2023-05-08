local QBCore = exports['qb-core']:GetCoreObject()





RegisterNetEvent('Hazza-coprobbery:server:reward', function (copName)
    local src          = source
    local Player       = QBCore.Functions.GetPlayer(src)

    Config.cops[copName].Robbed     = true
    item_cash = math.random(1,2) -- 1 = item
    if item_cash == 1 then
        -- item
        local items = {
            'goldbar',
            'goldchain',
            'diamond_ring',
            'rolex',
            '10kgoldchain',
            'tablet',
            'iphone',
            'samsungphone',
            'diamond',

        }
        local item = items[math.random(#items)]
        Player.Functions.AddItem(item, math.random(1,3), false, 'Cop Robbery - item reward')
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
        TriggerClientEvent('QBCore:Notify', src, 'Police Officer robbed successfully', 'success', 5000)
    else
        -- bill
        Player.Functions.AddItem('markedbills', math.random(1,3), false, 'Cop Robbery - cash bill reward')
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
        TriggerClientEvent('QBCore:Notify', src, 'Police Officer robbed successfully', 'success', 5000)
    end
end)


RegisterNetEvent('Hazza-coprobbery:server:robcop', function (copName, coords, StreetLabel)
    local src          = source
    local Player       = QBCore.Functions.GetPlayer(src)
    local playerCoords = coords
    local ped          = GetPlayerPed(src)
    local amount       = playerCoords.x - Config.cops[copName].Coords.x
    if amount < -3.0 then
        return DropPlayer(src, "Attempted exploit abuse")
    end

    cops_chance = math.random(2,4)
    if cops_chance > 2 then
        local coords = GetEntityCoords(ped)
        TriggerEvent("police:server:policeAlert", 'Police Officer is being robbed', coords)
    end
end)

local function GetCurrentCops()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    return amount
end


RegisterNetEvent('Hazza-coprobbery:server:setCurrentCops')
AddEventHandler('Hazza-coprobbery:server:setCurrentCops', function()
    local cops = GetCurrentCops()
    TriggerClientEvent('police:SetCopCount', -1, cops)
end)