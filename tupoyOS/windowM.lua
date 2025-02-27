local compAPI = dofile("tupoyOS/componentsAPI.lua")
local linesAPI = dofile("tupoyOS/linesAPI.lua")
local screenAPI = dofile("tupoyOS/screenAPI.lua")



local windowM = {
    coroutinesManager = nil,
    windows = {},
    windowOrder = {},
    isReadyToDrag = {},
    isReadyToResize = {},
    focusedWindowKey = nil,
    edgeClicked = {},

    mainLinesM = linesAPI:createLinesM(screenAPI:getSize()),

    add = function(self, x, y, width, height, title, processID)
        local key = randStr()

        local function createWindow()
            local window = compAPI:createComponent()

            window.size:set({x=width,y=height})
            window.pos:set({x=x,y=y})
            window.title = title or "unnamed"
            window.backround = colorsChar.oragne
            window.processID = processID
            window.borderVisibility = true
            window.isFocused = false
            window.isMaximized = false
            window.alwaysOnTop = false
            window.alwaysOnBack = false
            window.borderColor = colorsChar.gray
            window.borderManager = dofile("tupoyOS/borderManager.lua")
            window.windowID = key
            window.isHidden = false
            window.isPaused = false
            window.pause = function()
                window.isPaused = true
                window.borderColor = colorsChar.red
                os.queueEvent("windows_paint")
            end
            window.restume = function()
                window.isPaused = false
                window.borderColor = window.isFocused and colorsChar.gray or colorsChar.lightGray
                os.queueEvent("windows_paint")
            end

            window.hide = function()
                window.isHidden = true
            end
            window.show = function()
                window.isHidden = false
            end

            window.titleChangeListeners = {}
            window.addTitleChangeListener = function(newListener)
                table.insert(window.titleChangeListeners,newListener)
            end
            window.setTitle = function(self,newTitle)
                window.title = newTitle
                for _, titleChangeListener in pairs( window.titleChangeListeners) do
                    print(newTitle)
                    titleChangeListener(newTitle)
                end
            end
    
            window:addCustomPaint(function (linesM)
                linesM:clear()
            end)

            window.setFocus = function()
                window.borderColor = colorsChar.lightGray
                window.isFocused = true
                self:windowToFront(window.windowID)
            end
            window.removeFocus = function()
                window.borderColor = colorsChar.gray
                window.isFocused = false
            end

            return window
        end
        local function createContent(window)
            local function findContentPos()
                local out = {
                    x=5,
                    y=3
                }
                -- print(textutils.serialise(out))
                -- os.sleep(1)
                return out
            end
            local findContentSize = function()
                return({
                    x=window.size:get().x,
                    y=window.size:get().y-1
                })
            end

            local content = compAPI:createComponent()
            content.size:set(findContentSize())
            content.pos:set(findContentPos())
    

            local squaresPos = {}
            for i = 1,50 do
                table.insert(squaresPos,{
                    x=math.random(1,content.size:get().x),
                    y=math.random(1,content.size:get().y),
                    color = math.random(1,2)==1 and  colorsChar.yellow or math.random(1,2)==1 and colorsChar.cyan or colorsChar.orange
                })
            end

            content.windowLinesBackup = nil
            content:addCustomPaint (function (linesM)
                linesM:clear()
                local windowLines
                if not window.isPaused then
                    windowLines = self:tryToGetScreenLines(window.processID,window.windowID)
                end
                if windowLines ~= nil then
                    content.windowLinesBackup = windowLines
                    linesM:addLines(
                        {x=1,y=1},
                        windowLines
                    )
                else
                    local size = linesM.size
                    local colors = {}
                    if content.windowLinesBackup~= nil then
                        linesM:addLines(
                            {x=1,y=1},
                            content.windowLinesBackup
                        )
                    end
                    for key,squarePos in pairs(squaresPos) do



                        squarePos.x = squarePos.x+math.random(-2,2)
                        -- if squarePos.x<1 then
                        --     squarePos.x= content.pos:get().x
                        -- end
                        if squarePos.x>content.size:get().x then
                            squarePos.x= 1
                        end
                        squarePos.y = squarePos.y- (math.random(1,100)>70 and 1 or 2)
                        if squarePos.y<1 then
                            squarePos.y = content.size:get().y
                            squarePos.x = math.random(1,content.size:get().x)
                        end
                        linesM:drawSquare(
                            squarePos,
                            {
                                x=math.random(1,2),
                                y=math.random(1,2)
                            },
                            squarePos.color
                        )
                    end
                    local text = "Screen lines is nil"
                    linesM:drawText(
                        {
                            x=math.floor(size.x/2)-math.floor(#text/2),
                            y=math.floor(size.y/2+1)
                        },
                        text,
                        colorsChar.black,
                        colorsChar.red
                    )
                    
                end
            end)

            content:addMouseListener(function(mEvent)
                if not self.isReadyToDrag[1] and not self.isReadyToResize[1] then
                    self.coroutinesManager:sendMessage(window.processID,{
                        type = "window",
                        info = "window content clicked",
                        windowID = window.windowID,
                        mEvent = mEvent
                    })
                end
            end)

            return content
        end

        local addCorners = function(window,content,foregroundComoponents)
            local createLeftDownCornerComp = function()
                local findLeftCornerPos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=contPos.x,
                        y=contSize.y+contPos.y-1
                    }
                end
                local button = compAPI:createComponent()
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                button.size:set({x=1,y=1})
                button.pos:set(findLeftCornerPos())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    if (window.pos:get().x+content.pos:get().x-1)>1 then
                        --drawLeftDown corner
                        local ldCornerSymbol = "\138"
                        linesM:drawPixel(1,1,{
                            bkColor = window.borderColor,
                            tColor = 0,
                            text = ldCornerSymbol,
                            tColorIsBackground = true,
                        })
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)
                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.isReadyToResize = {
                            true,
                            key,
                            "leftDown",
                            window.pos:get().x+button.pos:get().x-1,
                            window.pos:get().y+button.pos:get().y-1,
                            content.size:get().x,
                            content.size:get().y,
                            window.getContentInScreenPos().x,
                            window.getContentInScreenPos().y,
                        }
                    end
                    -- print("Left down CornerPos Clicked")
                    -- os.sleep(1)
                end)
                content.size:addListener(function ()
                    button.pos:set(findLeftCornerPos())
                end)
                return (button)
            
            end

            local createRightDownCornerComp = function()
                local findRightDownCornerPos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=contPos.x+contSize.x-1,
                        y=contPos.y+contSize.y-1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.pos:set(findRightDownCornerPos())
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    if (window.pos:get().x+content.pos:get().x-1)+content.size:get().x-1 < screenAPI.getSize().x then
                        --drawRightDown corner
                        local rdCornerSymbol = "\133"
                        linesM:drawPixel(1,1,{
                            bkColor = window.borderColor,
                            tColor = 0,
                            text = rdCornerSymbol,
                            tColorIsBackground = true,
                        })
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)
                button:addMouseListener(function(mEvent)
                    if mEvent.type == "mouse down" then
                        self.isReadyToResize = {
                            true,
                            key,
                            "rightDown",
                            window.pos:get().x+button.pos:get().x-1,
                            window.pos:get().y+button.pos:get().y-1,
                            content.size:get().x,
                            content.size:get().y,
                            window.getContentInScreenPos().x,
                            window.getContentInScreenPos().y,
                        }
                    end
                    -- print("RightDownCorner Clicked")
                    -- os.sleep(1)
                end)
                content.size:addListener(function ()
                    button.pos:set(findRightDownCornerPos())
                end)
                return (button)
            
            end

            local createRightUpCornerComp = function()
                local findRightDownCornerPos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=contPos.x+contSize.x-1,
                        y=contPos.y
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                button.pos:set(findRightDownCornerPos())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    -- if #upLines.components>1 then
                        local lues = "\130" --rightUpEdgeSymbol
                        local lues = "\148" --rightUpEdgeSymbol
                        linesM:fill({
                            text = lues,
                            tColor = 0,
                            bkColor = colorsChar.gray,
                            tColorIsBackground = true
                        })
                        
                    -- else
                    --     local hls = "\143" -- horizontal line symbol
                    --     linesM:fill({
                    --         text = hls,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- end
                    for _,comp in pairs(foregroundComoponents)do
                        linesM:drawSquare(
                            {
                                x=comp.pos:get().x-button.pos:get().x+1,
                                y=comp.pos:get().y-button.pos:get().y+1
                            },
                            comp.size:get(),
                            {
                                tColor = 0,
                                bkColor = 0,
                                text = 0
                            }
                        )
                    end
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.isReadyToResize = {
                            true,
                            key,
                            "rightUp",
                            window.pos:get().x+button.pos:get().x-1,
                            window.pos:get().y+button.pos:get().y-1,
                            content.size:get().x,
                            content.size:get().y,
                            window.getContentInScreenPos().x,
                            window.getContentInScreenPos().y,
                        }
                    end
                        -- print("RightUpCorner Clicked")
                    -- os.sleep(1)
                end)

                content.size:addListener(function ()
                    button.pos:set(findRightDownCornerPos())
                end)
                return (button)
            
            end

            local createLeftUpCornerComp = function()
                local findLeftUpCornerComp = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=contPos.x,
                        y=contPos.y
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                button.pos:set(findLeftUpCornerComp())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    -- if #upLines.components>1 then
                        local lues = "\129" --leftUpEdgeSymbol
                        local lues = "\151" --leftUpEdgeSymbol
                        linesM:fill({
                            text = lues,
                            tColor = colorsChar.gray,
                            bkColor = 0,
                            -- tColorIsBackground = true
                        })
                    -- else
                    --     local hls = "\143" -- horizontal line symbol
                    --     linesM:fill({
                    --         text = hls,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- end
                    for _,comp in pairs(foregroundComoponents)do
                        linesM:drawSquare(
                            {
                                x=comp.pos:get().x-button.pos:get().x+1,
                                y=comp.pos:get().y-button.pos:get().y+1
                            },
                            comp.size:get(),
                            {
                                tColor = 0,
                                bkColor = 0,
                                text = 0
                            }
                        )
                    end
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.isReadyToResize = {
                            true,
                            key,
                            "leftUp",
                            window.pos:get().x+button.pos:get().x-1,
                            window.pos:get().y+button.pos:get().y-1,
                            content.size:get().x,
                            content.size:get().y,
                            window.getContentInScreenPos().x,
                            window.getContentInScreenPos().y,
                        }
                    end
                    -- print("leftUpBorderClicked")
                    -- os.sleep(1)
                end)

                content.size:addListener(function ()
                    button.pos:set(findLeftUpCornerComp())
                end)
                return (button)
            
            end
            window:add(createRightUpCornerComp())
            window:add(createRightDownCornerComp())
            window:add(createLeftDownCornerComp())
            window:add(createLeftUpCornerComp())
        end

        local addEdges = function (content,window,foregroundComoponents)
            local createleftEdge = function()
                local findleftEdgeSize = function()
                    return {
                        x=1,
                        y=content.size:get().y-2
                    }
                end
                local findLeftEdgePos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.pos:get().x,
                        y=content.pos:get().y+1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findleftEdgeSize())
                button.pos:set(findLeftEdgePos())
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    if (window.pos:get().x+content.pos:get().x-1)>1 then
                        linesM:fill({
                                bkColor = 0,
                                tColor = window.borderColor,
                                text = "\149"
                            }
                        )
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.edgeClicked = {
                            true,
                            key,
                            "left edge",
                            button.pos:get().x+mEvent.pos.x-1,
                            button.pos:get().y+mEvent.pos.y-1,
                        }
                    end
                end)

                content.size:addListener(function()
                    button.pos:set(findLeftEdgePos())
                    button.size:set(findleftEdgeSize())
                end)

                return button
            end

            local createRightEdge = function()
                local findRightEdgeSize = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=1,
                        y=content.size:get().y-2
                    }
                end
                local findRightEdgePos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.pos:get().x+content.size:get().x-1,
                        y=content.pos:get().y+1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findRightEdgeSize())
                button.pos:set(findRightEdgePos())
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    if (window.pos:get().x+content.pos:get().x-1)+content.size:get().x-1 < screenAPI.getSize().x then
                        linesM:fill({
                            bkColor = window.borderColor,
                            tColor = 0,
                            text = "\149",
                            tColorIsBackground = true
                        })
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)

                content.size:addListener(function ()
                    button.size:set(findRightEdgeSize())
                    button.pos:set(findRightEdgePos())
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.edgeClicked = {
                            true,
                            key,
                            "right edge",
                            button.pos:get().x+mEvent.pos.x-1,
                            button.pos:get().y+mEvent.pos.y-1,
                        }
                    end
                end)
                return button
            end
            
            local createUpEdge = function()
                
                local findUpEdgeSize = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.size:get().x-2,
                        y=1
                    }
                end
                local findUpEdgePos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.pos:get().x+1,
                        y=content.pos:get().y
                    }
                end

                local button = compAPI:createComponent()
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true
                button.size:set(findUpEdgeSize())
                button.pos:set(findUpEdgePos())
                

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    if (window.pos:get().y+content.pos:get().y-1)>1 then
                        local hls = "\131" -- horizontal line symbol
                        linesM:fill({
                            bkColor = 0,
                            tColor = window.borderColor,
                            text = hls,
                            tColorIsBackground = false
                        })
                    
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        -- print(mEvent.pos.x)
                        -- os.sleep(1)
                        self.isReadyToDrag = {
                            true,
                            key, 
                            (button.pos:get().x+mEvent.pos.x-1)-content.pos:get().x,
                            (button.pos:get().y+mEvent.pos.y-1)-content.pos:get().y,
                        }
                    end
                    -- print("dibily3")
                    -- os.sleep(1)
                end)

                content.size:addListener(function()
                    button.size:set(findUpEdgeSize())
                    button.pos:set(findUpEdgePos())
                end)
                
                return button
            end

            local createDownEdge = function()
                local findDownEdgeSize = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.size:get().x-2,
                        y=1
                    }
                end
                local findDownEdgePos = function()
                    local contPos = content.pos:get()
                    local contSize = content.size:get()
                    return {
                        x=content.pos:get().x+1,
                        y=content.pos:get().y + content.size:get().y-1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findDownEdgeSize())
                button.pos:set(findDownEdgePos())
                button.isGhostMouseClicked=true
                button.isGhostMouseDragged=true

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    if window.pos:get().y+button.pos:get().y-1< screenAPI:getSize().y then
                        local hls = "\143" -- horizontal line symbol
                        linesM:fill({
                            bkColor = window.borderColor,
                            tColor = 0,
                            text = hls,
                            tColorIsBackground = true,
                        })
                        for _,comp in pairs(foregroundComoponents)do
                            linesM:drawSquare(
                                {
                                    x=comp.pos:get().x-button.pos:get().x+1,
                                    y=comp.pos:get().y-button.pos:get().y+1
                                },
                                comp.size:get(),
                                {
                                    tColor = 0,
                                    bkColor = 0,
                                    text = 0
                                }
                            )
                        end
                    end
                end)

                button:addMouseListener(function(mEvent)
                    if mEvent.type=="mouse down" then
                        self.edgeClicked = {
                            true,
                            key,
                            "down edge",
                            button.pos:get().x + mEvent.pos.x-1,
                            button.pos:get().y + mEvent.pos.y-1,
                        }
                    end
                end)
                content.size:addListener(function()
                    button.size:set(findDownEdgeSize())
                    button.pos:set(findDownEdgePos())
                end)
                return button
            end

            window:add(createleftEdge())
            window:add(createRightEdge())
            window:add(createDownEdge())
            window:add(createUpEdge())
        end

        local createEdgedComponent = function(component,window,params)
            local edged = compAPI:createComponent()
            edged.drawLeftEdge = true
            edged.drawRightEdge = true
            if params ~= nil then
                if params.drawRightEdge~= nil then
                    edged.drawRightEdge = params.drawRightEdge
                end
                if params.drawLeftEdge~= nil then
                    edged.drawLeftEdge = params.drawLeftEdge
                end
            end
            
            edged.pos:set({x=0,y=2})
            component.pos:set({x=2,y=1})
            edged:add(component)
            edged.size:set({x=component.size:get().x+2,y=1})
            edged:addCustomPaint(function(linesM)
                linesM:clear()
                -- linesM:fill(window.borderColor)
                if window.pos:get().y+edged.pos:get().y-1 >1 then
                    if edged.drawLeftEdge then
                        linesM:drawPixel(1,1,{
                            text = "\139",
                            tColor = window.borderColor,
                            bkColor = 0,
                            tColorIsBackground = false
                        })
                    end
                    if edged.drawRightEdge then
                        linesM:drawPixel(linesM.size.x,1,{
                            text = "\135",
                            tColor = window.borderColor,
                            bkColor = 0,
                            tColorIsBackground = false
                        })
                    end
                end
                
            end)
            return edged
        end

        local addCloseButtons = function(window,content,foregroundComoponents)
            local createCloseMenu = function()

                local closeMenu = compAPI:createComponent()
                closeMenu.size:set({x=5,y=1})

                closeMenu:addCustomPaint(function(linesM)
                    linesM:fill(window.borderColor)
                end)

                local posCount = 0
                local createButton = function (buttonSymbol,func)
                    local button = compAPI:createComponent()
                    button.size:set({x=1,y=1})
                    button.pos:set({
                        x=1+posCount*2,
                        y=1
                    })
                    button:addCustomPaint(function(linesM)
                        linesM:clear()
                        linesM:drawPixel(1,1,buttonSymbol)
                    end)
                    button:addMouseListener(func)

                    posCount=posCount+1
                    return (button)
                end

                local createMaxumizedButton = function ()
                    local button = compAPI:createComponent()
                    button.size:set({x=1,y=1})
                    button.pos:set({
                        x=1+posCount*2,
                        y=1
                    })
                    button:addCustomPaint(function(linesM)
                        linesM:clear()
                        if not window.isMaximized then
                            linesM:drawPixel(1,1,{
                                bkColor= 0,
                                tColor = colorsChar.black,
                                text = "\30"
                            })
                        else
                            linesM:drawPixel(1,1,{
                                bkColor= 0,
                                tColor = colorsChar.black,
                                text = "\31"
                            })
                        end
                    end)
                    button:addMouseListener(function(mEvent)
                        if mEvent.type=="mouse click" and mEvent.buttonName == "LBM" then
                            if not window.isMaximized then
                                window.maximize()
                            else
                                window.minimize()
                            end
                        end
                    end)

                    posCount=posCount+1
                    return (button)
                end

                --hide button
                closeMenu:add(createButton({
                        bkColor= 0,
                        tColor = colorsChar.black,
                        text = "-"
                },function(mEvent)
                    if mEvent.type=="mouse click" and mEvent.buttonName == "LBM" then
                        window.isHidden = true
                    end
                end))
                --maximize Button
                closeMenu:add(createMaxumizedButton())

                --closeButton
                closeMenu:add(createButton({
                    bkColor= 0,
                    tColor = colorsChar.black,
                    text = "\215"
                },function(mEvent)
                    if mEvent.type=="mouse click" and mEvent.buttonName == "LBM" then
                        self:remove(window.windowID)
                    end
                end))
                
                return closeMenu
            end
            local closeMenu = createCloseMenu()
            local edged = createEdgedComponent(closeMenu,window)
            -- edged.drawLeftEdge=false

            local function findCloseMenuPos()
                return {
                    x=(content.pos:get().x+content.size:get().x-1)-edged.size:get().x+2,
                    y=content.pos:get().y
                }
            end

            content.size:addListener(function()
                edged.pos:set(findCloseMenuPos())
            end)
            table.insert(foregroundComoponents,edged)
            window:add(edged)
        end

        local addTitle = function (window,content,foregroundComoponents)
            local findTitleMenuPos = function()
                return {
                    x=content.pos:get().x-1,
                    y=content.pos:get().y
                }
            end
            local createTitleMenu = function(window)
                local function findTitleMenuSize()
                    return {
                        x=#window.title,
                        y=1
                    }
                end

                local titleMenu = compAPI:createComponent()
                titleMenu.size:set(findTitleMenuSize())
                titleMenu:addCustomPaint(function(linesM)
                    linesM:fill(window.borderColor)
                    linesM:drawText(
                        {
                            x=1,
                            y=1
                        },
                        window.title,
                        colorsChar.black,
                        window.borderColor
                    )
                end)
                return titleMenu
            end

            local titleMenu = createTitleMenu(window)
            local edged = createEdgedComponent(titleMenu,window)
            edged.drawLeftEdge=false
            window.addTitleChangeListener(function(newTitle)
                titleMenu.size:set({x=#newTitle,y=1})
                edged.size:set({x=titleMenu.size:get().x+2,y=1})
            end)

            content.size:addListener(function()
                edged.pos:set(findTitleMenuPos())
            end)

            table.insert(foregroundComoponents,edged)
            window:add(edged)
        end

        local foregroundComoponents = {}

        local window = createWindow()
        local content = createContent(window)
        window.content = content
        window:add(content)

        addTitle(window,content,foregroundComoponents)
        addCloseButtons(window,content,foregroundComoponents)
        
        
        addEdges(content,window,foregroundComoponents)
        addCorners(window,content,foregroundComoponents)

        --send coroutine resize info
        content.size:addListener(function()
            self.coroutinesManager:sendMessage(window.processID,{
                type = "window",
                info = "size changed",
                
                windowID = window.windowID,
                newSize = content.size:get()
            })
        end)

        window.maximize = function()
            window.sizeBeforeMaximized = window.size:get()
            window.posBeforeMaximized = window.pos:get()

            window.isMaximized = true
            window.pos:set({x=1,y=0})
            window.setSize({
                x=screenAPI:getSize().x,
                y=screenAPI:getSize().y
            })
        end

        window.minimize = function()
            window.isMaximized = true
            window.pos:set(window.posBeforeMaximized)
            window.size:set(window.sizeBeforeMaximized)

            window.isMaximized = false
        end

        window.setSize = function(newSize)
            window.size:set({x=newSize.x+4,y=newSize.y+4})
            content.size:set(newSize)
        end
        window.setPos = function(newPos)
            --размещать окно так, чтобы в указанный координатах был левый край контента
            window.pos:set({
                x=newPos.x-content.pos:get().x+1,
                y=newPos.y-content.pos:get().y+1
            })
        end
        window.getContentInScreenPos = function()
            return {
                x=window.pos:get().x+content.pos:get().x-1,
                y=window.pos:get().y+content.pos:get().y-1,
            }
        end


        self.windows[key] = window
        table.insert(self.windowOrder, key)
        os.queueEvent("window_added", key)
        os.queueEvent("windows_paint")
        return key
    end,

    remove = function(self,windowID)
        if self.focusedWindowKey == windowID then
            self.focusedWindowKey = nil
        end
        if self.isReadyToResize[1] == true then
            if self.isReadyToResize[2]==windowID then
                self.isReadyToResize[1] = false
            end
        end
        if self.isReadyToDrag[1] == true then
            if self.isReadyToDrag[2]==windowID then
                self.isReadyToDrag[1] = false
            end
        end


        table.remove(self.windowOrder,findIndex(self.windowOrder,windowID))
        self.windows[windowID]=nil
    end,

    windowToFront = function(self, windowKey)
        -- Удаляем окно из списка, если оно уже там
        local index = findIndex(self.windowOrder, windowKey)
        if index then
            table.remove(self.windowOrder, index)
        end
    
        local insertPos = 0
        -- Находим последний индекс, до окна, у которого индекс всегда поверх (alwaysOnTop == false)
        for i, key in ipairs(self.windowOrder) do
            if not self.windows[key].alwaysOnTop then
                insertPos = i
            end
        end
    
        -- Вставляем windowKey сразу после найденного элемента
        table.insert(self.windowOrder, insertPos + 1, windowKey)
    end,

    windowToBack = function(self, windowKey)
        -- Удаляем окно из списка, если оно уже там
        local index = findIndex(self.windowOrder, windowKey)
        if index then
            table.remove(self.windowOrder, index)
        end
        -- Добавляем в конец
        table.insert(self.windowOrder, 1, windowKey)
    end,





    LBMouseDownPos = nil,
    MBMouseDownPos = nil,
    RBMouseDownPos = nil,

    isMouseWasDragged = false,
    clickedWindow = nil,
    process = function(self, eData)
        local function inWindow(window,clickPos)
            
            return clickPos.x >= window.pos:get().x and 
                clickPos.x <= window.pos:get().x + window.size:get().x - 1 and 
                clickPos.y >= window.pos:get().y and 
                clickPos.y <= window.pos:get().y + window.size:get().y - 1
        end

        local function inContent(window,x,y)
            local borderIndents = window.borderManager:getTouchIndents(window)
            return 
                false
        end

        if eData[1] == "mouse_up" then
            local button, x, y = eData[2], eData[3], eData[4]
            local buttonName = button == 1 and "LBM" or button == 2 and "RBM" or "MBM"

            
            if not self.isMouseWasDragged then
                if self.clickedWindow~=nil then
                    local window = self.clickedWindow
                    
                    if buttonName == "LBM" then

                        self.isReadyToDrag[1]=false
                        self.isReadyToResize[1]=false

                        if self.LBMouseDownPos ~= nil then
                            window:triggerMouseListeners({
                                type = "mouse click",
                                pos = {
                                    x= self.LBMouseDownPos.x-window.pos:get().x+1,
                                    y= self.LBMouseDownPos.y-window.pos:get().y+1
                                },
                                buttonName = buttonName
                            })
                        end
                        self.LBMouseDownPos = nil
                    end
                    if buttonName == "MBM" then
                        if self.MBMouseDownPos ~= nil then
                            window:triggerMouseListeners({
                                type = "mouse click",
                                pos = {
                                    x= self.MBMouseDownPos.x-window.pos:get().x+1,
                                    y= self.MBMouseDownPos.y-window.pos:get().y+1
                                },
                                buttonName = buttonName
                            })
                            self.MBMouseDownPos = nil
                            
                        end
                    end
                    if buttonName == "RBM" then
                        if self.RBMouseDownPos ~= nil then
                            local mEvent = {
                                type = "mouse click",
                                pos = {
                                    x= self.RBMouseDownPos.x-window.pos:get().x+1,
                                    y= self.RBMouseDownPos.y-window.pos:get().y+1
                                },
                                buttonName = buttonName
                            }
                            window:triggerMouseListeners(mEvent)
                            self.RBMouseDownPos=nil
                        end
                    end
                end
            end

            local function removeMouseDown()
                if buttonName == "LBM" then
                    self.LBMouseDownPos = nil
                end
                if buttonName == "MBM" then
                    self.MBMouseDownPos = nil
                end
                if buttonName == "RBM" then
                    self.RBMouseDownPos=nil
                end
            end

            removeMouseDown()
            os.queueEvent("windows_paint")
        end

        if eData[1] == "mouse_click" then
            
            local button, x, y = eData[2], eData[3], eData[4]
            local buttonName = button == 1 and "LBM" or button == 2 and "RBM" or "MBM"
            local mousePos = {
                x = eData[3],
                y = eData[4]
            }

            if buttonName == "LBM" then
                self.LBMouseDownPos=mousePos
            end
            if buttonName == "MBM" then
                self.MBMouseDownPos=mousePos
            end
            if buttonName == "RBM" then
                self.RBMouseDownPos=mousePos
            end

            local foundFocused = false
            self.isReadyToDrag = {false}
            self.isReadyToResize = {false}
            self.edgeClicked = {false}self.isMouseWasDragged = false

            local focusedWindowKey = nil
            local focusedWindowOrderIndex = nil


            --пройтись по всем окнам
            for i = #self.windowOrder, 1, -1 do
                local windowKey = self.windowOrder[i]
                local window = self.windows[windowKey]

                if not window.isHidden then
                    if inWindow(window,mousePos) then
                        foundFocused = true
                        local inWindowClickEvent = {
                            pos = {
                                x= mousePos.x-window.pos:get().x+1,
                                y= mousePos.y-window.pos:get().y+1
                            },
                            button = button
                        }
                        if button == 1 then
                            local mEvent = {
                                type = "mouse down",
                                pos = {
                                    x= mousePos.x-window.pos:get().x+1,
                                    y= mousePos.y-window.pos:get().y+1
                                },
                                buttonName = buttonName
                            }

                            window:triggerMouseListeners(mEvent)
                        end
                    end

                    if inContent(window,x,y) then
                        window.isFocused = true
                        foundFocused = true

                        focusedWindowKey = windowKey
                        focusedWindowOrderIndex = i

                        local inWindowX = x - window.x + 1
                        local inWindowY = y - window.y + 1

                        local borderSize = 1

                        local inContentX = inWindowX-1
                        local inContentY = inWindowY-1

                        if eData[1] == "mouse_click" or eData[1] == "mouse_scroll"  then
                            os.queueEvent("wind mouse down",{
                                windowID = windowKey,
                                type = eData[1],
                                scrollValue = eData[2],
                                x = inContentX,
                                y = inContentY
                            })
                        end
                    end
                end

                if foundFocused then
                    window.setFocus()
                    window.isFocused = true
                    focusedWindowKey = windowKey
                    focusedWindowOrderIndex = i

                    if self.clickedWindow ~= nil and self.clickedWindow ~= window then
                        self.clickedWindow.removeFocus()
                    end
                    self.clickedWindow = window

                    break
                else
                    if self.clickedWindow~=nil then
                        self.clickedWindow.removeFocus()
                    end
                    self.clickedWindow = nil
                end
                
            end
            if self.focusedWindowKey~=nil then
                if self.focusedWindowKey ~= focusedWindowKey then
                    if foundFocused then
                        if self.focusedWindowKey ~= nil then
                            self.windows[self.focusedWindowKey].isFocused = false
                        end 
                        self.focusedWindowKey = focusedWindowKey
                        
                        if not self.windows[self.focusedWindowKey].alwaysOnBack then
                            self:windowToFront(focusedWindowKey)
                        end
                        
                    else
                        if self.focusedWindowKey ~= nil then
                            self.windows[self.focusedWindowKey].isFocused = false
                        end 
                        self.focusedWindowKey = nil
                    end
                end
            end

            os.queueEvent("windows_paint")
        end
        if eData[1] == "mouse_drag" then
            self.isMouseWasDragged=true
            local x, y = eData[3], eData[4]

            if self.edgeClicked[1] then
                --если перемещается в направлении ребра, тогда изменять размер, иначе изменять позицию 
                local wind = self.windows[self.edgeClicked[2]]

                local inWindowFrameClickedX = self.edgeClicked[4]
                local inWindowFrameClickedY = self.edgeClicked[5]

                local inScreenClickedX = (wind.pos:get().x+inWindowFrameClickedX-1)
                local inScreenClickedY = (wind.pos:get().y+inWindowFrameClickedY-1)

                if self.edgeClicked[3] == "left edge" or self.edgeClicked[3] == "right edge" then
                    if y>=inScreenClickedY and y<=inScreenClickedY then
                        if self.edgeClicked[3] == "left edge" then 
                            self.isReadyToResize = {
                                true,
                                self.edgeClicked[2],
                                "left edge",
                                wind.pos:get().x+self.edgeClicked[4]-1,
                                wind.pos:get().y+self.edgeClicked[5]-1,
                                wind.content.size:get().x,
                                wind.content.size:get().y,
                                wind.getContentInScreenPos().x,
                                wind.getContentInScreenPos().y
                            }
                        end
                        if self.edgeClicked[3] == "right edge" then 
                            self.isReadyToResize = {
                                true,
                                self.edgeClicked[2],
                                "right edge",
                                wind.pos:get().x+self.edgeClicked[4]-1,
                                wind.pos:get().y+self.edgeClicked[5]-1,
                                wind.content.size:get().x,
                                wind.content.size:get().y,
                                wind.getContentInScreenPos().x,
                                wind.getContentInScreenPos().y
                            }
                        end
                    else
                        self.isReadyToDrag = {
                            true,
                            self.edgeClicked[2],
                            inWindowFrameClickedX-wind.content.pos:get().x,
                            inWindowFrameClickedY-wind.content.pos:get().y
                        }
                    end
                end
                if self.edgeClicked[3] == "down edge" then
                    if x>=inScreenClickedX and x<=inScreenClickedX then
                        self.isReadyToResize = {
                            true,
                            self.edgeClicked[2],
                            "down edge",
                            wind.pos:get().x+self.edgeClicked[4]-1,
                            wind.pos:get().y+self.edgeClicked[5]-1,
                            wind.content.size:get().x,
                            wind.content.size:get().y,
                            wind.getContentInScreenPos().x,
                            wind.getContentInScreenPos().y
                        }
                    else
                        self.isReadyToDrag = {
                            true,
                            self.edgeClicked[2],
                            inWindowFrameClickedX-wind.content.pos:get().x,
                            inWindowFrameClickedY-wind.content.pos:get().y
                        }
                    end
                end
                self.edgeClicked[1]=false
            end
            if self.isReadyToDrag[1] then
                local wind = self.windows[self.isReadyToDrag[2]]

                wind.setPos({
                    x= x - self.isReadyToDrag[3],
                    y= y - self.isReadyToDrag[4]
                })
            end
            if self.isReadyToResize[1] then
                local windowKey = self.isReadyToResize[2]
                local wind = self.windows[windowKey]

                local oldX = self.isReadyToResize[4]
                local oldY = self.isReadyToResize[5]

                local oldWidth = self.isReadyToResize[6]
                local oldHeight = self.isReadyToResize[7]

                local oldPosX = self.isReadyToResize[8]
                local oldPosY = self.isReadyToResize[9]

                local changeX = x- oldX
                local changeY = y- oldY
                
                local maxWidth  = 7 
                local maxHeight = 2

                if self.isReadyToResize[3] == "leftUp" then
                    wind.setSize({
                        x=math.max (maxWidth, oldWidth-changeX),
                        y=math.max (maxHeight, oldHeight-changeY)
                    })
                    wind.setPos({
                        x = math.min(oldPosX+oldWidth-maxWidth,oldPosX+changeX),
                        y = math.min(oldPosY+oldHeight-maxHeight,oldPosY+changeY),
                    })
                end

                if self.isReadyToResize[3] == "leftDown" then
                    wind.setSize({
                        x=math.max (maxWidth, oldWidth-changeX),
                        y=math.max (maxHeight, oldHeight+changeY)
                    })
                    wind.setPos({
                        x = math.min(oldPosX+oldWidth-maxWidth,oldPosX+changeX),
                        y = wind.getContentInScreenPos().y,
                    })
                end

                if self.isReadyToResize[3] == "rightUp" then
                    wind.setSize({
                        x=math.max (maxWidth, oldWidth+changeX),
                        y=math.max (maxHeight, oldHeight-changeY)
                    })
                    wind.setPos({
                        x = wind.getContentInScreenPos().x,
                        y = math.min(oldPosY+oldHeight-maxHeight,oldPosY+changeY),
                    })
                end

                if self.isReadyToResize[3] == "rightDown" then
                    wind.setSize({
                        x=math.max (maxWidth, oldWidth+changeX),
                        y=math.max (maxHeight, oldHeight+changeY)
                    })
                    
                end
                if self.isReadyToResize[3] == "right edge" then
                    wind.setSize({
                        x=math.max (maxWidth, oldWidth+changeX),
                        y= wind.content.size:get().y
                    })
                    
                end
                if self.isReadyToResize[3] == "left edge" then
                    wind.setSize({
                        x= math.max (maxWidth, oldWidth - changeX),
                        y= wind.content.size:get().y
                    })
                    wind.setPos({
                        x = math.min(oldPosX+oldWidth-maxWidth,oldPosX+changeX),
                        y = wind.getContentInScreenPos().y
                    })
                    
                end
                if self.isReadyToResize[3] == "down edge" then
                    wind.setSize({
                        x= wind.content.size:get().x,
                        y= math.max (maxHeight, oldHeight+ changeY-1)
                    })
                    
                end

                -- os.queueEvent("wind resize",{
                --     windowID = windowKey,
                --     newSizeX = wind.size:get().x,
                --     newSizeY = wind.size:get().y
                -- })
            end

            if self.clickedWindow~=nil then
                if self.LBMouseDownPos~=nil then
                    local mEvent = {
                        type = "mouse drag",
                        pos = {
                            x= x-self.clickedWindow.pos:get().x+1,
                            y= y-self.clickedWindow.pos:get().y+1
                        },
                        buttonName = "LBM"
                    }
                    self.clickedWindow:triggerMouseListeners(mEvent)
                end
                if self.RBMouseDownPos~=nil then
                    local mEvent = {
                        type = "mouse drag",
                        pos = {
                            x= x-self.clickedWindow.pos:get().x+1,
                            y= y-self.clickedWindow.pos:get().y+1
                        },
                        buttonName = "RBM"
                    }
                    self.clickedWindow:triggerMouseListeners(mEvent)
                end
                if self.MBMouseDownPos~=nil then
                    local mEvent = {
                        type = "mouse drag",
                        pos = {
                            x= x-self.clickedWindow.pos:get().x+1,
                            y= y-self.clickedWindow.pos:get().y+1
                        },
                        buttonName = "MBM"
                    }
                    self.clickedWindow:triggerMouseListeners(mEvent)
                end
            end

            os.queueEvent("windows_paint")
        end

        if eData[1] == "windows_paint" then
            self:drawWindows()
        end
    end,

    tryToGetScreenLines = function(self,processID,windowID)
        local cor = self.coroutinesManager.coroutines[processID]
        if cor == nil then
            return nil, "Process "..processID.." is not exist"
        end

        local status, message = coroutine.resume(cor,{
            type = "window",
            windowID = windowID,
            info = "paint request"
        })

        

        local windowScreenLines
        if message.type == "window" and 
            message.windowID == windowID and 
            message.info == "paint response" 
        then
            windowScreenLines = message.data
        else
            error("window "..self.windows[windowID].title.."paint response not valid "..textutils.serialise(message))
        end

        return windowScreenLines
    end,

    drawWindows = function(self)
        self.mainLinesM:fill(colorsChar.blue)
        for _, windowKey in ipairs(self.windowOrder) do
            local window = self.windows[windowKey]
            if not window.isHidden then
                self.mainLinesM:addLines(window.pos:get(),window:getLines())
            end
        end
        screenAPI:printLines(self.mainLinesM.lines)
    end
}

return windowM