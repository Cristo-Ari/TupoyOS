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
            window.borderManager = dofile("tupoyOS/borderManager.lua")
            window.windowID = key
    
            window:addCustomPaint(function (linesM)
                linesM:clear()
            end)
            return window
        end
        local window = createWindow()

        local function createContent(upLines)
            local function findContentPos()
                local out = {
                    x=1,
                    y=#upLines.components+1
                }
                -- print(textutils.serialise(out))
                -- os.sleep(1)
                return out
            end
            local findContentSize = function()
                return({
                    x=window.size:get().x,
                    y=window.size:get().y-#upLines.components+1
                })
            end

            local content = compAPI:createComponent()
            content.size:set(findContentSize())
            content.pos:set(findContentPos())
    
            content:addCustomPaint (function (linesM)
                linesM:clear()
                local windowLines = self:tryToGetScreenLines(window.processID,window.windowID)
                if windowLines ~= nil then
                    linesM:addLines(
                        {x=1,y=1},
                        windowLines
                    )
                else
                    local size = linesM.size
                    local colors = {}
                    for i = 1,50 do
                        linesM:drawSquare(
                        {
                            x=math.random(1,linesM.size.x),
                            y=math.random(1,linesM.size.y)
                        },{
                            x=math.random(1,4),
                            y=math.random(1,3)
                        },
                        colorsChar.orange
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
                
                self.coroutinesManager:sendMessage(window.processID,{
                    type = "window",
                    info = "window content clicked",
                    windowID = window.windowID,
                    mEvent = mEvent
                })
            end)
            window.size:addListener(function()
                content.size:set(findContentSize())
                content.pos:set(findContentPos())
            end)

            return content
        end

        local function createBorder(window)
            local border = compAPI:createComponent()

            border.additionalMenus = {}
            
            border.addAdditionalMenu = function(self,newMenu)
                table.insert(border.additionalMenus,newMenu)
                local createAdditionalMenu = function()
                    local menuComp = compAPI:createComponent()
                    border.additionalMenusLayoutManager.setAviablePos(menuComp)
                    return menuComp
                end
                border:add(createAdditionalMenu())
            end

            border.additionalMenusLayoutManager = {
                setAviablePos = function(newMenu)
                    newMenu.pos:set({x=1,y=1})
                end
            }
            border.ignoreSelfListenersWhenClickedInsideComponent = true

            border.size:set({x=window.size:get().x,y=window.size:get().y})

            border.pos:set({x=1,y=1})
            border.borderColor = window.isFocused and colorsChar.lightGray or colorsChar.gray

            local closeMenuSize = {
                x=7,
                y=1
            }

            local titleMenuSize = {
                x=7,
                y=1
            }
    
            border:addCustomPaint(function(linesM)
                linesM:clear()
    
                -- local wSize = window.size:get()
                -- local wPos = window.pos:get()
                -- border.borderColor = window.isFocused and colorsChar.lightGray or colorsChar.gray
                
                -- local function drawLeftSide()
                --     linesM:drawSquare({x=1,y=2},{x=1,y=wSize.y-2},{
                --         bkColor = 0,
                --         tColor = border.borderColor,
                --         text = "\149"
                --     })
                -- end
                -- local function drawRightSide()
                --     linesM:drawSquare({x=wSize.x,y=2},{x=1,y=wSize.y-2},{
                --         bkColor = border.borderColor,
                --         tColor = 0,
                --         text = "\149",
                --         tColorIsBackground = true
                --     })
                -- end
                -- local function drawUpSide ()
                --     local hls = "\143" -- horizontal line symbol
                --     linesM:drawSquare({
                --         x=titleMenuSize.x+1,y=1
                --     },{
                --         x=wSize.x-closeMenuSize.x-titleMenuSize.x,
                --         y=1
                --     },{
                --         bkColor = border.borderColor,
                --         tColor = 0,
                --         text = hls,
                --         tColorIsBackground = true
                --     })
                -- end
                -- local function drawDownSide ()
                --     local hls = "\143" -- horizontal line symbol
                --     linesM:drawSquare({x=2,y=wSize.y},{x=wSize.x-2,y=1},{
                --         bkColor = border.borderColor,
                --         tColor = 0,
                --         text = hls,
                --         tColorIsBackground = true,
                --     })
                    
                -- end

                -- drawLeftSide()
                -- drawRightSide()
                -- drawUpSide()
                -- drawDownSide()

    
            end)
            return border
        end

        local addCorners = function(border, upLines)
            local createLeftDownCornerComp = function()
                local findLeftCornerPos = function()
                    return {
                        x=1,
                        y=border.size:get().y
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.pos:set(findLeftCornerPos())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    --drawLeftDown corner
                    local ldCornerSymbol = "\138"
                    linesM:drawPixel(1,1,{
                        bkColor = border.borderColor,
                        tColor = 0,
                        text = ldCornerSymbol,
                        tColorIsBackground = true,
                    })
                end)
                button:addMouseListener(function()
                    self.isReadyToResize = {
                        true,
                        key,
                        "leftDown"
                        ,window.pos:get().x,
                        window.pos:get().y,
                        window.size:get().x,
                        window.size:get().y
                    }
                    -- print("Left down CornerPos Clicked")
                    -- os.sleep(1)
                end)
                border.size:addListener(function ()
                    button.pos:set(findLeftCornerPos())
                end)
                return (button)
            
            end
            border:add(createLeftDownCornerComp())

            local createRightDownCornerComp = function()
                local findRightDownCornerPos = function()
                    return {
                        x=border.size:get().x,
                        y=border.size:get().y
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.pos:set(findRightDownCornerPos())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    --drawRightDown corner
                    local rdCornerSymbol = "\133"
                    linesM:drawPixel(1,1,{
                        bkColor = border.borderColor,
                        tColor = 0,
                        text = rdCornerSymbol,
                        tColorIsBackground = true,
                    })
                end)
                button:addMouseListener(function()
                    self.isReadyToResize = {
                        true,
                        key,
                        "rightDown",
                        window.pos:get().x,
                        window.pos:get().y,
                        window.size:get().x,
                        window.size:get().y
                    }
                    -- print("RightDownCorner Clicked")
                    -- os.sleep(1)
                end)
                border.size:addListener(function ()
                    button.pos:set(findRightDownCornerPos())
                end)
                return (button)
            
            end
            border:add(createRightDownCornerComp())

            local createRightUpCornerComp = function()
                local findRightDownCornerPos = function()
                    return {
                        x=border.size:get().x,
                        y=1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.pos:set(findRightDownCornerPos())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    -- if #upLines.components>1 then
                    --     local lues = "\130" --rightUpEdgeSymbol
                    --     linesM:fill({
                    --         text = lues,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- else
                    --     local hls = "\143" -- horizontal line symbol
                    --     linesM:fill({
                    --         text = hls,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- end
                end)

                button:addMouseListener(function()
                    self.isReadyToResize = {true,key,"rightUp",window.pos:get().x,window.pos:get().y,window.size:get().x,window.size:get().y}
                    -- print("RightUpCorner Clicked")
                    -- os.sleep(1)
                end)

                border.size:addListener(function ()
                    button.pos:set(findRightDownCornerPos())
                end)
                return (button)
            
            end
            border:add(createRightUpCornerComp())

            local createLeftUpCornerComp = function()
                local findLeftUpCornerComp = function()
                    return {
                        x=1,
                        y=1
                    }
                end
                local button = compAPI:createComponent()
                button.size:set({x=1,y=1})
                button.pos:set(findLeftUpCornerComp())
                button:addCustomPaint(function(linesM)
                    linesM:clear()
                    -- if #upLines.components>1 then
                    --     local lues = "\129" --leftUpEdgeSymbol
                    --     linesM:fill({
                    --         text = lues,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- else
                    --     local hls = "\143" -- horizontal line symbol
                    --     linesM:fill({
                    --         text = hls,
                    --         tColor = 0,
                    --         bkColor = colorsChar.gray,
                    --         tColorIsBackground = true
                    --     })
                    -- end
                end)

                button:addMouseListener(function()
                    self.isReadyToResize = {true,key,"leftUp",window.pos:get().x,window.pos:get().y,window.size:get().x,window.size:get().y}
                    -- print("leftUpBorderClicked")
                    -- os.sleep(1)
                end)

                border.size:addListener(function ()
                    button.pos:set(findLeftUpCornerComp())
                end)
                return (button)
            
            end
            border:add(createLeftUpCornerComp())
        end

        local addEdges = function (border, upLines)
            local createleftEdge = function()
                local findleftEdgeSize = function()
                    return {
                        x=1,
                        y=window.size:get().y-2
                    }
                end
                local findLeftEdgePos = function()
                    return {
                        x=1,
                        y=2
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findleftEdgeSize())
                button.pos:set(findLeftEdgePos())

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    linesM:fill({
                        bkColor = 0,
                        tColor = border.borderColor,
                        text = "\149"
                    })
                end)

                button:addMouseListener(function(mEvent)
                    self.edgeClicked = {
                        true,
                        key,
                        "left edge",
                        button.pos:get().x+mEvent.pos.x-1,
                        button.pos:get().y+mEvent.pos.y-1,
                    }
                end)

                window.size:addListener(function()
                    button.pos:set(findLeftEdgePos())
                    button.size:set(findleftEdgeSize())
                end)

                return button
            end

            local createRightEdge = function()
                local findRightEdgeSize = function()
                    return {
                        x=1,
                        y=border.size:get().y-2
                    }
                end
                local findRightEdgePos = function()
                    return {
                        x=border.size:get().x,
                        y=2
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findRightEdgeSize())
                button.pos:set(findRightEdgePos())

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    linesM:fill({
                        bkColor = border.borderColor,
                        tColor = 0,
                        text = "\149",
                        tColorIsBackground = true
                    })
                end)

                border.size:addListener(function ()
                    button.size:set(findRightEdgeSize())
                    button.pos:set(findRightEdgePos())
                end)

                button:addMouseListener(function(mEvent)
                    self.edgeClicked = {
                        true,
                        key,
                        "right edge",
                        button.pos:get().x+mEvent.pos.x-1,
                        button.pos:get().y+mEvent.pos.y-1,
                    }
                end)
                return button
            end
            
            local createUpEdge = function()
                
                local findUpEdgeSize = function()
                    return {
                        x=window.size:get().x-2,
                        y=1
                    }
                end
                local findUpEdgePos = function()
                    return {
                        x=2,
                        y=1
                    }
                end

                local button = compAPI:createComponent()
                button.isGhost = true
                button.size:set(findUpEdgeSize())
                button.pos:set(findUpEdgePos())

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    -- local hls = "\143" -- horizontal line symbol
                    -- linesM:fill({
                    --     bkColor = border.borderColor,
                    --     tColor = 0,
                    --     text = hls,
                    --     tColorIsBackground = true
                    -- })
                end)

                button:addMouseListener(function(mEvent)
                    self.isReadyToDrag = {
                        true,
                        key, 
                        button.pos:get().x+mEvent.pos.x-1,
                        button.pos:get().y+mEvent.pos.y-1,
                    }
                    -- print("dibily3")
                    -- os.sleep(1)
                end)

                border.size:addListener(function()
                    button.size:set(findUpEdgeSize())
                    button.pos:set(findUpEdgePos())
                end)
                
                return button
            end

            local createDownEdge = function()
                local findDownEdgeSize = function()
                    return {
                        x=window.size:get().x-2,
                        y=1
                    }
                end
                local findDownEdgePos = function()
                    return {
                        x=2,
                        y=window.size:get().y
                    }
                end
                local button = compAPI:createComponent()
                button.size:set(findDownEdgeSize())
                button.pos:set(findDownEdgePos())

                button:addCustomPaint(function (linesM)
                    linesM:clear()
                    local hls = "\143" -- horizontal line symbol
                    linesM:fill({
                        bkColor = border.borderColor,
                        tColor = 0,
                        text = hls,
                        tColorIsBackground = true,
                    })
                end)

                button:addMouseListener(function(mEvent)
                    self.edgeClicked = {
                        true,
                        key,
                        "down edge",
                        button.pos:get().x+mEvent.pos.x-1,
                        button.pos:get().y+mEvent.pos.y-1,
                    }
                end)
                border.size:addListener(function()
                    button.size:set(findDownEdgeSize())
                    button.pos:set(findDownEdgePos())
                end)
                return button
            end

            border:add(createleftEdge())
            border:add(createRightEdge())
            border:add(createUpEdge())
            border:add(createDownEdge())
        end

        local addBorderMenuBaseElements = function(upLines,border)
            local line1 = upLines.createLine()
            local line2 =upLines.createLine()
            -- local line3 =upLines.createLine()

            local createCloseMenu = function(line)
                local function findCloseMenuSize()
                    return {
                        x=5,
                        y=1
                    }
                end

                local closeMenu = compAPI:createComponent()
                closeMenu.size:set(findCloseMenuSize())

                closeMenu:addCustomPaint(function(linesM)
                    linesM:clear()
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

                closeMenu:add(
                    createButton(
                        {
                            bkColor= 0,
                            tColor = colorsChar.black,
                            text = "-"
                        }
                        ,function()
                            print("HelloWorld")
                            os.sleep(1)
                        end
                    )
                )
                closeMenu:add(createButton({
                    bkColor= 0,
                    tColor = colorsChar.black,
                    text = "\30"
                },function()
                    print("HelloWorld")
                    os.sleep(1)
                end))
                closeMenu:add(createButton({
                    bkColor= 0,
                    tColor = colorsChar.black,
                    text = "\215"
                },function()
                    print("HelloWorld")
                    os.sleep(1)
                end))
                
                return closeMenu
            end

            local createTitleMenu = function(line,border)
                local function findTitleMenuSize()
                    return {
                        x=#window.title,
                        y=1
                    }
                end
                local titleMenu = compAPI:createComponent()
                titleMenu.size:set(findTitleMenuSize())

                line.size:addListener(function(sizeEvent)
                    titleMenu.size:set(findTitleMenuSize())
                    -- local wSizeX= window.size:get().x
                    -- local clSizeX = line.size:get().x
                    -- local someOffset = (wSizeX>=clSizeX and 1 or 0)
                    -- local aviableSizeX = (wSizeX-clSizeX)+ someOffset
                    -- if wSizeX>clSizeX then
                    --     titleMenuSize.x= math.min(aviableSizeX,#window.title+2)
                    --     titleMenu.size:set({
                    --         x=titleMenuSize.x,
                    --         y=1
                    --     })
                    -- else
                    --     titleMenuSize.x= 0
                    --     titleMenu.size:set({
                    --         x=titleMenuSize.x,
                    --         y=1
                    --     })
                    -- end
                end)

                titleMenu:addCustomPaint(function(linesM)
                    linesM:clear()
                    linesM:drawText(
                        {
                            x=1,
                            y=1
                        },
                        window.title,
                        colorsChar.black,
                        border.borderColor
                    )
                end)
                return titleMenu
            end

            local closeMenu = createCloseMenu(line1)
            upLines.addUpLineBorderElement(
                closeMenu,
                1,
                "right"
            )
            local closeMenu = createCloseMenu(line1)
            upLines.addUpLineBorderElement(
                closeMenu,
                1,
                "right"
            )
            upLines.addUpLineBorderElement(
                createTitleMenu(line1,border),
                1,
                "left"
            )
        end

        local function createUpLines(border)
            local upLines = compAPI:createComponent()

            local function findUpLinesPos()
                return {
                    x=1,
                    y=1
                }
            end
            local function findUpLinesSize()
                local out = {
                    x=border.size:get().x,
                    y=#upLines.components
                }
                return out
            end
            
            upLines:addCustomPaint(function(linesM)
                linesM:clear()
            end)
            upLines.pos:set(findUpLinesPos())
            upLines.size:set(findUpLinesSize())
            upLines.createLine = function()

                local lineCount = #upLines.components+1

                local function findLinePos(lineCount)
                    return {
                        x=1,
                        y=lineCount
                    }
                end
                local function findLineSize()
                    return {
                        x=upLines.size:get().x,
                        y=1
                    }
                end
                local lineComp = compAPI:createComponent()
                
                lineComp.size:set(findLineSize())
                lineComp.pos:set(findLinePos(lineCount))
                lineComp:addCustomPaint(function(linesM)
                    linesM:clear()
                    if lineCount==1 then
                        if #upLines.components ==1 then
                            local hls = "\143" -- horizontal line symbol
                            linesM:fill({
                                bkColor = border.borderColor,
                                tColor = 0,
                                text = hls,
                                tColorIsBackground = true
                            })
                            for key, comp in pairs(lineComp.components) do
                                linesM:drawSquare(comp.pos:get(),comp.size:get(),{
                                    bkColor = 0,
                                    tColor = 0,
                                    text = 0,
                                    tColorIsBackground = 0
                                })
                            end
                        else
                            linesM:fill({
                                bkColor = border.borderColor,
                                tColor = 0,
                                text = " ",
                            })
                        end
                    else
                        if lineCount == #upLines.components then
                            linesM:fill({
                                bkColor = border.borderColor,
                                tColor = 0,
                                text = " ",
                            })
                            local rues = "\130" --rightUpEdgeSymbol
                            linesM:drawPixel(
                                linesM.size.x,
                                linesM.size.y,
                                {
                                    text = rues,
                                    tColor = 0,
                                    bkColor = colorsChar.gray,
                                    tColorIsBackground = true
                                }
                            )
                            local lues = "\129" --leftUpEdgeSymbol
                            linesM:drawPixel(
                                1,
                                1,
                                {
                                    text = lues,
                                    tColor = 0,
                                    bkColor = colorsChar.gray,
                                    tColorIsBackground = true
                                }
                            )
                        else
                            linesM:fill({
                                bkColor = border.borderColor,
                                tColor = 0,
                                text = " ",
                            })
                        end
                    end
                end)

                lineComp.rightComponents = {}
                lineComp.leftComponents = {}

                upLines.size:addListener(function()
                    lineComp.size:set(findLineSize())
                    lineComp.pos:set(findLinePos(lineCount))
                end)

                upLines:add(lineComp)
                return(lineComp)
            end

            upLines.getLine = function(num)
                return upLines.components[num]
            end

            upLines.addUpLineBorderElement = function(component,lineCount,elementPos )
                local line = upLines.getLine(lineCount)
                if elementPos == "left" then
                    table.insert(line.leftComponents,component)
                elseif elementPos == "right" then
                    table.insert(line.rightComponents,component)
                else
                    error("addUpLineBorderElement pos not set")
                end

                
                local function findEdgedComponentPos()
                    if elementPos == "left" then
                        return {
                            x=1,
                            y=1
                        }
                    elseif elementPos == "right" then
                        local aviablePosX = line.size:get().x-component.size:get().x-1

                        for key, comp in pairs(line.rightComponents) do
                            if comp~= component then
                                aviablePosX = aviablePosX- comp.size:get().x-2
                            else 
                                break
                            end
                        end

                        return {
                            x=aviablePosX,
                            y=1
                        }
                    
                    end
                end
                local function findInsideComponentPos()
                    return {
                        x=2,
                        y=1
                    }
                end
                local function findEdgedComponentSize()
                    local out = {
                        x=component.size:get().x+2,
                        y=1
                    }
                    return out
                end

                component.pos:set({
                    x=2,
                    y=1
                })

                
                local edgedComp = compAPI:createComponent()
                edgedComp:add(component)
                edgedComp:addCustomPaint(function(linesM)
                    linesM:clear()
                    linesM:drawSquare(
                        {
                            x=2,
                            y=1
                        },
                        {
                            x=component.size:get().x,
                            y=component.size:get().y
                        },
                        {
                            text = " ",
                            tColor = colorsChar.black,
                            bkColor = border.borderColor,
                        }
                    )
                    if lineCount==1 then
                        --right cornder
                        linesM:drawPixel(
                            linesM.size.x,
                            1
                        ,{
                            text = "\130",
                            tColor = 0,
                            bkColor = border.borderColor,
                            tColorIsBackground = true
                        })
                        --left corner
                        linesM:drawPixel(
                            1,
                            1
                        ,{
                            text = "\129",
                            tColor = 0,
                            bkColor = border.borderColor,
                            tColorIsBackground = true
                        })
                    end
                end)
                line.size:addListener(function()
                    edgedComp.size:set(findEdgedComponentSize())
                    edgedComp.pos:set(findEdgedComponentPos())
                end)
                

                line:add(edgedComp)
            end

            
            border.size:addListener(function()
                upLines.pos:set(findUpLinesPos())
                upLines.size:set(findUpLinesSize())
            end)
            return upLines
        end

        local border = createBorder(window)
        local upLines = createUpLines(border)
        border:add(upLines)
        addEdges(border,upLines)
        addCorners(border, upLines)
        local content = createContent(upLines)
        addBorderMenuBaseElements(upLines,border)
        window.content = content
        --так как сначала курсор кликает на слой с рамкой, тогда сама рамка триггерит контент

        border:addMouseListener(function (mEvent)
            local contentPos = content.pos:get()
            local contentSize = content.size:get()

            local x = mEvent.pos.x
            local y = mEvent.pos.y
            if x>=contentPos.x and 
                x<=contentPos.x+contentSize.x-1 and
                y>=contentPos.y and
                y<=contentPos.y+contentSize.y-1
            then
                local copyEvent = {
                    clickType = mEvent.clickType,
                    pos = {
                        x=x-contentPos.x+1,
                        y=y-contentPos.y+1
                    },
                    buttonName = mEvent.buttonName
                }
                content:triggerMouseListeners(copyEvent)
            end
        end)
        window:add(content)
        -- border.addAdditionalMenu({
        --     width = 5
        -- })
        window.size:addListener(function(sizeEvent)
            border.size:set({
                x=window.size:get().x,
                y=window.size:get().y
            })
        end)

        window:add(border)

        --send coroutine resize size info
        window.size:addListener(function()
            self.coroutinesManager:sendMessage(window.processID,{
                type = "window",
                info = "size changed",
                
                windowID = window.windowID,
                newSize = content.size:get()
            })
        end)
        
        

        self.windows[key] = window
        table.insert(self.windowOrder, key)
        os.queueEvent("window_added", key)
        os.queueEvent("windows_paint")
        return key
    end,
    remove = function(self,windowID)
        self.windows[windowID] = nil
        table.remove(self.windowOrder,findIndex(self.windowOrder,windowID))
        os.queueEvent("window_removed", windowID)
        os.queueEvent("windows_paint")
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



        if eData[1] == "mouse_click" then
            
            local button, x, y = eData[2], eData[3], eData[4]
            local clickPos = {
                x = eData[3],
                y = eData[4]
            }

            local foundFocused = false
            self.isReadyToDrag = {false}
            self.isReadyToResize = {false}
            self.edgeClicked = {false}

            local focusedWindowKey = nil
            local focusedWindowOrderIndex = nil


            --пройтись по всем окнам
            for i = #self.windowOrder, 1, -1 do
                local windowKey = self.windowOrder[i]
                local window = self.windows[windowKey]


                if inWindow(window,clickPos) then
                    local inWindowClickEvent = {
                        pos = {
                            x= clickPos.x-window.pos:get().x+1,
                            y= clickPos.y-window.pos:get().y+1
                        },
                        button = button
                    }
                    if button == 1 then
                        local mEvent = {
                            clickType = "double click",
                            pos = {
                                x= clickPos.x-window.pos:get().x+1,
                                y= clickPos.y-window.pos:get().y+1
                            },
                            buttonName = "LBM"
                        }

                        window:triggerMouseListeners(mEvent)
                    end
                end

                if window.borderVisibility then
                    if inWindow(window,clickPos) then
                        window.isFocused = true
                        foundFocused = true

                        focusedWindowKey = windowKey
                        focusedWindowOrderIndex = i

                        local inWindowX = x - window.pos:get().x + 1
                        local inWindowY = y - window.pos:get().y + 1
                        
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

                if foundFocused then 
                    break
                end
                
            end
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

            os.queueEvent("windows_paint")
        end
        if eData[1] == "mouse_drag" then
            local x, y = eData[3], eData[4]

            if self.edgeClicked[1] then
                --если перемещается в направлении ребра, тогда изменять размер, иначе изменять позицию 
                local wind = self.windows[self.edgeClicked[2]]

                local inWindowX = self.edgeClicked[4]
                local inWindowY = self.edgeClicked[5]

                local inScreenClickedX = (wind.pos:get().x+inWindowX-1)
                local inScreenClickedY = (wind.pos:get().y+inWindowY-1)

                if self.edgeClicked[3] == "left edge" or self.edgeClicked[3] == "right edge" then
                    if y>=inScreenClickedY and y<=inScreenClickedY then
                        if self.edgeClicked[3] == "left edge" then 
                            self.isReadyToResize = {
                                true,
                                self.edgeClicked[2],
                                "left edge",
                                wind.pos:get().x,
                                wind.pos:get().y,
                                wind.size:get().x,
                                wind.size:get().y
                            }
                        end
                        if self.edgeClicked[3] == "right edge" then 
                            self.isReadyToResize = {
                                true,
                                self.edgeClicked[2],
                                "right edge",
                                wind.pos:get().x,
                                wind.pos:get().y,
                                wind.size:get().x,
                                wind.size:get().y
                            }
                        end
                    else
                        self.isReadyToDrag = {
                            true,
                            self.edgeClicked[2],
                            inWindowX,
                            inWindowY
                        }
                    end
                end
                if self.edgeClicked[3] == "down edge" then
                    if x>=inScreenClickedX and x<=inScreenClickedX then
                        self.isReadyToResize = {
                            true,
                            self.edgeClicked[2],
                            "down edge",
                            wind.pos:get().x,
                            wind.pos:get().y,
                            wind.size:get().x,
                            wind.size:get().y
                        }
                    else
                        self.isReadyToDrag = {
                            true,
                            self.edgeClicked[2],
                            inWindowX,
                            inWindowY
                        }
                    end
                end
                self.edgeClicked[1]=false
            end



            if self.isReadyToDrag[1] then
                local wind = self.windows[self.isReadyToDrag[2]]

                wind.pos:set({
                    x= x - self.isReadyToDrag[3] + 1,
                    y= y - self.isReadyToDrag[4] + 1
                })

                os.queueEvent("windows_paint")
            end
            if self.isReadyToResize[1] then
                local windowKey = self.isReadyToResize[2]
                local wind = self.windows[windowKey]

                local oldX = self.isReadyToResize[4]
                local oldY = self.isReadyToResize[5]

                local oldWidth = self.isReadyToResize[6]
                local oldHeight = self.isReadyToResize[7]

                local changeX = x- oldX
                local changeY = y- oldY
                
                local maxWidth  = 7 
                local maxHeight = 2

                if self.isReadyToResize[3] == "leftUp" then
                    -- print("oldX")
                    -- print(oldX)
                    -- os.sleep(1)
                    wind.size:set({
                        x=math.max (maxWidth, self.isReadyToResize[6]-changeX),
                        y=math.max (maxHeight, self.isReadyToResize[7]-changeY)
                    })
                    wind.pos:set({
                        x = math.min(oldX+(oldWidth-1) - (wind.size:get().x-1),x),
                        y = math.min(oldY+(oldHeight-1) - (wind.size:get().y-1),y)
                    })
                end

                if self.isReadyToResize[3] == "leftDown" then
                    wind.size:set({
                        x= math.max (maxWidth, oldWidth - changeX),
                        y= math.max (maxHeight, changeY+1)
                    })
                    wind.pos:set({
                        x = math.min(oldX+(oldWidth-1) - (wind.size:get().x-1),x),
                        y = wind.pos:get().y
                    })
                end

                if self.isReadyToResize[3] == "rightUp" then
                    wind.size:set({
                        x= math.max (maxWidth, changeX+1),
                        y= math.max (maxHeight, oldHeight-changeY)
                    })
                    wind.pos:set({
                        x = wind.pos:get().x,
                        y = math.min(oldY+(oldHeight-2),y)
                    })
                end

                if self.isReadyToResize[3] == "rightDown" then
                    wind.size:set({
                        x= math.max (maxWidth, changeX+1),
                        y= math.max (maxHeight, changeY+1)
                    })
                    
                end
                if self.isReadyToResize[3] == "right edge" then
                    wind.size:set({
                        x= math.max (maxWidth, changeX+1),
                        y= wind.size:get().y
                    })
                    
                end
                if self.isReadyToResize[3] == "left edge" then
                    wind.size:set({
                        x= math.max (maxWidth, oldWidth - changeX),
                        y= wind.size:get().y
                    })
                    wind.pos:set({
                        x = math.min(oldX+(oldWidth-1) - (wind.size:get().x-1),x),
                        y = wind.pos:get().y
                    })
                    
                end
                if self.isReadyToResize[3] == "down edge" then
                    wind.size:set({
                        x= wind.size:get().x,
                        y= math.max (maxHeight, changeY+1)
                    })
                    
                end

                -- os.queueEvent("wind resize",{
                --     windowID = windowKey,
                --     newSizeX = wind.size:get().x,
                --     newSizeY = wind.size:get().y
                -- })
                
                os.queueEvent("windows_paint")
            end
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

            if window.borderVisibility == true then
                local position = window.pos:get()
                self.mainLinesM:addLines(position,window:getLines())
            end
        end
        screenAPI:printLines(self.mainLinesM.lines)
    end
}

return windowM