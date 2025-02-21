local screenAPI = {
    -- Печать содержимого экрана
    printLines = function(self,lines)
        for y = 1, #lines do
            term.setCursorPos(1, y)
            term.blit(
                table.concat(lines[y].text),
                table.concat(lines[y].tColor),
                table.concat(lines[y].bkColor)
            )
        end
    end,
    getSize = function(self)
        local width, height = term.getSize()
        return {x=width,y=height}
    end
}
return screenAPI