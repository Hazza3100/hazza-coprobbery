local QBCore = exports['qb-core']:GetCoreObject()

local CopPed = {}


RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

function ResetRobbery(copName)
    Citizen.Wait(Config.cops[copName].CoolDown)
    Config.cops[copName].Robbed = false
  end

RegisterNetEvent('Hazza-coprobbery:client:startCopRob', function(data)
    local src     = source
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local copName = data.cop

    if CurrentCops < Config.cops[copName].MinimumPolice then
        TriggerEvent('QBCore:Notify', string.format('Minimum of %s police required', Config.cops[copName].MinimumPolice), 'error', 5000)
    else
        check = Config.cops[copName].Robbed
        if check ~= true then
            Config.cops[copName].Robbed = true
            RequestAnimDict("anim@gangops@facility@servers@")
            TaskPlayAnim(ped, 'anim@gangops@facility@servers@', 'hotwire', 3.0, 3.0, -1, 1, 0, false, false, false)
            QBCore.Functions.Progressbar("rob_cop", "Robbing Cop", math.random(5000, 8000), false, true, {
                disableMovement     = false,
                disableCarMovement  = false,
                disableMouse        = false,
                disableCombat       = true,
            }, {
            }, {}, {}, function()
                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                local pos    = GetEntityCoords(PlayerPedId())
                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                StreetLabel  = GetStreetNameFromHashKey(s1) .. " " .. GetStreetNameFromHashKey(s2)
                TriggerServerEvent('Hazza-coprobbery:server:robcop', copName, coords, StreetLabel)
                TriggerServerEvent('Hazza-coprobbery:server:reward', copName)
                ResetRobbery(copName)
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)

            end)
        else
            TriggerEvent('QBCore:Notify', 'This police officer was robbed recently', 'error', 5000)
        end
    end
    end)

RegisterNetEvent('Hazza-coprobbery:client:loadCops', function (source)
    TriggerServerEvent('Hazza-coprobbery:server:setCurrentCops')
    for k, v in pairs(Config.cops) do
        local CopHash = v['CopHash']
        RequestModel(CopHash)
        while not HasModelLoaded(CopHash) do
            Wait(10)
        end
        CopPed[k] = CreatePed(0, CopHash, v['Coords'].x, v['Coords'].y, v['Coords'].z, 10, false, false)
        SetEntityHeading(CopPed[k], GetEntityHeading(CopPed[k]) - 195.0)
        TaskStartScenarioInPlace(CopPed[k], v["scenario"], 0, true)
        SetEntityInvincible(CopPed[k], true)
        SetBlockingOfNonTemporaryEvents(CopPed[k], true)
        --Citizen.Wait(700) -- Otherwise ped doesn't reach the ground when frozen
        --FreezeEntityPosition(CopPed[k], true)

        local coords = GetEntityCoords(ped)

        exports['qb-target']:AddTargetEntity(CopPed[k], {
            options = {
                {
                    label = 'Rob Cop',
                    icon  = 'fa-solid fa-sack-dollar',
                    event = 'Hazza-coprobbery:client:startCopRob',
                    cop   = k
                }
            },
            distance = 2.0
        })

    end

end)


TriggerEvent('Hazza-coprobbery:client:loadCops')