--Program API Advansed
local pAPI = dofile("pAPI.lua")

return {

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
        local id = pAPI:createWindow(args)

        local window = self:createComponent(args)
        window.windowID = id
        window.layoutManager = self.layouts.fillWithIndentLayoutManager

        self.windows[id] = window
        return self.windows[id]
    end,

    createComponent = function (self,args)
        local comp = {
            isGhost = false,

            layoutManager = fillLayoutManager,
            resizeListners = {},
            addResizeListener = function(self,resizeListener)
                table.insert(self.resizeListners, resizeListener)
            end,

            mouseListeners = {},
            addMouseListener = function(self,mouseListener)
                table.insert(self.mouseListeners, mouseListener)
            end,
            triggerMouseListeners = function(self,event)
                local x = event.x
                local y = event.y

                local clickedInsideComponent = false

                --проверить все компоненты. если кликнул на компонент, тогда не вызывать свои обработчики
                for key, comp in pairs (self.components) do
                    if x>=comp.pos.x and 
                        x<comp.pos.x+comp.size.x and
                        y>=comp.pos.y and
                        y<comp.pos.y+comp.size.y then

                        comp:triggerMouseListeners({
                            type = event.type,
                            x = event.x-comp.pos.x+1,
                            y = event.y-comp.pos.y+1,
                        })
                        clickedInsideComponent = true
                        break
                    end
                end

                --пройтись по всем компонентам
                if self.whenClickedToInternalComponentsIgnoreLiseners then
                    if not clickedInsideComponent then
                        for key,mListener in pairs(self.mouseListeners) do
                            mListener(event)
                        end
                    end
                else
                    for key,mListener in pairs(self.mouseListeners) do
                        mListener(event)
                    end
                end 
                
            end,

            customPaints = {},
            addCustomPaint = function(self, customPaint)
                table.insert(self.customPaints,customPaint)
            end,
            
            whenClickedToInternalComponentsIgnoreLiseners = false,

            components = {},
            display = {
                screenLines = generateFilledScreen({x=10,y=10},_,_,"6"),
                changeBackroundColor = function (self,bkColor)
                    for i = 1, #self.screenLines do
                        local line = self.screenLines[i]
                        for j = 1, #line.bkColor do
                            self.screenLines[i].bkColor[j]=bkColor
                        end
                    end
                end,

                -- Добавляем строку в указанную позицию
                addLine = function(self, pos, anotherLine)
                    if pos.y < 1 or pos.y > #self.screenLines then
                        return
                    end

                    local lineLength = #anotherLine.text
                    local x = pos.x
                    local y = pos.y
                    local maxX = math.min(x + lineLength - 1, #self.screenLines[1].text)

                    for i = x, maxX do
                        local textValue = anotherLine.text[i - x + 1]
                        local tColorValue = anotherLine.tColor[i - x + 1]
                        local bkColorValue = anotherLine.bkColor[i - x + 1]
                        if type(textValue) == "string" then
                            self.screenLines[y].text[i] = textValue
                        end
                        if type(tColorValue) == "string" then
                            self.screenLines[y].tColor[i] = tColorValue
                        end
                        if type(bkColorValue) == "string" then
                            self.screenLines[y].bkColor[i] = bkColorValue
                        end
                    end
                end,

                addLines = function(self,pos,anotherLines)
                    for i, line in ipairs(anotherLines) do
                        self:addLine({x=pos.x,y=pos.y + i - 1},line)
                    end
                end,

                drawText = function(self,x,y,text,tColor,bkColor)
                    bkColor = bkColor==nil and "8" or bkColor
                    tColor = tColor==nil and "1" or tColor
                    local splittedText = splitString(text)
                    for key, char in pairs(splittedText) do
                        if y<=#self.screenLines then
                            local targetX = key+x
                            if targetX <= #self.screenLines[y].text then
                                self.screenLines[y].text[targetX] = char
                                self.screenLines[y].tColor[targetX]  = tColor
                                self.screenLines[y].bkColor[targetX]  = bkColor
                            end

                        end
                    end
                end
            },

            getLines = function(self)
                self.display.screenLines = generateFilledScreen(self.size," ","1",self.bkColor)

                if self.layoutManager ~= nil then
                    self.layoutManager(self,self.components)
                end

                for key,customPaints in pairs(self.customPaints)do
                    customPaints(self.display)
                end

                for key, component in pairs(self.components) do
                    self.display:addLines(
                        component.pos,
                        component:getLines()
                    )
                end
                return self.display.screenLines
            end,
            pos = {
                x=3,
                y=3
            },
            size = {
                x = 10,
                y = 10
            },
            bkColor = "1",
            add = function (self, comp)
                table.insert(self.components,comp)
            end,
        }

        comp:addResizeListener(function(resizeParam)
            comp.size = resizeParam.newSize
        end)

        if args ~= nil then
            if args.pos ~= nil then
                comp.pos = args.pos
            end
            if args.size ~= nil then
                comp.size = args.size
            end
            if args.bkColor ~= nil then
                comp.bkColor = args.bkColor
            end
        end

        return comp
    end,

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
                textPos = {
                    x=math.max(math.ceil(TText.size.x/2-(#coloredLine.text / 2)) , 1+TText.leftSpace),
                    y=math.ceil(TText.size.y/2)
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

    
    eventHystory = {"start"},
    eventCount = 1,

    eventHandlers = {
        windowClickHandler = function(self,message)
        
            if message.eData~=nil then 
                --click mouse down event
                if message.eData[1]=="wind mouse down" then
                    local clickDetail = message.eData[2]
    
                    --checkEveryWindow
                    for key, window in pairs(self.windows) do
                        
                        if clickDetail.windowID == key then
                            local mouseEvent = {
                                type = clickDetail.type,
                                scrollValue = clickDetail.scrollValue,
                                x = clickDetail.x,
                                y = clickDetail.y,
                            }
                            
                            window:triggerMouseListeners(mouseEvent)
                            --callAllMouseListenersInWindow
                            -- for key, listener in pairs(window.mouseListeners) do
                            --     listener({
                            --         type = "mouse down",
                            --         x = clickDetail.x,
                            --         y = clickDetail.y,
                            --     })
                            -- end
                        end
                    end
                end
    
                --resize event
                if message.eData[1]=="wind resize" then
                    local resizeDetail = message.eData[2]
    
                    --checkEveryWindow
                    for key, window in pairs(self.windows) do
                        
                        if resizeDetail.windowID == key then
                            
                            --callAllMouseListenersInWindow
                            for key, listener in pairs(window.resizeListners) do
                                listener({
                                    newSize = {
                                        x = resizeDetail.newSizeX,
                                        y = resizeDetail.newSizeY
                                    }
                                })
                            end
    
                            break
                        end
                    end
                end
            end
        end,

        drawWindowsHandler = function(self,message)
            if message.type == "window" then
                if message.info == "paint request" then
                    for windowKey, window in pairs(self.windows) do
                        if message.windowID == windowKey then
                            local returnMessage = {
                                type = "window",
                                windowID = message.windowID,
                                info = "paint response",
                                data = window:getLines()
                            }
                            coroutine.yield(returnMessage)
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
    end
}