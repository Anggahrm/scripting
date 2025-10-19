math.randomseed(os.time())

local config = {
    safeWorld = "GROWCH",
    cWorld = "CARNIVAL",
    waitTimeMin = 500, 
    waitTimeMax = 500, 
    hideWaitTime = 20000, 
    playerDetectionEnabled = true,
    autoRestartAfterHide = true,
}

local stats = {
    isRunning = false,
    statusText = "Idle",
}

local playerDetected = false
local playerCount = 0


local function checkOtherPlayers()
    if not config.playerDetectionEnabled then
        playerDetected = false
        playerCount = 0
        return false
    end
    local list = getPlayerList()
    local localPlayer = getLocal()
    if not list or not localPlayer then return false end
    local count = 0
    for _, p in pairs(list) do
        if p.netID ~= localPlayer.netID then
            count = count + 1
        end
    end
    playerCount = count
    playerDetected = (count > 0)
    return playerDetected
end

local function handlePlayerDetection()
    if config.playerDetectionEnabled and checkOtherPlayers() then
        sendNotification("Player detected! Warping to " .. config.safeWorld)
        sendPacket(3, "action|join_request\nname|" .. config.safeWorld .. "\ninvitedWorld|0")
        Sleep(config.hideWaitTime)
        if config.autoRestartAfterHide then
            sendPacket(3, "action|join_request\nname|" .. config.cWorld .. "\ninvitedWorld|0")
            Sleep(3000)
        end
        playerDetected = false
        playerCount = 0
        return true
    end
    return false
end

local function enterDoor(tileX, tileY)
    if handlePlayerDetection() then return true end
    local player = getLocal()
    if not player then return true end

    findPath(tileX, tileY)
    local timeout = os.time() + 5
    repeat
        if handlePlayerDetection() then return true end
        local p = getLocal()
        if not p then return true end
        local px = math.floor(p.pos.x / 32)
        local py = math.floor(p.pos.y / 32)
        if px == tileX and py == tileY then break end
        Sleep(100)
    until os.time() > timeout

    Sleep(300)
    if handlePlayerDetection() then return true end

    local pkt = {
        type = 7,
        value = 18,
        x = player.pos.x,
        y = player.pos.y,
        px = tileX,
        py = tileY
    }
    sendPacketRaw(false, pkt)
    return false
end

local function checkStartPosition()
    local p = getLocal()
    if not p then return false end
    local px = math.floor(p.pos.x / 32)
    local py = math.floor(p.pos.y / 32)
    return px == 14 and py == 32
end

local function runCarnivalCycle()
    if handlePlayerDetection() then return end

    local p = getLocal()
    if not p then return end
    local px = math.floor(p.pos.x / 32)
    local py = math.floor(p.pos.y / 32)
    if not (px == 27 and py == 25) then
        findPath(27, 25)
        local timeout = os.time() + 5
        repeat
            if handlePlayerDetection() then return end
            p = getLocal()
            if not p then return end
            px = math.floor(p.pos.x / 32)
            py = math.floor(p.pos.y / 32)
            if px == 27 and py == 25 then break end
            Sleep(100)
        until os.time() > timeout
    end

    if enterDoor(26, 25) then return end

    if handlePlayerDetection() then return end

    local tries = 0
    while not checkStartPosition() and tries < 30 do
        Sleep(500)
        tries = tries + 1
        if handlePlayerDetection() then return end
    end

    local waitTime = math.random(config.waitTimeMin, config.waitTimeMax)
    Sleep(waitTime)

    findPath(24, 24)
        if handlePlayerDetection() then return end
        local px = math.floor(p.pos.x / 32)
        local py = math.floor(p.pos.y / 32)
        Sleep(150)
end

local function mainLoop()
    stats.isRunning = true
    sendNotification("▶️ Auto Carnival Started!")
    LogToConsole("Auto Carnival started.")
    while stats.isRunning do
        runCarnivalCycle()
        Sleep(800)
    end
    sendNotification("⏹️ Auto Carnival Stopped.")
    LogToConsole("Stopped.")
end

if not stats.isRunning then
    runThread(function()
        mainLoop()
    end)
end