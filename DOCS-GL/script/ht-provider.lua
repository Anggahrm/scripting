local worldType = "normal" -- normal/island
local providerID = 866
local harvestDelay = 200
local collectDelay = 200
local collectID = 868
local loopDelay = 500

local sizeX = 99
local sizeY = (worldType == "island" and 115 or 54)

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

local function tp(x, y)
    sendPacketRaw(false, {
        type = 0,
        x = x * 32,
        y = y * 32
    })
    sleep(100)
end

local function ht(x, y)
    sendPacketRaw(false, {
        type = 3,
        value = 18,
        px = x,
        py = y,
        x = x * 32,
        y = y * 32
    })
    sleep(harvestDelay)
end

function take(x, y)
    for _, obj in pairs(getObjectList()) do
        if math.floor(obj.posX / 32) == x and math.floor(obj.posY / 32) == y then
            sendPacketRaw(false, {
                type = 11,
                value = obj.id,
                x = obj.posX,
                y = obj.posY
            })
        end
    end
end

function doExchange()
    local dialog =
        "action|dialog_return\n" ..
        "dialog_name|exchange_go\n" ..
        "1VsZFGQaV71mdPUcsz0jF4ae7lnl8n|sG0J4sRHwj3UApC9TiuLVall|\n" ..
        "BTyp6eMMg5ClZipyjp2T58FV3skf|NF5yGlmlSLdF8mYfqr07lZBxDZatD0|\n" ..
        "YcrY8kFjmDlvfeMJVXB9VqCYDaw|7y2T36B60GT8qpywbRn0h|\n" ..
        "5pXNkVa9jfAC5ibqnN27zgGf6BN3|pZtm275lIToXip4rnk7zhVFb1|\n" ..
        "buttonClicked|ex_868200179610"
    sendPacket(2, dialog)
end

function blockExchangeDialog(varlist, packet)
    if varlist.v1:find("OnDialogRequest") and varlist.v2:find("end_dialog|exchange_go") then
        return true
    end
end

addHook(blockExchangeDialog, "onVariant")

local function harvestAll()
    local harvested = 0
    for col = 0, sizeX do
        for row = 0, sizeY do
            local tile = getTile(col, row)
            if tile and tile.fg == providerID and tile.readyharvest then
                ht(col, row)
                sleep(harvestDelay)
                harvested = harvested + 1
            end
        end
    end
    if harvested > 0 then
        LogToConsole("Harvested " .. harvested .. " tiles.")
    else
        LogToConsole("No ready tiles found.")
    end
end

local function collectAllMilk()
    local collected = 0
    local objects = getObjectList()
    for _, obj in pairs(objects) do
        if obj.itemid == collectID then
            local x = math.floor(obj.posX / 32)
            local y = math.floor(obj.posY / 32)
            tp(x, y)
            sleep(collectDelay)
            take(x, y)
            collected = collected + 1
            local milkCount = getItemCount(collectID)
            if milkCount == 200 then
                doExchange()
                sleep(500)
                return
            end
            sleep(50)
        end
    end
    if collected > 0 then
        LogToConsole("Collected " .. collected .. " milk bottles.")
    else
        LogToConsole("No milk objects found.")
    end
end

while true do
    local milkCount = getItemCount(collectID)
    if milkCount == 200 then
        doExchange()
        sleep(500)
    else
        harvestAll()
        sleep(200)
        collectAllMilk()
    end
    sleep(loopDelay)
end
