return function(message)

    local timerID = os.startTimer(1)
    while true do
        local message = coroutine.yield({
            type = "done"
        })
        if message.type == "event" then
            local eData = message.eData
            if eData[1] == "timer" and eData[2] == timerID then
                redstone.setOutput("back", not redstone.getOutput("back"))
                timerID = os.startTimer(1)
            end
        end
    end
    
end