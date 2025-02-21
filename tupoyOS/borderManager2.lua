local defaultDrawBorderManager2 = {
    draw = function (self,window)
        local borderColor = window.isFocused and colorsChar.lightGray or colorsChar.gray
        --local vls = window.isFocused and "|" or "\183" -- vertical line symbol
        local vls = "\149" -- vertical line symbol
        --local hls = window.isFocused and "-" or "\183" -- horizontal line symbol
        local hls = "\143"
        local es = window.isFocused and "\4" or "\7" -- edge symbol

        --drawLeftSide
        if window.height>2 then
            self.screen:drawLineBkToText(
                window.x,
                window.y+1,
                window.x,
                window.y+window.height-2,
                vls,
                0,
                borderColor
            )
        end

        --drawRightSide
        if window.height>2 then
            self.screen:drawLineBkToText(
                window.x+window.width-1,
                window.y+1,
                window.x+window.width-1,
                window.y+window.height-2,
                vls,
                borderColor,
                0
            )
        end

        --draw up side

        
        local rucs = "\144" --right Up DotCorner symbol
        self.screen:drawPixelBkToText(
            window.x+window.width-1,
            window.y,
            rucs,
            borderColor,
            0
        )

        local lucs = "\159" --left Up DotCorner symbol
        local titleLenCut = window.width - 5 - 7
        if titleLenCut <0 then
            titleLenCut = 0
        end
        local outTitle = string.sub(window.title, 1, titleLenCut)

        if not (window.width - #outTitle - 9 > 0) then
            outTitle = string.sub((window.title.."                  "), 1, titleLenCut+(window.width>=9 and 1 or 0)+(window.width>=8 and 1 or 0))
        end

        local indents = self:getIndents()
    
        local header = string.rep(hls, window.width-1)
        
        local splittedHeader = splitString(header)

        splittedHeader[1] = lucs

        local tColor = {}
        for i = 1,#splittedHeader do
            tColor[i]=0
        end

        local bkColor = {}
        for i = 1,#splittedHeader do
            bkColor[i]=borderColor
        end

        local finalLine = {
            text = splittedHeader,
            tColor = tColor,
            bkColor = bkColor
        }

        self.screen:addLineBkToText(finalLine,window.x,window.y)

        --drawDownSide
        local leftDownEdge  = "\130"
        local rightDownEdge  = "\129"

        local footer = leftDownEdge .. string.rep("\131", window.width - 2) .. rightDownEdge
        local splittedFooter = splitString(footer)

        local tColor = {}
        for i = 1,#splittedFooter do
            tColor[i]=borderColor
        end
        local bkColor = {}
        for i = 1,#splittedFooter do
            bkColor[i]=0
        end

        local finalLine = {
            text = splittedFooter,
            tColor = tColor,
            bkColor = bkColor
        }

        self.screen:addLine(finalLine,window.x,window.y+window.height-1)
    end,
    getIndents = function(self)
        return {
            left = 1,
            right= 1,
            up = 1,
            down = 1,
        }
    end,
}