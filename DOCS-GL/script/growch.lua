math.randomseed(os.time())

local config = {
    treeID = 3200,
    axeID = 3206,
    gemID = 16816,
    homeWorld = "NICE",
    farmWorld = "GROWCH",
    hitDelay = 100,
    minAxe = 1,
    eatGemsAt = 190,
    vendX = 8,
    vendY = 46,
    axesToBuy = 200,
    minAxeStock = 1
}

local stats = {
    isRunning = false,
    isPaused = false,
    treesCleared = 0,
    gemsEaten = 0
}

function hook(var)
    if var.v1 == "OnDialogRequest" then
        return true
    end
end
addHook(hook, "onVariant")

local function getItemCount(itemID)
    local count = 0
    for _, item in pairs(getInventory()) do
        if item.id == itemID then
            count = count + item.amount
        end
    end
    return count
end

local function goToWorld(name)
    SendPacket(3, "action|join_request\nname|" .. name .. "\ninvitedWorld|0")
    Sleep(1000)
end

local function hit(offsetX, offsetY)
    local pkt = {
        type = 3,
        value = 18,
        x = getLocal().posX,
        y = getLocal().posY,
        px = math.floor(getLocal().posX / 32) + offsetX,
        py = math.floor(getLocal().posY / 32) + offsetY
    }
    SendPacketRaw(false, pkt)
end

local function put(id, offsetX, offsetY)
    local pkt = {
        type = 3,
        value = id,
        x = getLocal().posX,
        y = getLocal().posY,
        px = math.floor(getLocal().posX / 32) + offsetX,
        py = math.floor(getLocal().posY / 32) + offsetY
    }
    SendPacketRaw(false, pkt)
end

local function wrench(offsetX, offsetY)
    local packet = {
        type = 3, value = 32,
        x = getLocal().posX,
        y = getLocal().posY,
        px = math.floor(getLocal().posX / 32) + offsetX,
        py = math.floor(getLocal().posY / 32) + offsetY
    }
    SendPacketRaw(false, packet)
end

local function wearAxe()
    local packet = { type = 10, value = config.axeID }
    SendPacketRaw(false, packet)
    Sleep(300)
end

local lastPlayerCount = -1
local playerCount = 0
local playerDetected = false

local function fRealtimePlayerWatcher()
    local list = getPlayerList()
    local me = getLocal()
    if not list or not me then return end
    local count = 0
    for _, p in pairs(list) do
        if p.netID ~= me.netID then
            count = count + 1
        end
    end
    playerDetected = (count > 0)
    playerCount = count
    if count ~= lastPlayerCount then
        if count > 0 then
            sendNotification("👀 " .. count .. " player detected!")
        else
            sendNotification("lanjut wok")
        end
        lastPlayerCount = count
    end
end

AddHook(fRealtimePlayerWatcher, "onDraw")

local function buyAxe()
    findPath(config.vendX, config.vendY)
    Sleep(200)
    wrench(0, 0)
    Sleep(200)
    local buyCount = config.axesToBuy
    local tileX, tileY = config.vendX, config.vendY
    SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..tileX.."|\ntiley|"..tileY.."|\nexpectprice|1|\nexpectitem|"..config.axeID.."|\nbuycount|"..buyCount)
    Sleep(200)
    SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..tileX.."|\ntiley|"..tileY.."|\nverify|1|\nbuycount|"..buyCount.."|\nexpectprice|1|\nexpectitem|"..config.axeID.."|")
    Sleep(200)
    wearAxe()
    return true
end

local function eatAllGems()
    local count = getItemCount(config.gemID)
    if count <= 0 then return end
    for i = 1, count do
        put(config.gemID, 0, 0)
        stats.gemsEaten = stats.gemsEaten + 1
        Sleep(100)
    end
end

local function lumberTrees()
    while stats.isRunning do
        if playerDetected then
            sendNotification("sabar jing ada orang")
            while playerDetected and stats.isRunning do
                Sleep(1000)
            end
            if stats.isRunning then
                sendNotification("lanjut wok")
            end
        else
            local tiles = GetTiles()
            local treeTiles = {}
            for _, t in pairs(tiles) do
                if t.fg == config.treeID or t.bg == config.treeID then
                    table.insert(treeTiles, {x = t.x, y = t.y})
                end
            end
            if #treeTiles == 0 then
                Sleep(1000)
            else
                table.sort(treeTiles, function(a, b)
                    if a.y == b.y then
                        return a.x < b.x
                    end
                    return a.y < b.y
                end)
                local ordered = {}
                local currentY = -999
                local line = {}
                for _, t in ipairs(treeTiles) do
                    if t.y ~= currentY then
                        if #line > 0 then
                            if currentY % 2 == 1 then
                                for i = #line, 1, -1 do
                                    table.insert(ordered, line[i])
                                end
                            else
                                for i = 1, #line do
                                    table.insert(ordered, line[i])
                                end
                            end
                        end
                        line = {}
                        currentY = t.y
                    end
                    table.insert(line, t)
                end
                if #line > 0 then
                    if currentY % 2 == 1 then
                        for i = #line, 1, -1 do
                            table.insert(ordered, line[i])
                        end
                    else
                        for i = 1, #line do
                            table.insert(ordered, line[i])
                        end
                    end
                end
                
                for _, t in ipairs(ordered) do
                    if not stats.isRunning then break end

                    if playerDetected then
                        sendNotification("sabar jing ada orang")
                        while playerDetected and stats.isRunning do
                            Sleep(1000)
                        end
                        if stats.isRunning then
                            sendNotification("lanjut wok")
                        end
                        break
                    end

                    local currentAxeCount = getItemCount(config.axeID)
                    if currentAxeCount < config.minAxe then
                        return
                    end

                    local currentGemCount = getItemCount(config.gemID)
                    if currentGemCount >= config.eatGemsAt then
                        return
                    end
                    
                    findPath(t.x, t.y)
                    Sleep(config.hitDelay)

                    local timeout = 50
                    local lastPosX, lastPosY = -1, -1
                    local isMoving = true

                    while timeout > 0 and isMoving do
                        local currentTileX = math.floor(getLocal().posX / 32)
                        local currentTileY = math.floor(getLocal().posY / 32)

                        if currentTileX == lastPosX and currentTileY == lastPosY then
                            isMoving = false
                        else
                            lastPosX, lastPosY = currentTileX, currentTileY
                        end
                        timeout = timeout - 1
                    end
                    
                    if not isMoving then
                        local currentTileX = math.floor(getLocal().posX / 32)
                        local currentTileY = math.floor(getLocal().posY / 32)
                        
                        if currentTileX == t.x and currentTileY == t.y then
                            Sleep(config.hitDelay)
                            hit(0, 0)
                            stats.treesCleared = stats.treesCleared + 1
                        end
                    end
                    Sleep(config.hitDelay)
                end
            end
        end
        Sleep(200)
    end
end

local function mainLoop()
    stats.isRunning = true
    while stats.isRunning do
        local axeCount = getItemCount(config.axeID)
        local gemCount = getItemCount(config.gemID)
        if axeCount < config.minAxeStock then
            goToWorld(config.homeWorld)
            buyAxe()
        elseif gemCount >= config.eatGemsAt then
            eatAllGems()
        else
            goToWorld(config.farmWorld)
            lumberTrees()
        end
    end
end

runThread(mainLoop)