dofile("lib.lua")
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
                bkColor = {}
            }
            for i = 1, self.screenWidth do
                self.screenLines[y].text[i] = " "
                self.screenLines[y].tColor[i] = "0"
                self.screenLines[y].bkColor[i] = acolors.black
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
        
            -- Проверяем, что значение для текста не является числом
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

-- Очищаем экран
screen:clear()
screen:print()

-- Добавляем тестовую строку
local lines = {}
for i = 1,7 do
    lines[i]={
        text =      {'H', 'e', 'l', 'l', 'o', ',', ' ', 'C', 'o', 'm', 'p', 000, 't', 'e', 'r', 'C', 'r', 'a', 'f', 't', '!'},
        tColor =    {"e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", 000, "e", "e", "e", "e", "e", "e", "e", "e", "e"},
        bkColor =   {"0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", 000, "0", "0", "0", "0", "0", "0", "0", "0", "0"}
    }
end

-- Главный цикл с обработкой кликов
while true do
    -- Ожидаем клика мыши
    local event, button, x, y = os.pullEvent("mouse_click")
    
    -- Очищаем экран
    screen:clear()

    -- Добавляем строку в место клика
    screen:addLines(lines, x-4, y-3)
    screen:drawLine(20,7,x,y,'I',acolors.yellow,0)
    
    -- Печатаем экран после изменений
    screen:print()
end
