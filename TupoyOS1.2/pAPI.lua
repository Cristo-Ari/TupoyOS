return {
    changeWindowTitle = function(self,windowID,title)
        local message = coroutine.yield({
            type = "request",
            info = "change window title",
            windowID = windowID,
            title = title
        })
    end,
    createWindow = function(self,args)
        local windowID
        local message = coroutine.yield({
            type = "request",
            info = "create window"
        })
        if message.type == "window" then
            if message.info == "create window response" then
                windowID = message.data
            else
                error ("response to create window request is not valid")
            end
        else 
            error ("response to create window request is not valid")
        end

        if args ~= nil then
            if args.title ~= nil then
                self:changeWindowTitle(windowID,args.title)
            end
        end

        return windowID
    end,
    getDisplayInfo = function(self)
        local message = coroutine.yield({
            type = "request",
            info = "get display info"
        })
    end
}