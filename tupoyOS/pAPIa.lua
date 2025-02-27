--Program API Advansed
local pAPI = dofile("tupoyOS/pAPI.lua")
local compAPI = dofile("tupoyOS/componentsAPI.lua")

return {
    compAPI = compAPI,
    logWindow = nil,
    logs = {},

    layouts = {
        fillLayoutManager = function(father, childs)
            for index, child in pairs(childs) do
                child.pos = {x=1,y=1}
                child.size = father.size
            end
        end,
        
        fillWithIndentLayoutManager = function(father, childs)
            for index, child in pairs(childs) do
                child.pos = {x=2,y=2}
                child.size = {x=father.size.x-2,y=father.size.y-2}
            end
        end
    },

    windows = {},
    createWindow = function(self,args)
        local id = pAPI:createWindow()

        local window = self.compAPI:createComponent()
        window.windowID = id
        window.layoutManager = self.layouts.fillWithIndentLayoutManager
        window.size:addListener(function (resizeEvent)
            if resizeEvent.newSize.isOSRequest~= nil and resizeEvent.newSize.isOSRequest == true then
                return
            end
            pAPI:setContentSize(window.windowID,resizeEvent.newSize)
        end)
        window.pos:addListener(function (posEvent)
            pAPI:setContentPos(window.windowID,posEvent.newPos)
        end)

        if args~=nil then
            if args.pos~=nil then
                window.pos:set(args.pos)
            end
            if args.size~=nil then
                window.size:set(args.size)
            end
            if args.title~=nil then
                pAPI:setWindowTitle(window.windowID,args.title)
            end
        end

        self.windows[id] = window
        return self.windows[id]
    end,

    createComponent = compAPI.createComponent,

    createTText = function(self,args)
        local TText = self:createComponent(args)
        TText.text = "Hello from TText component"
        TText.textColor = colorsChar.black
        TText.textBackroundColor = 0
        TText.bkColor = colorsChar.white
        TText.textPos = "center"
        TText.leftSpace = 0

        if args ~= nil then
            if args.text ~= nil then
                TText.text = args.text
            end
        end

        TText:addCustomPaint(function(display)
            local coloredLine = {
                text = splitString(TText.text),
                tColor = {},
                bkColor = {}
            }

            for i = 1,#coloredLine.text do
                coloredLine.tColor[i]= TText.textColor
                coloredLine.bkColor[i]= TText.textBackroundColor
            end

            local textPos
            if TText.textPos == "center" then
                local TTextSize = TText.size:get()
                textPos = {
                    x=math.max(math.ceil(TTextSize.x/2-(#coloredLine.text / 2)) , 1+TText.leftSpace),
                    y=math.ceil(TTextSize.y/2)
                }
            elseif TText.textPos == "left" then
                
                textPos = {
                    x=1+TText.leftSpace,
                    y=math.ceil(TText.size.y/2)
                }
            
            end
            display:addLine(textPos,coloredLine)
        end)

        
        return TText
    end,

    createTButton = function (self,args)
        local baseComponent = self:createComponent(args)
        return baseComponent
    end,

    createLogWindow = function(self)
        self.logWindow = self:createWindow()
    end,

    log = function(self,text)
        if self.logWindow==nil then
            self:createLogWindow()
        end
        table.insert(self.logs,text)
    end,

    
    eventHystory = {"start"},
    eventCount = 1,

    eventHandlers = {
        windowClickHandler = function(self,message)
            if message.type == "window" then
                if message.info == "window content clicked" then
                    
                    for key, window in pairs(self.windows) do
                        if message.windowID == key then
                            window:triggerMouseListeners(message.mEvent)
                            
                            break
                        end
                    end
                end
            end
        
        end,

        drawWindowsHandler = function(self,message)
            if message.type == "window" then
                if message.info == "paint request" then
                    
                    print("message.windowID is ".. message.windowID)
                    print("windows is ")
                    print("")
                    for windowKey, window in pairs(self.windows) do
                        print(""..windowKey)
                    end
                    print("")
                    self:compSleep(0.2)

                    local windowFound = false
                    for windowKey, window in pairs(self.windows) do
                        if message.windowID == windowKey then
                            local returnMessage = {
                                type = "window",
                                windowID = message.windowID,
                                info = "paint response",
                                data = window:getLines()
                            }
                            coroutine.yield(returnMessage)
                            windowFound = true
                            break
                        end
                    end

                    if not windowFound then
                        print("message.windowID is ".. message.windowID)
                        print("windows is ")
                        print("")
                        for windowKey, window in pairs(self.windows) do
                            print(""..windowKey)
                        end
                        print("")
                        print("window not found")
                        error("window not found")
                    end
                end
            end
        end,
        windowResizeHandler = function(self,message)
            if message.type == "window" then
                if message.info == "size changed" then
                    for key, window in pairs(self.windows) do
                        if message.windowID == key then
                            local newSize = message.newSize
                            newSize.isOSRequest = true
                            window.size:set(message.newSize)

                            break
                        end
                    end
                end
            end
        end,

        timersHandler = function(self,message)
            if message.eData~=nil then
                local event = message.eData
                if event[1] == "timer" then
                    local timerID = event[2]
                    for key , timer in pairs (self.timers) do
                        if timer.id == event[2] then
                            timer.func()
                        end
                    end
                end
            end
        end
    },
    runLoop = function(self)
        while true do
            local message = coroutine.yield({
                type = "done"
            })

            for key,handler in pairs (self.eventHandlers) do
                handler(self,message)
            end
        end
    end,

    getDisplayInfo = function(self)
        return pAPI:getDisplayInfo()
    end,

    timers = {},
    startTimer = function(self,time,func)
        local timerID = os.startTimer(time)
        table.insert(self.timers,{id = timerID,func = func})
    end,
    getAllWindows = function(self)
        local message = coroutine.yield({
            type = "request",
            info = "get all winodws"
        })

        if message.content == nil then
            error("get all windows response is invalid")
        end

        return message.content
    end,
    coroutineSleep = function(self,seconds)
        pAPI:coroutineSleep(seconds)
    end,
    compSleep = function(self,seconds)
        pAPI:compSleep(seconds)
    end,
}