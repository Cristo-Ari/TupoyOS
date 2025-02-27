local coroutineM = {
    coroutines = {},
    corInfos = {
        
    },
    windowM = nil,

    add = function(self, func)
        local key = randStr()
        self.coroutines[key] = coroutine.create(func)
        self.corInfos[key] = {
            name = "unnamed program",
            isFirstLauch = true,
            messageQueue = {},
            createdWindowsID = {},
        }
        local pAPIa = dofile("tupoyOS/pAPIa.lua")
        self:sendMessage(key,pAPIa)
        

        return key
    end,
    process = function(self,eData)
        for processID, cor in pairs(self.coroutines) do
            if eData[1]=="timer" then
                for key,corInfo in pairs(self.corInfos) do
                    if corInfo.isCoroutineStopped then
                        if corInfo.coroutineStopTimerID == eData[2] then
                            corInfo.isCoroutineStopped = false
                            for key,windowID in pairs(corInfo.createdWindowsID)do
                                self.windowM.windows[windowID].restume()
                            end
                        end
                    end
                end
            end
            self:sendMessage(processID,{
                type = "event",
                eData = eData
            })
        end
    end,
    sendMessage = function(self,processID,message)
        local cor = self.coroutines[processID]
        local corInfo = self.corInfos[processID]

        table.insert(corInfo.messageQueue,message)

        if not corInfo.isCoroutineStopped then
            local stopProcessingCoroutine = false
            for key,messageInQueue in pairs(corInfo.messageQueue) do
                local sendingMessage = messageInQueue

                repeat
                    local status, message = coroutine.resume(cor,sendingMessage)
                    if not status then
                        error("Coroutine error: " .. tostring(message))
                    end

                    if message.type == "request" then
                        if message.info == "create window" then
                            local windowKey = self.windowM:add(
                                2,
                                2,
                                15,
                                15,
                                "Window 14442343",
                                processID
                            )

                            table.insert(corInfo.createdWindowsID,windowKey)

                            sendingMessage ={
                                type = "window",
                                info = "create window response",
                                data = windowKey
                            }
                        end

                        local wind = self.windowM.windows[message.windowID]

                        if message.info == "set window title" then
                            wind:setTitle( message.title)
                            wind.size:set(wind.size:get())
                        end
                        if message.info == "set window pos" then
                            wind.pos:set({x=message.pos.x,y=message.pos.y})
                        end
                        if message.info == "set content pos" then
                            wind.pos:set({
                                x=message.pos.x - wind.content.pos:get().x+1,
                                y=message.pos.y - wind.content.pos:get().y+1
                            })
                        end
                        if message.info == "set window size" then
                            --размер окна - размер его контента
                            local borderIndents= wind.borderManager.getIndents()
                            wind.size:set({
                                x=message.size.x,
                                y=message.size.y
                            })
                        end
                        if message.info == "set content size" then
                            wind.setSize({
                                x=message.size.x,
                                y=message.size.y
                            })
                        end
                        if message.info == "set window border visibility" then
                            wind.borderVisibility = message.borderVisibility
                            --os.sleep(11)
                        end
                        if message.info == "set window always on top" then
                            wind.alwaysOnTop = message.alwaysOnTop
                            self.windowM:windowToFront(message.windowID)
                        end
                        if message.info == "set window always on back" then
                            wind.alwaysOnBack = message.alwaysOnBack
                            self.windowM:windowToBack(message.windowID)
                        end
                        if message.info == "set program name" then
                            self.corInfos[processID].name = message.name
                        end

                        if message.info == "get all winodws" then
                            self.corInfos[processID].name = message.name
                            sendingMessage = {
                                type = "response",
                                content = self.windowM.windows
                            }
                        end

                        if message.info == "get display info" then
                            local x,y = term.getSize()
                            local display = {
                                size = {
                                    x=x,
                                    y=y
                                }
                            }
                            sendingMessage = {
                                type = "response",
                                content = display
                            }
                        end

                        if message.info == "coroutine sleep" then
                            corInfo.isCoroutineStopped = true
                            corInfo.coroutineStopTimerID = os.startTimer(message.params.seconds)
                            for key,windowID in pairs(corInfo.createdWindowsID)do
                                self.windowM.windows[windowID].pause()
                            end
                            stopProcessingCoroutine = true
                        end
                        
                        if message.info == "computer sleep" then
                            os.sleep(message.params.seconds)
                        end


                    end
                until message.type == "done" or stopProcessingCoroutine

                corInfo.messageQueue[key] = nil
                if stopProcessingCoroutine then
                    break
                end
            end
        end
    end
    
}

return coroutineM