local worldType = "normal"
local collectIDs = { 2, 3, 4, 5, 10, 11, 14, 15, 112, 2914, 5028, 5032 }
local skipIDs = { 6, 8, 242 }
local hitDelay = 150
local loopDelay = 500

local sizeX = 99
local sizeY = (worldType == "island" and 115 or 54)

function a(itemID)
    local total = 0
    for _, item in ipairs(getInventory()) do
        if item.id == itemID then
            total = total + item.amount
        end
    end
    return total
end

function b(x, y)
    sendPacketRaw(false, {
        type = 3,
        value = 18,
        punchx = x,
        punchy = y,
        x = x * 32,
        y = y * 32
    })
end

function c(value, list)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

function d(x, y)
    sendPacketRaw(false, {
        type = 0,
        x = x * 32,
        y = y * 32
    })
sleep(100)
end

function z(x, y, r)
    maxRetries = r or 5
    local tries = 0

    while tries < r do
        b(x, y)
        sleep(hitDelay)

        local tile = checkTile(x, y)
        local fg = 0
        local bg = 0
        if tile then
            fg = tile.fg or 0
            bg = tile.bg or 0
        end

        if fg == 0 and bg == 0 then
            return true
        end

        tries = tries + 1
    end

    return false
end

function e()
    local cleared = 0
    for row = 0, sizeY do
        if row % 2 == 0 then
            for col = 0, sizeX do
                local tile = checkTile(col, row)
                if tile then
                    local fg = tile.fg or 0
                    local bg = tile.bg or 0
                    if not c(fg, skipIDs) and not c(bg, skipIDs) then
                        if (fg ~= 0) or (bg ~= 0) then
                            local ok = z(col, row, 5)
                            if not ok then
                                --doToast(2, 1500, "Warn: unable to clear tile at " .. col .. "," .. row)
                            end
                            cleared = cleared + 1
                        end
                    end
                end
            end
        else
            for col = sizeX, 0, -1 do
                local tile = checkTile(col, row)
                if tile then
                    local fg = tile.fg or 0
                    local bg = tile.bg or 0
                    if not c(fg, skipIDs) and not c(bg, skipIDs) then
                        if (fg ~= 0) or (bg ~= 0) then
                            local ok = z(col, row, 5)
                            if not ok then
                                --doToast(2, 1500, "Warn: unable to clear tile at " .. col .. "," .. row)
                            end
                            cleared = cleared + 1
                        end
                    end
                end
            end
        end
    end

    if cleared > 0 then
        doToast(1, 2000, "Cleared " .. cleared .. " tiles.")
    else
        doToast(4, 2000, "No tiles to clear.")
    end
end

function f()
    local collected = 0
    local objects = getWorldObject()
    for _, obj in pairs(objects) do
        if c(obj.id, collectIDs) then
            local x = math.floor(obj.pos.x / 32)
            local y = math.floor(obj.pos.y / 32)
            d(x, y)
            sleep(50)
            requestCollect(x, y, obj.id)
            collected = collected + 1
        end
    end

    if collected > 0 then
        doToast(1, 2000, "Collected " .. collected .. " items.")
    else
        doToast(4, 2000, "No floating items found.")
    end
end

while true do
    e()
    sleep(500)
    f()
    sleep(loopDelay)
end
















