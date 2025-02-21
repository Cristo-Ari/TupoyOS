local linesAPI = dofile("tupoyOS/linesAPI.lua")

local componentsAPI = {
    createComponent = function (self)
        local comp = {
            isGhost = false, -- если кликнули на компонент, тогда кликнуть даже на те, что позади компонента
            ignoreSelfListenersWhenClickedInsideComponent = false,

            layoutManager = nil,

            components = {},
            add = function (self, comp)
                table.insert(self.components,comp)
            end,
            
            pos = {
                value = {x=1,y=1},
                set = function (self,value)
                    self.value = value
                    self:triggerListeners({
                        newPos = value
                    })
                end,
                get = function(self)
                    return self.value
                end,

                listeners = {},
                addListener = function(self,resizeListener)
                    table.insert(self.listeners, resizeListener)
                end,
                triggerListeners = function(self,event)
                    for key,resizeListner in pairs(self.listeners) do
                        resizeListner(event)
                    end
                end,
            },
            
            size = {
                value = {x=16,y=5},
                set = function (self,value)
                    self.value = value
                    self:triggerListeners({
                        newSize = value
                    })
                end,
                get = function(self)
                    return self.value
                end,

                listeners = {},
                addListener = function(self,resizeListener)
                    table.insert(self.listeners, resizeListener)
                end,
                triggerListeners = function(self,event)
                    for key,resizeListner in pairs(self.listeners) do
                        resizeListner(event)
                    end
                end,
            },

            ignoreSelfWhenClickedOtherComp = false,
            mouseListeners = {},
            addMouseListener = function(self,mouseListener)
                table.insert(self.mouseListeners, mouseListener)
            end,
            triggerMouseListeners = function(self,event)
                local clickedInsideComponent = false

                local x = event.pos.x
                local y = event.pos.y

                --кликнуть на компоненты внутри 
                for i = #self.components , 1, -1 do
                    local comp = self.components[i]

                    local compPos = comp.pos:get()
                    local compSize = comp.size:get()

                    if x>=compPos.x and 
                        x<=compPos.x+compSize.x-1 and
                        y>=compPos.y and
                        y<=compPos.y+compSize.y-1 then


                        --[[
                        Пример евента клика
                        mEvent = {
                            clickType = "double click",
                            pos = {
                                x=10,
                                y=3
                            },
                            buttonName = "LBM"
                        }
                        ]]--
                        comp:triggerMouseListeners({
                            clickType = event.clickType,
                            pos = {
                                x = x-compPos.x+1,
                                y = y-compPos.y+1,
                            }
                        })
                        if not comp.isGhost then
                            clickedInsideComponent = true
                            break
                        end
                    end
                end

                -- пройтись по всем своим лисенерам
                if self.ignoreSelfListenersWhenClickedInsideComponent then
                    if not clickedInsideComponent then
                        for key,mListener in pairs(self.mouseListeners) do
                            mListener(event)
                        end
                    end
                else
                    for key,mListener in pairs(self.mouseListeners) do
                        mListener(event)
                    end
                end 
                
            end,

            customPaints = {},
            addCustomPaint = function(self, customPaint)
                table.insert(self.customPaints,customPaint)
            end,

            getLines = function(self)
                local linesM = linesAPI:createLinesM(self.size:get())

                --рисовать кастомные  рисунки
                for key,customPaints in pairs(self.customPaints)do
                    customPaints(linesM)
                end
                --рисовать компоненты
                for key, component in pairs(self.components) do
                    linesM:addLines(
                        component.pos:get(),
                        component:getLines()
                    )
                end
                return linesM.lines
            end,
            bkColor = "1",
        }

        return comp
    end
}

return componentsAPI