local config = {
    gemID = 16816,
}

local stats = {
    gemsEaten = 0
}

function getItemCount(itemID)
    local total = 0
    local inventory = getInventory()
    for _, item in ipairs(inventory) do
        if item.id == itemID then
            total = total + item.amount
        end
    end
    return total
end


function put(id, offsetX, offsetY)
    local player = getLocal()
    if not player then return end
    
    local packet = {}
    packet.type = 3
    packet.value = id 
    packet.x = player.posX
    packet.y = player.posY
    packet.px = math.floor(player.posX / 32) + offsetX
    packet.py = math.floor(player.posY / 32) + offsetY

    sendPacketRaw(false, packet)
end

function eatAllGems()
    local count = getItemCount(config.gemID)
    for i = 1, count do
        if getItemCount(config.gemID) <= 0 then break end

        put(config.gemID, 0, 0)
        stats.gemsEaten = stats.gemsEaten + 1
        sleep(100) 
        
        if i % 50 == 0 then
             sendNotification("Eaten " .. i .. "/" .. count)
        end
    end
    
    sendNotification("Finished eating " .. count .. " gems")
    sleep(1000) 
end

eatAllGems()