return function(pAPI)
    local backroundColor = "6"

    local displaySize = pAPI.getDisplayInfo().size

    local window = pAPI:createWindow({
        title = "Test",
        pos = {x=1,y=2},
        size = {x = displaySize.x,y = 8}
    })

    local ttext = pAPI:createTText({
        text = "Hello "..randStr(),
        bkColor = "4"
    })

    window:add(ttext)
    window:addMouseListener(function(args)
        -- window.display.screenLines[args.y].text[args.x] = "Y"
        window.bkColor = backroundColor
        pAPI:startTimer(0.3,function()
            window.bkColor = "8"
            os.queueEvent("windows_paint")
        end)
        ttext.textBackroundColor = backroundColor
        if backroundColor == "6" then
            backroundColor = "7"
        else
            backroundColor = "6"
        end
    end)
    --window:add(pAPI:createButton())
    pAPI:runLoop(function(message)
        
    end)
end