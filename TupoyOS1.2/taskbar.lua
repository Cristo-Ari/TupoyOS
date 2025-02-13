local pAPI = dofile("pAPI.lua")
return function(message)
    -- local screenLines = {}

    -- local screenWidth = 30
    -- local screenHeight = 30

    -- local initScreen = function(self)
    --     screenLines = {}
    --     for y = 1, screenHeight do
    --         screenLines[y] = string.rep("#", screenWidth)
    --     end
    -- end
    -- initScreen()

    local screenLines = {}
    for i = 1,7 do
        screenLines[i]={
            text =      {'H', 'e', 'l', 'l', 'o', ',', ' ', 'C', 'o', 'm', 'p', 000, 't', 'e', 'r', 'C', 'r', 'a', 'f', 't', '!'},
            tColor =    {"e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", 000, "e", "e", "e", "e", "e", "e", "e", "e", "e"},
            bkColor =   {"0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", 000, "0", "0", "0", "0", "0", "0", "0", "0", "0"}
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