function hook(var)
    if var.v1 == "OnDialogRequest" then
        return true
    end
end
addHook(hook, "onVariant")

function buy()
SendPacket(2, "action|dialog_return\ndialog_name|carnival_booth\ntilex|65\ntiley|53\nbuttonClicked|buy_112")
end

function main()
while true do
buy()
Sleep(50)
end
end

main()
        