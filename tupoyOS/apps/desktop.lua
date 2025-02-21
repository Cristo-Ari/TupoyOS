return(function(pAPI)
    



    --other params
    local directory = "/DesktopFolder/"
    local selectedItem = nil
    local scrollPosition = 2

    local displaySize = pAPI.getDisplayInfo().size
    --print(textutils.serialise(displaySize))
    local window = pAPI:createWindow({
        title = "Test",
        pos = {x=1,y=1},
        size = {x = displaySize.x, y = displaySize.y-1},
        alwaysOnBack = true,
        borderVisibility = false,
    })
    window.bkColor = colorsChar.black

    local directoryTEXTComponent = pAPI:createTText({
        text = "Directory is : "..directory,
    })
    directoryTEXTComponent.bkColor = colorsChar.white
    directoryTEXTComponent.leftSpace = 1

    local fileComponents = {}

    local localDirFiles = fs.list(directory)

    --place inems params
    local frameSizeX = 7
    local frameSizeY = 4

    local frameSpaceX = 1
    local frameSpaceY = 0

    local iconSizeX = 5
    local iconSizeY = 3

    local numOfCols = 5
    local numOfRows = 5

    local selectedItemBkColor = colorsChar.lightBlue
    local noSelectItemColor = 0


    local colCount =0
    local rowCount = 0

    for key, fileNameText in pairs (localDirFiles) do
        --createFrame = 

        local frame = pAPI:createComponent()
        frame.size.x = frameSizeX
        frame.size.y = frameSizeY
        frame.pos.x = 1+(frameSizeX+frameSpaceX)*colCount
        frame.pos.y = 1+(frameSizeY+frameSpaceY)*rowCount
        frame.bkColor = colorsChar.red
        frame.layoutManager = nil
        frame:addMouseListener(function(mEvent)
            if mEvent.type == "mouse_click" then
                if selectedItem ~= frame then
                    frame.bkColor = selectedItemBkColor
                    if selectedItem ~= nil then
                        selectedItem.bkColor = noSelectItemColor
                    end
                    selectedItem = frame
                end
            end
        end)

        --createText
        local fileName = pAPI:createTText({
            text = fileNameText,
        })
        fileName.leftSpace=0
        fileName.textPos = "left"
        fileName.size.x = frame.size.x
        fileName.size.y = 1
        fileName.pos.x = 1
        fileName.pos.y = frame.size.y

        if fs.isDir(directory..fileNameText) then
            fileName.textColor = colorsChar.red
        end
        table.insert(fileComponents, fileName)

        frame:add(fileName)

        window:add(frame)

        rowCount = rowCount +1
        if rowCount >= numOfRows-1 then
            rowCount = 0
            colCount = colCount +1
        end
    end
    window.layoutManager = nil
    -- window.layoutManager = function()
    --     directoryTEXTComponent.size = {
    --         x= window.size.x,
    --         y= 1
    --     }
    --     directoryTEXTComponent.pos = {
    --         x=1,
    --         y=1
    --     }
    --     for key, fileComp in pairs (fileComponents) do
    --         fileComp.size = {
    --             x= window.size.x,
    --             y= 1
    --         }
    --         fileComp.pos = {
    --             x=1,
    --             y=scrollPosition+key
    --         }
    --     end
    -- end
    --indow:add(directoryTEXTComponent)


    pAPI:runLoop()
end)