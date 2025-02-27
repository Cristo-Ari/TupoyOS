return function(pAPI)
    local displaySize = pAPI.getDisplayInfo().size
    local windowSize = {
        x = 30,
        y = 15
    }
    local window = pAPI:createWindow({
        title = "Paint",
        pos = {
            x=math.floor(displaySize.x/2) - math.floor(windowSize.x/2)+1+math.random(-10,10),
            y=math.floor(displaySize.y/2) - math.floor(windowSize.y/2)+2+math.random(-4,4),
        },
        size = windowSize,
        borderVisibility = true,
    })

    local someComp = pAPI.compAPI:createComponent()
    local imageSize = {
        x=30,
        y=16
    }
    
    local dots = {}
    someComp:addCustomPaint(function(linesM)
        linesM:fill(colorsChar.green)
        for key, dot in pairs(dots)do
            linesM:drawPixel(dot.pos.x,dot.pos.y,dot.color)
        end
    end)
    someComp:addMouseListener(function(mouseEvent)
        pAPI:log("0.5")
        if mouseEvent.buttonName == "LBM" then
            table.insert(dots,{pos=mouseEvent.pos,color=colorsChar.blue})
        elseif mouseEvent.buttonName == "RBM" then
            table.insert(dots,{pos=mouseEvent.pos,color=colorsChar.cyan})
        else
            table.insert(dots,{pos=mouseEvent.pos,color=colorsChar.lightGray})
        end
    end)
    someComp.size:set(imageSize)
    someComp.pos:set({x=1,y=1})

    window:add(someComp)

    pAPI:runLoop()
end