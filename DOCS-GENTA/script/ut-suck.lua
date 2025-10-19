add   = 100
id    = 9928
X     = 21
Y     = 52
delay = 300
running = false

function DoLoop()
    runThread(function()
        while running do
            local pkt1 = string.format([[
action|dialog_return
dialog_name|itemremovedfromsucker
tilex|%d|
tiley|%d|
itemtoremove|%d
]], X, Y, add)
            sendPacket(2, pkt1)

            local pkt2 = string.format([[
action|dialog_return
dialog_name|drop_item
itemID|%d|
count|%d
]], id, add)
            sendPacket(2, pkt2)

            if math.random(1, 10) == 1 then
                logToConsole("`9Remove+Drop berjalan...")
            end
            sleep(delay)
        end
    end)
end

AddHook("OnVarlist", "suckmadih", function(vlist, netid)
    for _, v in pairs(vlist) do
        if type(v) == "string" then
            local text = v:match("|text|(.+)") or v
            if text:find("!on") or text:find("/on") then
                if not running then
                    running = true
                    logToConsole("`2Remove+Drop DIMULAI")
                    DoLoop()
                end
            elseif text:find("!off") or text:find("/off") then
                if running then
                    running = false
                    logToConsole("`4Remove+Drop DIMATIKAN")
                end
            elseif text:find("!setid") or text:find("/setid") then
                local newId = tonumber(text:match("%d+"))
                if newId then
                    id = newId
                    logToConsole("`6Item ID diganti ke: " .. id)
                end
            elseif text:find("!setcount") or text:find("/setcount") then
                local newCount = tonumber(text:match("%d+"))
                if newCount then
                    add = newCount
                    logToConsole("`6Jumlah diganti ke: " .. add)
                end
            end
        end
    end
end)


