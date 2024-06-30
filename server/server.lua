ESX.RegisterUsableItem(Death.MedikitItem, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('medikit', 1)
    TriggerClientEvent('lithe-deathsystem:useMedikit', source)
end)

RegisterServerEvent('lithe-deathsystem:revivePlayer')
AddEventHandler('lithe-deathsystem:revivePlayer', function(targetPlayerId)
    local xPlayer = ESX.GetPlayerFromId(targetPlayerId)

    if xPlayer then
        TriggerClientEvent('lithe-deathsystem:revive', targetPlayerId)
    end
end)


RegisterCommand(Death.ReviveCommand , function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourcePlayer = tonumber(source)

    if xPlayer and xPlayer.getGroup() == Death.GroupCommand then
        local targetId = tonumber(args[1])

        if targetId then
            local targetServerId = GetPlayerServerId(targetId)
            
            if targetServerId then
                TriggerClientEvent('lithe-deathsystem:revive', targetServerId)
                xPlayer.showNotification(Death.YouRevived .. targetServerId)
            else
                xPlayer.showNotification(Death.InvalidID)
            end
        else
            -- Revive the current player if no ID is specified
            TriggerClientEvent('lithe-deathsystem:revive', sourcePlayer)
            xPlayer.showNotification(Death.SelfRevive)
        end
    else
        xPlayer.showNotification(Death.NoAdmin)
    end
end, false)



RegisterServerEvent('death:removeinv',function(antic)
    local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer ~= nil then
            for i=1, #xPlayer.inventory, 1 do
                exports['ox_inventory']:ClearInventory(xPlayer.inventory[i])
                if xPlayer.inventory[i].count > 0 then
                    xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
                end
            end
            if xPlayer.getMoney() > 0 then
                xPlayer.removeMoney(xPlayer.getMoney())
            end
        end
end)
