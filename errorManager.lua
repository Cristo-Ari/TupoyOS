local pAPI = dofile("pAPI.lua")

local screens = {}

local createScreen = function()
    
end

local createErrorWindow = function()
    local screenLines = {}
    for i = 1,1 do
        screenLines[i]={
            text =      {"d","d"},
            tColor =    {"9","9"},
            bkColor =   {}
        }
    end
end

return function(message)
    pAPI:setProgramName("error manager")
    local screenLines = {}
    for i = 1,1 do
        screenLines[i]={
            text =      {"d","d"},
            tColor =    {"9","9"},
            bkColor =   {}
        }
    end
        
    local display = pAPI.getDisplayInfo()
    
    local windowID = pAPI:createWindow({
        title = "taskbar",
        pos = {
            x=0, 
            y=display.size.y-1
        },
        size = {
            x = display.size.x+2,
            y = 3
        },
        borderVisibility = false,
        alwaysOnTop = true,
    })

    

    while true do
        local message = coroutine.yield({
            type = "done"
        })

        if message.type == "window" then
            if message.windowID == windowID then
                if message.info == "paint request" then

                    local returnMessage = {
                        type = "window",
                        windowID = message.windowID,
                        info = "paint response",
                        data = screenLines
                    }
                    coroutine.yield(returnMessage)
                end
            end
        end
    end
    
end

-- return function(message)

--     local timerID = os.startTimer(1)
--     while true do
--         local message = coroutine.yield({
--             type = "done"
--         })
--         if message.type == "event" then
--             local eData = message.eData
--             if eData[1] == "timer" and eData[2] == timerID then
--                 redstone.setOutput("back", not redstone.getOutput("back"))
--                 timerID = os.startTimer(1)
--             end
--         end
--     end
    
-- end