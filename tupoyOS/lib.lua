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

function copy(obj)  
    return textutils.unserialise(textutils.serialise(obj))
end 