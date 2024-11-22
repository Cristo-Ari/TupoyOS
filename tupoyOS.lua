local term = term
local colors = colors
local peripheral = peripheral
local os = os
local paintutils = paintutils

local TupoyOS = {
    eventHandlers = {},
    --handlerStructure = {"what handlers do", function(eData)end}

    addEventHandler = function(self, handler)
        table.insert(self.eventHandlers, handler)
    end,

    processes = {},
    corUpdateTimerID = nil,
    coroutineUpdateDelay = 1,
    startCoroutineUpdateTLoop = function(self)
        self.corUpdateTimerID = os.startTimer(self.coroutineUpdateDelay)
    end,
    addProcess = function(self, filePath)
        table.insert(self.processes, {
            cor = coroutine.create(dofile(filePath)),
            name = "helloProgramm",
            status = "starting",
            iGetEvent = false
        })
    end,
    removeProcess = function(self, key)
        self.coroutines[key] = nil
    end,
    updateProcesses = function(self)
        for i, v in pairs(self.coroutines) do
            if not v.iGetEvent then
                packet = {
                    ["osAPI"] = self.osAPI
                }
                
                isComplete, corRequire = coroutine.resume(v.cor, packet)

                if corRequire == "iGetEvent" then
                    v.iGetEvent = true
                    break
                end
            
                if coroutine.status(v.cor) == "dead" then
                    self:removeCor(i)
                end
            end
        end
        self.corUpdateTimerID = os.startTimer(self.coroutineUpdateDelay)
    end,

    mainLoop = function(self)
        while true do 
            local eData = {os.pullEventRaw()}

            for i,v in pairs(self.eventHandlers)do
                v[2](eData)
            end

            if eData[1] == "terminate" then
                clearScreen()
                break
            end
            

            self:render()
        end
    end,
}
local myGUI = dofile("myGUI.lua")
dofile("addWindowsModule.lua")(TupoyOS,myGUI)
dofile("addCoroutineModule.lua")(TupoyOS)

TupoyOS:addDesktop()
TupoyOS:addRandomWindow()
TupoyOS:addRandomWindow()
TupoyOS:addRandomWindow()

TupoyOS:mainLoop()
