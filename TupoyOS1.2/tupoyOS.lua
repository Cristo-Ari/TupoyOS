dofile("lib.lua")

local term = term

local windowM
local screen
local coroutinesManager

local debugPrint = function(info)
    print(info)
    os.sleep(2)
end

local acolors = {
    white = 'f',
    orange = '0',
    magenta = '2',
    lightBlue = '3',
    yellow = '4',
    lime = '5',
    pink = '6',
    gray = '7',
    lightGray = '8',
    cyan = '9',
    purple = 'a',
    blue = 'b',
    brown = 'c',
    green = 'd',
    red = 'e',
    black = 'f'
}

windowM = {
    windows = {},
    windowOrder = {},
    isReadyToDrag = {},
    isReadyToResize = {},

    add = function(self, x, y, width, height, title, processID)
        local window = {
            processID = processID,
            x = x,
            y = y,
            backround = "0",
            width = width,
            height = height,
            title = title or "Window",
            isFocused = false,
            isMaximized = false
        }
        local key = randStr()
        self.windows[key] = window
        table.insert(self.windowOrder, key)
        os.queueEvent("window_added", key)
        os.queueEvent("windows_paint")
        return key
    end,

    process = function(self, eData)
        if eData[1] == "mouse_click" then
            local button, x, y = eData[2], eData[3], eData[4]
            local foundFocused = false
            for i = #self.windowOrder, 1, -1 do
                local key = self.windowOrder[i]
                local window = self.windows[key]
                if x >= window.x and x <= window.x + window.width - 1 and 
                   y >= window.y and y <= window.y + window.height - 1 then
                    window.isFocused = true
                    foundFocused = true
                    local inWindowX = x - window.x + 1
                    local inWindowY = y - window.y + 1
                    if inWindowY == 1 and inWindowX > 1 and inWindowX < window.width then
                        self.isReadyToDrag = {true, key, inWindowX, inWindowY}
                    else
                        self.isReadyToDrag = {false}
                    end

                    --левый верхний угол
                    if inWindowX == 1 and inWindowY ==1 then
                        self.isReadyToResize = {true,key,"leftUp",x,y,window.width,window.height}
                    --левый нижний угол
                    elseif inWindowX ==1 and inWindowY == window.height then
                        self.isReadyToResize = {true,key,"leftDown",x,y,window.width,window.height}
                    --правый верхний угол
                    elseif inWindowX == window.width and inWindowY == 1 then
                        self.isReadyToResize = {true,key,"rightUp",x,y,window.width,window.height}
                    --правый нижний угол
                    elseif inWindowX == window.width and inWindowY == window.height then
                        self.isReadyToResize = {true,key,"rightDown",x,y,window.width,window.height}
                    
                    else
                        self.isReadyToResize[1] = false
                    end

                    table.remove(self.windowOrder, i)
                    table.insert(self.windowOrder, key)
                    break
                else
                    window.isFocused = false
                end
            end
            if not foundFocused then
                self.isReadyToDrag = {false}
                self.isReadyToResize = {false}
                for _, window in pairs(self.windows) do
                    window.isFocused = false
                end
            end

            os.queueEvent("windows_paint")
        end
        if eData[1] == "mouse_drag" then
            local x, y = eData[3], eData[4]
            if self.isReadyToDrag[1] then
                local wind = self.windows[self.isReadyToDrag[2]]
                wind.x = x - self.isReadyToDrag[3] + 1
                wind.y = y - self.isReadyToDrag[4] + 1

                os.queueEvent("windows_paint")
            end

            if self.isReadyToResize[1] then
                local wind = self.windows[self.isReadyToResize[2]]

                local oldX = self.isReadyToResize[4]
                local oldY = self.isReadyToResize[5]

                local oldWidth = self.isReadyToResize[6]
                local oldHeight = self.isReadyToResize[7]

                local changeX = x- oldX
                local changeY = y- oldY
                
                local maxWidth  = 7 
                local maxHeight = 2

                if self.isReadyToResize[3] == "leftUp" then
                    wind.width = math.max (maxWidth, self.isReadyToResize[6]-changeX)
                    wind.height = math.max (maxHeight, self.isReadyToResize[7]-changeY)

                    wind.x = math.min(oldX+(oldWidth-1) - (wind.width-1),x)
                    wind.y = math.min(oldY+(oldHeight-1) - (wind.height-1),y)
                end

                if self.isReadyToResize[3] == "leftDown" then
                    wind.width = math.max (maxWidth, self.isReadyToResize[6]-changeX)
                    wind.height = math.max (maxHeight, self.isReadyToResize[7]+changeY)

                    wind.x = math.min(oldX+(oldWidth-1) - (wind.width-1),x)
                end

                if self.isReadyToResize[3] == "rightUp" then
                    wind.width = math.max (maxWidth, oldWidth+changeX)
                    wind.height = math.max (maxHeight, oldHeight-changeY)
                    wind.y = math.min(oldY+(oldHeight-2),y)
                end

                if self.isReadyToResize[3] == "rightDown" then
                    wind.width = math.max (maxWidth, oldWidth+changeX)
                    wind.height = math.max (maxHeight, oldHeight+changeY)
                end
                
                os.queueEvent("windows_paint")
            end
        end

        if eData[1] == "windows_paint" then
            self:drawWindows()
        end
    end,

    drawBorder = function(self, window)

        local borderColor = window.isFocused and acolors.lightGray or acolors.gray
        --local vls = window.isFocused and "|" or "\183" -- vertical line symbol
        local vls = "\149" -- vertical line symbol
        --local hls = window.isFocused and "-" or "\183" -- horizontal line symbol
        local hls = "\143"
        local es = window.isFocused and "\4" or "\7" -- edge symbol

        --drawLeftSide
        if window.height>2 then
            screen:drawLine(
                window.x,
                window.y+1,
                window.x,
                window.y+window.height-2,
                vls,
                borderColor,
                window.backround
            )
        end

        --drawRightSide
        if window.height>2 then
            screen:drawLine(
                window.x+window.width-1,
                window.y+1,
                window.x+window.width-1,
                window.y+window.height-2,
                vls,
                window.backround,
                borderColor
            )
        end

        --draw up side
        local titleLenCut = window.width - 5 - 4
        if titleLenCut <0 then
            titleLenCut = 0
        end
        local outTitle = string.sub(window.title, 1, titleLenCut)

        if not (window.width - #outTitle - 9 > 0) then
            outTitle = string.sub((window.title.."                  "), 1, titleLenCut+(window.width>=9 and 1 or 0)+(window.width>=8 and 1 or 0))
        end
    
        local header = "\129" ..
            outTitle .. 
            (window.width - #outTitle - 9 > 0 and "\130" or "")..
            string.rep(hls, window.width - #outTitle - 9) ..
            (window.width - #outTitle - 9 > 0 and "\129" or "")..
            "\131" ..
            " "..
            (window.isMaximized and "\31" or "\30") .. 
            " "..
            "\215" ..
            "\130"
        
        local splittedHeader = splitString(header)
        --splittedHeader[window.width-8] = "\129"

        local tColor = {}
        for i = 1,#splittedHeader do
            tColor[i]=acolors.black
            if splittedHeader[i] == "\129"
            or splittedHeader[i] == "\130"
            or splittedHeader[i] == hls then
                if window.x+i-1 < screen.screenWidth then
                    tColor[i] = screen.screenLines[window.y].bkColor[window.x+i-1]
                end
            end

            if splittedHeader[i] == "\131"
            or splittedHeader[i] == "\30"
            or splittedHeader[i] == "\31"
            or splittedHeader[i] == "\215" then
                --tColor[i] = window.isFocused and acolors.blue or acolors.lightGray
                if window.isFocused then
                    tColor[i] = acolors.blue
                end
            end
        end

        local bkColor = {}
        for i = 1,#splittedHeader do
            bkColor[i]=borderColor
        end
        if (window.width - #outTitle - 9 > 0) then
            for i = #splittedHeader-6,#splittedHeader do
                bkColor[i]=acolors.gray
            end
        else
            for i = #splittedHeader-5,#splittedHeader-1 do
                bkColor[i]=acolors.gray
            end
        end

        local finalLine = {
            text = splittedHeader,
            tColor = tColor,
            bkColor = bkColor
        }

        screen:addLine(finalLine,window.x,window.y)

        --drawDownSide
        local leftDownEdge  = "\138"
        local rightDownEdge  = "\133"

        local footer = leftDownEdge .. string.rep(hls, window.width - 2) .. rightDownEdge
        local splittedFooter = splitString(footer)

        local tColor = {}
        for i = 1,#splittedFooter do
            tColor[i]=window.backround
        end
        local bkColor = {}
        for i = 1,#splittedFooter do
            bkColor[i]=borderColor
        end

        local finalLine = {
            text = splittedFooter,
            tColor = tColor,
            bkColor = bkColor
        }

        screen:addLine(finalLine,window.x,window.y+window.height-1)
    end,

    tryToGetScreenLines = function(self,processID,windowID)
        local cor = coroutinesManager.coroutines[processID]
        if cor == nil then
            return nil, "Process "..processID.." is not exist"
        end

        local status, message = coroutine.resume(cor,{
            type = "window",
            windowID = windowID,
            info = "paint request"
        })

        local windowScreenLines
        if message.type == "window" then
            if message.windowID == windowID then
                if message.info == "paint response" then
                    windowScreenLines = message.data
                end
            end
        end

        return windowScreenLines

        
    end,

    drawContent = function(self,window,wwwiindow)
        local screenLines , error = self:tryToGetScreenLines(window.processID,wwwiindow)
        
        if error == nil then
            local cutScreenLines = cropScreenLines(screenLines,window.width-2,window.height-2)
            screen:addLines(cutScreenLines,window.x+1,window.y+1)
        else
            debugPrint(error)
        end
    end,

    drawBackround = function(self,window)
        screen:drawSquare(
            window.x+1,
            window.y+1,
            window.width-2,
            window.height-2,
            window.backround
        )
    end,

    drawWindows = function(self)
        screen:clear()
        for _, windowKey in ipairs(self.windowOrder) do
            local window = self.windows[windowKey]
            self:drawBackround(window)
            self:drawBorder(window)
            self:drawContent(window,windowKey)
        end
        screen:print()
    end
}

coroutinesManager = {
    coroutines = {},
    add = function(self, func)
        local key = randStr()
        self.coroutines[key] = coroutine.create(func)
        return key
    end,
    process = function(self,eData)
        -- print("handler computed")
        -- os.sleep(0.15)
        for processID, cor in pairs(self.coroutines) do
            local eventMessage = {
                type = "event",
                eData = eData
            }
            local sendingMessage = eventMessage
            repeat
                local status, message = coroutine.resume(cor,sendingMessage)

                -- print(textutils.serialise(message))
                -- os.sleep(0.5)

                if message.type == "request" then
                    if message.info == "create window" then
                        local windowKey = windowM:add(
                            math.random(1, 20),
                            math.random(1, 10),
                            20,
                            4,
                            "Window 14442343",
                            processID)

                        sendingMessage ={
                            type = "window",
                            info = "create window response",
                            data = windowKey
                        }
                    end
                    -- print(message.info)
                    -- os.sleep(1)
                    if message.info == "change window title" then
                        windowM.windows[message.windowID].title = message.title
                        -- local status, message = coroutine.resume(cor,{
                        --     type = "window",
                        --     info = "change title window response"
                        -- })
                        
                    end

                    if message.info == "get display info" then
                        local x,y = term.getSize()
                        local status, message = coroutine.resume(cor,{
                            type = "response",
                            info = "change title window response"
                        })
                        
                    end

                end


                if not status then
                    error("Coroutine error: " .. tostring(message))
                end
            until message.type == "done"
        end
    end
}

screen = {
    screenLines = {},
    screenWidth = term.getSize(),
    screenHeight = select(2, term.getSize()),
    bkColor = colors.black;

    -- Очищаем экран
    clear = function(self)
        self.screenLines = {}
        for y = 1, self.screenHeight do
            self.screenLines[y] = {
                text = {},
                tColor = {},
                bkColor = {},
                bkInverted = {}
            }
            for i = 1, self.screenWidth do
                self.screenLines[y].text[i] = " "
                self.screenLines[y].tColor[i] = "0"
                self.screenLines[y].bkColor[i] = acolors.black
                self.screenLines[y].bkInverted[i] = false
            end
        end
    end,

    -- Печать содержимого экрана
    print = function(self)
        for y = 1, self.screenHeight do
            term.setCursorPos(1, y)
            local line = self.screenLines[y]
            if line then
                term.blit(
                    table.concat(line.text),
                    table.concat(line.tColor),
                    table.concat(line.bkColor)
                )
            end
        end
    end,

    drawPixel = function(self,x,y,text,tColor,bkColor)
        if y < 1 or y > self.screenHeight or x<1 or x>self.screenWidth then
            return
        end
        if type(text) == "string" then
            self.screenLines[y].text[x] = text
        end

        -- if invertBackround == true and not self.screenLines[y].bkInverted[x] then
        --     local backroundTemp = self.screenLines[y].bkColor[x]
        --     self.screenLines[y].bkColor[x] = self.screenLines[y].tColor[x]
        --     self.screenLines[y].tColor[x] = backroundTemp

        --     self.screenLines[y].bkInverted[x] = true
        -- end


        if type(tColor) == "string" then
            self.screenLines[y].tColor[x] = tColor
        end
        if type(bkColor) == "string" then
            self.screenLines[y].bkColor[x] = bkColor
        end
    end,

    drawLine = function(self,x1,y1,x2,y2,text,tColor,bkColor)
        for i, point in ipairs(getLine(x1, y1, x2, y2)) do
            self:drawPixel(point.x,point.y,text,tColor,bkColor)
        end
    end,

    drawSquare = function(self,x,y,width,height,color)
        local lines = {}
        for i = 1,height do
            local line = {
                text = {},
                tColor = {},
                bkColor = {}
            }

            for d = 1,width do
                line.text[d]=" "
                line.tColor[d]=color
                line.bkColor[d]=color
            end
            lines[i]=line
        end
        self:addLines(lines,x,y)
    end,

    -- Добавляем строку в указанную позицию
    addLine = function(self, anotherLine, x, y)
        if y < 1 or y > self.screenHeight then
            return
        end

        local lineLength = #anotherLine.text
        local maxX = math.min(x + lineLength - 1, self.screenWidth)

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

    addLines = function(self, anotherLines,x,y)
        for i, line in ipairs(anotherLines) do
            self:addLine(line, x, y + i - 1)
        end
    end
}

screen:clear()

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

        --mainLoop
        while self.isRunning do
            self.eventHandlers:process({os.pullEventRaw()})
        end
    end
}


-- windowM:add(math.random(1, 20), math.random(1, 10), 20, 4, "Window 1")
-- windowM:add(math.random(1, 20), math.random(1, 10), 20, 4, "Window 2")
-- windowM:add(math.random(1, 20), math.random(1, 10), 20, 4, "Window 3")

--coroutinesManager:add(dofile("erp.lua"))
--coroutinesManager:add(dofile("exampleProgram.lua"))
--coroutinesManager:add(dofile("exampleProgram.lua"))
--coroutinesManager:add(dofile("exampleProgram.lua"))
coroutinesManager:add(dofile("taskbar.lua"))


tupoyOS:mainLoop()
