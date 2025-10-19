local config = {
    gemID = 16816,
}

local stats = {
    isRunning = false,
    isPaused = false,
    treesCleared = 0,
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
    packet.x = player.pos.x
    packet.y = player.pos.y
    packet.punchx = math.floor(player.pos.x / 32) + offsetX
    packet.punchy = math.floor(player.pos.y / 32) + offsetY

    sendPacketRaw(false, packet)
end

function eatAllGems()
    doToast(4, 2000, "Starting gem eating at home world")
    
    local count = getItemCount(config.gemID)
    for i = 1, count do
        if getItemCount(config.gemID) <= 0 then break end

        put(config.gemID, 0, 0)
        stats.gemsEaten = stats.gemsEaten + 1
        sleep(100) 
        
        if i % 50 == 0 then
            doToast(4, 2000, "Eaten " .. i .. "/" .. count)
        end
    end
    
    doToast(1, 2000, "Finished eating " .. count .. " gems")
    sleep(1000) 
end

eatAllGems()

