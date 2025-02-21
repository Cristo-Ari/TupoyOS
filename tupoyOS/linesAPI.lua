local count = 1

local linesAPI = {
    createLinesM = function(self,size,color)
        if type(size)~= "table" then
            error("error createLinesM - size not set")
        end
        local linesM = {
            lines = {},
            size = size,

            drawLine = function(self,x1,y1,x2,y2,text,tColor,bkColor)
                for i, point in ipairs(getLine(x1, y1, x2, y2)) do
                    self:drawPixel(point.x,point.y,text,tColor,bkColor)
                end
            end,
            drawPixel = function(self,x,y,colorr)
                if (y < 1 or y > self.lines.size.y or x<1 or x>self.lines.size.x) then
                    return
                end
                if type(colorr) == "string" then
                    self.lines[y].tColor[x] = colorsChar.black
                    self.lines[y].bkColor[x] = colorr
                    self.lines[y].text[x] = " "
                    self.lines[y].tColorIsBackground[x] = false
                end
                if type(colorr) == "table" then
                    self.lines[y].text[x] = colorr.text
                    self.lines[y].tColor[x] = colorr.tColor
                    self.lines[y].bkColor[x] = colorr.bkColor
                    if colorr.tColorIsBackground ~= nil then
                        self.lines[y].tColorIsBackground[x] = colorr.tColorIsBackground
                    else
                        self.lines[y].tColorIsBackground[x] = false
                    end
                end
            end,
            drawSquare = function(self,pos,size,color)
                local startX = pos.x
                local endX = pos.x+size.x-1
                local startY = pos.y
                local endY = pos.y+size.y-1

                for i = startY,endY do
                    for j = startX,endX do
                        self:drawPixel(j,i,color)
                    end
                end
            end,
            addLines = function(self,pos,anotherLines)
                for i=1,anotherLines.size.y do
                    for j = 1,anotherLines.size.x do
                        local x=pos.x+j-1
                        local y=pos.y+i-1
                        if not (y < 1 or y > self.lines.size.y or x<1 or x>self.lines.size.x) then
                            local tColor = anotherLines[i].tColor[j]
                            local bkColor = anotherLines[i].bkColor[j]
                            local text = anotherLines[i].text[j]

                            --если текстовое значение является бекграундом
                            if anotherLines[i].tColorIsBackground[j] then
                                --если текст прозрачен
                                if type(tColor) == "string" then
                                    self.lines[y].tColor[x] = anotherLines[i].tColor[j]
                                else
                                    --тогда заменить свой текст на бек
                                    self.lines[y].tColor[x] = self.lines[y].bkColor[x]
                                end
                                
                                if type(bkColor) == "string" then
                                    self.lines[y].bkColor[x]  = anotherLines[i].bkColor[j]
                                else
                                    self.lines[y].bkColor[x] = self.lines[y].tColor[x]
                                end

                                self.lines[y].tColorIsBackground[x] = true
                            else
                                if type(tColor) == "string" then
                                    self.lines[y].tColor[x] = anotherLines[i].tColor[j]
                                end
                                if type(bkColor) == "string" then
                                    self.lines[y].bkColor[x]  = anotherLines[i].bkColor[j]
                                end
                            end

                            if type(text) == "string" then
                                self.lines[y].text[x]  = anotherLines[i].text[j]
                            end
                        end
                    end
                end
            end,
            drawText = function(self,pos,text,tColor,bkColor)
                local splittedText = splitString(text)
                for key, char in pairs(splittedText) do
                    if pos.y <=#self.lines then
                        local targetX = key+ pos.x-1
                        
                        self:drawPixel(targetX,pos.y,{
                            text = char,
                            bkColor = bkColor,
                            tColor = tColor
                        })

                        
                    end
                end
            end,
            fill = function (self,color)
                if type(color)=="string" then
                    self:drawSquare({x=1, y=1}, {y=self.size.y, x=self.size.x},{
                        bkColor = color,
                        tColor = colorsChar.white,
                        text = " "
                    })
                else
                    self:drawSquare({x=1, y=1}, {y=self.size.y, x=self.size.x},color)
                end
            end,
            clear = function (self)
                self:drawSquare({x=1, y=1}, {y=self.size.y, x=self.size.x},{
                    tColor = 0,
                    bkColor = 0,
                    text = 0
                })
            end,
        }

        linesM.lines = self:createLines(size)
        if type(color) == "number" then
            linesM:clear()
        end
        if type(color)=="string" then
            linesM:fill(color)
        end


        return linesM
    end,

    createLines = function(self,size)

        local screenLines = {
            size = size
        }
        local y = size.y

        local counter =1
        for i = 1,y do
            screenLines[i]={
                text =      {},
                tColor =    {},
                bkColor =   {},
                tColorIsBackground = {}
            }
            for j = 1,size.x do
                screenLines[i].text[j] = " "
                screenLines[i].tColor[j] = colorsChar.gray
                screenLines[i].bkColor[j] =colorsChar.black
                screenLines[i].tColorIsBackground[j] = false
            end
        end

        return screenLines
    end,

    generateRandomScreen = function(width,height)
        local dcolors = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
        local letters = {}
        for i = 1, 255 do
            table.insert(letters, string.char(i))
        end
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
                screenLines[i].bkColor[j] =dcolors[2]
            end
        end
        return screenLines
    end,

    cropScreenLines = function(lines, newWidth, newHeight)
        local cropped = {}
        -- Определяем, сколько строк мы будем обрабатывать (не больше, чем доступно)
        local height = math.min(newHeight, #lines)
        
        for i = 1, height do
            local line = lines[i]
            local croppedLine = {
                text = {},
                tColor = {},
                bkColor = {}
            }
            -- Определяем, сколько символов обрезать в строке (не больше, чем длина строки)
            local width = math.min(newWidth, #line.text)
            for j = 1, width do
                croppedLine.text[j] = line.text[j]
                croppedLine.tColor[j] = line.tColor[j]
                croppedLine.bkColor[j] = line.bkColor[j]
            end
            cropped[i] = croppedLine
        end
        
        return cropped
    end,
}

return linesAPI