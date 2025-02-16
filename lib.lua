
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
end

generateFilledScreen = function(size,text,tColor,bkColor)

    local text = text == nil and " " or text
    local tColor = tColor == nil and "4" or tColor
    local bkColor = bkColor == nil and "3" or bkColor

    local screenLines = {}
    for i = 1,size.y do
        screenLines[i]={
            text =      {},
            tColor =    {},
            bkColor =   {}
        }
        for j = 1,size.x do
            screenLines[i].text[j] =text
            screenLines[i].tColor[j] =tColor
            screenLines[i].bkColor[j] =bkColor
        end
    end
    return screenLines
end

colorsChar = {
    white = "0",
    orange = "1",
    magenta = "2",
    lightBlue = "3",
    yellow = "4",
    lime = "5",
    pink = "6",
    gray = "7",
    lightGray = "8",
    cyan = "9",
    purple = "a",
    blue = "b",
    brown = "c",
    green = "d",
    red = "e",
    black = "f",
}

function findIndex(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil  -- Если значение не найдено
end

function randStr()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = 7
    local result = {}
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        table.insert(result, charset:sub(randomIndex, randomIndex))
    end
    return table.concat(result)
end

function cropScreenLines(lines, newWidth, newHeight)
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
end

-- Функция для обрезки массива линий по ширине и высоте
local function cropScreenLines(lines, newWidth, newHeight)
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
end

function getLine(x1, y1, x2, y2)
    local points = {}

    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy

    while true do
        table.insert(points, {x = x1, y = y1})
        if x1 == x2 and y1 == y2 then break end

        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
    
    return points
end

function splitString(str)
    local letters = {}
    for i = 1, #str do
      letters[i] = str:sub(i, i)
    end
    return letters
end

changeBackroundColor = function (lines,bkColor)
    for i = 1, #lines do
        local line = lines[i]
        for j = 1, #line.bkColor do
            lines[i].bkColor[j]=bkColor
        end
    end
end