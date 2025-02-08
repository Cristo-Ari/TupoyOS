
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

-- Пример использования:
local screenLines = {}
for i = 1, 7 do
    screenLines[i] = {
        text =    {'H', 'e', 'l', 'l', 'o', ',', ' ', 'C', 'o', 'm', 'p', 0, 't', 'e', 'r', 'C', 'r', 'a', 'f', 't', '!'},
        tColor =  {"e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", 0, "e", "e", "e", "e", "e", "e", "e", "e", "e"},
        bkColor = {"0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", 0, "0", "0", "0", "0", "0", "0", "0", "0", "0"}
    }
end

-- Допустим, хотим оставить 10 символов в строке и 5 строк
local croppedLines = cropScreenLines(screenLines, 10, 5)

-- Вывод результата для проверки:
for i, line in ipairs(croppedLines) do
    print(table.concat(line.text))
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