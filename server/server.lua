local RSGCore = exports['rsg-core']:GetCoreObject()

-- Buy New Boats
RegisterServerEvent('rsg-boats:BuyBoat')
AddEventHandler('rsg-boats:BuyBoat', function(buyData, location)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    local name = buyData.boatName
    local model = buyData.boatModel
    local buyPrice = buyData.buyPrice
    local money = Player.PlayerData.money.cash
    if money >= buyPrice then
        Player.Functions.RemoveMoney('cash', buyPrice)
        TriggerClientEvent('rNotify:NotifyLeft', source, "YOU BOUGHT ", "A NEW BOAT", "generic_textures", "tick", 4000)

        MySQL.Async.execute('INSERT INTO boats (citizenid, name, model, location) VALUES (@citizenid, @name, @model, @location)', {
            ['@citizenid'] = citizenId,
            ['@name'] = name,
            ['@model'] = model,
            ['@location'] = location
        })
    else
        TriggerClientEvent('rNotify:NotifyLeft', source, "SORRY", "YOU ARE SHORT ON CASH", "generic_textures", "tick", 4000)
    end
end)

-- Get List of Owned Boats
RegisterServerEvent('rsg-boats:GetOwnedBoats')
AddEventHandler('rsg-boats:GetOwnedBoats', function(location, shopId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid

    local result = MySQL.query.await('SELECT * FROM boats WHERE citizenid = @citizenid AND location = @location', {
        ['@citizenid'] = citizenId,
        ['@location'] = location
    })
    if result[1] then
        TriggerClientEvent("rsg-boats:OwnedBoatsMenu", src, result, shopId)
    else
        TriggerClientEvent('rNotify:NotifyLeft', source, "SORRY", "NO BOATS", "generic_textures", "tick", 4000)
    end
end)

-- Sell Owned Boats
RegisterServerEvent('rsg-boats:SellBoat')
AddEventHandler('rsg-boats:SellBoat', function(ownedData, boatData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    local name = ownedData.name
    local model = ownedData.model
    local location = ownedData.location
    local sellPrice = boatData.sellPrice

    Player.Functions.AddMoney('cash', sellPrice)
    TriggerClientEvent('rNotify:NotifyLeft', source, "YOU SOLD ", "A BOAT", "generic_textures", "tick", 4000)

    MySQL.Async.execute('DELETE FROM boats WHERE citizenid = @citizenid AND location = @location AND name = @name AND model = @model LIMIT 1', {
        ['@citizenid'] = citizenId,
        ['@location'] = location,
        ['@name'] = name,
        ['@model'] = model
    })
end)

-- Transfer Owned Boats Between Shops
RegisterServerEvent('rsg-boats:TransferBoat')
AddEventHandler('rsg-boats:TransferBoat', function(ownedData, transferLocation, transferMode, boatData, shopName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    local name = ownedData.name
    local model = ownedData.model
    local location = ownedData.location

    if transferMode == "menuTransfer" then
        local transferPrice = boatData.transferPrice
        local money = Player.PlayerData.money.cash
        if money >= transferPrice then
            Player.Functions.RemoveMoney('cash', transferPrice)
            TriggerClientEvent('rNotify:NotifyLeft', source, "TRANSFER", "IS A SUCCESS", "generic_textures", "tick", 4000)

            MySQL.Async.execute('UPDATE boats SET location = @transferLocation WHERE citizenid = @citizenid AND location = @location AND name = @name AND model = @model LIMIT 1', {
                ['@citizenid'] = citizenId,
                ['@location'] = location,
                ['@name'] = name,
                ['@model'] = model,
                ['@transferLocation'] = transferLocation
            })
        else
            TriggerClientEvent('RSGCore:Notify', src, _U("shortCash"), 'error', 6000)
        end

    elseif transferMode == "driveTransfer" then

        MySQL.Async.execute('UPDATE boats SET location = @transferLocation WHERE citizenid = @citizenid AND location = @location AND name = @name AND model = @model LIMIT 1', {
            ['@citizenid'] = citizenId,
            ['@location'] = location,
            ['@name'] = name,
            ['@model'] = model,
            ['@transferLocation'] = transferLocation
        })
    end
end)

-- Prevent NPC Boat Spawns
if Config.blockNpcBoats then
    AddEventHandler('entityCreating', function(entity)
        if GetEntityType(entity) == 2 then
            if GetVehicleType(entity) == "boat" then
                if GetEntityPopulationType(entity) ~= 7 and GetEntityPopulationType(entity) ~= 8 then
                    CancelEvent()
                end
            end
        end
    end)
end
