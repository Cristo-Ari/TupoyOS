local timersManager = {
    timers = {},
    startTimer = function(self,time,func)
        local timerID = os.startTimer(time)
        table.insert(self.timers,{id = timerID,func = func})
    end,
    handler = nil
}
local handler = function(eData)
    if eData[1] == "timer" then
        local timerID = eData[2]
        for key , timer in pairs (timersManager.timers) do
            if timer.id == eData[2] then
                timer.func()
            end
        end
    end
end
timersManager.handler = handler

return timersManager