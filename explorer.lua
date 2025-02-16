return function(pAPI)
    local displaySize = pAPI.getDisplayInfo().size

    local directory = "/"

    local selectedItem = nil

    local scrollPosition = 2

    local windowSize = {
        x = math.floor(displaySize.x/2),
        y = math.floor(displaySize.y/2)
    }
    local window = pAPI:createWindow({
        title = "Explorer",
        pos = {
            x=math.floor(displaySize.x/2) - math.floor(windowSize.x/2),
            y=math.floor(displaySize.y/2) - math.floor(windowSize.y/2),
        },
        size = windowSize,
        borderVisibility = true,
    })
    window:addMouseListener(function(mEvent)
        if mEvent.type == "mouse_scroll" then
            scrollPosition=scrollPosition+mEvent.scrollValue *-1
        end
    end)

    local directoryTEXTComponent = pAPI:createTText({
        text = "Directory is : "..directory,
    })
    directoryTEXTComponent.bkColor = colorsChar.white
    directoryTEXTComponent.leftSpace = 1

    local fileComponents = {}

    local localDirFiles = fs.list(directory)

    for key, filename in pairs (localDirFiles) do
        local fileComp = pAPI:createTText({
            text = filename,
        })
        fileComp.leftSpace=1
        fileComp.textPos = "left"
        if fs.isDir(directory..filename) then
            fileComp.textColor = colorsChar.red
        end
        table.insert(fileComponents, fileComp)
        
        fileComp:addMouseListener(function(mEvent)
            if mEvent.type == "mouse_click" then
                if selectedItem ~= fileComp then
                    fileComp.bkColor = colorsChar.lightGray
                    if selectedItem ~= nil then
                        selectedItem.bkColor = colorsChar.white
                    end
                    selectedItem = fileComp
                else
                    dofile(directory..filename)
                end
            end
        end)

        window:add(fileComp)
    end

    window.layoutManager = function()
        directoryTEXTComponent.size = {
            x= window.size.x,
            y= 1
        }
        directoryTEXTComponent.pos = {
            x=1,
            y=1
        }
        for key, fileComp in pairs (fileComponents) do
            fileComp.size = {
                x= window.size.x,
                y= 1
            }
            fileComp.pos = {
                x=1,
                y=scrollPosition+key
            }
        end
    end
    window:add(directoryTEXTComponent)

    pAPI:runLoop()
end