local pAPI = dofile("pAPI.lua")

local dcolors = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
local letters = {}
for i = 1, 255 do
    table.insert(letters, string.char(i))
end

local generateRandomScreen = function(width,height)
    local screenLines = {}
    for i = 1, 255 do
        table.insert(letters, string.char(i))
    end
    for i = 1,height do
        screenLines[i]={
            text =      {},
            tColor =    {},
            bkColor =   {}
        }
        for j = 1,width do
            screenLines[i].text[j] =letters[math.random(1,255)]
            screenLines[i].tColor[j] =dcolors[math.random(1,16)]
            screenLines[i].bkColor[j] =dcolors[math.random(1,16)]
        end
    end
    
    return screenLines
end

return function(message)
    local windowID = pAPI:createWindow({
        title = "psycho",
        pos = {
            x=3,
            y=3
        },
        size = {
            x = 5,
            y = 2
        }
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
                        data = generateRandomScreen(80,40)
                    }
                    coroutine.yield(returnMessage)
                end
            end
        end
    end
    
end