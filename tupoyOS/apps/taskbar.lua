return function(pAPI)
    local displaySize = pAPI.getDisplayInfo().size
    local window = pAPI:createWindow({
        title = "taskbar",
        pos = {
            x=1, 
            y=displaySize.y
        },
        size = {
            x = displaySize.x,
            y = 1
        },
        borderVisibility = false,
        alwaysOnTop = true,
    })
    window.layoutManager = nil

    local windowsRAW = pAPI:getAllWindows()


    local counter = 1

    local distance_between = 1
    local len = 5
    
    for key, windowRAW in pairs (windowsRAW) do
        local allWinodws = pAPI:getAllWindows()
        local ttext = pAPI:createTText({
            pos = {x=(counter*(len+distance_between)),y=1},
            size = {x=len,y=1},
            text = "Hello "..randStr(),
            bkColor = "4"
        })
        window:add(ttext)
        counter = counter+1
    end
    

    
    pAPI:runLoop()
end