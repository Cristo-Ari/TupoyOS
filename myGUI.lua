local BlitToNum = {
    ["0"] = 1,
    ["1"] = 2,
    ["2"] = 4,
    ["3"] = 8,
    ["4"] = 16,
    ["5"] = 32,
    ["6"] = 64,
    ["7"] = 128,
    ["8"] = 256,
    ["9"] = 512, 
    a = 1024,
    b = 2048,
    c = 4096,
    d = 8192,
    e = 16384,
    f = 32768,
}

return({
    monitorOut = function(self,input)
        local monitor = peripheral.find("monitor")

        if not monitor then
            return nil
        end

        monitor.setTextScale(1) -- Масштаб текста
        monitor.clear()
        monitor.setCursorPos(1, 1)
        local bgColor = colors.black
        local textColor = colors.white
        monitor.setBackgroundColor(bgColor)
        monitor.setTextColor(textColor)
        local function writeToMonitor(text)
            local x, y = monitor.getCursorPos()
            local width, height = monitor.getSize()
            if y > height then
                monitor.clear()
                monitor.setCursorPos(1, 1)
                y = 1
            end
            monitor.setCursorPos(1, y)
            monitor.write(text)
            monitor.setCursorPos(1, y + 1)
        end

        writeToMonitor(input)
    end,

    write = function(self,x,y,text,bkColor,textColor)
        term.setBackgroundColor(bkColor)
        term.setTextColor(textColor)
        term.setCursorPos(x,y)
        term.write(text)
        for crtX = x,x+#text-1 do
            self.screen.backround[y][crtX]=bkColor
        end
    end,
    drawFilledBox = function(self,x1,y1,x2,y2,color)
        paintutils.drawFilledBox(x1,y1,x2,y2,color)
        for y = y1,y2 do
            for x=x1,x2 do
                self.screen.backround[y][x]=color
            end
        end
    end,
    clear = function(self)
        term.setBackgroundColor(colors.black)
        term.clear()

        local termX,termY=term.getSize()

        for y=1,termX do
            self.screen.backround[y]={}
            for x=1,termY do
                self.screen.backround[y][x]=colors.black
            end
        end
    end,
    screen = {
        backround = {
            
        }
    },
    drawPixel = function(self, x,y,bkColor,textColor,symbol,isInvertedColor)
        local width,height = term.getSize()
        if x <= width and y<= height then
            if isInvertedColor == false or isInvertedColor==nil then
                if bkColor == nil then
                    term.setBackgroundColor(self:getBackgroundOfPixel(x,y))
                else
                    term.setBackgroundColor(bkColor)
                end
                
                if textColor == nil then
                    term.setTextColor(self:getBackgroundOfPixel(x,y))
                else
                    term.setTextColor(textColor)
                end
            else
                if textColor == nil then
                    term.setBackgroundColor(self:getBackgroundOfPixel(x,y))
                else
                    term.setBackgroundColor(textColor)
                end
                
                if bkColor == nil then
                    term.setTextColor(self:getBackgroundOfPixel(x,y))
                else
                    term.setTextColor(bkColor)
                end
            end
            term.setCursorPos(x,y)
            term.write(symbol)
            if bkColor ~=nil then 
                self.screen.backround[y][x]=bkColor
            end
        end
    end,
    getBackgroundOfPixel = function(self, x,y)
        local out= self.screen.backround[y][x]

        out = out~=nil and out or colors.black

        return out
    end
})