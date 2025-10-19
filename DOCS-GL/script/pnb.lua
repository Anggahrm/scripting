config = {
    block = 5640,
    far = 1,
    delay = {
        pnb = 500,
    },
}

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

local function pnb()
    for b = 1, config.far do
        put(config.block, 1, 0)
        Sleep(config.delay.pnb)
    end
    
    hit(1, 0)
    Sleep(config.delay.pnb)
end

local function main()
    while true do
        pnb()
Sleep(200)
    end
end

main()