local function cutString(str, maxLength)
    if #str > maxLength then
        return string.sub(str, 1, maxLength)
    else
        return str
    end
end

local function rotateArray(array)
    local reversed = {}
    local keyMap = {}
    local keys = {}
    for key in pairs(array) do
        if type(key) == "number" then
            table.insert(keys, key)
        end
    end
    table.sort(keys, function(a, b) return a > b end)
    for i, oldKey in ipairs(keys) do
        reversed[i] = array[oldKey]
        keyMap[i] = oldKey
    end

    return reversed, keyMap
end

local findIndex = function(table,number)
    for i,v in pairs(table)do
        if v==number then return i end
    end
end

return function(TupoyOS,myGUI)
    TupoyOS.windows = {}
    TupoyOS.windowsDrawingOrder = {}
    TupoyOS.windowsCount = 0
    
    TupoyOS.isReadyToDrag = {false}
    TupoyOS.isReadyToResize = {false}

    TupoyOS.taskBarItems = {}
    TupoyOS.activeWindowID = nil

    

    TupoyOS.addRandomWindow = function(self)
        self.windowsCount = self.windowsCount+1

        table.insert(self.windows,{
            isHaveBorder = true,
            isShowing = true,
            isMaximize = false,
            pos = {
                x=math.random(2, 20),
                y=math.random(2, 20),
            },
            size = {
                width = math.random(20, 30),
                height = math.random(4, 13),
            },
            borderColor = colors.lightGray,
            backroundColor = colors.white,
            windowName = self.windowsCount.." Window",
            content = {
                {
                    1,2,2,3,3,colors.blue
                }
            },
            touchHandlers = {
                {
                    function (x,y)
                        
                    end
                }
            }
        })
        local windowID = # self.windows
        table.insert(self.windowsDrawingOrder, windowID)

        self:addTaskbarItem(windowID)
    end

    TupoyOS.addDesktop = function(self)
        self.windowsCount = self.windowsCount+1
        self.isMaximize = true
        local tWidth,tHeight = term.getSize()

        table.insert(self.windows,{
            isHaveBorder = false;
            pos = {
                x=1,
                y=1
            },
            size = {
                width = tWidth,
                height = tHeight-1,
            },
            borderColor = colors.lightGray,
            backroundColor = colors.pink,
            windowName = "Desktop",
            content = {
                {
                    1,2,2,3,3,colors.red
                }
            }
        })
        local windowID = # self.windows
        table.insert(self.windowsDrawingOrder, windowID)

        self:addTaskbarItem(windowID)
    end

    TupoyOS.addTaskbarItem = function(self,windowID)
        local termX,termY=term.getSize()
        local x_offset = 5
        local elementSpaces = 2
        local elementWidth = 5
        local size
        table.insert(self.taskBarItems,{
            targetWindowID = # self.windows,
            button = {
                x_offset + (#self.taskBarItems * (elementWidth+elementSpaces)),
                termY,
                x_offset+ ((#self.taskBarItems+1) * (elementWidth+elementSpaces)-elementSpaces)-1,
                termY
            }
        })
    end

    TupoyOS.windowToFront = function(self,id)
        if self.windows[self.windowsDrawingOrder[id]].windowName~="Desktop" then
            table.insert(self.windowsDrawingOrder, table.remove(self.windowsDrawingOrder, id))
        end
    end

    TupoyOS.printBorder = function(self,window)
        local borderColor = window.borderColor

        --drawRightSide
        local x = window.pos.x+window.size.width
        for i = window.pos.y, window.pos.y+window.size.height-1 do
            myGUI:drawPixel (x,i,borderColor,window.backroundColor,"\149")
        end
        --drawLeftSide
        local x = window.pos.x-1
        for i = window.pos.y, window.pos.y+window.size.height-1 do
            myGUI:drawPixel (x,i,borderColor,window.backroundColor,"\149",true)
        end
        --drawUpSide
        local y = window.pos.y-1
        for i = window.pos.x-1, window.pos.x+window.size.width do
            myGUI:drawPixel (i,y,nil,borderColor,"\143",true)
        end
        --drawDownSide
        local y = window.pos.y+window.size.height
        for i = window.pos.x, window.pos.x+window.size.width-1 do
            myGUI:drawPixel (i,y,window.backroundColor,borderColor,"\143",true)
        end

        --drawleftDownCorner
        myGUI:drawPixel (
            window.pos.x-1,
            window.pos.y+window.size.height,
            borderColor,
            window.backroundColor,
            "\138"
        )
        --drawRightDownCorner
        myGUI:drawPixel (
            window.pos.x+window.size.width,
            window.pos.y+window.size.height,
            borderColor,
            window.backroundColor,
            "\133"
        )


        local labelPos = {x= window.pos.x, y= window.pos.y-1}
        --drawLabelRoundingLeft
        myGUI:drawPixel (
            labelPos.x-1,
            labelPos.y,
            borderColor,
            nil,
            "\129"
        )
        --drawLabel
        myGUI:write(labelPos.x,labelPos.y,window.windowName,borderColor,colors.black)
        --drawLabelRoundingRight
        myGUI:drawPixel (
            labelPos.x+ #window.windowName,
            labelPos.y,
            borderColor,
            nil,
            "\130"
        )

        local menuPos = {x=window.pos.x+window.size.width-5, y=window.pos.y-1,}
        --drawLabelRoundingLeft
        myGUI:drawPixel (
            menuPos.x-1,
            menuPos.y,
            borderColor,
            nil,
            "\129"
        )
        --drawLabel
        myGUI:write(menuPos.x,menuPos.y,"- "..(window.isMaximize and"\31"or"\30").." \215",borderColor,colors.black)
        --drawLabelRoundingRight
        myGUI:drawPixel (
            menuPos.x+5,
            menuPos.y,
            borderColor,
            nil,
            "\130"
        )
    end

    TupoyOS.printWindow = function(self,window)
        --drawInsise
        myGUI:drawFilledBox(
            window.pos.x,
            window.pos.y,
            window.pos.x+window.size.width-1,
            window.pos.y+window.size.height-1,
            window.backroundColor
        )
        for i,v in pairs(window.content)do
            if v[1]==1 then
                -- Корректируем 1-е и 3-е числа (x-координаты)
                local x1 = math.max(window.pos.x, math.min(v[2] + window.pos.x - 1, window.size.width + window.pos.x))
                local x2 = math.max(window.pos.x, math.min(v[2] + v[4] + window.pos.x - 1, window.size.width + window.pos.x))

                -- Корректируем 2-е и 4-е числа (y-координаты)
                local y1 = math.max(window.pos.y, math.min(v[3] + window.pos.y - 1, window.size.height + window.pos.y))
                local y2 = math.max(window.pos.y, math.min(v[3] + v[5] + window.pos.y - 1, window.size.height + window.pos.y))

                -- Вызываем функцию с подогнанными значениями
                paintutils.drawFilledBox(x1, y1, x2, y2, v[6])
            end
        end
        if window.isHaveBorder then
            self:printBorder(window)
        end
    end

    TupoyOS.printWindows = function(self)
        for i,windowID in pairs( self.windowsDrawingOrder) do
            if self.windows[windowID].isShowing == true then
                self:printWindow(self.windows[windowID])
            end
        end
    end

    TupoyOS.isReadyToResizeCheck = function(self,x,y)
        local rotatedArray, indexMap = rotateArray(self.windowsDrawingOrder)
        for i,wID in pairs(rotatedArray) do
            
            local w = self.windows[wID]
            if w.isShowing then
                if w.isHaveBorder then
                    if x>=w.pos.x-1 and 
                        x<=w.pos.x+w.size.width and
                        y>=w.pos.y-1 and 
                        y<=w.pos.y+w.size.height
                    then
                        local targetWindowID = self.windowsDrawingOrder[indexMap[i]]
                        --if ckicked to up window interface then return 
                        if w.pos.y - 1 == y and x == w.pos.x-1 then
                            return({true,targetWindowID,"upL",x,y,w.size.width,w.size.height,w.pos.x,w.pos.y})
                        end
                        if w.pos.y - 1 == y and x == w.pos.x+w.size.width then
                            return({true,targetWindowID,"upR",x,y,w.size.width,w.size.height,w.pos.x,w.pos.y})
                        end
                        if w.pos.y +w.size.height == y and x == w.pos.x-1 then
                            return({true,targetWindowID,"downL",x,y,w.size.width,w.size.height,w.pos.x,w.pos.y})
                        end
                        if w.pos.y +w.size.height == y and x == w.pos.x+w.size.width then
                            return({true,targetWindowID,"downR",x,y,w.size.width,w.size.height,w.pos.x,w.pos.y})
                        end

                        return {false}
                    end
                end
            end
        end
        return {false}
    end

    TupoyOS.isReadyToDragCheck = function(self, x, y)
        local rotatedArray, indexMap = rotateArray(self.windowsDrawingOrder)
        for i,wID in pairs(rotatedArray) do
            local w = self.windows[wID]
            if w.isShowing then
                if w.isHaveBorder then
                    --check ckicked to window. then not check next
                    if x>=w.pos.x-1 and 
                        x<=w.pos.x+w.size.width and
                        y>=w.pos.y-1 and 
                        y<=w.pos.y+w.size.height
                    then
                        --if ckicked to up window interface then return 
                        if w.pos.y - 1 == y and x >= w.pos.x and x <= (w.pos.x - 1 + w.size.width) then
                            local offsetX = x - (w.pos.x - 1)-1
                            local offsetY = 1
                            return {true, self.windowsDrawingOrder[indexMap[i]], -offsetX, offsetY}
                        end
                        return {false}
                    end
                end
            end
        end
        return {false}
    end

    TupoyOS.printTaskBar = function(self)
        local termX,termY=term.getSize()

        --drawLogo

        local tBarY = termY
        myGUI:drawPixel (
            1,
            tBarY,
            colors.blue,
            colors.orange,
            "\210"
        )
        myGUI:drawPixel (
            2,
            tBarY,
            colors.yellow,
            colors.green,
            "\211"
        )
        
        --drawLine
        term.setCursorPos(3,tBarY)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        term.write(string.rep(" ", termX-2))

        for i,v in pairs(self.taskBarItems) do
            -- paintutils.drawBox(
            --     v.button[1],
            --     v.button[2],
            --     v.button[3],
            --     v.button[4],
            --     colors.lightGray
            -- )
            term.setCursorPos(v.button[1],v.button[2])
            term.setBackgroundColor(self.windows[v.targetWindowID].borderColor)
            term.write(cutString(self.windows[v.targetWindowID].windowName,5))
        end
    end

    TupoyOS.render = function(self)
        myGUI:clear()
        self:printWindows()
        self:printTaskBar()
    end

    TupoyOS.setActiveWindow = function(self,newActiveWindowID)
        if self.activeWindowID ~=nil then
            self.windows[self.activeWindowID].borderColor = colors.lightGray
        end
        self.windows[newActiveWindowID].borderColor = colors.blue
        self.windows[newActiveWindowID].isShowing= true
        self.activeWindowID = newActiveWindowID
    end

    TupoyOS.activeWindowToFront = function(self,x,y)
        local rotatedArray, indexMap = rotateArray(self.windowsDrawingOrder)
        for i , wID in pairs(rotatedArray) do
            local w = self.windows[wID]
            if w.isShowing then
                if w.isHaveBorder then
                    if x>=w.pos.x-1 and 
                        x<=w.pos.x+w.size.width and
                        y>=w.pos.y-1 and 
                        y<=w.pos.y+w.size.height
                    then
                        
                        self:setActiveWindow(self.windowsDrawingOrder[indexMap[i]])
                        self:windowToFront(indexMap[i])
                        break
                    end
                else
                    if x>=w.pos.x and 
                        x<=w.pos.x+w.size.width-1 and
                        y>=w.pos.y and 
                        y<=w.pos.y+w.size.height-1
                    then
                        
                        self:setActiveWindow(self.windowsDrawingOrder[indexMap[i]])
                        self:windowToFront(indexMap[i])
                        break
                    end
                end
            end
        end
    end

    TupoyOS.updateInWindowTouchesHandlers = function (self,x,y)
        local rotatedArray, indexMap = rotateArray(self.windowsDrawingOrder)
        for i , wID in pairs(rotatedArray) do
            local w = self.windows[wID]
            if x>=w.pos.x-1 and 
                x<=w.pos.x+w.size.width and
                y>=w.pos.y-1 and 
                y<=w.pos.y+w.size.height
            then
                if x>=w.pos.x and 
                    x<=w.pos.x+w.size.width-1 and
                    y>=w.pos.y and 
                    y<=w.pos.y+w.size.height-1
                then
                    
                    local inWindowX = x-w.pos.x+1
                    local inWindowY = y-w.pos.y+1
                    --myGUI:monitorOut("x:"..inWindowX.." y:"..inWindowY)
                    break
                end
                local inWindowX = x-w.pos.x+1
                local inWindowY = y-w.pos.y+1

                if inWindowX==w.size.width-4 then
                    w.isShowing=false
                end
                if inWindowX==w.size.width-2 then
                    if not w.isMaximize then 
                        w.beforeMaxWidth = w.size.width
                        w.beforeMaxHeight = w.size.height

                        w.beforeMaxX= w.pos.x
                        w.beforeMaxY = w.pos.y

                        w.beforeMax = w.size
                        

                        w.pos.x=1
                        w.pos.y=2
                        local tWidth,tHeight = term.getSize()
                        
                        w.size.width = tWidth
                        w.size.height=tHeight

                        w.isMaximize = true
                    else
                        
                        w.size.width = w.beforeMaxWidth
                        w.size.height = w.beforeMaxHeight

                        w.pos.x = w.beforeMaxX
                        w.pos.y = w.beforeMaxY

                        w.isMaximize = false
                    end
                end
                break
            end
        end
    end

    TupoyOS.taskbarUpdate = function(self,x,y)
        for i,v in pairs(self.taskBarItems) do
            if x>=v.button[1] and x<=v.button[3] and y>=v.button[2] and y<=v.button[4] then
                self:windowToFront(findIndex(self.windowsDrawingOrder,v.targetWindowID))
                self:setActiveWindow(v.targetWindowID)
                --monitorOut("clicked in "..self.windows[v.targetWindowID].windowName)
            end
        end
    end

    TupoyOS:addEventHandler({"mouse window drag handler",function(eData)
        if eData[1] == "mouse_drag" then
            local x,y = eData[3],eData[4]

            if TupoyOS.isReadyToDrag[1] then
                local w = TupoyOS.windows[TupoyOS.isReadyToDrag[2]]
                if w.isMaximize then
                    w.isMaximize = false
                    w.size.width = w.beforeMaxWidth
                    w.size.height = w.beforeMaxHeight
                end
                TupoyOS.windows[TupoyOS.isReadyToDrag[2]].pos.x= x + TupoyOS.isReadyToDrag[3]
                TupoyOS.windows[TupoyOS.isReadyToDrag[2]].pos.y= y + TupoyOS.isReadyToDrag[4]
            end
            if TupoyOS.isReadyToResize[1] then

                local window = TupoyOS.windows[TupoyOS.isReadyToResize[2]]

                local changeX = x-TupoyOS.isReadyToResize[4]
                local changeY = y-TupoyOS.isReadyToResize[5]

                if TupoyOS.isReadyToResize[3]=="downR" then
                    window.size.width= TupoyOS.isReadyToResize[6]+changeX
                    window.size.height= TupoyOS.isReadyToResize[7]+changeY
                end

                if TupoyOS.isReadyToResize[3]=="upR" then
                    window.pos.y = TupoyOS.isReadyToResize[9]+changeY
                    window.size.width= TupoyOS.isReadyToResize[6]+changeX
                    window.size.height= TupoyOS.isReadyToResize[7]-changeY
                end

                if TupoyOS.isReadyToResize[3]=="upL" then
                    window.pos.y = TupoyOS.isReadyToResize[9]+changeY
                    window.pos.x = TupoyOS.isReadyToResize[8]+changeX
                    window.size.width= TupoyOS.isReadyToResize[6]-changeX
                    window.size.height= TupoyOS.isReadyToResize[7]-changeY
                end

                if TupoyOS.isReadyToResize[3]=="downL" then
                    window.pos.x = TupoyOS.isReadyToResize[8]+changeX
                    window.size.width= TupoyOS.isReadyToResize[6]-changeX
                    window.size.height= TupoyOS.isReadyToResize[7]+changeY
                end

            end
        end
    end})

    TupoyOS:addEventHandler({"mouse window click handler",function(eData)
        if eData[1]== "mouse_click" then
            local x,y=eData[3],eData[4]
            
            TupoyOS:activeWindowToFront(x,y)
            TupoyOS.isReadyToDrag = TupoyOS:isReadyToDragCheck(x,y)
            TupoyOS.isReadyToResize = TupoyOS:isReadyToResizeCheck(x,y)

            TupoyOS:taskbarUpdate(x,y)
            
        end
    end})

    TupoyOS:addEventHandler({"mouse in windows click handler",function(eData)
        if eData[1]== "mouse_click" then
            local x,y=eData[3],eData[4]
            
            TupoyOS:updateInWindowTouchesHandlers(x,y)
            
        end
    end})



end