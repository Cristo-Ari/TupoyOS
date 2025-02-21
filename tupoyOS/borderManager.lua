local borderManager = {
    screen = nil,
    elements = {},
    window = nil,
    
    getIndents = function(self, window)
        return {
            left = 0,
            right= 0,
            up = 1,
            down = 0,
        }
    end,
    getTouchIndents = function(self,window)
        if window.borderVisibility == false then
            return {
                left = 0,
                right= 0,
                up = 0,
                down = 0,
            }
        end
        return {
            left = 1,
            right= 1,
            up = 1,
            down = 1,
        }
    end,
    clickProcess = function (self,x,y)
        
    end
}
return borderManager