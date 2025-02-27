dofile("tupoyOS/lib.lua")

local windowM = dofile("tupoyOS/windowM.lua")
local coroutinesManager = dofile("tupoyOS/coroutineM.lua")

windowM.coroutinesManager = coroutinesManager
coroutinesManager.windowM = windowM

local timersManager = dofile("tupoyOS/timersManager.lua")

local tupoyOS = {
    isRunning = true,
    eventHandlers = {
        handlers = {},
        add = function(self, func)
            local key = randStr()
            self.handlers[key] = func
            return key
        end,
        remove = function(self, key)
            if self.handlers[key] then
                self.handlers[key] = nil
                return true
            end
            return false
        end,
        process = function(self, eData)
            for _, v in pairs(self.handlers) do
                v(eData)
            end
        end
    },

    mainLoop = function(self)
        --terminate event
        self.eventHandlers:add(function(eData)
            if eData[1] == "terminate" then
                self.isRunning = false
            end
        end)
        --updateWindowEvent
        self.eventHandlers:add(function(eData)
            windowM:process(eData)
        end)

        self.eventHandlers:add(function(eData)
            coroutinesManager:process(eData)
        end)

        --я не знаю как сделать обновление экрана в начале выполнения прогарммы лучше
        timersManager:startTimer(0,function()
            os.queueEvent("windows_paint")
        end)

        self.eventHandlers:add(timersManager.handler)

        --mainLoop
        while self.isRunning do
            self.eventHandlers:process({os.pullEventRaw()})
        end
    end
}


-- coroutinesManager:add(dofile("tupoyOS/apps/taskbar.lua"))
-- coroutinesManager:add(dofile("tupoyOS/apps/explorer.lua"))
-- coroutinesManager:add(dofile("tupoyOS/apps/explorer.lua"))
-- coroutinesManager:add(dofile("tupoyOS/apps/desktop.lua"))
coroutinesManager:add(dofile("tupoyOS/apps/paint.lua"))
-- coroutinesManager:add(dofile("tupoyOS/apps/paint.lua"))
-- coroutinesManager:add(dofile("tupoyOS/apps/paint.lua"))

tupoyOS:mainLoop()
