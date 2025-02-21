return {
    setProgramName = function(self,name)
        local message = coroutine.yield({
            type = "request",
            info = "set program name",
            name = name
        })
    end,
    setWindowTitle = function(self,windowID,title)
        local message = coroutine.yield({
            type = "request",
            info = "set window title",
            windowID = windowID,
            title = title
        })
    end,
    setWindowPos = function(self,windowID,pos)
        local message = coroutine.yield({
            type = "request",
            info = "set window pos",
            windowID = windowID,
            pos = pos
        })
    end,
    setWindowSize = function(self,windowID,size)
        local message = coroutine.yield({
            type = "request",
            info = "set window size",
            windowID = windowID,
            size = size
        })
    end,
    setWindowBorderVisibility = function(self,windowID,borderVisibility)
        local message = coroutine.yield({
            type = "request",
            info = "set window border visibility",
            windowID = windowID,
            borderVisibility = borderVisibility
        })
    end,
    setWindowAlwaysOnTop = function (self,windowID,alwaysOnTop)
        local message = coroutine.yield({
            type = "request",
            info = "set window always on top",
            windowID = windowID,
            alwaysOnTop = alwaysOnTop
        })
    end,

    setWindowAlwaysOnBack = function (self,windowID,alwaysOnBack)
        local message = coroutine.yield({
            type = "request",
            info = "set window always on back",
            windowID = windowID,
            alwaysOnBack = alwaysOnBack
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
                self:setWindowTitle(windowID,args.title)
            end
            if args.pos ~= nil then
                self:setWindowPos(windowID,args.pos)
            end
            if args.size ~= nil then
                self:setWindowSize(windowID,args.size)
            end
            if args.borderVisibility ~= nil then
                self:setWindowBorderVisibility(windowID,args.borderVisibility)
            end
            if args.alwaysOnTop ~= nil then
                self:setWindowAlwaysOnTop(windowID,args.alwaysOnTop)
            end
            if args.alwaysOnBack ~= nil then
                self:setWindowAlwaysOnBack(windowID,args.alwaysOnBack)
            end
            
        end

        return windowID
    end,
    getDisplayInfo = function(self)
        local message = coroutine.yield({
            type = "request",
            info = "get display info"
        })
        return message.content
    end,
    runLoop = function(self,handler)
        while true do
            local message = coroutine.yield({
                type = "done"
            })
            handler(message)
        end
    end,
}