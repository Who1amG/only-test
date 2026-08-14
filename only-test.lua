local ALLOWED_GAME_ID = "76427445314955"
if tostring(game.PlaceId) ~= ALLOWED_GAME_ID and tostring(game.GameId) ~= ALLOWED_GAME_ID then
    local pls = game:GetService("Players")
    local LPLR = pls.LocalPlayer
    if LPLR then
        LPLR:Kick("\n[VROY UI - Game Lock]\nThis Script Is Not For This Game.\nGame ID Required: " ..
            ALLOWED_GAME_ID .. "\nYour Place ID: " .. tostring(game.PlaceId) .. " | Game ID: " .. tostring(game.GameId))
    end
    return
end
local tws = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local pls = game:GetService("Players")
local LPLR = pls.LocalPlayer
local ESP, LocalChams, espGui
local pgui = LPLR:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local VROY_UI_ID = "VROY_UI"
if getgenv()[VROY_UI_ID] then
    if getgenv().EXE then
        if getgenv().EXE.CLEANUP_CAR_FLY then pcall(getgenv().EXE.CLEANUP_CAR_FLY) end
        if getgenv().EXE.CLEANUP_HITBOXES then pcall(getgenv().EXE.CLEANUP_HITBOXES) end
    end
    if getgenv().UI_CONNECTIONS then
        for _, conn in ipairs(getgenv().UI_CONNECTIONS) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end
    pcall(function()
        getgenv()[VROY_UI_ID]:Destroy()
    end)
end
local gui = Instance.new("ScreenGui")
gui.Name = "VROYUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 2147483640
gui.IgnoreGuiInset = true
local success, cg = pcall(function() return game:GetService("CoreGui") end)
gui.Parent = (success and cg) and cg or pgui
getgenv()[VROY_UI_ID] = gui
getgenv().UI_CONNECTIONS = {}
local ConfigPath = "VROY/VROY-Config.json"
local sleitnickNetFolder = nil
function getSleitnickNet()
    if sleitnickNetFolder and sleitnickNetFolder.Parent then return sleitnickNetFolder end
    pcall(function()
        local _Index = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
            and game:GetService("ReplicatedStorage").Modules:FindFirstChild("Packages")
            and game:GetService("ReplicatedStorage").Modules.Packages:FindFirstChild("_Index")
        if not _Index then return end
        for _, v in ipairs(_Index:GetChildren()) do
            if v.Name:sub(1, 13) == "sleitnick_net" then
                sleitnickNetFolder = v:FindFirstChild("net") or v
                break
            end
        end
    end)
    return sleitnickNetFolder
end

local colorOptions = {
    { Name = "Default",      Value = Color3.fromRGB(180, 180, 180) },
    { Name = "Blue",         Value = Color3.fromRGB(40, 100, 180) },
    { Name = "Light Yellow", Value = Color3.fromRGB(255, 235, 150) },
    { Name = "Purple",       Value = Color3.fromRGB(150, 80, 200) },
    { Name = "Yellow",       Value = Color3.fromRGB(255, 200, 0) },
    { Name = "White",        Value = Color3.fromRGB(240, 240, 240) },
    { Name = "Gray",         Value = Color3.fromRGB(150, 150, 150) },
    { Name = "Green",        Value = Color3.fromRGB(150, 220, 150) },
    { Name = "Red",          Value = Color3.fromRGB(220, 50, 50) }
}
local fontOptions = {
    { Name = "SourceSans", Value = Enum.Font.SourceSansBold },
    { Name = "Arcade",     Value = Enum.Font.Arcade },
    { Name = "Gotham",     Value = Enum.Font.GothamBold },
    { Name = "SciFi",      Value = Enum.Font.SciFi },
    { Name = "Code",       Value = Enum.Font.Code },
    { Name = "Oswald",     Value = Enum.Font.Oswald },
    { Name = "Jura",       Value = Enum.Font.Jura }
}
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
local Config = {
    SizeX = isMobile and 450 or 660,
    SizeY = isMobile and 280 or 440,
    CustomImage = "rbxassetid://93021928981636",
    EnableImage = true,
    Transparency = 50,
    ThemeColorIdx = 9,
    FontIdx = 1,
    NotificationPosition = "Bottom Right",
    Toggles = {},
    Sliders = {},
    Keybinds = {}
}
if isfolder and not isfolder("VROY") then
    pcall(makefolder, "VROY")
end
if isfile and isfile(ConfigPath) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(ConfigPath))
        for k, v in pairs(data) do
            Config[k] = v
        end
    end)
end
if isMobile and Config.SizeX == 640 then
    Config.SizeX = 450
    Config.SizeY = 280
end
function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigPath, HttpService:JSONEncode(Config))
        end)
    end
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, Config.SizeX, 0, Config.SizeY)
main.Position = UDim2.new(0.5, -Config.SizeX / 2, 0.5, -Config.SizeY / 2)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
local corn = Instance.new("UICorner")
corn.CornerRadius = UDim.new(0, 5)
corn.Parent = main
local mstroke = Instance.new("UIStroke")
mstroke.Color = Color3.fromRGB(45, 45, 45)
mstroke.Thickness = 1
mstroke.Parent = main
local bgImg = Instance.new("ImageLabel")
bgImg.Name = "BgImg"
bgImg.Size = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image = Config.CustomImage
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ImageTransparency = Config.Transparency / 100
bgImg.Visible = Config.EnableImage
main.BackgroundTransparency = Config.Transparency / 100
bgImg.ZIndex = 0
bgImg.Parent = main
local bgCorn = Instance.new("UICorner")
bgCorn.CornerRadius = UDim.new(0, 5)
bgCorn.Parent = bgImg
local side = Instance.new("Frame")
side.Name = "Side"
side.Size = UDim2.new(0, 190, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
side.BackgroundTransparency = 0.3
side.BorderSizePixel = 0
side.Parent = main
local scorn = Instance.new("UICorner")
scorn.CornerRadius = UDim.new(0, 5)
scorn.Parent = side
local sdiv = Instance.new("Frame")
sdiv.Name = "SDiv"
sdiv.Size = UDim2.new(0, 1, 1, 0)
sdiv.Position = UDim2.new(1, -1, 0, 0)
sdiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sdiv.BorderSizePixel = 0
sdiv.Parent = side
local lbox = Instance.new("Frame")
lbox.Name = "LBox"
lbox.Size = UDim2.new(0, 166, 0, 95)
lbox.Position = UDim2.new(0, 12, 0, 12)
lbox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
lbox.BorderSizePixel = 0
lbox.Parent = side
local lcorn = Instance.new("UICorner")
lcorn.CornerRadius = UDim.new(0, 4)
lcorn.Parent = lbox
local lstroke = Instance.new("UIStroke")
lstroke.Color = Color3.fromRGB(40, 40, 40)
lstroke.Thickness = 1
lstroke.Parent = lbox
local img = Instance.new("ImageLabel")
img.Name = "Img"
img.Size = UDim2.new(1, 0, 1, 0)
img.Position = UDim2.new(0, 0, 0, 0)
img.BackgroundTransparency = 1
img.BorderSizePixel = 0
img.Image = "rbxassetid://75058265168838"
img.ScaleType = Enum.ScaleType.Crop
img.Parent = lbox
local ldiv = Instance.new("Frame")
ldiv.Name = "LDiv"
ldiv.Size = UDim2.new(1, 24, 0, 1)
ldiv.Position = UDim2.new(0, -12, 1, 12)
ldiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ldiv.BorderSizePixel = 0
ldiv.Parent = lbox
local tcon = Instance.new("ScrollingFrame")
tcon.Name = "TCon"
tcon.Size = UDim2.new(1, -1, 1, -135)
tcon.Position = UDim2.new(0, 0, 0, 126)
tcon.BackgroundTransparency = 1
tcon.BorderSizePixel = 0
tcon.CanvasSize = UDim2.new(0, 0, 0, 0)
tcon.ScrollBarThickness = 0
tcon.Parent = side
local tlay = Instance.new("UIListLayout")
tlay.SortOrder = Enum.SortOrder.LayoutOrder
tlay.Padding = UDim.new(0, 2)
tlay.Parent = tcon
local head = Instance.new("Frame")
head.Name = "Head"
head.Size = UDim2.new(1, -190, 0, 55)
head.Position = UDim2.new(0, 190, 0, 0)
head.BackgroundTransparency = 1
head.BorderSizePixel = 0
head.Parent = main
local hdiv = Instance.new("Frame")
hdiv.Name = "HDiv"
hdiv.Size = UDim2.new(1, 0, 0, 1)
hdiv.Position = UDim2.new(0, 0, 1, -1)
hdiv.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hdiv.BorderSizePixel = 0
hdiv.Parent = head
local httl = Instance.new("TextLabel")
httl.Name = "HTtl"
httl.Size = UDim2.new(1, -60, 0, 22)
httl.Position = UDim2.new(0, 16, 0, 10)
httl.BackgroundTransparency = 1
httl.Text = "Vroy Family"
httl.TextColor3 = Color3.fromRGB(245, 245, 245)
httl.Font = Enum.Font.SourceSansBold
httl.TextSize = 16
httl.TextXAlignment = Enum.TextXAlignment.Left
httl.Parent = head
local hsub = Instance.new("TextLabel")
hsub.Name = "HSub"
hsub.Size = UDim2.new(1, -60, 0, 16)
hsub.Position = UDim2.new(0, 16, 0, 28)
hsub.BackgroundTransparency = 1
hsub.Text = "Vice City 2"
hsub.TextColor3 = Color3.fromRGB(120, 120, 120)
hsub.Font = Enum.Font.SourceSans
hsub.TextSize = 12
hsub.TextXAlignment = Enum.TextXAlignment.Left
hsub.Parent = head
local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -36, 0.5, -12)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(140, 140, 140)
close.Font = Enum.Font.SourceSansBold
close.TextSize = 16
close.ZIndex = 5
close.Parent = head
local updatesBell = Instance.new("ImageButton")
updatesBell.Name = "UpdatesBell"
updatesBell.Size = UDim2.new(0, 18, 0, 18)
updatesBell.Position = UDim2.new(1, -66, 0.5, -9)
updatesBell.BackgroundTransparency = 1
updatesBell.Image = "rbxassetid://92077674149013"
updatesBell.ImageColor3 = Color3.fromRGB(200, 200, 200)
updatesBell.ZIndex = 5
updatesBell.Parent = head
updatesBell.Visible = getgenv().ShowUpdatesBell ~= false
local updatesFrame = Instance.new("Frame")
updatesFrame.Name = "UpdatesFrame"
updatesFrame.Size = UDim2.new(0, 400, 0, 280)
updatesFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
updatesFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
updatesFrame.BorderSizePixel = 0
updatesFrame.Visible = false
updatesFrame.ZIndex = 100
updatesFrame.Parent = gui
local ufCor = Instance.new("UICorner", updatesFrame)
ufCor.CornerRadius = UDim.new(0, 6)
local ufStr = Instance.new("UIStroke", updatesFrame)
ufStr.Color = Color3.fromRGB(50, 50, 50)
ufStr.Thickness = 1
local ufTop = Instance.new("Frame")
ufTop.Size = UDim2.new(1, 0, 0, 36)
ufTop.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ufTop.BorderSizePixel = 0
ufTop.ZIndex = 101
ufTop.Parent = updatesFrame
local ufTopCor = Instance.new("UICorner", ufTop)
ufTopCor.CornerRadius = UDim.new(0, 6)
local ufTopDiv = Instance.new("Frame")
ufTopDiv.Size = UDim2.new(1, 0, 0, 1)
ufTopDiv.Position = UDim2.new(0, 0, 1, -1)
ufTopDiv.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ufTopDiv.BorderSizePixel = 0
ufTopDiv.ZIndex = 102
ufTopDiv.Parent = ufTop
local ufTitle = Instance.new("TextLabel")
ufTitle.Size = UDim2.new(1, -60, 1, 0)
ufTitle.Position = UDim2.new(0, 16, 0, 0)
ufTitle.BackgroundTransparency = 1
ufTitle.Text = "Vice City 2 - Updates"
ufTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
ufTitle.Font = Enum.Font.SourceSansBold
ufTitle.TextSize = 16
ufTitle.TextXAlignment = Enum.TextXAlignment.Left
ufTitle.ZIndex = 102
ufTitle.Parent = ufTop
local ufClose = Instance.new("TextButton")
ufClose.Size = UDim2.new(0, 24, 0, 24)
ufClose.Position = UDim2.new(1, -30, 0.5, -12)
ufClose.BackgroundTransparency = 1
ufClose.Text = "X"
ufClose.TextColor3 = Color3.fromRGB(140, 140, 140)
ufClose.Font = Enum.Font.SourceSansBold
ufClose.TextSize = 16
ufClose.ZIndex = 102
ufClose.Parent = ufTop
ufClose.MouseButton1Click:Connect(function() updatesFrame.Visible = false end)
ufClose.MouseEnter:Connect(function() ufClose.TextColor3 = Color3.fromRGB(240, 70, 70) end)
ufClose.MouseLeave:Connect(function() ufClose.TextColor3 = Color3.fromRGB(140, 140, 140) end)
local ufScroll = Instance.new("ScrollingFrame")
ufScroll.Size = UDim2.new(1, -20, 1, -46)
ufScroll.Position = UDim2.new(0, 10, 0, 40)
ufScroll.BackgroundTransparency = 1
ufScroll.BorderSizePixel = 0
ufScroll.ScrollBarThickness = 4
ufScroll.ZIndex = 101
ufScroll.Parent = updatesFrame
local ufList = Instance.new("UIListLayout", ufScroll)
ufList.SortOrder = Enum.SortOrder.LayoutOrder
ufList.Padding = UDim.new(0, 10)
function AddUpdateText(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 102
    lbl.Parent = ufScroll
    lbl.AutomaticSize = Enum.AutomaticSize.Y
end

AddUpdateText("🎉 What's New:")
AddUpdateText("Reworked Chicken Farm")
AddUpdateText("Added Better Taleport Mehod")
AddUpdateText("Fix all farms")



updatesBell.MouseButton1Click:Connect(function()
    updatesFrame.Visible = not updatesFrame.Visible
end)
updatesBell.MouseEnter:Connect(function() updatesBell.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
updatesBell.MouseLeave:Connect(function() updatesBell.ImageColor3 = Color3.fromRGB(200, 200, 200) end)
close.MouseEnter:Connect(function()
    close.TextColor3 = Color3.fromRGB(240, 70, 70)
end)
close.MouseLeave:Connect(function()
    close.TextColor3 = Color3.fromRGB(140, 140, 140)
end)
if isMobile then
    local mobileToggle = Instance.new("ImageButton")
    mobileToggle.Name = "MobileToggle"
    mobileToggle.Size = UDim2.new(0, 40, 0, 40)
    mobileToggle.Position = UDim2.new(0, 10, 0.5, -20)
    mobileToggle.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    mobileToggle.Image = "rbxassetid://131789276869952"
    mobileToggle.ZIndex = 1000
    mobileToggle.Parent = gui
    local mcor = Instance.new("UICorner", mobileToggle)
    mcor.CornerRadius = UDim.new(1, 0)
    local mstr = Instance.new("UIStroke", mobileToggle)
    mstr.Color = Color3.fromRGB(45, 45, 45)
    mstr.Thickness = 1
    local mtDragging = false
    local mtDragStart, mtStartPos
    mobileToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mtDragging = true
            mtDragStart = input.Position
            mtStartPos = mobileToggle.Position
        end
    end)
    table.insert(getgenv().UI_CONNECTIONS, uis.InputChanged:Connect(function(input)
        if mtDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - mtDragStart
            if delta.Magnitude > 10 then
                mobileToggle.Position = UDim2.new(
                    mtStartPos.X.Scale, mtStartPos.X.Offset + delta.X,
                    mtStartPos.Y.Scale, mtStartPos.Y.Offset + delta.Y
                )
            end
        end
    end))
    table.insert(getgenv().UI_CONNECTIONS, uis.InputEnded:Connect(function(input)
        if mtDragging and input.UserInputType == Enum.UserInputType.Touch then
            mtDragging = false
            local delta = input.Position - mtDragStart
            if delta.Magnitude < 10 then
                main.Visible = not main.Visible
            end
        end
    end))
end
close.MouseButton1Click:Connect(function()
    if getgenv().EXE then
        if getgenv().EXE.CLEANUP_CAR_FLY then
            pcall(getgenv().EXE.CLEANUP_CAR_FLY)
        end
        if getgenv().EXE.CLEANUP_HITBOXES then
            pcall(getgenv().EXE.CLEANUP_HITBOXES)
        end
    end
    if getgenv().UI_CONNECTIONS then
        for _, conn in ipairs(getgenv().UI_CONNECTIONS) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
    end
    getgenv()[VROY_UI_ID] = nil
    gui:Destroy()
end)
local pcon = Instance.new("Frame")
pcon.Name = "PCon"
pcon.Size = UDim2.new(1, -214, 1, -79)
pcon.Position = UDim2.new(0, 204, 0, 67)
pcon.BackgroundTransparency = 1
pcon.BorderSizePixel = 0
pcon.Parent = main
local dragging, dragInput, dragStart, startPos
function registerDrag(object)
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

registerDrag(head)
registerDrag(side)
uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        tws:Create(main, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)
local resizeBtn = Instance.new("ImageButton")
resizeBtn.Name = "ResizeBtn"
resizeBtn.Size = UDim2.new(0, 16, 0, 16)
resizeBtn.Position = UDim2.new(1, -16, 1, -16)
resizeBtn.BackgroundTransparency = 1
resizeBtn.Image = "rbxassetid://93021928981636"
resizeBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
resizeBtn.ZIndex = 10
resizeBtn.Parent = main
local resizing = false
local startMousePos, startSizeX, startSizeY
resizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        startMousePos = uis:GetMouseLocation()
        startSizeX = main.Size.X.Offset
        startSizeY = main.Size.Y.Offset
        resizeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
uis.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMousePos = uis:GetMouseLocation()
        local delta = currentMousePos - startMousePos
        local minW = isMobile and 350 or 640
        local maxW = isMobile and 600 or 950
        local minH = isMobile and 250 or 360
        local maxH = isMobile and 450 or 650
        local newWidth = math.clamp(startSizeX + delta.X, minW, maxW)
        local newHeight = math.clamp(startSizeY + delta.Y, minH, maxH)
        tws:Create(main, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, newWidth, 0, newHeight)
        }):Play()
    end
end)
uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if resizing then
            resizing = false
            resizeBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
            Config.SizeX = main.Size.X.Offset
            Config.SizeY = main.Size.Y.Offset
            SaveConfig()
        end
    end
end)
local tabs = {}
local actv = nil
local ThemeUpdateCallbacks = {}
local SharedThemeColor = colorOptions[Config.ThemeColorIdx].Value
local SharedThemeFont = fontOptions[Config.FontIdx].Value
function ApplyTheme()
    for _, cb in ipairs(ThemeUpdateCallbacks) do
        pcall(function() cb(SharedThemeColor, SharedThemeFont) end)
    end
end

local notifWidth = isMobile and 220 or 300
local notifOffset = notifWidth + 20
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, notifWidth, 1, -40)
NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 100
NotifContainer.Parent = gui
local UIListLayoutNotif = Instance.new("UIListLayout")
UIListLayoutNotif.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayoutNotif.Padding = UDim.new(0, 10)
UIListLayoutNotif.Parent = NotifContainer
function UpdateNotifPosition(pos)
    if pos == "Bottom Right" then
        NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
    elseif pos == "Bottom Left" then
        NotifContainer.Position = UDim2.new(0, 20, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Bottom
    elseif pos == "Top Right" then
        NotifContainer.Position = UDim2.new(1, -notifOffset, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Top
    elseif pos == "Top Left" then
        NotifContainer.Position = UDim2.new(0, 20, 0, 20)
        UIListLayoutNotif.VerticalAlignment = Enum.VerticalAlignment.Top
    end
end

UpdateNotifPosition(Config.NotificationPosition)
function Notify(title, text, duration)
    if Config and Config.NotificationsEnabled == false then return end
    duration = duration or 3
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, isMobile and 45 or 60)
    Notif.BackgroundTransparency = 1
    Notif.Parent = NotifContainer
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Position = UDim2.new(1, 50, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Content.Parent = Notif
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 6)
    nCorner.Parent = Content
    local nStroke = Instance.new("UIStroke")
    nStroke.Color = SharedThemeColor or Color3.fromRGB(255, 120, 50)
    nStroke.Thickness = 1
    nStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    nStroke.Parent = Content
    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -20, 0, isMobile and 16 or 20)
    nTitle.Position = UDim2.new(0, 10, 0, isMobile and 6 or 10)
    nTitle.BackgroundTransparency = 1
    nTitle.Font = SharedThemeFont or Enum.Font.GothamBold
    nTitle.Text = title
    nTitle.TextColor3 = SharedThemeColor or Color3.fromRGB(255, 120, 50)
    nTitle.TextSize = isMobile and 12 or 14
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.TextTruncate = Enum.TextTruncate.AtEnd
    nTitle.Parent = Content
    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, -20, 0, isMobile and 16 or 20)
    nText.Position = UDim2.new(0, 10, 0, isMobile and 22 or 30)
    nText.BackgroundTransparency = 1
    nText.Font = SharedThemeFont or Enum.Font.Gotham
    nText.Text = text
    nText.TextColor3 = Color3.fromRGB(200, 200, 200)
    nText.TextSize = isMobile and 11 or 12
    nText.TextXAlignment = Enum.TextXAlignment.Left
    nText.TextTruncate = Enum.TextTruncate.AtEnd
    nText.Parent = Content
    local inTween = tws:Create(Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 0, 0, 0) })
    inTween:Play()
    task.spawn(function()
        task.wait(duration)
        local outTween = tws:Create(Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 })
        for _, child in ipairs(Content:GetChildren()) do
            if child:IsA("TextLabel") then
                tws:Create(child, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            elseif child:IsA("UIStroke") then
                tws:Create(child, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            end
        end
        outTween:Play()
        outTween.Completed:Wait()
        Notif:Destroy()
    end)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        if Content.Parent then
            nStroke.Color = color
            nTitle.TextColor3 = color
            nTitle.Font = font
            nText.Font = font
        end
    end)
end

local ColorPickerModal = Instance.new("Frame")
ColorPickerModal.Name = "ColorPickerModal"
ColorPickerModal.Size = UDim2.new(0, 200, 0, 220)
ColorPickerModal.Position = UDim2.new(0.5, -100, 0.5, -110)
ColorPickerModal.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ColorPickerModal.BackgroundTransparency = 0.05
ColorPickerModal.ZIndex = 100
ColorPickerModal.Visible = false
ColorPickerModal.Parent = main
local PickerCorner = Instance.new("UICorner")
PickerCorner.CornerRadius = UDim.new(0, 10)
PickerCorner.Parent = ColorPickerModal
local PickerStroke = Instance.new("UIStroke")
PickerStroke.Color = Color3.fromRGB(45, 45, 52)
PickerStroke.Thickness = 1.5
PickerStroke.Parent = ColorPickerModal
local PickerTitle = Instance.new("TextLabel")
PickerTitle.Size = UDim2.new(1, 0, 0, 30)
PickerTitle.BackgroundTransparency = 1
PickerTitle.Text = "Select Color"
PickerTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
PickerTitle.Font = Enum.Font.SourceSansBold
PickerTitle.TextSize = 13
PickerTitle.ZIndex = 101
PickerTitle.Parent = ColorPickerModal
local PaletteFrame = Instance.new("ImageButton")
PaletteFrame.Size = UDim2.new(1, -20, 0, 130)
PaletteFrame.Position = UDim2.new(0, 10, 0, 35)
PaletteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
PaletteFrame.Image = "rbxassetid://4155801252"
PaletteFrame.ZIndex = 101
PaletteFrame.Parent = ColorPickerModal
local HueGradient = Instance.new("UIGradient")
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.new(1, 0, 0)),
    ColorSequenceKeypoint.new(0.16, Color3.new(1, 1, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
    ColorSequenceKeypoint.new(0.50, Color3.new(0, 1, 1)),
    ColorSequenceKeypoint.new(0.66, Color3.new(0, 0, 1)),
    ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
    ColorSequenceKeypoint.new(1.00, Color3.new(1, 0, 0))
})
HueGradient.Parent = PaletteFrame
local PaletteCorner = Instance.new("UICorner")
PaletteCorner.CornerRadius = UDim.new(0, 8)
PaletteCorner.Parent = PaletteFrame
local SelectorRing = Instance.new("Frame")
SelectorRing.Size = UDim2.new(0, 10, 0, 10)
SelectorRing.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorRing.BackgroundColor3 = Color3.new(1, 1, 1)
SelectorRing.ZIndex = 102
SelectorRing.Parent = PaletteFrame
local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(1, 0)
SelectorCorner.Parent = SelectorRing
local ClosePickerBtn = Instance.new("TextButton")
ClosePickerBtn.Size = UDim2.new(1, -20, 0, 30)
ClosePickerBtn.Position = UDim2.new(0, 10, 0, 175)
ClosePickerBtn.BackgroundColor3 = SharedThemeColor
ClosePickerBtn.Text = "Confirm"
ClosePickerBtn.TextColor3 = Color3.new(1, 1, 1)
ClosePickerBtn.Font = Enum.Font.SourceSansBold
ClosePickerBtn.TextSize = 12
ClosePickerBtn.ZIndex = 101
ClosePickerBtn.Parent = ColorPickerModal
local ClosePickerCorner = Instance.new("UICorner")
ClosePickerCorner.CornerRadius = UDim.new(0, 6)
ClosePickerCorner.Parent = ClosePickerBtn
local ActiveColorCallback = nil
local isPicking = false
PaletteFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPicking = true
    end
end)
uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPicking = false
    end
end)
local function updateColor(input)
    if not isPicking then return end
    local pos = input.Position
    if input.UserInputType == Enum.UserInputType.Touch then pos = Vector3.new(input.Position.X, input.Position.Y, 0) end
    local px = math.clamp((pos.X - PaletteFrame.AbsolutePosition.X) / PaletteFrame.AbsoluteSize.X, 0, 1)
    local py = math.clamp((pos.Y - PaletteFrame.AbsolutePosition.Y) / PaletteFrame.AbsoluteSize.Y, 0, 1)
    SelectorRing.Position = UDim2.new(px, 0, py, 0)
    local col = Color3.fromHSV(px, 1, 1 - py)
    if ActiveColorCallback then ActiveColorCallback(col) end
end
uis.InputChanged:Connect(function(input)
    if isPicking and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateColor(input)
    end
end)
ClosePickerBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ColorPickerModal.Visible = false
    end
end)
function OpenPicker(callback)
    ActiveColorCallback = callback
    ColorPickerModal.Visible = true
end

table.insert(ThemeUpdateCallbacks, function(color, font)
    ClosePickerBtn.BackgroundColor3 = color
    PickerTitle.Font = font
    ClosePickerBtn.Font = font
end)
function CreateTab(name, sub)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = pcon
    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftCol"
    leftCol.Size = UDim2.new(0.48, 0, 1, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.Parent = page
    local leftLay = Instance.new("UIListLayout")
    leftLay.Padding = UDim.new(0, 12)
    leftLay.SortOrder = Enum.SortOrder.LayoutOrder
    leftLay.Parent = leftCol
    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightCol"
    rightCol.Size = UDim2.new(0.48, 0, 1, 0)
    rightCol.Position = UDim2.new(0.52, 0, 0, 0)
    rightCol.BackgroundTransparency = 1
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.Parent = page
    local rightLay = Instance.new("UIListLayout")
    rightLay.Padding = UDim.new(0, 12)
    rightLay.SortOrder = Enum.SortOrder.LayoutOrder
    rightLay.Parent = rightCol
    local ppad = Instance.new("UIPadding")
    ppad.PaddingTop = UDim.new(0, 2)
    ppad.PaddingLeft = UDim.new(0, 2)
    ppad.PaddingRight = UDim.new(0, 2)
    ppad.PaddingBottom = UDim.new(0, 2)
    ppad.Parent = page
    local function updateCanvas()
        local maxH = math.max(leftLay.AbsoluteContentSize.Y, rightLay.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, maxH + 15)
    end
    leftLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    rightLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = tcon
    local bcrn = Instance.new("UICorner")
    bcrn.CornerRadius = UDim.new(0, 4)
    bcrn.Parent = btn
    local bstroke = Instance.new("UIStroke")
    bstroke.Color = Color3.fromRGB(45, 45, 45)
    bstroke.Thickness = 1
    bstroke.Transparency = 1
    bstroke.Parent = btn
    local lbl1 = Instance.new("TextLabel")
    lbl1.Size = UDim2.new(1, -30, 0, 20)
    lbl1.Position = UDim2.new(0, 16, 0, 6)
    lbl1.BackgroundTransparency = 1
    lbl1.Text = name
    lbl1.TextColor3 = Color3.fromRGB(140, 140, 140)
    lbl1.Font = Enum.Font.SourceSansBold
    lbl1.TextSize = 14
    lbl1.TextXAlignment = Enum.TextXAlignment.Left
    lbl1.Parent = btn
    local lbl2 = Instance.new("TextLabel")
    lbl2.Size = UDim2.new(1, -30, 0, 14)
    lbl2.Position = UDim2.new(0, 16, 0, 24)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = sub or ""
    lbl2.TextColor3 = Color3.fromRGB(90, 90, 90)
    lbl2.Font = Enum.Font.SourceSans
    lbl2.TextSize = 11
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.Parent = btn
    local ind = Instance.new("Frame")
    ind.Name = "Ind"
    ind.Size = UDim2.new(0, 3, 0, 22)
    ind.Position = UDim2.new(1, -3, 0.5, -11)
    ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = btn
    local function open()
        if actv == name then return end
        if ColorPickerModal then ColorPickerModal.Visible = false end
        if actv and tabs[actv] then
            tabs[actv].page.Visible = false
            tabs[actv].ind.Visible = false
            tws:Create(tabs[actv].btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            tws:Create(tabs[actv].bstroke, TweenInfo.new(0.15), { Transparency = 1 }):Play()
            tws:Create(tabs[actv].lbl1, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(140, 140, 140) }):Play()
        end
        actv = name
        page.Visible = true
        ind.Visible = true
        tws:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 }):Play()
        tws:Create(bstroke, TweenInfo.new(0.15), { Transparency = 0 }):Play()
        tws:Create(lbl1, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end
    btn.MouseEnter:Connect(function()
        if actv ~= name then
            tws:Create(lbl1, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(200, 200, 200) }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if actv ~= name then
            tws:Create(lbl1, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(140, 140, 140) }):Play()
        end
    end)
    btn.MouseButton1Click:Connect(open)
    tabs[name] = {
        page = page,
        btn = btn,
        lbl1 = lbl1,
        bstroke = bstroke,
        ind = ind,
        open = open
    }
    table.insert(ThemeUpdateCallbacks, function(color, font)
        lbl1.Font = font
        lbl2.Font = font
    end)
    tcon.CanvasSize = UDim2.new(0, 0, 0, tlay.AbsoluteContentSize.Y + 10)
    return page
end

function CreateCard(page, text, side, layoutOrder)
    local targetCol = page
    local leftCol = page:FindFirstChild("LeftCol")
    local rightCol = page:FindFirstChild("RightCol")
    if side and page:FindFirstChild(side) then
        targetCol = page:FindFirstChild(side)
    elseif side == "left" and leftCol then
        targetCol = leftCol
    elseif side == "right" and rightCol then
        targetCol = rightCol
    elseif leftCol and rightCol then
        if #rightCol:GetChildren() < #leftCol:GetChildren() then
            targetCol = rightCol
        else
            targetCol = leftCol
        end
    end
    local card = Instance.new("Frame")
    card.Name = text .. "Card"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = layoutOrder or #targetCol:GetChildren()
    local ccrd = Instance.new("UICorner")
    ccrd.CornerRadius = UDim.new(0, 4)
    ccrd.Parent = card
    local cstr = Instance.new("UIStroke")
    cstr.Color = Color3.fromRGB(45, 45, 45)
    cstr.Thickness = 1
    cstr.Parent = card
    local cttl = Instance.new("TextLabel")
    cttl.Name = "CTtl"
    cttl.Size = UDim2.new(1, 0, 0, 25)
    cttl.Position = UDim2.new(0, 0, 0, 6)
    cttl.BackgroundTransparency = 1
    cttl.Text = text
    cttl.TextColor3 = Color3.fromRGB(255, 255, 255)
    cttl.TextSize = 13
    cttl.Font = Enum.Font.SourceSansBold
    cttl.TextXAlignment = Enum.TextXAlignment.Center
    cttl.Parent = card
    local bbox = Instance.new("Frame")
    bbox.Name = "BBox"
    bbox.Size = UDim2.new(1, -16, 0, 0)
    bbox.Position = UDim2.new(0, 8, 0, 32)
    bbox.BackgroundTransparency = 1
    bbox.BorderSizePixel = 0
    bbox.AutomaticSize = Enum.AutomaticSize.Y
    bbox.Parent = card
    local blay = Instance.new("UIListLayout")
    blay.Padding = UDim.new(0, 6)
    blay.SortOrder = Enum.SortOrder.LayoutOrder
    blay.Parent = bbox
    local bpad = Instance.new("UIPadding")
    bpad.PaddingBottom = UDim.new(0, 10)
    bpad.Parent = bbox
    table.insert(ThemeUpdateCallbacks, function(color, font)
        cttl.Font = font
    end)
    card.Parent = targetCol
    return bbox
end

function CreateCardButton(parent, text, callback)
    local bttn = Instance.new("TextButton")
    bttn.Size = UDim2.new(1, 0, 0, 28)
    bttn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    bttn.BackgroundTransparency = 0.1
    bttn.Text = text
    bttn.TextColor3 = Color3.fromRGB(185, 185, 185)
    bttn.Font = Enum.Font.SourceSans
    bttn.TextSize = 13
    bttn.AutoButtonColor = false
    local bcn = Instance.new("UICorner")
    bcn.CornerRadius = UDim.new(0, 4)
    bcn.Parent = bttn
    local bst = Instance.new("UIStroke")
    bst.Color = Color3.fromRGB(40, 40, 40)
    bst.Thickness = 1
    bst.Parent = bttn
    bttn.MouseEnter:Connect(function()
        tws:Create(bttn, TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end)
    bttn.MouseLeave:Connect(function()
        tws:Create(bttn, TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(26, 26, 26), TextColor3 = Color3.fromRGB(185, 185, 185) }):Play()
    end)
    bttn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        bttn.Font = font
    end)
    bttn.Parent = parent
    return bttn
end

local ActiveToggles = {}
function CreateToggle(parent, text, defaultVal, saveKey, callback, colorPickers, disableNotifications)
    local togFr = Instance.new("Frame")
    togFr.Size = UDim2.new(1, 0, 0, 32)
    togFr.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    togFr.BackgroundTransparency = 0.1
    togFr.BorderSizePixel = 0
    togFr.Parent = parent
    local tcn = Instance.new("UICorner")
    tcn.CornerRadius = UDim.new(0, 4)
    tcn.Parent = togFr
    local tst = Instance.new("UIStroke")
    tst.Color = Color3.fromRGB(40, 40, 40)
    tst.Thickness = 1
    tst.Parent = togFr
    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, isMobile and -50 or -90, 1, 0)
    tlbl.Position = UDim2.new(0, 10, 0, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = togFr
    local keybtn = Instance.new("TextButton")
    keybtn.Size = UDim2.new(0, 24, 0, 20)
    keybtn.Position = UDim2.new(1, -68, 0.5, -10)
    keybtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    keybtn.Text = "-"
    keybtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    keybtn.Font = Enum.Font.SourceSans
    keybtn.TextSize = 12
    keybtn.Visible = not isMobile
    keybtn.Parent = togFr
    local keycn = Instance.new("UICorner")
    keycn.CornerRadius = UDim.new(0, 4)
    keycn.Parent = keybtn
    local keyst = Instance.new("UIStroke")
    keyst.Color = Color3.fromRGB(45, 45, 45)
    keyst.Parent = keybtn
    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 32, 0, 16)
    switchBg.Position = UDim2.new(1, -38, 0.5, -8)
    switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = togFr
    local swcn = Instance.new("UICorner")
    swcn.CornerRadius = UDim.new(1, 0)
    swcn.Parent = switchBg
    local swcir = Instance.new("Frame")
    swcir.Size = UDim2.new(0, 12, 0, 12)
    swcir.Position = UDim2.new(0, 2, 0.5, -6)
    swcir.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    swcir.Parent = switchBg
    local swccn = Instance.new("UICorner")
    swccn.CornerRadius = UDim.new(1, 0)
    swccn.Parent = swcir
    local allowedToggles = {
        ["EnableImage"] = true,
        ["NotificationsEnabled"] = true,
        ["HideUIKey"] = true,
        ["ShowUpdatesBell"] = true
    }
    local toggled = defaultVal or false
    if saveKey ~= nil and type(saveKey) == "string" and allowedToggles[saveKey] then
        if Config.Toggles[saveKey] ~= nil then
            toggled = Config.Toggles[saveKey]
        else
            Config.Toggles[saveKey] = toggled
        end
    end
    local currentKeybind = nil
    if saveKey ~= nil and type(saveKey) == "string" and allowedToggles[saveKey] then
        Config.Keybinds = Config.Keybinds or {}
        if Config.Keybinds[saveKey] ~= nil then
            local success, enumKey = pcall(function() return Enum.KeyCode[Config.Keybinds[saveKey]] end)
            if success and enumKey then
                currentKeybind = enumKey
                keybtn.Text = enumKey.Name
            end
        end
    end
    if toggled then
        swcir.Position = UDim2.new(1, -14, 0.5, -6)
        switchBg.BackgroundColor3 = SharedThemeColor
    else
        swcir.Position = UDim2.new(0, 2, 0.5, -6)
        switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    local function doToggle(forceFalse)
        if forceFalse then
            if not toggled then return end
            toggled = false
        else
            toggled = not toggled
        end
        if saveKey ~= nil and type(saveKey) == "string" and not forceFalse and allowedToggles[saveKey] then
            Config.Toggles[saveKey] = toggled
            SaveConfig()
        end
        if toggled then
            tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(1, -14, 0.5, -6) }):Play()
            tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = SharedThemeColor }):Play()
            if not forceFalse and text ~= "Hide UI" and not disableNotifications then
                Notify("Toggle Enabled",
                    text .. " has been enabled.", 2)
            end
        else
            tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6) }):Play()
            tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
            if not forceFalse and text ~= "Hide UI" and not disableNotifications then
                Notify("Toggle Disabled",
                    text .. " has been disabled.", 2)
            end
        end
        if callback then pcall(callback, toggled) end
    end
    table.insert(ActiveToggles, doToggle)
    switchBg.MouseButton1Click:Connect(function() doToggle() end)
    local waitingForKey = false
    keybtn.MouseButton1Click:Connect(function()
        waitingForKey = true
        keybtn.Text = "..."
    end)
    local keybindConn = uis.InputBegan:Connect(function(input, gpe)
        if waitingForKey then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode
                if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
                    currentKeybind = nil
                    keybtn.Text = "-"
                else
                    currentKeybind = key
                    keybtn.Text = key.Name
                end
                waitingForKey = false
                if saveKey ~= nil and type(saveKey) == "string" and allowedToggles[saveKey] then
                    Config.Keybinds = Config.Keybinds or {}
                    Config.Keybinds[saveKey] = currentKeybind and currentKeybind.Name or nil
                    SaveConfig()
                end
            end
        elseif not gpe and currentKeybind and input.KeyCode == currentKeybind then
            doToggle()
        end
    end)
    table.insert(getgenv().UI_CONNECTIONS, keybindConn)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        keybtn.Font = font
        if toggled then
            switchBg.BackgroundColor3 = color
        end
    end)
    if colorPickers and #colorPickers > 0 then
        keybtn.Visible = false
        local offset = -68
        for i, cObj in ipairs(colorPickers) do
            local ColBtn = Instance.new("TextButton")
            ColBtn.Size = UDim2.new(0, 18, 0, 18)
            ColBtn.Position = UDim2.new(1, offset, 0.5, -9)
            ColBtn.BackgroundColor3 = cObj.get() or Color3.new(1, 1, 1)
            ColBtn.Text = ""
            ColBtn.ZIndex = 6
            ColBtn.Parent = togFr
            local cC = Instance.new("UICorner")
            cC.CornerRadius = UDim.new(0, 4)
            cC.Parent = ColBtn
            local cS = Instance.new("UIStroke")
            cS.Color = Color3.fromRGB(45, 45, 45)
            cS.Thickness = 1
            cS.Parent = ColBtn
            ColBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    OpenPicker(function(nc)
                        ColBtn.BackgroundColor3 = nc
                        if cObj.set then cObj.set(nc) end
                    end)
                end
            end)
            offset = offset - 24
        end
    end
    return {
        Frame = togFr,
        Toggle = switchBg,
        Keybind = keybtn,
        SET = function(self, val, skip)
            if toggled ~= val then
                if skip then
                    toggled = val
                    if toggled then
                        tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(1, -14, 0.5, -6) }):Play()
                        tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = SharedThemeColor }):Play()
                    else
                        tws:Create(swcir, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6) }):Play()
                        tws:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
                    end
                else
                    doToggle()
                end
            end
        end
    }
end

function CreateSlider(parent, text, min, max, defaultVal, saveKey, callback)
    local default = defaultVal or min
    if saveKey ~= nil and type(saveKey) == "string" then
        if Config.Sliders[saveKey] ~= nil then
            default = Config.Sliders[saveKey]
        else
            Config.Sliders[saveKey] = default
        end
    end
    local sldFr = Instance.new("Frame")
    sldFr.Size = UDim2.new(1, 0, 0, 38)
    sldFr.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    sldFr.BackgroundTransparency = 0.1
    sldFr.BorderSizePixel = 0
    sldFr.Parent = parent
    local scn = Instance.new("UICorner")
    scn.CornerRadius = UDim.new(0, 4)
    scn.Parent = sldFr
    local sst = Instance.new("UIStroke")
    sst.Color = Color3.fromRGB(40, 40, 40)
    sst.Thickness = 1
    sst.Parent = sldFr
    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -50, 0, 16)
    tlbl.Position = UDim2.new(0, 10, 0, 4)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = sldFr
    local vlbl = Instance.new("TextLabel")
    vlbl.Size = UDim2.new(0, 30, 0, 16)
    vlbl.Position = UDim2.new(1, -38, 0, 4)
    vlbl.BackgroundTransparency = 1
    vlbl.Text = tostring(default)
    vlbl.TextColor3 = Color3.fromRGB(255, 120, 120)
    vlbl.Font = Enum.Font.SourceSansBold
    vlbl.TextSize = 12
    vlbl.TextXAlignment = Enum.TextXAlignment.Right
    vlbl.Parent = sldFr
    local sbg = Instance.new("TextButton")
    sbg.Size = UDim2.new(1, -20, 0, 4)
    sbg.Position = UDim2.new(0, 10, 0, 26)
    sbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sbg.Text = ""
    sbg.AutoButtonColor = false
    sbg.Parent = sldFr
    local sbgcn = Instance.new("UICorner")
    sbgcn.CornerRadius = UDim.new(1, 0)
    sbgcn.Parent = sbg
    local sfill = Instance.new("Frame")
    local pct = math.clamp((default - min) / (max - min), 0, 1)
    sfill.Size = UDim2.new(pct, 0, 1, 0)
    sfill.BackgroundColor3 = SharedThemeColor
    sfill.Parent = sbg
    local sfcn = Instance.new("UICorner")
    sfcn.CornerRadius = UDim.new(1, 0)
    sfcn.Parent = sfill
    local scir = Instance.new("Frame")
    scir.Size = UDim2.new(0, 10, 0, 10)
    scir.Position = UDim2.new(1, -5, 0.5, -5)
    scir.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scir.Parent = sfill
    local sccn = Instance.new("UICorner")
    sccn.CornerRadius = UDim.new(1, 0)
    sccn.Parent = scir
    local dragging = false
    local function updateSlider(inputX)
        local rel = math.clamp((inputX - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
        sfill.Size = UDim2.new(rel, 0, 1, 0)
        local val = math.floor(min + ((max - min) * rel))
        vlbl.Text = tostring(val)
        if saveKey ~= nil and type(saveKey) == "string" then
            Config.Sliders[saveKey] = val
        end
        if callback then callback(val) end
    end
    sbg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if saveKey ~= nil and type(saveKey) == "string" then
                    SaveConfig()
                end
            end
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        vlbl.Font = font
        vlbl.TextColor3 = color
        sfill.BackgroundColor3 = color
    end)
    if callback then callback(default) end
    return { Frame = sldFr, Value = vlbl, Fill = sfill }
end

function CreateInput(parent, text, saveKey, defaultVal, callback)
    local inpFr = Instance.new("Frame")
    inpFr.Size = UDim2.new(1, 0, 0, 36)
    inpFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inpFr.BackgroundTransparency = 0.1
    inpFr.BorderSizePixel = 0
    inpFr.ClipsDescendants = true
    inpFr.Parent = parent
    local icn = Instance.new("UICorner")
    icn.CornerRadius = UDim.new(0, 4)
    icn.Parent = inpFr
    local ist = Instance.new("UIStroke")
    ist.Color = Color3.fromRGB(40, 40, 40)
    ist.Thickness = 1
    ist.Parent = inpFr
    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -20, 0, 14)
    tlbl.Position = UDim2.new(0, 10, 0, 4)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = text
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = Enum.Font.SourceSansBold
    tlbl.TextSize = 12
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = inpFr
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 14)
    box.Position = UDim2.new(0, 10, 0, 18)
    box.BackgroundTransparency = 1
    box.Text = Config[saveKey] or defaultVal or ""
    box.TextColor3 = Color3.fromRGB(150, 150, 150)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = true
    box.Parent = inpFr
    box.FocusLost:Connect(function()
        Config[saveKey] = box.Text
        SaveConfig()
        if callback then callback(box.Text) end
    end)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        box.Font = font
    end)
    return { Frame = inpFr, Box = box }
end

local AllDropdowns = {}
function CreateDropdown(parent, text, options, saveKey, defaultIdx, callback, textOverride)
    local dropFr = Instance.new("Frame")
    dropFr.Size = UDim2.new(1, 0, 0, 36)
    dropFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    dropFr.BackgroundTransparency = 0.1
    dropFr.BorderSizePixel = 0
    dropFr.Parent = parent
    local dcn = Instance.new("UICorner")
    dcn.CornerRadius = UDim.new(0, 4)
    dcn.Parent = dropFr
    local dst = Instance.new("UIStroke")
    dst.Color = Color3.fromRGB(40, 40, 40)
    dst.Thickness = 1
    dst.Parent = dropFr
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = dropFr
    local tlbl = Instance.new("TextLabel")
    tlbl.Size = UDim2.new(1, -30, 1, 0)
    tlbl.Position = UDim2.new(0, 10, 0, 0)
    tlbl.BackgroundTransparency = 1
    local currentIdx = defaultIdx
    if saveKey ~= nil and Config[saveKey] ~= nil then
        currentIdx = Config[saveKey]
    end
    if textOverride then
        tlbl.Text = textOverride
    else
        tlbl.Text = text .. ": " .. (options[currentIdx] and options[currentIdx].Name or "")
    end
    tlbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    tlbl.Font = SharedThemeFont
    tlbl.TextSize = 12
    tlbl.TextXAlignment = Enum.TextXAlignment.Left
    tlbl.TextTruncate = Enum.TextTruncate.AtEnd
    tlbl.Parent = btn
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.Font = Enum.Font.SourceSansBold
    arrow.TextSize = 14
    arrow.Parent = btn
    local listFr = Instance.new("ScrollingFrame")
    listFr.Size = UDim2.new(1, 0, 0, 0)
    listFr.Position = UDim2.new(0, 0, 1, 2)
    listFr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    listFr.BorderSizePixel = 0
    listFr.ScrollBarThickness = 2
    listFr.ZIndex = 10
    listFr.Visible = false
    listFr.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFr.Parent = dropFr
    local lcn = Instance.new("UICorner")
    lcn.CornerRadius = UDim.new(0, 4)
    lcn.Parent = listFr
    local lst = Instance.new("UIStroke")
    lst.Color = Color3.fromRGB(45, 45, 45)
    lst.Thickness = 1
    lst.Parent = listFr
    local llay = Instance.new("UIListLayout")
    llay.SortOrder = Enum.SortOrder.LayoutOrder
    llay.Parent = listFr
    local open = false
    local totalH = #options * 26
    local api = { Frame = dropFr, Parent = parent }
    table.insert(AllDropdowns, api)
    function api.IsOpen() return open end

    function api.Close()
        if open then
            open = false
            arrow.Text = "v"
            local tw = tws:Create(listFr, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) })
            tw:Play()
            tw.Completed:Connect(function()
                if not open then
                    listFr.Visible = false
                    dropFr.ZIndex = 1
                    local anyOpen = false
                    for _, d in ipairs(AllDropdowns) do
                        if d.Parent == parent and d.IsOpen() then
                            anyOpen = true
                        end
                    end
                    if not anyOpen then
                        if parent then parent.ZIndex = 1 end
                        if parent and parent.Parent then parent.Parent.ZIndex = 1 end
                    end
                end
            end)
        end
    end

    btn.MouseButton1Click:Connect(function()
        if not open then
            for _, d in ipairs(AllDropdowns) do
                if d ~= api and d.IsOpen() then
                    d.Close()
                end
            end
            open = true
            dropFr.ZIndex = 10
            if parent then parent.ZIndex = 10 end
            if parent and parent.Parent then parent.Parent.ZIndex = 10 end
            listFr.Visible = true
            arrow.Text = "^"
            tws:Create(listFr, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, math.min(totalH, 120)) }):Play()
        else
            api.Close()
        end
    end)
    local optBtns = {}
    function api.Refresh(newOptions, newTextOverride)
        for _, ob in ipairs(optBtns) do ob:Destroy() end
        optBtns = {}
        options = newOptions
        totalH = #options * 26
        if newTextOverride then
            tlbl.Text = newTextOverride
        elseif saveKey == nil then
            tlbl.Text = text .. ": " .. (options[1] and options[1].Name or "")
        end
        for i, opt in ipairs(options) do
            local obtn = Instance.new("TextButton")
            obtn.Size = UDim2.new(1, 0, 0, 26)
            obtn.BackgroundTransparency = 1
            obtn.Text = "  " .. opt.Name
            if string.find(opt.Name, "^%-%-%[") then
                obtn.TextColor3 = SharedThemeColor
                obtn.Font = Enum.Font.GothamBold
                obtn.TextSize = 13
                obtn.TextXAlignment = Enum.TextXAlignment.Center
                obtn.AutoButtonColor = false
            else
                obtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                obtn.Font = SharedThemeFont
                obtn.TextSize = 12
                obtn.TextXAlignment = Enum.TextXAlignment.Left
                obtn.MouseEnter:Connect(function()
                    tws:Create(obtn, TweenInfo.new(0.15), {
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                end)
                obtn.MouseLeave:Connect(function()
                    tws:Create(obtn, TweenInfo.new(0.15), {
                        TextColor3 = Color3.fromRGB(180, 180, 180)
                    }):Play()
                end)
                obtn.MouseButton1Click:Connect(function()
                    tlbl.Text = text .. ": " .. opt.Name
                    api.Close()
                    if saveKey ~= nil then
                        Config[saveKey] = i
                        SaveConfig()
                    end
                    if callback then callback(opt.Value) end
                end)
            end
            obtn.ZIndex = 11
            obtn.Parent = listFr
            table.insert(optBtns, obtn)
        end
    end

    api.Refresh(options, textOverride)
    table.insert(ThemeUpdateCallbacks, function(color, font)
        tlbl.Font = font
        arrow.Font = font
        for _, ob in ipairs(optBtns) do
            if ob.AutoButtonColor == false then
                ob.TextColor3 = color
            else
                ob.Font = font
            end
        end
    end)
    return api
end

local function WH01AM_TP(target, timeout)
    local SPEED     = 200
    local THRESHOLD = 5
    timeout         = timeout or 35
    local targetPos = typeof(target) == "CFrame" and target.Position or target

    local plr       = LPLR
    local char      = workspace:FindFirstChild(plr.Name) or (plr and plr.Character)
    local hrp       = char and char:FindFirstChild("HumanoidRootPart")
    local hum       = char and char:FindFirstChildOfClass("Humanoid")
    local att       = hrp and hrp:FindFirstChild("RootAttachment")

    if not (hrp and att) then return end

    hrp.Anchored = false

    if hum and hum.SeatPart then
        hum.Sit = false
        task.wait(0.1)
    end

    local origCollide = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            origCollide[p] = p.CanCollide
            p.CanCollide = false
        end
    end

    local lv                  = Instance.new("LinearVelocity")
    lv.Attachment0            = att
    lv.MaxForce               = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity         = Vector3.zero
    lv.Parent                 = hrp

    local noclipConn
    noclipConn                = RS.Stepped:Connect(function()
        if not char or not char.Parent then
            noclipConn:Disconnect()
            return
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)

    local arrived             = false
    local startTime           = tick()

    local conn
    conn                      = RS.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent or (tick() - startTime > timeout) then
            conn:Disconnect()
            noclipConn:Disconnect()
            pcall(function() lv:Destroy() end)
            arrived = true
            return
        end

        local remaining = targetPos - hrp.Position
        local dist = remaining.Magnitude

        if dist <= THRESHOLD then
            lv.VectorVelocity = Vector3.zero
            conn:Disconnect()
            pcall(function() lv:Destroy() end)
            arrived = true

            task.delay(1, function()
                noclipConn:Disconnect()
                for p, state in pairs(origCollide) do
                    pcall(function() p.CanCollide = state end)
                end
            end)

            return
        end

        local speed = math.clamp(dist * 3, 20, SPEED)
        lv.VectorVelocity = remaining.Unit * speed
    end)

    while not arrived do
        task.wait(0.05)
    end
end
getgenv().WH01AM_TP = WH01AM_TP

function HouseRobTP(pos)
    WH01AM_TP(pos)
end

local LOCATIONS = {
    ["🏘️Apartments"] = Vector3.new(-1665.98, 4.60, -299.28),
    ["💈Barber Shop"] = Vector3.new(-1468.55, 4.80, -66.79),
    ["🔫BlackMarket"] = Vector3.new(-1010.57, 5.28, 160.24),
    ["📦Box Job"] = Vector3.new(248, 5, -344),
    ["🐔Chicken Shop"] = Vector3.new(-897.63, 4.79, -1569.57),
    ["👕Clothes Shop"] = Vector3.new(-1481.19, 4.80, -1760.46),
    ["🛒Convenience Store"] = Vector3.new(85, 5, -321),
    ["🚗Dealer"] = Vector3.new(-230.78, 4.83, -411.38),
    ["🥪Deli"] = Vector3.new(-1004.40, 4.83, -671.72),
    ["👗Female Clothing"] = Vector3.new(-335.85, 4.80, -752.62),
    ["🔫Gun Store"] = Vector3.new(-1254.09, 4.91, -1086.93),
    ["🍔Ham"] = Vector3.new(-1476.70, 4.80, -867.19),
    ["🔧HardWare Store"] = Vector3.new(92.37, 4.85, -1926.36),
    ["💍Jewelry"] = Vector3.new(-302.70, 4.80, 649.07),
    ["💰Pawn Shop"] = Vector3.new(-1151.66, 4.80, 644.32),
    ["👟Shoe Store"] = Vector3.new(175, 5, 125),
    ["🎤Studio"] = Vector3.new(-70.84, 4.80, 2114.73),
    ["💉Tattoo"] = Vector3.new(-1090.62, 4.80, -517.11),
    ["🍬Candy"] = Vector3.new(442, 5, 253),
}
function getMyPropertyPosition()
    local CS = game:GetService("CollectionService")
    for _, apt in ipairs(CS:GetTagged("Apt")) do
        if apt:GetAttribute("Owner") == LPLR.Name then
            local p = apt:FindFirstChild("Door") or apt:FindFirstChild("BuyPart") or apt.PrimaryPart
            if p then return p.Position end
            return apt:GetPivot().Position
        end
    end
    local aptFolders = {
        workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("BrokeAPTS"),
        workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("Houses")
    }
    for _, folder in ipairs(aptFolders) do
        if folder then
            for _, apt in ipairs(folder:GetChildren()) do
                if apt:GetAttribute("Owner") == LPLR.Name then
                    local p = apt:FindFirstChild("Door") or apt:FindFirstChild("BuyPart") or apt.PrimaryPart
                    if p then return p.Position end
                    return apt:GetPivot().Position
                end
                local success, foundPos = pcall(function()
                    local buyPart = apt:FindFirstChild("BuyPart")
                    local userLabel = buyPart and buyPart:FindFirstChild("UI")
                        and buyPart.UI:FindFirstChild("Owned")
                        and buyPart.UI.Owned:FindFirstChild("Frame")
                        and buyPart.UI.Owned.Frame:FindFirstChild("User")
                    if userLabel and userLabel:IsA("TextLabel") then
                        if userLabel.Text == LPLR.Name or userLabel.Text == LPLR.DisplayName then
                            local p = apt:FindFirstChild("Door") or apt:FindFirstChild("BuyPart") or apt.PrimaryPart
                            if p then return p.Position end
                            return apt:GetPivot().Position
                        end
                    end
                end)
                if success and foundPos then return foundPos end
            end
        end
    end
    return nil
end

getgenv().EXE = getgenv().EXE or {}
getgenv().EXE.GUN_MODS = getgenv().EXE.GUN_MODS or {
    RapidFire = false,
    AutoReload = false,
    NoRecoil = false,
    FastReload = false,
    FireRate = 0.05,
    SpeedBypass = false,
    FlySpeed = 50,
    WalkBypassSpeed = 50,
    CarFly = false,
    CarFlySpeed = 150,
    ReloadThreshold = 5
}
getgenv().EXE.GUN_MODS.InfAmmo = false
getgenv().EXE.CAR_MODS = getgenv().EXE.CAR_MODS or {
    SpeedBoost = false,
    SpeedValue = 100,
    InstaBrake = false,
    InfGas = false
}
local fovCircle = nil
getgenv().SilentAim_Enabled = getgenv().SilentAim_Enabled or false
getgenv().SilentAim_ShowFOV = getgenv().SilentAim_ShowFOV or false
getgenv().SilentAim_FOVRadius = getgenv().SilentAim_FOVRadius or 150
getgenv().SilentAim_TargetPart = getgenv().SilentAim_TargetPart or "Head"
getgenv().SilentAim_Wallbang = getgenv().SilentAim_Wallbang or false
getgenv().SilentAim_FOVColor = getgenv().SilentAim_FOVColor or Color3.fromRGB(255, 255, 255)

task.spawn(function()
    while task.wait(0.1) do
        shared.EXE = getgenv().EXE
        shared.SilentAim_Enabled = getgenv().SilentAim_Enabled
        shared.SilentAim_FOVRadius = getgenv().SilentAim_FOVRadius
        shared.SilentAim_TargetPart = getgenv().SilentAim_TargetPart
        shared.SilentAim_Wallbang = getgenv().SilentAim_Wallbang
    end
end)
local function getTargetScreenPosition()
    local cam = workspace.CurrentCamera
    if uis.TouchEnabled and cam then
        return cam.ViewportSize / 2
    end
    return uis:GetMouseLocation()
end

pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = false
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 64
        fovCircle.Radius = 150
        fovCircle.Filled = false
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        RS.RenderStepped:Connect(function()
            if fovCircle then
                if getgenv().SilentAim_ShowFOV and getgenv().SilentAim_Enabled then
                    fovCircle.Position = getTargetScreenPosition()
                    fovCircle.Radius = getgenv().SilentAim_FOVRadius or 150
                    fovCircle.Color = getgenv().SilentAim_FOVColor or Color3.fromRGB(255, 255, 255)
                    fovCircle.Visible = true
                else
                    fovCircle.Visible = false
                end
            end
        end)
    end
end)
local function isPartVisible(part, targetCharacter, origin)
    local cam = workspace.CurrentCamera
    local startPos = origin or (cam and cam.CFrame.Position)
    if not startPos or not part then return false end
    local destination = part.Position
    local direction = destination - startPos
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local charFolder = workspace:FindFirstChild("Characters")
    local myChar = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
        workspace:FindFirstChild(LPLR.Name)
    local filterList = {}
    if myChar then table.insert(filterList, myChar) end
    if targetCharacter then table.insert(filterList, targetCharacter) end
    local debris = workspace:FindFirstChild("Debris")
    if debris then table.insert(filterList, debris) end
    local safezones = workspace:FindFirstChild("Safezones")
    if safezones then table.insert(filterList, safezones) end
    local camZones = workspace:FindFirstChild("CameraZones")
    if camZones then table.insert(filterList, camZones) end
    params.FilterDescendantsInstances = filterList
    params.IgnoreWater = true
    local result = workspace:Raycast(startPos, direction, params)
    if result then
        local hit = result.Instance
        if hit.CanCollide then
            local isPlayerPart = hit:FindFirstAncestorOfClass("Model") and
                hit:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")
            local isCharFolderPart = hit:IsDescendantOf(charFolder or workspace) and
                (hit.Parent:FindFirstChildOfClass("Humanoid") or (hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass("Humanoid")))
            if not isPlayerPart and not isCharFolderPart then
                return false
            end
        end
    end
    return true
end

local function getClosestPlayerToMouse(fovRadius, targetPartName, originOverride)
    local closestPlayer = nil
    local closestPart = nil
    local minDist = fovRadius or 99999
    local mousePos = getTargetScreenPosition()
    local cam = workspace.CurrentCamera

    local wallbang = getgenv().SilentAim_Wallbang
    if wallbang == nil then wallbang = shared.SilentAim_Wallbang end

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = nil
            if targetPartName == "Torso" then
                part = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            else
                part = player.Character:FindFirstChild(targetPartName)
            end
            if part then
                local isAllowed = true
                if not wallbang then
                    isAllowed = isPartVisible(part, player.Character, originOverride or (cam and cam.CFrame.Position))
                end
                if isAllowed then
                    local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestPlayer = player
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPlayer, closestPart
end

getgenv().EXE.CastRayHandler = function(self, oldCastRay, origin, targetPosition, ...)
    if getgenv().SilentAim_Enabled then
        local targetPlayer, targetPart = getClosestPlayerToMouse(getgenv().SilentAim_FOVRadius,
            getgenv().SilentAim_TargetPart, origin)
        if targetPlayer and targetPart then
            local distance = (origin - targetPart.Position).Magnitude
            local mockResult = {
                Position = targetPart.Position,
                Instance = targetPart,
                Normal = Vector3.new(0, 1, 0),
                Material = Enum.Material.SmoothPlastic
            }
            return targetPart.Position, targetPart, distance, mockResult
        end
    end
    return oldCastRay(self, origin, targetPosition, ...)
end
getgenv().EXE.ImpulseXHandler = function(springSelf, oldImpulseX, ...)
    if getgenv().EXE.GUN_MODS.NoRecoil then
        return
    end
    return oldImpulseX(springSelf, ...)
end
getgenv().EXE.ImpulseZHandler = function(springSelf, oldImpulseZ, ...)
    if getgenv().EXE.GUN_MODS.NoRecoil then
        return
    end
    return oldImpulseZ(springSelf, ...)
end
getgenv().EXE.FireHandler = function(self, oldFire, ...)
    if self.Setting then
        if not self.Setting.OriginalRPM then
            self.Setting.OriginalOriginalRPM = self.Setting.RPM
            self.Setting.OriginalAutomatic = self.Setting.Automatic
            self.Setting.OriginalEquipTime = self.Setting.OriginalEquipTime or self.Setting.EquipTime
            self.Setting.OriginalCameraRecoil = self.Setting.OriginalCameraRecoil or self.Setting.CameraRecoil
        end
        if getgenv().EXE.GUN_MODS.NoRecoil then
            self.Setting.CameraRecoil = 0
        else
            self.Setting.CameraRecoil = self.Setting.OriginalCameraRecoil
        end
        if getgenv().EXE.GUN_MODS.RapidFire then
            self.Setting.RPM = 1200
            self.Setting.Automatic = true
        else
            self.Setting.RPM = self.Setting.OriginalOriginalRPM or self.Setting.RPM
            self.Setting.Automatic = self.Setting.OriginalAutomatic
        end
    end
    if getgenv().EXE.GUN_MODS.AutoReload and self.Gun then
        pcall(function()
            local currentAmmo = self.Gun:GetAttribute("Ammo")
            local threshold = getgenv().EXE.GUN_MODS.ReloadThreshold or 5
            if currentAmmo and currentAmmo <= threshold then
                local reloadEvent = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Reload")
                if reloadEvent then
                    reloadEvent:FireServer()
                end
            end
        end)
    end
    return oldFire(self, ...)
end
getgenv().EXE.ReloadHandler = function(self, oldReload, ...)
    if self.Animations and getgenv().EXE.GUN_MODS.AutoReload then
        task.spawn(function()
            local startReload = tick()
            while self.Gun and self.Gun:GetAttribute("IsReloading") and tick() - startReload < 5 do
                pcall(function()
                    local track = self.Animations.Reload or self.OneHandedAnimations.Reload
                    if track and track.IsPlaying then
                        track:AdjustSpeed(100)
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
    return oldReload(self, ...)
end
task.spawn(function()
    while task.wait(2) do
        local success, GunClass = pcall(function()
            return require(game:GetService("ReplicatedStorage").Modules.Utils.GunClass)
        end)
        if success and GunClass then
            if not GunClass.HotReloadable then
                GunClass.HotReloadable = true

                -- Exposure to shared for Luarmor sandbox compatibility:
                shared.EXE = getgenv().EXE
                shared.SilentAim_Enabled = getgenv().SilentAim_Enabled
                shared.SilentAim_FOVRadius = getgenv().SilentAim_FOVRadius
                shared.SilentAim_TargetPart = getgenv().SilentAim_TargetPart
                shared.SilentAim_Wallbang = getgenv().SilentAim_Wallbang

                local oldCastRay = GunClass.CastRay
                GunClass.CastRay = function(self, origin, targetPosition, ...)
                    -- Luarmor runs the main script in a sandbox, but game calls hooks on native threads.
                    -- We read from shared if getgenv() is not accessible.
                    local exeObj = getgenv().EXE or shared.EXE
                    local silentAimEnabled = getgenv().SilentAim_Enabled or shared.SilentAim_Enabled
                    local fovRadius = getgenv().SilentAim_FOVRadius or shared.SilentAim_FOVRadius
                    local targetPartName = getgenv().SilentAim_TargetPart or shared.SilentAim_TargetPart
                    local wallbang = getgenv().SilentAim_Wallbang or shared.SilentAim_Wallbang

                    if silentAimEnabled then
                        local targetPlayer, targetPart = getClosestPlayerToMouse(fovRadius, targetPartName, origin)
                        if targetPlayer and targetPart then
                            local distance = (origin - targetPart.Position).Magnitude
                            local mockResult = {
                                Position = targetPart.Position,
                                Instance = targetPart,
                                Normal = Vector3.new(0, 1, 0),
                                Material = Enum.Material.SmoothPlastic
                            }
                            return targetPart.Position, targetPart, distance, mockResult
                        end
                    end
                    return oldCastRay(self, origin, targetPosition, ...)
                end

                local oldFire = GunClass.Fire
                GunClass.Fire = function(self, ...)
                    local exeObj = getgenv().EXE or shared.EXE
                    if exeObj and exeObj.GUN_MODS and self.Setting then
                        if not self.Setting.OriginalRPM then
                            self.Setting.OriginalOriginalRPM = self.Setting.RPM
                            self.Setting.OriginalAutomatic = self.Setting.Automatic
                            self.Setting.OriginalEquipTime = self.Setting.OriginalEquipTime or self.Setting.EquipTime
                            self.Setting.OriginalCameraRecoil = self.Setting.OriginalCameraRecoil or
                                self.Setting.CameraRecoil
                        end
                        if exeObj.GUN_MODS.NoRecoil then
                            self.Setting.CameraRecoil = 0
                        else
                            self.Setting.CameraRecoil = self.Setting.OriginalCameraRecoil
                        end
                        if exeObj.GUN_MODS.RapidFire then
                            self.Setting.RPM = 1200
                            self.Setting.Automatic = true
                        else
                            self.Setting.RPM = self.Setting.OriginalOriginalRPM or self.Setting.RPM
                            self.Setting.Automatic = self.Setting.OriginalAutomatic
                        end
                    end
                    if exeObj and exeObj.GUN_MODS and exeObj.GUN_MODS.AutoReload and self.Gun then
                        pcall(function()
                            local currentAmmo = self.Gun:GetAttribute("Ammo")
                            local threshold = exeObj.GUN_MODS.ReloadThreshold or 5
                            if currentAmmo and currentAmmo <= threshold then
                                local reloadEvent = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Reload")
                                if reloadEvent then
                                    reloadEvent:FireServer()
                                end
                            end
                        end)
                    end
                    return oldFire(self, ...)
                end

                local oldReload = GunClass.Reload
                GunClass.Reload = function(self, ...)
                    local exeObj = getgenv().EXE or shared.EXE
                    if exeObj and exeObj.GUN_MODS and self.Animations and exeObj.GUN_MODS.AutoReload then
                        task.spawn(function()
                            local startReload = tick()
                            while self.Gun and self.Gun:GetAttribute("IsReloading") and tick() - startReload < 5 do
                                pcall(function()
                                    local track = self.Animations.Reload or self.OneHandedAnimations.Reload
                                    if track and track.IsPlaying then
                                        track:AdjustSpeed(100)
                                    end
                                end)
                                task.wait(0.05)
                            end
                        end)
                    end
                    return oldReload(self, ...)
                end

                pcall(function()
                    if GunClass.RecoilSpringX and GunClass.RecoilSpringX.Impulse then
                        local oldImpulseX = GunClass.RecoilSpringX.Impulse
                        GunClass.RecoilSpringX.Impulse = function(springSelf, ...)
                            local exeObj = getgenv().EXE or shared.EXE
                            if exeObj and exeObj.GUN_MODS and exeObj.GUN_MODS.NoRecoil then
                                return
                            end
                            return oldImpulseX(springSelf, ...)
                        end
                    end
                    if GunClass.RecoilSpringZ and GunClass.RecoilSpringZ.Impulse then
                        local oldImpulseZ = GunClass.RecoilSpringZ.Impulse
                        GunClass.RecoilSpringZ.Impulse = function(springSelf, ...)
                            local exeObj = getgenv().EXE or shared.EXE
                            if exeObj and exeObj.GUN_MODS and exeObj.GUN_MODS.NoRecoil then
                                return
                            end
                            return oldImpulseZ(springSelf, ...)
                        end
                    end
                end)
            end
            break
        end
    end
end)
local speedAttachment = nil
local speedVelocity = nil
local speedConn = nil
function CLEANUP_SPEED()
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
    pcall(function()
        if speedVelocity then
            speedVelocity:Destroy()
            speedVelocity = nil
        end
        if speedAttachment then
            speedAttachment:Destroy()
            speedAttachment = nil
        end
        local charFolder = workspace:FindFirstChild("Characters")
        local char = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in ipairs(hrp:GetChildren()) do
                    if child.Name == "SpeedBypassVelocity" or child.Name == "SpeedBypassAttachment" then
                        child:Destroy()
                    end
                end
            end
        end
    end)
end

function APPLY_SPEED_BOOST()
    CLEANUP_SPEED()
    local charFolder = workspace:FindFirstChild("Characters")
    local char = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
        workspace:FindFirstChild(LPLR.Name)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    speedAttachment = Instance.new("Attachment")
    speedAttachment.Name = "SpeedBypassAttachment"
    speedAttachment.Parent = root
    speedVelocity = Instance.new("LinearVelocity")
    speedVelocity.Name = "SpeedBypassVelocity"
    speedVelocity.Attachment0 = speedAttachment
    speedVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    speedVelocity.MaxAxesForce = Vector3.new(25000, 0, 25000)
    speedVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    speedVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    speedVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    speedVelocity.Parent = root
    speedConn = RS.Heartbeat:Connect(function()
        local cFolder = workspace:FindFirstChild("Characters")
        local c2 = (cFolder and cFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
        if not r2 or not h2 or not speedVelocity then
            CLEANUP_SPEED()
            return
        end
        local moveDir = h2.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local target = getgenv().EXE.GUN_MODS.WalkBypassSpeed or 50
            local targetSpeed = 20 + (target / 100) * (28 - 20)
            speedVelocity.VectorVelocity = Vector3.new(moveDir.X * targetSpeed, 0, moveDir.Z * targetSpeed)
        else
            speedVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

local staminaConn = nil
local originalStaminaLoss = nil
local originalStaminaGain = nil
local originalStaminaCD = nil
local staminaCfgTable = nil
local staminaStateTable = nil
local infStaminaActive = false
function FIND_STAMINA_TABLES()
    if staminaCfgTable and staminaStateTable then
        return staminaCfgTable, staminaStateTable
    end
    local gc = (type(getgc) == "function" and getgc)
    if not gc then return nil, nil end
    local success, tbls = pcall(function() return gc(true) end)
    if not success then
        success, tbls = pcall(function() return gc() end)
    end
    if not success or not tbls then return nil, nil end
    for _, v in ipairs(tbls) do
        if type(v) == "table" then
            if rawget(v, "STAMINA_LOSS_RATE") ~= nil and rawget(v, "STAMINA_GAIN_RATE") ~= nil then
                staminaCfgTable = v
            end
            if rawget(v, "Stamina") ~= nil and rawget(v, "IsVaulting") ~= nil then
                staminaStateTable = v
            end
        end
        if staminaCfgTable and staminaStateTable then break end
    end
    return staminaCfgTable, staminaStateTable
end

function APPLY_INF_STAMINA()
    local cfg, state = FIND_STAMINA_TABLES()
    if cfg then
        if originalStaminaLoss == nil then originalStaminaLoss = cfg.STAMINA_LOSS_RATE end
        if originalStaminaGain == nil then originalStaminaGain = cfg.STAMINA_GAIN_RATE end
        if originalStaminaCD == nil then originalStaminaCD = cfg.STAMINA_CD_TIME end
        cfg.STAMINA_LOSS_RATE = 0
        cfg.STAMINA_GAIN_RATE = 9999
        cfg.STAMINA_CD_TIME = 0
    end
    if staminaConn then
        staminaConn:Disconnect()
        staminaConn = nil
    end
    staminaConn = RS.Heartbeat:Connect(function()
        local _, s = FIND_STAMINA_TABLES()
        if s then
            s.Stamina = 100
        end
    end)
end

function CLEANUP_STAMINA()
    if staminaConn then
        staminaConn:Disconnect()
        staminaConn = nil
    end
    local cfg, _ = FIND_STAMINA_TABLES()
    if cfg then
        if originalStaminaLoss ~= nil then cfg.STAMINA_LOSS_RATE = originalStaminaLoss end
        if originalStaminaGain ~= nil then cfg.STAMINA_GAIN_RATE = originalStaminaGain end
        if originalStaminaCD ~= nil then cfg.STAMINA_CD_TIME = originalStaminaCD end
    end
end

local flyConnection = nil
local flyPos = Vector3.zero
function CLEANUP_FLY()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local charFolder = workspace:FindFirstChild("Characters")
    local char = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
        workspace:FindFirstChild(LPLR.Name)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "BypassFlyPlatform" then
                obj:Destroy()
            end
        end
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child.Name == "BypassFlyPlatform" then
                    child:Destroy()
                end
            end
        end
    end)
end

local isCarFlying = false
local currentVehicle = nil
local carFlyConnection = nil
local originalCollisions = {}
function get_vic()
    local charFolder = workspace:FindFirstChild("Characters")
    local char = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
        workspace:FindFirstChild(LPLR.Name)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        local vehicle = seat:FindFirstAncestorWhichIsA("Model") or seat.Parent
        return vehicle, seat
    end
    return nil, nil
end

function cleanupCarFly()
    if carFlyConnection then
        carFlyConnection:Disconnect()
        carFlyConnection = nil
    end
    pcall(function()
        if currentVehicle then
            for _, p in ipairs(currentVehicle:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    if originalCollisions[p] ~= nil then
                        p.CanCollide = originalCollisions[p]
                    end
                end
            end
        end
    end)
    originalCollisions = {}
    currentVehicle = nil
    isCarFlying = false
end

getgenv().EXE.CLEANUP_CAR_FLY = cleanupCarFly
function startCarFly()
    cleanupCarFly()
    local vehicle, seat = get_vic()
    if not vehicle or not seat then
        Notify("Car Fly", "You must be sitting in a vehicle seat!", 3)
        if getgenv().EXE.AS_TGL_OBJ_CARFLY then
            getgenv().EXE.AS_TGL_OBJ_CARFLY:SET(false, true)
        end
        return
    end
    currentVehicle = vehicle
    isCarFlying = true
    local pos = seat.Position
    for _, p in ipairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") then
            originalCollisions[p] = p.CanCollide
            p.Anchored = true
            if p ~= seat then
                p.CanCollide = false
            end
        end
    end
    carFlyConnection = RS.Heartbeat:Connect(function(dt)
        if not isCarFlying or not vehicle.Parent or not seat.Parent then
            cleanupCarFly()
            return
        end
        local cFolder = workspace:FindFirstChild("Characters")
        local char = (cFolder and cFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.SeatPart ~= seat then
            cleanupCarFly()
            if getgenv().EXE.AS_TGL_OBJ_CARFLY then
                getgenv().EXE.AS_TGL_OBJ_CARFLY:SET(false, true)
            end
            return
        end
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        local speedVal = getgenv().EXE.GUN_MODS.CarFlySpeed or 150
        local speed = speedVal
        local UIS2 = game:GetService("UserInputService")
        local moveDir = Vector3.new(0, 0, 0)
        if UIS2:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
        if UIS2:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
        if UIS2:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end
        local vertical = 0
        if UIS2:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then
            vertical = -1
        end
        local velocity = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then
            velocity = moveDir.Unit * speed
        end
        if vertical ~= 0 then
            velocity = velocity + Vector3.new(0, vertical * speed, 0)
        end
        pos = pos + (velocity * dt)
        vehicle:PivotTo(CFrame.new(
            pos,
            cam.CFrame.Position + (pos - cam.CFrame.Position) * 2
        ))
    end)
end

task.spawn(function()
    RS.Heartbeat:Connect(function()
        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                local seat = hum.SeatPart
                if getgenv().EXE.CAR_MODS.SpeedBoost and seat.Throttle > 0 then
                    local speed = getgenv().EXE.CAR_MODS.SpeedValue or 100
                    seat.AssemblyLinearVelocity = seat.CFrame.LookVector * speed
                end
                if getgenv().EXE.CAR_MODS.InstaBrake and seat.Throttle < 0 then
                    seat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    seat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
                if getgenv().EXE.CAR_MODS.InfGas then
                    seat.Parent:SetAttribute("Gas", 100)
                end
            end
        end)
    end)
end)
local pma, pmo, pvi, pco, pfa, pbyp

local autoSendMoneyLoop = nil
local autoDropEnabled = false
local lastDropTime = 0
local isDropping = false

function sendChatMessage(msg)
    task.spawn(function()
        pcall(function()
            if LPLR and LPLR.Chat then
                LPLR:Chat(msg)
            end
        end)
    end)
    task.spawn(function()
        pcall(function()
            local TextChatService = game:GetService("TextChatService")
            if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local general = TextChatService:FindFirstChild("TextChannels") and
                    TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if general then general:SendAsync(msg) end
            end
        end)
    end)
    task.spawn(function()
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if DefaultChatSystemChatEvents then
                local SayMessageRequest = DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                if SayMessageRequest then SayMessageRequest:FireServer(msg, "All") end
            end
        end)
    end)
end

function checkAmountMatch(item, targetAmount)
    local possibleNames = { "Amount", "amount", "Ammount", "ammount" }
    for _, name in ipairs(possibleNames) do
        local attr = item:GetAttribute(name)
        if attr ~= nil then
            if tonumber(attr) == targetAmount or tostring(attr) == tostring(targetAmount) then return true end
        end
    end
    table.insert(possibleNames, "Value")
    table.insert(possibleNames, "value")
    for _, name in ipairs(possibleNames) do
        local amtObj = item:FindFirstChild(name)
        if amtObj then
            local val = tonumber(amtObj.Value)
            if val == targetAmount or tostring(amtObj.Value) == tostring(targetAmount) then return true end
        end
    end
    for _, child in ipairs(item:GetDescendants()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
            if tonumber(child.Value) == targetAmount or tostring(child.Value) == tostring(targetAmount) then return true end
        end
    end
    return false
end

function getMatchingCashTool(targetAmount)
    local inv = LPLR.Backpack:GetChildren()
    if LPLR.Character then
        for _, c in ipairs(LPLR.Character:GetChildren()) do
            table.insert(inv, c)
        end
    end
    for _, item in ipairs(inv) do
        if item:IsA("Tool") and (item.Name:lower():find("cash") or item.Name:lower():find("money")) then
            if checkAmountMatch(item, targetAmount) then
                return item
            end
        end
    end
    return nil
end

function handleCashDrop(cashTool)
    if isDropping or not cashTool or not LPLR.Character then return end
    isDropping = true
    pcall(function()
        local humanoid = LPLR.Character:FindFirstChildOfClass("Humanoid")
        for _, child in ipairs(LPLR.Character:GetChildren()) do
            if child:IsA("Tool") and child ~= cashTool then
                humanoid:UnequipTools()
                task.wait(0.2)
                break
            end
        end
        if cashTool.Parent ~= LPLR.Character then
            humanoid:EquipTool(cashTool)
            task.wait(0.8)
        end
        local rs = game:GetService("ReplicatedStorage")
        local consoleMenu
        pcall(function()
            consoleMenu = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/ConsoleMenu")
        end)
        if not consoleMenu then
            consoleMenu = rs:FindFirstChild("RE/ConsoleMenu", true)
        end
        if consoleMenu and consoleMenu:IsA("RemoteEvent") then
            consoleMenu:FireServer("Drop")
            task.wait(0.1)
            consoleMenu:FireServer("Drop")
        end
    end)
    task.wait(0.5)
    isDropping = false
end

function buildMainTeleports(pma)
    local ctp = CreateCard(pma, "Teleports")
    local SelectedLocation = "My Property"
    local locOptions = {}
    for name, _ in pairs(LOCATIONS) do
        table.insert(locOptions, { Name = name, Value = name })
    end
    table.sort(locOptions, function(a, b) return a.Name < b.Name end)
    table.insert(locOptions, 1, { Name = "My Property", Value = "My Property" })
    table.insert(locOptions, 2, { Name = "🏍️Surrons", Value = "🏍️Surrons" })
    table.insert(locOptions, 3, { Name = "🏧Random ATM", Value = "🏧Random ATM" })
    CreateDropdown(ctp, "Location", locOptions, "TeleportLocation", 1, function(val)
        SelectedLocation = val
    end, "Select Location...")
    local SelectedPlayer = nil
    local playerDropdown = nil
    function getPlayerOptions()
        local list = {}
        for _, p in ipairs(pls:GetPlayers()) do
            if p ~= LPLR then
                table.insert(list, { Name = p.Name, Value = p.Name })
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        if #list == 0 then
            table.insert(list, { Name = "No Players Found", Value = "" })
        end
        return list
    end

    playerDropdown = CreateDropdown(ctp, "Teleport to Player", getPlayerOptions(), nil, 1, function(val)
        SelectedPlayer = val
    end, "Select Player...")
    local lastTPTime = 0
    CreateCardButton(ctp, "Teleport to Location", function()
        if tick() - lastTPTime < 11 then
            Notify("Cooldown", "Please wait " .. math.ceil(11 - (tick() - lastTPTime)) .. " seconds.", 3)
            return
        end
        lastTPTime = tick()
        if SelectedLocation == "My Property" then
            local props = workspace:FindFirstChild("Properties")
            if props then
                for _, p in ipairs(props:GetChildren()) do
                    local owner = p:GetAttribute("Owner")
                    if owner and (owner == LPLR.Name or owner == tostring(LPLR.UserId)) then
                        HouseRobTP(p:GetPivot())
                        return
                    end
                end
            end
            Notify("Teleport", "Property not found!", 3)
        elseif SelectedLocation == "🏍️Surrons" then
            local purchases = workspace:FindFirstChild("Purchases")
            local surrons = purchases and purchases:FindFirstChild("Surrons")
            if surrons then
                local firstBike = surrons:FindFirstChildWhichIsA("Model")
                if firstBike then
                    HouseRobTP(firstBike:GetPivot() + Vector3.new(0, 3, 0))
                    return
                end
            end
            Notify("Teleport", "Surrons location not found!", 3)
        elseif SelectedLocation == "🏧Random ATM" then
            local atms = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:find("ATM") or obj.Name:find("Atm")) then
                    table.insert(atms, obj)
                end
            end
            if #atms > 0 then
                local randomATM = atms[math.random(1, #atms)]
                HouseRobTP(randomATM:GetPivot() + Vector3.new(0, 3, 0))
            else
                Notify("Teleport", "No ATMs found!", 3)
            end
        elseif LOCATIONS[SelectedLocation] then
            HouseRobTP(LOCATIONS[SelectedLocation])
        end
    end)
    CreateCardButton(ctp, "Teleport to Player", function()
        if not SelectedPlayer or SelectedPlayer == "" then
            Notify("Teleport", "Please select a player first!", 3)
            return
        end
        local target = pls:FindFirstChild(SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            HouseRobTP(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
        else
            Notify("Teleport", "Player character not found!", 3)
        end
    end)
    local refreshPending = false
    function scheduleRefresh()
        if refreshPending then return end
        refreshPending = true
        task.delay(0.5, function()
            refreshPending = false
            if playerDropdown and playerDropdown.Refresh then
                playerDropdown.Refresh(getPlayerOptions(), "Select Player...")
            end
        end)
    end

    pls.PlayerAdded:Connect(scheduleRefresh)
    pls.PlayerRemoving:Connect(scheduleRefresh)
end

function buildMainGunMods(pma)
    local cGunMods = CreateCard(pma, "Gun Mods")
    CreateToggle(cGunMods, "Auto Reload", getgenv().EXE.GUN_MODS.AutoReload, "GunModsAutoReload", function(state)
        getgenv().EXE.GUN_MODS.AutoReload = state
    end)
    CreateSlider(cGunMods, "Reload Ammo Count", 0, 10, getgenv().EXE.GUN_MODS.ReloadThreshold or 5,
        "GunModsReloadThreshold",
        function(val)
            getgenv().EXE.GUN_MODS.ReloadThreshold = val
        end)
    CreateToggle(cGunMods, "No Recoil & No Spread", getgenv().EXE.GUN_MODS.NoRecoil, "GunModsNoRecoil", function(state)
        getgenv().EXE.GUN_MODS.NoRecoil = state
    end)
    CreateToggle(cGunMods, "Rapid Fire", getgenv().EXE.GUN_MODS.RapidFire, "GunModsRapidFire", function(state)
        getgenv().EXE.GUN_MODS.RapidFire = state
    end)
end

function buildMainStore(pma)
    local cStore = CreateCard(pma, "Store")
    local selectedCategory = nil
    local selectedItemName = nil
    local selectedQty = 1

    local storeCategories = {
        { Name = "Guns", Value = "Guns" },
        { Name = "Ammo", Value = "Ammo" }
    }
    local itemsByCategory = {
        Guns = {
            { Name = "ARPistol $7300",            Value = "ARPistol" },
            { Name = "Draco $5600",               Value = "Draco" },
            { Name = "Draco Drum $10000",         Value = "Draco Drum" },
            { Name = "G17 $1500",                 Value = "G17" },
            { Name = "G19 Clear EXT $4300",       Value = "G19 Clear EXT" },
            { Name = "G22 DB $3200",              Value = "G22 DB" },
            { Name = "G43X Beam $3000",           Value = "G43X Beam" },
            { Name = "Tec-9 $4599",               Value = "Tec-9" },
            { Name = "Springfield Hellcat $3500", Value = "Springfield Hellcat" }
        },
        Ammo = {
            { Name = "5.56 Mag",      Value = "5.56 Mag" },
            { Name = "7.62 Mag",      Value = "7.62 Mag" },
            { Name = "9mm Extended",  Value = "9mm Extended" },
            { Name = "9mm Mag",       Value = "9mm Mag" },
            { Name = "Drum Mag",      Value = "Drum Mag" },
            { Name = "Flavor Packet", Value = "Flavor Packet" },
            { Name = "Water Gallon",  Value = "Water Gallon" }
        }
    }
    local itemDropdown = nil
    CreateDropdown(cStore, "Category:", storeCategories, "StoreCategory", 1, function(val)
        selectedCategory = val
        selectedItemName = nil
        if itemDropdown and itemDropdown.Refresh then
            local options = itemsByCategory[val] or { { Name = "Select a Category", Value = "" } }
            itemDropdown.Refresh(options, "Select Item...")
        end
    end, "Select Category...")

    itemDropdown = CreateDropdown(cStore, "Item:", { { Name = "Select a Category First", Value = "" } }, "StoreItem", 1,
        function(val)
            selectedItemName = val
        end, "Select Item...")

    local storeQtyOptions = {}
    for i = 1, 10 do
        table.insert(storeQtyOptions, { Name = tostring(i), Value = tostring(i) })
    end
    CreateDropdown(cStore, "Quantity:", storeQtyOptions, "StoreQty", 1, function(val)
        selectedQty = tonumber(val) or 1
    end, "1")

    CreateCardButton(cStore, "Buy Item", function()
        if not selectedCategory or selectedCategory == "" then
            Notify("Store", "Please select a Category first!", 3)
            return
        end
        if not selectedItemName or selectedItemName == "" then
            Notify("Store", "Please select an Item first!", 3)
            return
        end

        Notify("Store", "Purchasing " .. tostring(selectedQty) .. "x " .. selectedItemName .. "...", 3)
        task.spawn(function()
            for i = 1, selectedQty do
                pcall(function()
                    if selectedItemName == "Flavor Packet" or selectedItemName == "Water Gallon" then
                        local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Convenience")
                        if Event then
                            Event:FireServer("PurchasePablo", { name = selectedItemName, category = "Items" })
                        end
                    else
                        local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/GunShop")
                        if Event then
                            local catParam = (selectedCategory == "Guns") and "Gun" or "Ammo"
                            Event:FireServer("Purchase", { name = selectedItemName, category = catParam })
                        end
                    end
                end)
                if i < selectedQty then task.wait(0.3) end
            end
            Notify("Store", "Purchase complete!", 3)
        end)
    end)
end

function buildMainExtras(pma)
    local cExt = CreateCard(pma, "Extras")
    local selectedExtraPlayer = nil
    local sendAmount = 0
    local extraPlayerDropdown = nil

    function getExtraPlayerOptions()
        local list = {}
        for _, p in ipairs(pls:GetPlayers()) do
            if p ~= LPLR then
                table.insert(list, { Name = p.Name, Value = p.Name })
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        if #list == 0 then
            table.insert(list, { Name = "No Players Found", Value = "" })
        end
        return list
    end

    extraPlayerDropdown = CreateDropdown(cExt, "Select Player", getExtraPlayerOptions(), nil, 1, function(val)
        selectedExtraPlayer = val
    end, "Select Player...")

    local extraRefreshPending = false
    function scheduleExtraRefresh()
        if extraRefreshPending then return end
        extraRefreshPending = true
        task.delay(0.5, function()
            extraRefreshPending = false
            if extraPlayerDropdown and extraPlayerDropdown.Refresh then
                extraPlayerDropdown.Refresh(getExtraPlayerOptions(), "Select Player...")
            end
        end)
    end

    pls.PlayerAdded:Connect(scheduleExtraRefresh)
    pls.PlayerRemoving:Connect(scheduleExtraRefresh)

    CreateInput(cExt, "Amount", "SendMoneyAmount", "2000", function(val)
        sendAmount = tonumber(val) or 0
    end)

    CreateCardButton(cExt, "Send Money", function()
        if not selectedExtraPlayer or selectedExtraPlayer == "" then
            Notify("Send Money", "Please select a player first!", 3)
            return
        end
        if sendAmount <= 0 then
            Notify("Send Money", "Please enter a valid amount!", 3)
            return
        end
        local targetPlayer = pls:FindFirstChild(selectedExtraPlayer)
        if not targetPlayer then
            Notify("Send Money", "Player not found!", 3)
            return
        end
        local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/VicePay")
        if Event then
            pcall(function() Event:FireServer("Send", targetPlayer, sendAmount) end)
            Notify("Send Money", "Sent $" .. tostring(sendAmount) .. " to " .. targetPlayer.Name, 3)
        end
    end)

    CreateToggle(cExt, "Auto Send Money", false, "AutoSendMoneyToggle", function(v)
        if v then
            autoSendMoneyLoop = task.spawn(function()
                while true do
                    if selectedExtraPlayer and selectedExtraPlayer ~= "" and sendAmount > 0 then
                        local targetPlayer = pls:FindFirstChild(selectedExtraPlayer)
                        if targetPlayer then
                            local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/VicePay")
                            if Event then
                                pcall(function() Event:FireServer("Send", targetPlayer, sendAmount) end)
                                Notify("Send Money", "Auto-Sent $" .. tostring(sendAmount) .. " to " .. targetPlayer
                                    .Name, 1.5)
                            end
                        end
                    end
                    task.wait(15)
                end
            end)
        else
            if autoSendMoneyLoop then
                task.cancel(autoSendMoneyLoop)
                autoSendMoneyLoop = nil
            end
        end
    end)

    function onCashAdded(child)
        if not autoDropEnabled then return end
        if child:IsA("Tool") and (child.Name:lower():find("cash") or child.Name:lower():find("money")) then
            local targetAmt = sendAmount > 0 and sendAmount or 2000
            task.wait(0.5)
            if checkAmountMatch(child, targetAmt) then
                task.spawn(function() handleCashDrop(child) end)
            end
        end
    end

    LPLR.Backpack.ChildAdded:Connect(onCashAdded)
    function setupCharacterListener(char)
        char.ChildAdded:Connect(onCashAdded)
    end

    if LPLR.Character then setupCharacterListener(LPLR.Character) end
    LPLR.CharacterAdded:Connect(setupCharacterListener)

    CreateToggle(cExt, "Auto Drop Money", false, "AutoDropMoneyToggle", function(v)
        autoDropEnabled = v
        if v then lastDropTime = 0 end
    end)
    task.spawn(function()
        while task.wait(0.5) do
            if autoDropEnabled then
                task.spawn(function()
                    pcall(function()
                        local targetAmt = sendAmount > 0 and sendAmount or 2000
                        if tick() - lastDropTime >= 31 then
                            lastDropTime = tick()
                            sendChatMessage("/pay " .. tostring(targetAmt))
                        end
                        local pendingCash = getMatchingCashTool(targetAmt)
                        if pendingCash then
                            handleCashDrop(pendingCash)
                        end
                    end)
                end)
            end
        end
    end)
end

function buildMainTab()
    pma = CreateTab("Main", "Main Features")
    buildMainTeleports(pma)
    buildMainGunMods(pma)
    buildMainStore(pma)
    buildMainExtras(pma)
end

buildMainTab()
function buildMiscMovement(pmo)
    local cMov = CreateCard(pmo, "Movement")
    CreateToggle(cMov, "WalkSpeed", getgenv().EXE.GUN_MODS.SpeedBypass, "MovWalkSpeed", function(v)
        getgenv().EXE.GUN_MODS.SpeedBypass = v
        if v then
            APPLY_SPEED_BOOST()
        else
            CLEANUP_SPEED()
        end
    end)
    CreateSlider(cMov, "Speed Value", 0, 100, getgenv().EXE.GUN_MODS.WalkBypassSpeed or 50, "MovSpeedVal", function(v)
        getgenv().EXE.GUN_MODS.WalkBypassSpeed = v
    end)
    CreateToggle(cMov, "Player Fly", false, "MovPlayerFly", function(v)
        local charFolder = workspace:FindFirstChild("Characters")
        local char = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        if v then
            CLEANUP_FLY()
            flyPos = root.Position
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            local flyPlatform = Instance.new("Part")
            flyPlatform.Name = "BypassFlyPlatform"
            flyPlatform.Size = Vector3.new(6, 1, 6)
            flyPlatform.Transparency = 1
            flyPlatform.Anchored = true
            flyPlatform.CanCollide = true
            flyPlatform.Material = Enum.Material.Glass
            flyPlatform.CFrame = root.CFrame * CFrame.new(0, -3.1, 0)
            flyPlatform.Parent = workspace
            flyConnection = RS.Heartbeat:Connect(function(dt)
                local cFolder = workspace:FindFirstChild("Characters")
                local c2 = (cFolder and cFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
                    workspace:FindFirstChild(LPLR.Name)
                local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                if not r2 or not r2.Parent or not h2 or not flyPlatform.Parent then
                    CLEANUP_FLY()
                    return
                end
                h2.PlatformStand = false
                h2:ChangeState(Enum.HumanoidStateType.Swimming)
                local cam = workspace.CurrentCamera
                local cf = cam.CFrame
                local speedVal = getgenv().EXE.GUN_MODS.FlySpeed or 50
                local speed = (speedVal / 100) * 19.8
                local UIS2 = game:GetService("UserInputService")
                local moveDir = Vector3.new(0, 0, 0)
                if UIS2:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
                if UIS2:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
                if UIS2:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
                if UIS2:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end
                local vertical = 0
                if UIS2:IsKeyDown(Enum.KeyCode.Space) then
                    vertical = 1
                elseif UIS2:IsKeyDown(Enum.KeyCode.LeftShift) then
                    vertical = -1
                end
                local velocity = Vector3.new(0, 0, 0)
                if moveDir.Magnitude > 0 then
                    velocity = moveDir.Unit * speed
                end
                if vertical ~= 0 then
                    velocity = velocity + Vector3.new(0, vertical * speed, 0)
                end
                flyPos = flyPos + (velocity * dt)
                flyPlatform.CFrame = CFrame.new(flyPos - Vector3.new(0, 3.1, 0))
                r2.CFrame = CFrame.new(
                    flyPos,
                    cam.CFrame.Position + (flyPos - cam.CFrame.Position) * 2
                )
                r2.AssemblyLinearVelocity = Vector3.new(0, 0.05, 0)
                r2.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        else
            CLEANUP_FLY()
        end
    end)
    CreateSlider(cMov, "Fly Speed", 0, 100, getgenv().EXE.GUN_MODS.FlySpeed or 50, "MovFlySpeed", function(v)
        getgenv().EXE.GUN_MODS.FlySpeed = v
    end)
    CreateToggle(cMov, "Inf Stamina", infStaminaActive, "MovInfStamina", function(v)
        infStaminaActive = v
        if v then
            APPLY_INF_STAMINA()
        else
            CLEANUP_STAMINA()
        end
    end)
    local CarFlyTgl = nil
    CarFlyTgl = CreateToggle(cMov, "Car Fly", false, "MovCarFly", function(v)
        if v then
            startCarFly()
        else
            cleanupCarFly()
        end
    end)
    getgenv().EXE.AS_TGL_OBJ_CARFLY = {
        SET = function(self, val, skip)
            if CarFlyTgl and CarFlyTgl.SET then
                CarFlyTgl:SET(val, skip)
            end
        end
    }
    CreateSlider(cMov, "Car Fly Speed", 0, 1000, getgenv().EXE.GUN_MODS.CarFlySpeed or 150, "MovCarFlySpeed", function(v)
        getgenv().EXE.GUN_MODS.CarFlySpeed = v
    end)
end

function buildMiscCarMods(pmo)
    local cCarMods = CreateCard(pmo, "Car Mods")
    CreateToggle(cCarMods, "Car Speed Boost", getgenv().EXE.CAR_MODS.SpeedBoost, "CarModsSpeedBoost", function(v)
        getgenv().EXE.CAR_MODS.SpeedBoost = v
    end)
    CreateSlider(cCarMods, "Car Speed", 0, 300, getgenv().EXE.CAR_MODS.SpeedValue or 100, "CarModsSpeedVal", function(v)
        getgenv().EXE.CAR_MODS.SpeedValue = v
    end)
    CreateToggle(cCarMods, "Instant Brake", getgenv().EXE.CAR_MODS.InstaBrake, "CarModsInstaBrake", function(v)
        getgenv().EXE.CAR_MODS.InstaBrake = v
    end)
    CreateToggle(cCarMods, "Infinite Gas", getgenv().EXE.CAR_MODS.InfGas, "CarModsInfGas", function(v)
        getgenv().EXE.CAR_MODS.InfGas = v
    end)
    local selectedStealCar = nil
    local carStealDropdown = nil
    function getCarStealOptions()
        local list = {}
        local carsFolder = workspace:FindFirstChild("Cars")
        if not carsFolder then
            table.insert(list, { Name = "No Cars Folder Found", Value = nil })
            return list
        end
        local charFolder = workspace:FindFirstChild("Characters")
        local myModel = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local myRoot = myModel and myModel:FindFirstChild("HumanoidRootPart")
        for _, veh in ipairs(carsFolder:GetChildren()) do
            local seatObj = veh:FindFirstChild("DriveSeat") or veh:FindFirstChildOfClass("VehicleSeat", true)
            if seatObj and not seatObj.Occupant then
                local carType = veh:GetAttribute("CarType") or veh.Name
                local owner = veh:GetAttribute("Owner") or "Unowned"
                local dist = myRoot and math.floor((seatObj.Position - myRoot.Position).Magnitude) or 0
                local displayName = string.format("%s (%s) [%dm]", tostring(carType), tostring(owner), dist)
                table.insert(list, {
                    Name = displayName,
                    Value = veh
                })
            end
        end
        if #list == 0 then
            table.insert(list, { Name = "No Available Cars", Value = nil })
        end
        return list
    end

    carStealDropdown = CreateDropdown(cCarMods, "Select Car", getCarStealOptions(), nil, 1, function(val)
        selectedStealCar = val
    end, "Select Car to Steal...")
    task.spawn(function()
        local lastCheck = 0
        RS.Heartbeat:Connect(function()
            if tick() - lastCheck > 2 then
                lastCheck = tick()
                pcall(function()
                    if carStealDropdown and carStealDropdown.Refresh and not carStealDropdown.IsOpen() then
                        local opts = getCarStealOptions()
                        local labelText = "Select Car to Steal..."
                        if selectedStealCar and typeof(selectedStealCar) == "Instance" and selectedStealCar.Parent then
                            local carType = selectedStealCar:GetAttribute("CarType") or selectedStealCar.Name
                            local owner = selectedStealCar:GetAttribute("Owner") or "Unowned"
                            labelText = string.format("Car: %s (%s)", tostring(carType), tostring(owner))
                        end
                        carStealDropdown.Refresh(opts, labelText)
                    end
                end)
            end
        end)
    end)
    CreateCardButton(cCarMods, "Steal Selected Car", function()
        local charFolder = workspace:FindFirstChild("Characters")
        local myModel = (charFolder and charFolder:FindFirstChild(LPLR.Name)) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hum = myModel and myModel:FindFirstChildOfClass("Humanoid")
        local root = myModel and myModel:FindFirstChild("HumanoidRootPart")
        if not myModel or not root or not hum then
            Notify("Car Steal", "Character or HumanoidRootPart missing!", 3)
            return
        end
        local carsFolder = workspace:FindFirstChild("Cars")
        if not carsFolder then
            Notify("Car Steal", "No Cars folder found!", 3)
            return
        end
        local targetVehicle = nil
        local targetSeat = nil
        if selectedStealCar and typeof(selectedStealCar) == "Instance" and selectedStealCar.Parent and selectedStealCar:IsDescendantOf(carsFolder) then
            targetVehicle = selectedStealCar
            targetSeat = targetVehicle:FindFirstChild("DriveSeat") or
                targetVehicle:FindFirstChildOfClass("VehicleSeat", true)
            if targetSeat and targetSeat.Occupant then
                targetVehicle = nil
                targetSeat = nil
            end
        end
        if not targetVehicle or not targetSeat then
            local currentOpts = getCarStealOptions()
            for _, opt in ipairs(currentOpts) do
                if opt.Value and typeof(opt.Value) == "Instance" and opt.Value.Parent then
                    local seatObj = opt.Value:FindFirstChild("DriveSeat") or
                        opt.Value:FindFirstChildOfClass("VehicleSeat", true)
                    if seatObj and not seatObj.Occupant then
                        targetVehicle = opt.Value
                        targetSeat = seatObj
                        break
                    end
                end
            end
        end
        if not targetVehicle or not targetSeat then
            Notify("Car Steal", "No available free cars found!", 3)
            return
        end
        pcall(function()
            if targetVehicle:GetAttribute("Locked") then
                targetVehicle:SetAttribute("Locked", false)
            end
        end)
        targetSeat:Sit(hum)
        local carType = targetVehicle:GetAttribute("CarType") or targetVehicle.Name
        local owner = targetVehicle:GetAttribute("Owner") or "Unowned"
        Notify("Car Steal", "Stole car: " .. tostring(carType) .. " (" .. tostring(owner) .. ")", 3)
    end)
end

function buildMiscExtras(pmo)
    local cExtrasMisc = CreateCard(pmo, "Extras", "right")
    local nameSpooferEnabled = false
    local originalSpoofData = nil
    local nameSpooferToggle = nil
    nameSpooferToggle = CreateToggle(cExtrasMisc, "Name Spoofer", false, "NameSpooferToggle", function(v)
        nameSpooferEnabled = v
        if not v then
            if originalSpoofData and LPLR.Character then
                pcall(function()
                    local head = LPLR.Character:FindFirstChild("Head")
                    if not head then return end
                    local nametagContainer = head:FindFirstChild("NameTag")
                    if not nametagContainer then return end
                    local actualNametag = nametagContainer:FindFirstChild("NameTag")
                    if not actualNametag then return end
                    local label = actualNametag:FindFirstChild("Label")
                    if label and label:IsA("TextLabel") and originalSpoofData.label then
                        label.Text = originalSpoofData
                            .label
                    end
                    local shadow = actualNametag:FindFirstChild("Shadow")
                    if shadow and shadow:IsA("TextLabel") and originalSpoofData.shadow then
                        shadow.Text =
                            originalSpoofData.shadow
                    end
                    local realName = actualNametag:FindFirstChild("RealName")
                    if realName and realName:IsA("TextLabel") and originalSpoofData.realName then
                        realName.Text =
                            originalSpoofData.realName
                    end
                    local realNameShadow = actualNametag:FindFirstChild("RealNameShadow")
                    if realNameShadow and realNameShadow:IsA("TextLabel") and originalSpoofData.realNameShadow then
                        realNameShadow.Text =
                            originalSpoofData.realNameShadow
                    end
                end)
            end
        end
    end)
    local currentSpoofName = "discord.gg/E9rJVNj6ea"
    CreateInput(cExtrasMisc, "Spoof Name", "NameSpooferBoxStr", currentSpoofName, function(val)
        currentSpoofName = val
    end)
    task.spawn(function()
        while task.wait(0.5) do
            if nameSpooferEnabled and LPLR.Character then
                pcall(function()
                    local head = LPLR.Character:FindFirstChild("Head")
                    if not head then return end
                    local nametagContainer = head:FindFirstChild("NameTag")
                    if not nametagContainer then return end
                    local actualNametag = nametagContainer:FindFirstChild("NameTag")
                    if not actualNametag then return end
                    local label = actualNametag:FindFirstChild("Label")
                    local shadow = actualNametag:FindFirstChild("Shadow")
                    local realName = actualNametag:FindFirstChild("RealName")
                    local realNameShadow = actualNametag:FindFirstChild("RealNameShadow")
                    local currentLabelText = label and label.Text or ""
                    local newName = currentSpoofName
                    if currentLabelText ~= newName and currentLabelText ~= "" then
                        originalSpoofData = {
                            label = label and label.Text,
                            shadow = shadow and shadow.Text,
                            realName = realName and realName.Text,
                            realNameShadow = realNameShadow and realNameShadow.Text
                        }
                    end
                    if newName == "" then return end
                    if label and label:IsA("TextLabel") then label.Text = newName end
                    if shadow and shadow:IsA("TextLabel") then shadow.Text = newName end
                    if realName and realName:IsA("TextLabel") then realName.Text = newName end
                    if realNameShadow and realNameShadow:IsA("TextLabel") then realNameShadow.Text = newName end
                end)
            end
        end
    end)
    local Animations = {
        ["Aura Rng FLY"] = "rbxassetid://89523370947906",
        ["Emote"] = "rbxassetid://84112287597268",
        ["Floating"] = "rbxassetid://73980801925168",
        ["Floating on the clouds"] = "rbxassetid://77840765435893",
        ["gojo floating"] = "rbxassetid://109030594660124",
        ["Hero Landing Face"] = "rbxassetid://10714360164",
        ["Imported Animation Clip"] = "rbxassetid://121324026570464",
        ["Imported Animation Clip [CHANNELS] 1"] = "rbxassetid://133418516499878",
        ["Imported Animation Clip [CHANNELS] 2"] = "rbxassetid://121966805049108",
        ["Imported Animation Clip [CHANNELS] 3"] = "rbxassetid://94915612757079",
        ["KeyframeSequence_1 [CHANNELS]"] = "rbxassetid://74473837890133",
        ["Moon test 7"] = "rbxassetid://112089880074848",
        ["Obby Emote v1"] = "rbxassetid://125176243437210",
        ["ShatteredPublish"] = "rbxassetid://79757971761739",
        ["SiuSuperSlowedDJCurveModified"] = "rbxassetid://120331939816115",
        ["soda pop [CHANNELS]"] = "rbxassetid://77471219823552",
        ["THIS ONE GANG"] = "rbxassetid://112084042063926",
        ["V Pose"] = "rbxassetid://10214319518",
    }
    local animNames = {}
    for name in pairs(Animations) do
        table.insert(animNames, { Name = name, Value = name })
    end
    table.sort(animNames, function(a, b) return a.Name < b.Name end)
    local selectedEmoteName = animNames[1].Name
    local CurrentTrack = nil
    function PlayAnimation(Name, Looped, Speed)
        local AnimationId = Animations[Name]
        if not AnimationId then return end
        local Character = LPLR.Character or LPLR.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local Animator = Humanoid:WaitForChild("Animator")
        if CurrentTrack then
            pcall(function() CurrentTrack:Stop(0.15) end)
            pcall(function() CurrentTrack:Destroy() end)
            CurrentTrack = nil
        end
        local Animation = Instance.new("Animation")
        Animation.AnimationId = AnimationId
        local Success, Track = pcall(function()
            return Animator:LoadAnimation(Animation)
        end)
        Animation:Destroy()
        if not Success then return end
        CurrentTrack = Track
        Track.Priority = Enum.AnimationPriority.Action4
        Track.Looped = (Looped == true)
        Track:Play(0.15, 1, Speed or 1)
    end

    function StopAnimation()
        if CurrentTrack then
            pcall(function() CurrentTrack:Stop(0.15) end)
            pcall(function() CurrentTrack:Destroy() end)
            CurrentTrack = nil
        end
    end

    CreateDropdown(cExtrasMisc, "Select Emote", animNames, nil, 1, function(val)
        selectedEmoteName = val
    end, "Select an emote...")
    CreateCardButton(cExtrasMisc, "Play Emote", function()
        if selectedEmoteName then
            PlayAnimation(selectedEmoteName, true, 1)
        end
    end)
    CreateCardButton(cExtrasMisc, "Stop Emote", function()
        StopAnimation()
    end)
end

function buildMiscTab()
    pmo = CreateTab("Misc", "Misc Features")
    buildMiscMovement(pmo)
    buildMiscCarMods(pmo)
    buildMiscExtras(pmo)
end

buildMiscTab()
local VisualsConfig = {
    Enabled           = false,
    NamesEnabled      = false,
    HealthBarsEnabled = false,
    HealthTextEnabled = false,
    WeaponsEnabled    = false,
    DistanceEnabled   = false,
    SelfCharmsEnabled = false,
    ToolCharmsEnabled = false,
    SnaplinesEnabled  = false,
    OffScreenEnabled  = false,
    SkeletonEnabled   = false,
    ChamType          = "Normal",
    TextFont          = Enum.Font.SourceSansBold,
    TextSize          = 12,
    MaxDistance       = 500,
    NamesColor        = Color3.new(1, 1, 1),
    HealthColor1      = Color3.fromRGB(0, 255, 0),
    HealthColor2      = Color3.fromRGB(255, 0, 0),
    WeaponsColor      = Color3.new(1, 1, 1),
    DistanceColor     = Color3.new(1, 1, 1),
    SelfCharmsColor1  = Color3.fromRGB(119, 120, 255),
    SelfCharmsColor2  = Color3.new(0, 0, 0),
    ToolCharmsColor1  = Color3.fromRGB(119, 120, 255),
    ToolCharmsColor2  = Color3.new(0, 0, 0),
    SnaplinesColor    = Color3.new(1, 0, 0),
    SkeletonColor     = Color3.new(1, 1, 1),
}

function buildVisualsCombatUI()
    pvi = CreateTab("Visuals", "Visual Options")
    pco = CreateTab("Combat", "Combat Options")
    csa = CreateCard(pco, "Silent Aim")
    fovToggle = nil
    CreateToggle(csa, "Enable Silent Aim", getgenv().SilentAim_Enabled, "SilentAimEnabled", function(v)
        getgenv().SilentAim_Enabled = v
        if not v then
            getgenv().SilentAim_ShowFOV = false
            if fovToggle and fovToggle.SET then fovToggle:SET(false, false) end
        end
    end)
    CreateToggle(csa, "Silent Aim Wallbang", getgenv().SilentAim_Wallbang, "SilentAimWallbang", function(v)
        getgenv().SilentAim_Wallbang = v
    end)
    fovToggle = CreateToggle(csa, "Show FOV Circle", getgenv().SilentAim_ShowFOV, "SilentAimShowFOV", function(v)
        if v and not getgenv().SilentAim_Enabled then
            Notify("Silent Aim", "Silent Aim must be enabled first!", 2)
            if fovToggle and fovToggle.SET then fovToggle:SET(false, false) end
            return
        end
        getgenv().SilentAim_ShowFOV = v
    end, {
        {
            get = function() return getgenv().SilentAim_FOVColor or Color3.fromRGB(255, 255, 255) end,
            set = function(c) getgenv().SilentAim_FOVColor = c end
        }
    })
    CreateSlider(csa, "FOV Radius", 30, 500, getgenv().SilentAim_FOVRadius or 150, "SilentAimFOVRadius", function(v)
        getgenv().SilentAim_FOVRadius = v
    end)
    aimParts = {
        { Name = "Head",             Value = "Head" },
        { Name = "Torso",            Value = "Torso" },
        { Name = "HumanoidRootPart", Value = "HumanoidRootPart" }
    }
    CreateDropdown(csa, "Target Part", aimParts, "SilentAimHitbox", 1, function(val)
        getgenv().SilentAim_TargetPart = val
    end)
    chb = CreateCard(pco, "Hitbox Expander")
    cab = CreateCard(pco, "Aimbot")
    CreateToggle(cab, "Enable Aimbot", getgenv().Aimbot_Enabled or false, "AimbotEnabled", function(v)
        getgenv().Aimbot_Enabled = v
    end)
    aimbotParts = {
        { Name = "Head",             Value = "Head" },
        { Name = "Torso",            Value = "Torso" },
        { Name = "HumanoidRootPart", Value = "HumanoidRootPart" }
    }
    CreateDropdown(cab, "Target Part", aimbotParts, "AimbotTargetPart", 1, function(val)
        getgenv().Aimbot_TargetPart = val
    end)
    aimbotMethods = {
        { Name = "Camera", Value = "Camera" },
        { Name = "Mouse",  Value = "Mouse" }
    }
    CreateDropdown(cab, "Aim Method", aimbotMethods, "AimbotMethod", 1, function(val)
        getgenv().Aimbot_Method = val
    end)
    CreateSlider(cab, "Aim Smoothness", 1, 100, getgenv().Aimbot_Smoothness or 15, "AimbotSmoothness", function(v)
        getgenv().Aimbot_Smoothness = v
    end)
    CreateToggle(chb, "Enable Hitbox Expander", getgenv().HitboxExpander_Enabled or false, "HitboxExpanderEnabled",
        function(v)
            getgenv().HitboxExpander_Enabled = v
        end)
    CreateSlider(chb, "Hitbox Size", 2, 50, getgenv().HitboxExpander_Size or 10, "HitboxExpanderSize", function(v)
        getgenv().HitboxExpander_Size = v
    end)
    hitboxParts = {
        { Name = "Head",             Value = "Head" },
        { Name = "Torso",            Value = "Torso" },
        { Name = "HumanoidRootPart", Value = "HumanoidRootPart" }
    }
    CreateDropdown(chb, "Expand Part", hitboxParts, "HitboxExpanderPart", 1, function(val)
        getgenv().HitboxExpander_Part = val
    end)
    CreateSlider(chb, "Hitbox Intensity", 0, 100, getgenv().HitboxExpander_Trans or 30, "HitboxExpanderTrans",
        function(v)
            getgenv().HitboxExpander_Trans = (100 - v) / 100
        end)
    hbToggle = nil
    hbToggle = CreateToggle(chb, "Hitbox Color", true, "HitboxExpanderColorTog", function(v) end, {
        {
            get = function() return getgenv().HitboxExpander_Color or Color3.fromRGB(255, 0, 0) end,
            set = function(c) getgenv().HitboxExpander_Color = c end
        }
    })
end

function buildVisualsCombatUI_2()
    ccb = CreateCard(pvi, "Player Visual Settings")
    togESP = CreateToggle(ccb, "Enabled", false, "VisualsEnabled", function(v)
        VisualsConfig.Enabled = v
    end)
    togESP.Keybind.Visible = false
    CreateToggle(ccb, "Names", false, "VisualsNames", function(v)
        VisualsConfig.NamesEnabled = v
    end, {
        { get = function() return VisualsConfig.NamesColor end, set = function(c) VisualsConfig.NamesColor = c end }
    })
    CreateToggle(ccb, "Health Bars", false, "VisualsHealthBars", function(v)
        VisualsConfig.HealthBarsEnabled = v
    end, {
        { get = function() return VisualsConfig.HealthColor1 end, set = function(c) VisualsConfig.HealthColor1 = c end },
        { get = function() return VisualsConfig.HealthColor2 end, set = function(c) VisualsConfig.HealthColor2 = c end }
    })
    togHealthText = CreateToggle(ccb, "Health Text", false, "VisualsHealthText", function(v)
        VisualsConfig.HealthTextEnabled = v
    end)
    togHealthText.Keybind.Visible = false
    CreateToggle(ccb, "Weapons", false, "VisualsWeapons", function(v)
        VisualsConfig.WeaponsEnabled = v
    end, {
        { get = function() return VisualsConfig.WeaponsColor end, set = function(c) VisualsConfig.WeaponsColor = c end }
    })
    CreateToggle(ccb, "Distance", false, "VisualsDistance", function(v)
        VisualsConfig.DistanceEnabled = v
    end, {
        { get = function() return VisualsConfig.DistanceColor end, set = function(c) VisualsConfig.DistanceColor = c end }
    })
    CreateToggle(ccb, "Self Charms", false, "VisualsSelfCharms", function(v)
        VisualsConfig.SelfCharmsEnabled = v
    end, {
        {
            get = function() return VisualsConfig.SelfCharmsColor1 end,
            set = function(c)
                VisualsConfig.SelfCharmsColor1 =
                    c
            end
        }
    })
    CreateToggle(ccb, "Tool Charms", false, "VisualsToolCharms", function(v)
        VisualsConfig.ToolCharmsEnabled = v
    end, {
        {
            get = function() return VisualsConfig.ToolCharmsColor1 end,
            set = function(c)
                VisualsConfig.ToolCharmsColor1 =
                    c
            end
        }
    })
    CreateToggle(ccb, "Snaplines", false, "VisualsSnaplines", function(v)
        VisualsConfig.SnaplinesEnabled = v
    end, {
        { get = function() return VisualsConfig.SnaplinesColor end, set = function(c) VisualsConfig.SnaplinesColor = c end }
    })
    togOffScreen = CreateToggle(ccb, "Off-Screen Lines", false, "VisualsOffScreen", function(v)
        VisualsConfig.OffScreenEnabled = v
    end)
    togOffScreen.Keybind.Visible = false
    CreateToggle(ccb, "Skeleton", false, "VisualsSkeleton", function(v)
        VisualsConfig.SkeletonEnabled = v
    end, {
        { get = function() return VisualsConfig.SkeletonColor end, set = function(c) VisualsConfig.SkeletonColor = c end }
    })
    cvs = CreateCard(pvi, "Visual Player Settings")
    chamOptions = {
        { Name = "Normal",     Value = 1 },
        { Name = "ForceField", Value = 2 }
    }
    CreateDropdown(cvs, "Cham Type", chamOptions, "VisualsChamType", 1, function(val)
        VisualsConfig.ChamType = val
    end)
    CreateDropdown(cvs, "Text Font", fontOptions, "VisualsFont", 1, function(val)
        VisualsConfig.TextFont = val
    end)
    CreateSlider(cvs, "Text Size", 8, 30, 12, "VisualsFontSize", function(val)
        VisualsConfig.TextSize = val
    end)
    CreateSlider(cvs, "Max Render Distance", 50, 5000, 500, "VisualsMaxDist", function(val)
        VisualsConfig.MaxDistance = val
    end)
end

function buildVisualsCombatUI_3()
    cply = CreateCard(pvi, "Players", "right")
    selectedVisPlayer = nil
    visPlayerDropdown = nil
    isViewingInv = false
    buildInvViewerUI = nil
    function getVisPlayerOptions()
        local list = {}
        for _, p in ipairs(pls:GetPlayers()) do
            if p ~= LPLR then
                table.insert(list, { Name = p.Name, Value = p.Name })
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        if #list == 0 then
            table.insert(list, { Name = "No Players Found", Value = "" })
        end
        return list
    end

    visPlayerDropdown = CreateDropdown(cply, "Select Player", getVisPlayerOptions(), nil, 1, function(val)
        selectedVisPlayer = val
        if isViewingInv and buildInvViewerUI then
            buildInvViewerUI(selectedVisPlayer)
        end
    end, "Select Player...")
    visRefreshPending = false
    function scheduleVisPlayerRefresh()
        if visRefreshPending then return end
        visRefreshPending = true
        task.delay(0.5, function()
            visRefreshPending = false
            if visPlayerDropdown and visPlayerDropdown.Refresh then
                visPlayerDropdown.Refresh(getVisPlayerOptions(), "Select Player...")
            end
        end)
    end

    pls.PlayerAdded:Connect(scheduleVisPlayerRefresh)
    pls.PlayerRemoving:Connect(scheduleVisPlayerRefresh)
    isSpectating = false
    spectateConn = nil
    function stopSpectating()
        isSpectating = false
        if spectateConn then
            spectateConn:Disconnect()
            spectateConn = nil
        end
        pcall(function()
            local myChar = LPLR.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if myHum then
                workspace.CurrentCamera.CameraSubject = myHum
            end
        end)
    end

    spectateToggle = nil
    spectateToggle = CreateToggle(cply, "Spectate Player", false, nil, function(v)
        if v then
            if not selectedVisPlayer or selectedVisPlayer == "" then
                Notify("Spectate", "Select a valid player first!", 3)
                if spectateToggle and spectateToggle.SET then spectateToggle:SET(false, true) end
                return
            end
            isSpectating = true
            spectateConn = RS.RenderStepped:Connect(function()
                if not isSpectating then return end
                local targetP = pls:FindFirstChild(selectedVisPlayer)
                local char = targetP and targetP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    workspace.CurrentCamera.CameraSubject = hum
                else
                    stopSpectating()
                    if spectateToggle and spectateToggle.SET then spectateToggle:SET(false, true) end
                    Notify("Spectate", "Target player lost or died!", 3)
                end
            end)
        else
            stopSpectating()
        end
    end)
    currentInvPlayerName = nil
    invViewerFrame = nil
    updateInvFunc = nil
    function destroyInvViewer()
        isViewingInv = false
        currentInvPlayerName = nil
        if invViewerFrame then
            invViewerFrame:Destroy()
            invViewerFrame = nil
        end
    end

    invToggle = nil
    buildInvViewerUI = function(targetPlayerName)
        currentInvPlayerName = targetPlayerName
        if invViewerFrame and invViewerFrame.Parent then
            local ivTop = invViewerFrame:FindFirstChild("IvTop")
            local ivTitle = ivTop and ivTop:FindFirstChild("IvTitle")
            if ivTitle then
                ivTitle.Text = "🎒 Inventory: " .. targetPlayerName
            end
            if updateInvFunc then
                updateInvFunc()
            end
            return
        end
        invViewerFrame = Instance.new("Frame")
        invViewerFrame.Name = "InvViewerFrame"
        invViewerFrame.Size = UDim2.new(0, 320, 0, 240)
        invViewerFrame.Position = UDim2.new(0.5, -160, 0.4, -120)
        invViewerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        invViewerFrame.BorderSizePixel = 0
        invViewerFrame.ZIndex = 200
        invViewerFrame.Parent = gui
        local ivCor = Instance.new("UICorner", invViewerFrame)
        ivCor.CornerRadius = UDim.new(0, 8)
        local ivStr = Instance.new("UIStroke", invViewerFrame)
        ivStr.Color = Color3.fromRGB(55, 55, 55)
        ivStr.Thickness = 1
        local ivTop = Instance.new("Frame")
        ivTop.Name = "IvTop"
        ivTop.Size = UDim2.new(1, 0, 0, 34)
        ivTop.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ivTop.BorderSizePixel = 0
        ivTop.ZIndex = 201
        ivTop.Parent = invViewerFrame
        local ivTopCor = Instance.new("UICorner", ivTop)
        ivTopCor.CornerRadius = UDim.new(0, 8)
        local ivTitle = Instance.new("TextLabel")
        ivTitle.Name = "IvTitle"
        ivTitle.Size = UDim2.new(1, -40, 1, 0)
        ivTitle.Position = UDim2.new(0, 12, 0, 0)
        ivTitle.BackgroundTransparency = 1
        ivTitle.Text = "🎒 Inventory: " .. targetPlayerName
        ivTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
        ivTitle.Font = Enum.Font.SourceSansBold
        ivTitle.TextSize = 14
        ivTitle.TextXAlignment = Enum.TextXAlignment.Left
        ivTitle.ZIndex = 202
        ivTitle.Parent = ivTop
        local ivClose = Instance.new("TextButton")
        ivClose.Size = UDim2.new(0, 24, 0, 24)
        ivClose.Position = UDim2.new(1, -28, 0.5, -12)
        ivClose.BackgroundTransparency = 1
        ivClose.Text = "✕"
        ivClose.TextColor3 = Color3.fromRGB(160, 160, 160)
        ivClose.Font = Enum.Font.SourceSansBold
        ivClose.TextSize = 14
        ivClose.ZIndex = 202
        ivClose.Parent = ivTop
        ivClose.MouseButton1Click:Connect(function()
            if invToggle and invToggle.SET then invToggle:SET(false, true) end
            destroyInvViewer()
        end)
        local ivDragging, ivDragStart, ivStartPos
        ivTop.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ivDragging = true
                ivDragStart = input.Position
                ivStartPos = invViewerFrame.Position
            end
        end)
        table.insert(getgenv().UI_CONNECTIONS, uis.InputChanged:Connect(function(input)
            if ivDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - ivDragStart
                invViewerFrame.Position = UDim2.new(ivStartPos.X.Scale, ivStartPos.X.Offset + delta.X, ivStartPos.Y
                    .Scale, ivStartPos.Y.Offset + delta.Y)
            end
        end))
        table.insert(getgenv().UI_CONNECTIONS, uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ivDragging = false
            end
        end))
        local ivScroll = Instance.new("ScrollingFrame")
        ivScroll.Size = UDim2.new(1, -16, 1, -44)
        ivScroll.Position = UDim2.new(0, 8, 0, 38)
        ivScroll.BackgroundTransparency = 1
        ivScroll.BorderSizePixel = 0
        ivScroll.ScrollBarThickness = 4
        ivScroll.ZIndex = 201
        ivScroll.Parent = invViewerFrame
        local ivList = Instance.new("UIListLayout", ivScroll)
        ivList.SortOrder = Enum.SortOrder.LayoutOrder
        ivList.Padding = UDim.new(0, 4)
        function refreshItems()
            if not invViewerFrame or not invViewerFrame.Parent then return end
            for _, child in ipairs(ivScroll:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
            end
            local targetName = currentInvPlayerName
            if not targetName or targetName == "" then return end
            local p = pls:FindFirstChild(targetName)
            if not p then
                local errLbl = Instance.new("TextLabel")
                errLbl.Size = UDim2.new(1, 0, 0, 30)
                errLbl.BackgroundTransparency = 1
                errLbl.Text = "Player left the game"
                errLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
                errLbl.Font = Enum.Font.SourceSans
                errLbl.TextSize = 13
                errLbl.ZIndex = 202
                errLbl.Parent = ivScroll
                return
            end
            local tools = {}
            local bp = p:FindFirstChild("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, { Name = item.Name, Equipped = false })
                    end
                end
            end
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(p.Name) or p.Character
            if char then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, { Name = item.Name, Equipped = true })
                    end
                end
            end
            if #tools == 0 then
                local emptyLbl = Instance.new("TextLabel")
                emptyLbl.Size = UDim2.new(1, 0, 0, 40)
                emptyLbl.BackgroundTransparency = 1
                emptyLbl.Text = "Inventory is empty"
                emptyLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                emptyLbl.Font = Enum.Font.SourceSansItalic
                emptyLbl.TextSize = 13
                emptyLbl.ZIndex = 202
                emptyLbl.Parent = ivScroll
            else
                for _, itemData in ipairs(tools) do
                    local itemRow = Instance.new("Frame")
                    itemRow.Size = UDim2.new(1, 0, 0, 28)
                    itemRow.BackgroundColor3 = itemData.Equipped and Color3.fromRGB(45, 35, 60) or
                        Color3.fromRGB(32, 32, 32)
                    itemRow.BorderSizePixel = 0
                    itemRow.ZIndex = 202
                    itemRow.Parent = ivScroll
                    local rCor = Instance.new("UICorner", itemRow)
                    rCor.CornerRadius = UDim.new(0, 4)
                    local itemLbl = Instance.new("TextLabel")
                    itemLbl.Size = UDim2.new(1, -70, 1, 0)
                    itemLbl.Position = UDim2.new(0, 10, 0, 0)
                    itemLbl.BackgroundTransparency = 1
                    itemLbl.Text = itemData.Name
                    itemLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
                    itemLbl.Font = Enum.Font.SourceSans
                    itemLbl.TextSize = 13
                    itemLbl.TextXAlignment = Enum.TextXAlignment.Left
                    itemLbl.ZIndex = 203
                    itemLbl.Parent = itemRow
                    if itemData.Equipped then
                        local eqLbl = Instance.new("TextLabel")
                        eqLbl.Size = UDim2.new(0, 65, 1, 0)
                        eqLbl.Position = UDim2.new(1, -70, 0, 0)
                        eqLbl.BackgroundTransparency = 1
                        eqLbl.Text = "[Equipped]"
                        eqLbl.TextColor3 = Color3.fromRGB(160, 120, 240)
                        eqLbl.Font = Enum.Font.SourceSansBold
                        eqLbl.TextSize = 11
                        eqLbl.ZIndex = 203
                        eqLbl.Parent = itemRow
                    end
                end
            end
            ivScroll.CanvasSize = UDim2.new(0, 0, 0, ivList.AbsoluteContentSize.Y + 10)
        end

        updateInvFunc = refreshItems
        refreshItems()
        task.spawn(function()
            while isViewingInv and invViewerFrame and invViewerFrame.Parent do
                task.wait(1)
                if isViewingInv and invViewerFrame and invViewerFrame.Parent then
                    refreshItems()
                end
            end
        end)
    end
    invToggle = CreateToggle(cply, "View Inventory", false, nil, function(v)
        if v then
            if not selectedVisPlayer or selectedVisPlayer == "" then
                Notify("Inventory", "Select a valid player first!", 3)
                if invToggle and invToggle.SET then invToggle:SET(false, true) end
                return
            end
            isViewingInv = true
            buildInvViewerUI(selectedVisPlayer)
        else
            destroyInvViewer()
        end
    end)
end

function setupVisualsESP()
    do -- ESP Core System
        ESP = {
            Players = {},
            Camera = workspace.CurrentCamera
        }
        LocalChams = {
            SelfHighlight = nil,
            ToolHighlight = nil,
            OriginalMats = {}
        }
        espGui = Instance.new("ScreenGui")
        espGui.Name = "ViceESP"
        espGui.ResetOnSpawn = false
        espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        espGui.IgnoreGuiInset = true
        local success = pcall(function()
            if gethui then
                espGui.Parent = gethui()
            elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
                espGui.Parent = game:GetService("CoreGui")
            else
                espGui.Parent = LPLR:WaitForChild("PlayerGui")
            end
        end)
        if not success then
            espGui.Parent = LPLR:WaitForChild("PlayerGui")
        end
    end
    function setupVisualsESP_2()
        function getCharESP(player)
            if player == LPLR then return nil end
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(player.Name) or player.Character or
                workspace:FindFirstChild(player.Name)
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
                if char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    return char
                end
            end
            return nil
        end

        function createLine(parent)
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = Color3.new(1, 1, 1)
            frame.BorderSizePixel = 0
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.Visible = false
            frame.Parent = parent
            return frame
        end

        function drawLine(frame, p1, p2, thickness, color)
            local distance = (p2 - p1).Magnitude
            if distance < 1 then
                frame.Visible = false
                return
            end
            local center = (p1 + p2) / 2
            local angle = math.atan2(p2.Y - p1.Y, p2.X - p1.X)
            frame.Size = UDim2.new(0, distance, 0, thickness)
            frame.Position = UDim2.new(0, center.X, 0, center.Y)
            frame.Rotation = math.deg(angle)
            frame.BackgroundColor3 = color
            frame.Visible = true
        end

        function createESPComponents(player)
            local container = Instance.new("Folder")
            container.Name = player.Name
            container.Parent = espGui
            local nameLabel = Instance.new("TextLabel")
            nameLabel.BackgroundTransparency = 1
            nameLabel.Visible = false
            nameLabel.Text = player.Name
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.Parent = container
            local distLabel = Instance.new("TextLabel")
            distLabel.BackgroundTransparency = 1
            distLabel.Visible = false
            distLabel.TextStrokeTransparency = 0
            distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            distLabel.Parent = container
            local weaponLabel = Instance.new("TextLabel")
            weaponLabel.BackgroundTransparency = 1
            weaponLabel.Visible = false
            weaponLabel.TextStrokeTransparency = 0
            weaponLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            weaponLabel.Parent = container
            local hpText = Instance.new("TextLabel")
            hpText.BackgroundTransparency = 1
            hpText.Visible = false
            hpText.TextStrokeTransparency = 0
            hpText.TextStrokeColor3 = Color3.new(0, 0, 0)
            hpText.Parent = container
            local hpBg = Instance.new("Frame")
            hpBg.BorderSizePixel = 1
            hpBg.BorderColor3 = Color3.new(0, 0, 0)
            hpBg.Visible = false
            hpBg.Parent = container
            local hpFg = Instance.new("Frame")
            hpFg.BorderSizePixel = 0
            hpFg.Parent = hpBg
            local snapline = createLine(container)
            local offScreenArrow = Instance.new("TextLabel")
            offScreenArrow.BackgroundTransparency = 1
            offScreenArrow.Text = "▲"
            offScreenArrow.TextSize = 24
            offScreenArrow.Font = Enum.Font.SourceSansBold
            offScreenArrow.TextStrokeTransparency = 0
            offScreenArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
            offScreenArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            offScreenArrow.Visible = false
            offScreenArrow.Parent = container
            local skeleton = {}
            for i = 1, 15 do
                skeleton[i] = createLine(container)
            end
            ESP.Players[player] = {
                Container = container,
                Name = nameLabel,
                Dist = distLabel,
                Weapon = weaponLabel,
                HpText = hpText,
                HpBg = hpBg,
                HpFg = hpFg,
                Snapline = snapline,
                OffScreen = offScreenArrow,
                Skeleton = skeleton
            }
        end

        function removeESPComponents(player)
            if ESP.Players[player] then
                ESP.Players[player].Container:Destroy()
                ESP.Players[player] = nil
            end
        end

        for _, p in ipairs(pls:GetPlayers()) do
            if p ~= LPLR then createESPComponents(p) end
        end
        pls.PlayerAdded:Connect(function(p)
            if p ~= LPLR then createESPComponents(p) end
        end)
        pls.PlayerRemoving:Connect(removeESPComponents)
        function applyForceFieldChams(model, color)
            if not model then return end
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if not LocalChams.OriginalMats[part] then
                        LocalChams.OriginalMats[part] = { Material = part.Material, Color = part.Color }
                        if part:IsA("MeshPart") then
                            LocalChams.OriginalMats[part].TextureID = part.TextureID
                        elseif part:IsA("UnionOperation") then
                            LocalChams.OriginalMats[part].UsePartColor = part.UsePartColor
                        end
                    end
                    if part.Material ~= Enum.Material.ForceField then
                        part.Material = Enum.Material.ForceField
                    end
                    if part.Color ~= color then
                        part.Color = color
                    end
                    if part:IsA("MeshPart") and part.TextureID ~= "" then
                        part.TextureID = ""
                    elseif part:IsA("UnionOperation") and part.UsePartColor ~= true then
                        part.UsePartColor = true
                    end
                elseif part:IsA("SpecialMesh") then
                    if not LocalChams.OriginalMats[part] then
                        LocalChams.OriginalMats[part] = { TextureId = part.TextureId }
                    end
                    if part.TextureId ~= "" then
                        part.TextureId = ""
                    end
                elseif part:IsA("Texture") or part:IsA("Decal") then
                    if not LocalChams.OriginalMats[part] then
                        LocalChams.OriginalMats[part] = { Transparency = part.Transparency }
                    end
                    if part.Transparency ~= 1 then
                        part.Transparency = 1
                    end
                elseif part:IsA("SurfaceAppearance") then
                    if not LocalChams.OriginalMats[part] then
                        LocalChams.OriginalMats[part] = { Parent = part.Parent }
                    end
                    if part.Parent ~= nil then
                        part.Parent = nil
                    end
                end
            end
        end

        function revertForceFieldChams(model)
            if not model then return end
            for _, part in ipairs(model:GetDescendants()) do
                if LocalChams.OriginalMats[part] then
                    if part:IsA("BasePart") then
                        part.Material = LocalChams.OriginalMats[part].Material
                        part.Color = LocalChams.OriginalMats[part].Color
                        if LocalChams.OriginalMats[part].TextureID then
                            part.TextureID = LocalChams.OriginalMats[part].TextureID
                        elseif LocalChams.OriginalMats[part].UsePartColor ~= nil then
                            part.UsePartColor = LocalChams.OriginalMats[part].UsePartColor
                        end
                    elseif part:IsA("SpecialMesh") then
                        part.TextureId = LocalChams.OriginalMats[part].TextureId
                    elseif part:IsA("Texture") or part:IsA("Decal") then
                        part.Transparency = LocalChams.OriginalMats[part].Transparency
                    end
                    LocalChams.OriginalMats[part] = nil
                end
            end
            for part, orig in pairs(LocalChams.OriginalMats) do
                if typeof(part) == "Instance" and part:IsA("SurfaceAppearance") and orig.Parent then
                    if orig.Parent:IsDescendantOf(model) or orig.Parent == model then
                        part.Parent = orig.Parent
                        LocalChams.OriginalMats[part] = nil
                    end
                end
            end
        end

        function updateLocalChams()
            local myChar = LPLR.Character
            if not myChar then return end
            local chamType = VisualsConfig.ChamType
            -- Self Charms
            if VisualsConfig.Enabled and VisualsConfig.SelfCharmsEnabled then
                if chamType == 1 or chamType == "Normal" then
                    revertForceFieldChams(myChar)
                    if not LocalChams.SelfHighlight then
                        LocalChams.SelfHighlight = Instance.new("Highlight")
                        LocalChams.SelfHighlight.Name = "SelfCham"
                        LocalChams.SelfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        LocalChams.SelfHighlight.OutlineTransparency = 1
                        LocalChams.SelfHighlight.FillTransparency = 0.5
                        LocalChams.SelfHighlight.Parent = espGui
                    end
                    LocalChams.SelfHighlight.Adornee = myChar
                    LocalChams.SelfHighlight.FillColor = VisualsConfig.SelfCharmsColor1
                    LocalChams.SelfHighlight.Enabled = true
                elseif chamType == 2 or chamType == "ForceField" then
                    if LocalChams.SelfHighlight then LocalChams.SelfHighlight.Enabled = false end
                    applyForceFieldChams(myChar, VisualsConfig.SelfCharmsColor1)
                end
            else
                if LocalChams.SelfHighlight then LocalChams.SelfHighlight.Enabled = false end
                revertForceFieldChams(myChar)
            end
            -- Tool Charms
            local myTool = myChar:FindFirstChildOfClass("Tool")
            if myTool ~= LocalChams.LastTool then
                if LocalChams.LastTool then
                    revertForceFieldChams(LocalChams.LastTool)
                    if LocalChams.ToolHighlight then
                        LocalChams.ToolHighlight.Adornee = nil
                    end
                end
                LocalChams.LastTool = myTool
            end
            if VisualsConfig.Enabled and VisualsConfig.ToolCharmsEnabled and myTool then
                if chamType == 1 or chamType == "Normal" then
                    revertForceFieldChams(myTool)
                    if not LocalChams.ToolHighlight then
                        LocalChams.ToolHighlight = Instance.new("Highlight")
                        LocalChams.ToolHighlight.Name = "ToolCham"
                        LocalChams.ToolHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
                        LocalChams.ToolHighlight.OutlineTransparency = 1
                        LocalChams.ToolHighlight.FillTransparency = 0.5
                        LocalChams.ToolHighlight.Parent = espGui
                    end
                    LocalChams.ToolHighlight.Adornee = myTool
                    LocalChams.ToolHighlight.FillColor = VisualsConfig.ToolCharmsColor1
                    LocalChams.ToolHighlight.Enabled = true
                elseif chamType == 2 or chamType == "ForceField" then
                    if LocalChams.ToolHighlight then LocalChams.ToolHighlight.Enabled = false end
                    applyForceFieldChams(myTool, VisualsConfig.ToolCharmsColor1)
                end
            else
                if LocalChams.ToolHighlight then LocalChams.ToolHighlight.Enabled = false end
                if myTool then revertForceFieldChams(myTool) end
            end
        end

        if not getgenv().HitboxOriginals then
            getgenv().HitboxOriginals = {}
        end
        local OriginalHitboxes = getgenv().HitboxOriginals
        function cleanupHitboxes()
            for part, data in pairs(OriginalHitboxes) do
                if part and part.Parent then
                    part.Size = data.Size
                    part.Transparency = data.Transparency
                    part.CanCollide = data.CanCollide
                    if data.Material then part.Material = data.Material end
                    if data.Color then part.Color = data.Color end
                    if data.Massless ~= nil then part.Massless = data.Massless end
                end
            end
            table.clear(OriginalHitboxes)
        end

        if not getgenv().EXE then getgenv().EXE = {} end
        getgenv().EXE.CLEANUP_HITBOXES = cleanupHitboxes
        function updateHitboxes()
            local isEnabled = getgenv().HitboxExpander_Enabled
            local size = getgenv().HitboxExpander_Size or 10
            local targetPartName = getgenv().HitboxExpander_Part or "HumanoidRootPart"
            local targetParts = { targetPartName }
            if targetPartName == "Torso" then
                targetParts = { "Torso", "UpperTorso", "LowerTorso" }
            end
            for part, data in pairs(OriginalHitboxes) do
                if not part or not part.Parent then
                    OriginalHitboxes[part] = nil
                else
                    local isTarget = false
                    for _, tp in ipairs(targetParts) do
                        if part.Name == tp then
                            isTarget = true
                            break
                        end
                    end
                    if not isEnabled or not isTarget then
                        part.Size = data.Size
                        part.Transparency = data.Transparency
                        part.CanCollide = data.CanCollide
                        if data.Material then part.Material = data.Material end
                        if data.Color then part.Color = data.Color end
                        if data.Massless ~= nil then part.Massless = data.Massless end
                        OriginalHitboxes[part] = nil
                    end
                end
            end
            if not isEnabled then return end
            for _, p in ipairs(pls:GetPlayers()) do
                if p ~= LPLR and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    for _, pName in ipairs(targetParts) do
                        local part = p.Character:FindFirstChild(pName)
                        if part and part:IsA("BasePart") then
                            local targetSize = Vector3.new(size, size, size)
                            local targetTrans = getgenv().HitboxExpander_Trans or 0.7
                            local targetColor = getgenv().HitboxExpander_Color or Color3.fromRGB(255, 0, 0)
                            local targetMat = Enum.Material.ForceField
                            if not OriginalHitboxes[part] then
                                if part.Material ~= targetMat then
                                    OriginalHitboxes[part] = {
                                        Size = part.Size,
                                        Transparency = part.Transparency,
                                        CanCollide = part.CanCollide,
                                        Material = part.Material,
                                        Color = part.Color,
                                        Massless = part.Massless
                                    }
                                end
                            end
                            if part.Size ~= targetSize then part.Size = targetSize end
                            if part.Transparency ~= targetTrans then part.Transparency = targetTrans end
                            if part.Material ~= targetMat then part.Material = targetMat end
                            if part.Color ~= targetColor then part.Color = targetColor end
                            if part.CanCollide ~= false then part.CanCollide = false end
                            if part.Massless ~= true then part.Massless = true end
                        end
                    end
                end
            end
        end

        function updateAimbot()
            if not getgenv().Aimbot_Enabled then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local targetPartName = getgenv().Aimbot_TargetPart or "Head"
            local smoothness = getgenv().Aimbot_Smoothness or 15
            local closestTarget = nil
            local shortestDist = math.huge
            local center = cam.ViewportSize / 2
            for _, p in ipairs(pls:GetPlayers()) do
                if p ~= LPLR and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local part = p.Character:FindFirstChild(targetPartName)
                    if part and part:IsA("BasePart") then
                        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestTarget = part
                            end
                        end
                    end
                end
            end
            if closestTarget then
                local targetPos = closestTarget.Position
                local aimMethod = getgenv().Aimbot_Method or "Camera"
                if aimMethod == "Camera" then
                    local camCFrame = cam.CFrame
                    local newLook = CFrame.new(camCFrame.Position, targetPos)
                    local alpha = smoothness / 100
                    cam.CFrame = camCFrame:Lerp(newLook, alpha)
                elseif aimMethod == "Mouse" then
                    if mousemoverel then
                        local pos, onScreen = cam:WorldToViewportPoint(targetPos)
                        if onScreen then
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local deltaX = pos.X - mousePos.X
                            local deltaY = pos.Y - mousePos.Y
                            local factor = (101 - smoothness) / 10
                            if factor < 1 then factor = 1 end
                            mousemoverel(deltaX / factor, deltaY / factor)
                        end
                    end
                end
            end
        end
    end

    function setupVisualsESP_3()
        function updateESP()
            ESP.Camera = workspace.CurrentCamera
            updateLocalChams()
            updateHitboxes()
            updateAimbot()
            local myChar = getCharESP(LPLR) or
                (LPLR.Character and LPLR.Character:FindFirstChild("HumanoidRootPart") and LPLR.Character)
            local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
            for player, pData in pairs(ESP.Players) do
                local isValid = true
                local char, hrp, head, hum, hrpPos, onScreen, distance
                local offScreenRender = false
                if not VisualsConfig.Enabled then isValid = false end
                if isValid then
                    char = getCharESP(player)
                    if not char then isValid = false end
                end
                if isValid then
                    hrp = char:FindFirstChild("HumanoidRootPart")
                    head = char:FindFirstChild("Head")
                    hum = char:FindFirstChildOfClass("Humanoid")
                    if not (hrp and head and hum) then isValid = false end
                end
                if isValid then
                    hrpPos, onScreen = ESP.Camera:WorldToViewportPoint(hrp.Position)
                    distance = myPos and (hrp.Position - myPos).Magnitude or 0
                    if distance > VisualsConfig.MaxDistance then isValid = false end
                end
                if isValid and not onScreen then
                    isValid = false
                    offScreenRender = true
                end
                if not isValid then
                    pData.Name.Visible = false
                    pData.Dist.Visible = false
                    pData.Weapon.Visible = false
                    pData.HpText.Visible = false
                    pData.HpBg.Visible = false
                    pData.Snapline.Visible = false
                    for _, line in ipairs(pData.Skeleton) do line.Visible = false end
                end
                if offScreenRender and VisualsConfig.OffScreenEnabled then
                    local viewportSize = ESP.Camera.ViewportSize
                    local center = viewportSize / 2
                    local relPos = hrpPos
                    if hrpPos.Z < 0 then
                        local dx = hrpPos.X - center.X
                        local dy = hrpPos.Y - center.Y
                        relPos = Vector3.new(center.X - dx, center.Y - dy, hrpPos.Z)
                    end
                    local angle = math.atan2(relPos.Y - center.Y, relPos.X - center.X)
                    local radius = math.min(center.X, center.Y) * 0.85
                    local edgeX = center.X + math.cos(angle) * radius
                    local edgeY = center.Y + math.sin(angle) * radius
                    pData.OffScreen.Visible = true
                    pData.OffScreen.Position = UDim2.new(0, edgeX, 0, edgeY)
                    pData.OffScreen.Rotation = math.deg(angle) + 90
                    pData.OffScreen.TextColor3 = VisualsConfig.SnaplinesColor
                else
                    pData.OffScreen.Visible = false
                end
                if isValid then
                    local depth = hrpPos.Z
                    local viewportHeight = ESP.Camera.ViewportSize.Y
                    local fov = math.rad(ESP.Camera.FieldOfView)
                    local worldHeight = 5.5
                    local height = (viewportHeight / (2 * math.tan(fov / 2))) * (worldHeight / depth)
                    local width = height * 0.6
                    local boxX = hrpPos.X - width / 2
                    local boxY = hrpPos.Y - height / 2
                    local fontToUse = VisualsConfig.TextFont
                    local fontSizeToUse = VisualsConfig.TextSize
                    if VisualsConfig.NamesEnabled then
                        pData.Name.Visible = true
                        pData.Name.Font = fontToUse
                        pData.Name.TextSize = fontSizeToUse
                        pData.Name.TextColor3 = VisualsConfig.NamesColor
                        pData.Name.Size = UDim2.new(0, width, 0, 14)
                        pData.Name.Position = UDim2.new(0, boxX, 0, boxY - 15)
                    else
                        pData.Name.Visible = false
                    end
                    if VisualsConfig.HealthBarsEnabled then
                        pData.HpBg.Visible = true
                        pData.HpBg.Size = UDim2.new(0, 2, 0, height)
                        pData.HpBg.Position = UDim2.new(0, boxX - 5, 0, boxY)
                        pData.HpBg.BackgroundColor3 = VisualsConfig.HealthColor2
                        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        pData.HpFg.Size = UDim2.new(1, 0, hpPercent, 0)
                        pData.HpFg.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                        pData.HpFg.BackgroundColor3 = VisualsConfig.HealthColor1
                    else
                        pData.HpBg.Visible = false
                    end
                    if VisualsConfig.HealthTextEnabled then
                        pData.HpText.Visible = true
                        pData.HpText.Font = fontToUse
                        pData.HpText.TextSize = fontSizeToUse - 2
                        pData.HpText.TextColor3 = VisualsConfig.HealthColor1
                        pData.HpText.Text = tostring(math.floor(hum.Health))
                        pData.HpText.Size = UDim2.new(0, 20, 0, 14)
                        pData.HpText.Position = UDim2.new(0, boxX - 28, 0,
                            boxY + (height * (1 - math.clamp(hum.Health / hum.MaxHealth, 0, 1))) - 7)
                    else
                        pData.HpText.Visible = false
                    end
                    local yOffsetBottom = 2
                    if VisualsConfig.WeaponsEnabled then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            pData.Weapon.Visible = true
                            pData.Weapon.Font = fontToUse
                            pData.Weapon.TextSize = fontSizeToUse - 2
                            pData.Weapon.TextColor3 = VisualsConfig.WeaponsColor
                            pData.Weapon.Text = tool.Name
                            pData.Weapon.Size = UDim2.new(0, width, 0, 14)
                            pData.Weapon.Position = UDim2.new(0, boxX, 0, boxY + height + yOffsetBottom)
                            yOffsetBottom = yOffsetBottom + 14
                        else
                            pData.Weapon.Visible = false
                        end
                    else
                        pData.Weapon.Visible = false
                    end
                    if VisualsConfig.DistanceEnabled then
                        pData.Dist.Visible = true
                        pData.Dist.Font = fontToUse
                        pData.Dist.TextSize = fontSizeToUse - 2
                        pData.Dist.TextColor3 = VisualsConfig.DistanceColor
                        pData.Dist.Text = math.floor(distance) .. "m"
                        pData.Dist.Size = UDim2.new(0, width, 0, 14)
                        pData.Dist.Position = UDim2.new(0, boxX, 0, boxY + height + yOffsetBottom)
                    else
                        pData.Dist.Visible = false
                    end
                    if VisualsConfig.SnaplinesEnabled then
                        local viewportSize = ESP.Camera.ViewportSize
                        local bottomCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                        local targetPos = Vector2.new(hrpPos.X, hrpPos.Y + height / 2)
                        drawLine(pData.Snapline, bottomCenter, targetPos, 1, VisualsConfig.SnaplinesColor)
                    else
                        pData.Snapline.Visible = false
                    end
                    if VisualsConfig.SkeletonEnabled then
                        function getPoint(partName)
                            local part = char:FindFirstChild(partName)
                            if not part then return nil end
                            local pos, onSc = ESP.Camera:WorldToViewportPoint(part.Position)
                            if not onSc then return nil end
                            return Vector2.new(pos.X, pos.Y)
                        end

                        local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                        local connections = {}
                        if isR15 then
                            connections = {
                                { "Head",       "UpperTorso" },
                                { "UpperTorso", "LowerTorso" },
                                { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
                                { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
                                { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
                                { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
                            }
                        else
                            connections = {
                                { "Head",  "Torso" },
                                { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
                                { "Torso", "Left Leg" }, { "Torso", "Right Leg" }
                            }
                        end
                        for i = 1, 15 do
                            local conn = connections[i]
                            local line = pData.Skeleton[i]
                            if conn then
                                local p1 = getPoint(conn[1])
                                local p2 = getPoint(conn[2])
                                if p1 and p2 then
                                    drawLine(line, p1, p2, 1, VisualsConfig.SkeletonColor)
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(pData.Skeleton) do line.Visible = false end
                    end
                end
            end
        end

        RS:BindToRenderStep("ViceESP", 2000, updateESP)
    end
end

function buildVisualsCombatTab()
    buildVisualsCombatUI()
    buildVisualsCombatUI_2()
    buildVisualsCombatUI_3()
    setupVisualsESP()
    setupVisualsESP_2()
    setupVisualsESP_3()
end

buildVisualsCombatTab()
pfa = CreateTab("Farm", "Farming & Auto Features")
function safeGet(root, path)
    local current = root
    for _, name in ipairs(path) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

function waitForPath(root, path, timeout)
    local start = tick()
    timeout = timeout or 5
    while tick() - start < timeout do
        local obj = safeGet(root, path)
        if obj then return obj end
        task.wait(0.2)
    end
    return nil
end

function FORCE_HOLD(prompt)
    if not prompt then return false end
    if fireproximityprompt then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end
    local success = pcall(function()
        prompt:InputHoldBegin()
        local duration = prompt.HoldDuration or 0
        if duration > 0 then
            task.wait(duration + 0.05)
        end
        prompt:InputHoldEnd()
    end)
    return success
end

function getPlayerCash()
    local amountLabel = LPLR.PlayerGui:FindFirstChild("HUD")
        and LPLR.PlayerGui.HUD:FindFirstChild("Economy")
        and LPLR.PlayerGui.HUD.Economy:FindFirstChild("Cash")
        and LPLR.PlayerGui.HUD.Economy.Cash:FindFirstChild("Amount")
    if amountLabel and amountLabel:IsA("TextLabel") then
        local cleanText = amountLabel.Text:gsub("[^%d]", "")
        return tonumber(cleanText) or 0
    end
    return 0
end

function tpClassic(pos)
    HouseRobTP(pos)
end

function BYPASS_TP(pos)
    HouseRobTP(pos)
end

function forceAnchor()
    pcall(function()
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = true end
    end)
end

function getPromptPosition(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition
    end
    return parent:GetPivot().Position
end

function triggerPrompt(prompt)
    if not prompt then return end
    pcall(function()
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
    end)
    task.wait(0.02)
    pcall(function()
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end)
    task.wait(0.25)
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
        task.wait(0.05)
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            local duration = prompt.HoldDuration or 0
            if duration > 0 then
                task.wait(duration + 0.05)
            end
            prompt:InputHoldEnd()
        end)
    end
    task.wait(0.1)
    forceAnchor()
end

function buildRepzFarm()
    C1 = CreateCard(pfa, "Repz Farm", "left", 1)
    selectedMaterial = nil
    selectedBlank = nil
    purchaseQty = 1
    lastNotificationTime = nil
    autoPrintActive = false
    autoPrintThread = nil
    function getMyPlacedPrinters()
        local serverPlacements = workspace:FindFirstChild("Placements") and
            workspace.Placements:FindFirstChild("Server")
        if not serverPlacements then return {} end
        local printers = {}
        for _, v in ipairs(serverPlacements:GetChildren()) do
            if v.Name == "Screen Printer" and v:GetAttribute("Owner") == LPLR.Name then
                local handle = v:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    table.insert(printers, { model = v, prompt = prompt })
                end
            end
        end
        return printers
    end

    function startPrintingSequence()
        local backpack = LPLR.Backpack
        local char = LPLR.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        local placedPrinters = getMyPlacedPrinters()
        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Collect Rep" then
                Notify("Repz Farm", "Printer has ready reps. Collecting...", 3)
                local startCollect = tick()
                while prompt.Enabled and prompt.Parent and tick() - startCollect < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end
                task.wait(0.5)
                return true
            end
        end
        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Place Clothing (Shirt/Pants)" then
                local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
                    backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")
                if not blankTool then
                    if not lastNotificationTime or tick() - lastNotificationTime > 15 then
                        Notify("Repz Farm", "Missing: Shirt/Pants Blank!", 5)
                        lastNotificationTime = tick()
                    end
                    return false
                end
                Notify("Repz Farm", "Loading blank (" .. blankTool.Name .. ")...", 3)
                if blankTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(blankTool)
                    task.wait(0.25)
                end
                local startLoad = tick()
                while blankTool.Parent == char and tick() - startLoad < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end
                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end
        for _, printer in ipairs(placedPrinters) do
            local prompt = printer.prompt
            if prompt.ActionText == "Place Print" then
                local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
                    backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
                    backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")
                if not printTool then
                    if not lastNotificationTime or tick() - lastNotificationTime > 15 then
                        Notify("Repz Farm", "Missing: Print Material!", 5)
                        lastNotificationTime = tick()
                    end
                    return false
                end
                Notify("Repz Farm", "Applying print design (" .. printTool.Name .. ")...", 3)
                if printTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(printTool)
                    task.wait(0.25)
                end
                local startPrint = tick()
                while printTool.Parent == char and tick() - startPrint < 5 do
                    FORCE_HOLD(prompt)
                    task.wait(0.25)
                end
                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end
        local printerTool = backpack:FindFirstChild("Screen Printer") or char:FindFirstChild("Screen Printer")
        if not printerTool and getnilinstances then
            for _, obj in ipairs(getnilinstances()) do
                if obj.Name == "Screen Printer" and obj:IsA("Tool") then
                    printerTool = obj
                    break
                end
            end
        end
        if printerTool then
            local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
                backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")
            local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
                backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
                backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")
            if blankTool and printTool then
                Notify("Repz Farm", "Equipping Screen Printer tool...", 3)
                if printerTool.Parent == LPLR.Backpack then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(printerTool)
                    task.wait(0.25)
                end
                Notify("Repz Farm", "Placing new Screen Printer...", 3)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return false end
                local offsetOffset = #placedPrinters * 3.5
                local placeCF = hrp.CFrame * CFrame.new(offsetOffset, -2.5, -4.5)
                local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RF/InvokePlacement")
                pcall(function()
                    Event:InvokeServer("Place", printerTool, placeCF, false)
                end)
                task.wait(0.5)
                pcall(function() hum:UnequipTools() end)
                task.wait(0.25)
                return true
            end
        end
        local blankTool = backpack:FindFirstChild("Shirt Blank") or char:FindFirstChild("Shirt Blank") or
            backpack:FindFirstChild("Pants Blank") or char:FindFirstChild("Pants Blank")
        local printTool = backpack:FindFirstChild("Basic Print") or char:FindFirstChild("Basic Print") or
            backpack:FindFirstChild("Premium Print") or char:FindFirstChild("Premium Print") or
            backpack:FindFirstChild("Designer Print") or char:FindFirstChild("Designer Print")
        if not blankTool or not printTool then
            local missing = {}
            if not blankTool then table.insert(missing, "Shirt/Pants Blank") end
            if not printTool then table.insert(missing, "Print Material") end
            if not lastNotificationTime or tick() - lastNotificationTime > 15 then
                Notify("Repz Farm", "Missing: " .. table.concat(missing, ", "), 5)
                lastNotificationTime = tick()
            end
            return false
        end
        if not lastNotificationTime or tick() - lastNotificationTime > 10 then
            Notify("Repz Farm", "All printers busy. Waiting for printing to complete...", 3)
            lastNotificationTime = tick()
        end
        task.wait(1)
        return true
    end
end

function buildRepzFarm_2()
    local D_MATERIAL = CreateDropdown(C1, "Select Material", {}, "RepzMaterial", 1, function(v)
        selectedMaterial = v:match("^(.-)%s*%$") or v
    end)
    D_MATERIAL.Refresh({
        { Name = "Basic Print $50",     Value = "Basic Print $50" },
        { Name = "Premium Print $250",  Value = "Premium Print $250" },
        { Name = "Designer Print $500", Value = "Designer Print $500" }
    })
    local D_BLANK = CreateDropdown(C1, "Select Blank", {}, "RepzBlank", 1, function(v)
        selectedBlank = v:match("^(.-)%s*%$") or v
    end)
    D_BLANK.Refresh({
        { Name = "Shirt Blank $200", Value = "Shirt Blank $200" },
        { Name = "Pants Blank $400", Value = "Pants Blank $400" }
    })
    local D_QTY = CreateDropdown(C1, "Qty", {}, "RepzQty", 1, function(v)
        purchaseQty = tonumber(v) or 1
    end)
    D_QTY.Refresh({
        { Name = "1", Value = "1" },
        { Name = "2", Value = "2" },
        { Name = "3", Value = "3" },
        { Name = "4", Value = "4" }
    })
    function getMyPropertyModel()
        local CS = game:GetService("CollectionService")
        for _, apt in ipairs(CS:GetTagged("Apt")) do
            if apt:GetAttribute("Owner") == LPLR.Name then
                return apt
            end
        end
        local aptFolders = {
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("BrokeAPTS"),
            workspace:FindFirstChild("Apartments") and workspace.Apartments:FindFirstChild("Houses")
        }
        for _, folder in ipairs(aptFolders) do
            if folder then
                for _, apt in ipairs(folder:GetChildren()) do
                    if apt:GetAttribute("Owner") == LPLR.Name then
                        return apt
                    end
                    local found = false
                    pcall(function()
                        local buyPart = apt:FindFirstChild("BuyPart")
                        local userLabel = buyPart and buyPart:FindFirstChild("UI")
                            and buyPart.UI:FindFirstChild("Owned")
                            and buyPart.UI.Owned:FindFirstChild("Frame")
                            and buyPart.UI.Owned.Frame:FindFirstChild("User")
                        if userLabel and userLabel:IsA("TextLabel") then
                            if userLabel.Text == LPLR.Name or userLabel.Text == LPLR.DisplayName then
                                found = true
                            end
                        end
                    end)
                    if found then return apt end
                end
            end
        end
        return nil
    end

    local autoPrintTgl, autoBuyPrintTgl
    autoBuyPrintActive = false
    autoBuyPrintThread = nil
    function hasAnyRepzTools()
        local backpack = LPLR.Backpack
        local char = LPLR.Character
        local toolNames = {
            "Screen Printer",
            "Shirt Blank",
            "Pants Blank",
            "Basic Print",
            "Premium Print",
            "Designer Print"
        }
        for _, name in ipairs(toolNames) do
            if backpack:FindFirstChild(name) or char:FindFirstChild(name) then
                return true
            end
        end
        return false
    end

    autoPrintTgl = CreateToggle(C1, "Auto Print & Collect", false, "RepzAutoPrint", function(v)
        autoPrintActive = v
        if v then
            autoPrintActive = true
            autoPrintThread = task.spawn(function()
                Notify("Repz Farm", "Auto Print & Collect loop started.", 3)
                while autoPrintActive do
                    local didAction = startPrintingSequence()
                    if not didAction then
                        task.wait(1.5)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        else
            autoPrintActive = false
            if autoPrintThread then
                task.cancel(autoPrintThread)
                autoPrintThread = nil
            end
        end
    end)
    autoBuyPrintTgl = nil
    autoBuyPrintTgl = CreateToggle(C1, "Auto Buy, Print & Collect", false, "RepzAutoBuyPrint", function(v)
        if v then
            if not selectedMaterial then
                Notify("Repz Farm", "Please select a Material first!", 3)
                if autoBuyPrintTgl and autoBuyPrintTgl.SET then autoBuyPrintTgl:SET(false, true) end
                return
            end
            if not selectedBlank then
                Notify("Repz Farm", "Please select a Blank first!", 3)
                if autoBuyPrintTgl and autoBuyPrintTgl.SET then autoBuyPrintTgl:SET(false, true) end
                return
            end
            local myApt = getMyPropertyModel()
            if not myApt then
                Notify("Repz Farm", "You must own a property/apartment first!", 4)
                if autoBuyPrintTgl and autoBuyPrintTgl.SET then autoBuyPrintTgl:SET(false, true) end
                return
            end
            local deliveryPromptModel = myApt:FindFirstChild("DeliveryPrompt")
            local prompt = deliveryPromptModel and deliveryPromptModel:FindFirstChild("ProximityPrompt")
            if not prompt then
                Notify("Repz Farm", "Error: DeliveryPrompt not found in your property!", 4)
                if autoBuyPrintTgl and autoBuyPrintTgl.SET then autoBuyPrintTgl:SET(false, true) end
                return
            end
            autoBuyPrintActive = true
            autoBuyPrintThread = task.spawn(function()
                Notify("Repz Farm", "Auto Buy, Print & Collect loop started.", 3)
                while autoBuyPrintActive do
                    local matPrice = (selectedMaterial == "Basic Print" and 50) or
                        (selectedMaterial == "Premium Print" and 250) or
                        (selectedMaterial == "Designer Print" and 500) or 0
                    local blankPrice = (selectedBlank == "Shirt Blank" and 200) or
                        (selectedBlank == "Pants Blank" and 400) or 0
                    local machinePrice = 1300
                    local costPerUnit = matPrice + blankPrice + machinePrice
                    local currentCash = getPlayerCash()
                    if currentCash < costPerUnit then
                        Notify("Repz Farm",
                            string.format("Insufficient cash! Need $%d (You have $%d)", costPerUnit, currentCash), 4)
                        task.wait(5)
                    else
                        local maxAffordable = math.floor(currentCash / costPerUnit)
                        local targetQty = purchaseQty
                        if targetQty > maxAffordable then
                            Notify("Repz Farm",
                                string.format("Adjusting batch size from %d to %d due to cash", targetQty,
                                    maxAffordable), 4)
                            targetQty = maxAffordable
                        end
                        local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Repz")
                        if not Event then
                            Notify("Repz Farm", "Error: RE/Repz not found!", 5)
                            task.wait(5)
                        else
                            local loopSuccess = true
                            for i = 1, targetQty do
                                if not autoBuyPrintActive then
                                    loopSuccess = false; break
                                end
                                Notify("Repz Farm", string.format("Buying item #%d of %d...", i, targetQty),
                                    3)
                                pcall(function() Event:FireServer("PurchaseMaterial", selectedMaterial) end)
                                task.wait(1)
                                pcall(function() Event:FireServer("PurchaseBlank", selectedBlank) end)
                                task.wait(1)
                                pcall(function() Event:FireServer("PurchaseMachine", "Screen Printer") end)
                                task.wait(1)
                                local startWait = tick()
                                while tick() - startWait < 59 do
                                    if not autoBuyPrintActive then
                                        loopSuccess = false; break
                                    end
                                    local elapsed = math.floor(tick() - startWait)
                                    local secRemaining = 59 - elapsed
                                    if secRemaining < 1 then break end
                                    Notify("Repz Farm",
                                        string.format("Waiting for delivery... %d seconds remaining",
                                            secRemaining), 1)
                                    local didAction = startPrintingSequence()
                                    if not didAction then
                                        task.wait(1)
                                    else
                                        task.wait(0.2)
                                    end
                                end
                                if not autoBuyPrintActive then
                                    loopSuccess = false; break
                                end
                                local char = LPLR.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local startPos = hrp.Position
                                    Notify("Repz Farm", "Claiming delivery...", 3)
                                    BYPASS_TP(deliveryPromptModel.Position)
                                    task.wait(0.2)
                                    local startClaim = tick()
                                    while prompt.Enabled and prompt.Parent and (tick() - startClaim < 8) and autoBuyPrintActive do
                                        FORCE_HOLD(prompt)
                                        task.wait(0.3)
                                    end
                                    task.wait(0.5)
                                    Notify("Repz Farm", "Returning to start position...", 3)
                                    BYPASS_TP(startPos)
                                    task.wait(0.5)
                                end
                            end
                            if loopSuccess and autoBuyPrintActive then
                                Notify("Repz Farm", "Starting printing sequence...", 3)
                                while autoBuyPrintActive do
                                    local hasTools = hasAnyRepzTools()
                                    local placed = getMyPlacedPrinters()
                                    if not hasTools and #placed == 0 then
                                        Notify("Repz Farm", "Batch printing complete!", 4)
                                        break
                                    end
                                    startPrintingSequence()
                                    task.wait(1)
                                end
                            end
                        end
                    end
                end
            end)
        else
            autoBuyPrintActive = false
            if autoBuyPrintThread then
                task.cancel(autoBuyPrintThread)
                autoBuyPrintThread = nil
            end
        end
    end)
end

function buildRepzFarm_3()
    CreateCardButton(C1, "Purchase Batch", function()
        if not selectedMaterial then
            Notify("Repz Farm", "Please select a Material first!", 3)
            return
        end
        if not selectedBlank then
            Notify("Repz Farm", "Please select a Blank first!", 3)
            return
        end
        local myApt = getMyPropertyModel()
        if not myApt then
            Notify("Repz Farm", "You must own a property/apartment first!", 4)
            return
        end
        local deliveryPromptModel = myApt:FindFirstChild("DeliveryPrompt")
        local prompt = deliveryPromptModel and deliveryPromptModel:FindFirstChild("ProximityPrompt")
        if not prompt then
            Notify("Repz Farm", "Error: DeliveryPrompt not found in your property!", 4)
            return
        end
        for i = 1, purchaseQty do
            Notify("Repz Farm", string.format("Buying item #%d of %d...", i, purchaseQty), 3)
            pcall(function() Event:FireServer("PurchaseMaterial", selectedMaterial) end)
            task.wait(1)
            pcall(function() Event:FireServer("PurchaseBlank", selectedBlank) end)
            task.wait(1)
            pcall(function() Event:FireServer("PurchaseMachine", "Screen Printer") end)
            task.wait(1)
            Notify("Repz Farm", "Waiting 59s for delivery...", 3)
            task.wait(59)
            local char = LPLR.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local startPos = hrp.Position
                Notify("Repz Farm", "Claiming delivery...", 3)
                BYPASS_TP(deliveryPromptModel.Position)
                task.wait(0.2)
                local startClaim = tick()
                while prompt.Enabled and prompt.Parent and (tick() - startClaim < 8) do
                    FORCE_HOLD(prompt)
                    task.wait(0.3)
                end
                task.wait(0.5)
                Notify("Repz Farm", "Returning to start position...", 3)
                BYPASS_TP(startPos)
                task.wait(0.5)
            end
        end
        Notify("Repz Farm", "Batch purchase complete!", 4)
    end)
    CreateCardButton(C1, "Sell Repz (Nearest Buyer)", function()
        local hasRepz = false
        for _, tool in ipairs(LPLR.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                hasRepz = true
                break
            end
        end
        if not hasRepz and LPLR.Character then
            for _, tool in ipairs(LPLR.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                    hasRepz = true
                    break
                end
            end
        end
        if not hasRepz then
            Notify("Repz Farm", "No Reps items found in your inventory to sell!", 4)
            return
        end
        local function findAnyPrompt(model)
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    return obj
                end
            end
            return nil
        end
        local function findRepzBuyerNPC()
            local buyers = {}
            local npcNames = { "RepsBuyer", "RepsBuyer2", "RepsBuyer3", "RepsBuyer4", "RepsBuyer5", "RepsBuyer6",
                "RepsBuyer7" }
            local npcFolder = workspace:FindFirstChild("NPC")
            if npcFolder then
                for _, name in ipairs(npcNames) do
                    local npc = npcFolder:FindFirstChild(name)
                    if npc then
                        table.insert(buyers, npc)
                    end
                end
            end
            return buyers
        end
        local candidateBuyers = findRepzBuyerNPC()
        if #candidateBuyers == 0 then
            Notify("Repz Farm", "Searching for Reps Buyer in workspace...", 2)
            candidateBuyers = {}
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") then
                    local prompt = findAnyPrompt(obj)
                    if prompt then
                        local txt = (prompt.ObjectText .. " " .. prompt.ActionText):lower()
                        if txt:find("rep") or txt:find("sell") or txt:find("buyer") or txt:find("dealer") then
                            table.insert(candidateBuyers, obj)
                        end
                    end
                end
            end
        end
        local foundBuyers = {}
        for _, npc in ipairs(candidateBuyers) do
            local prompt = findAnyPrompt(npc)
            if prompt then
                table.insert(foundBuyers, npc)
            end
        end
        if #foundBuyers == 0 then
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    local txt = (descendant.ObjectText .. " " .. descendant.ActionText):lower()
                    if txt:find("rep") or txt:find("sell rep") then
                        local parentModel = descendant:FindFirstAncestorOfClass("Model")
                        if parentModel and not table.find(foundBuyers, parentModel) then
                            table.insert(foundBuyers, parentModel)
                        end
                    end
                end
            end
        end
        local chosenBuyer = foundBuyers[math.random(1, #foundBuyers)]
        local prompt = findAnyPrompt(chosenBuyer)
        if not prompt then
            Notify("Repz Farm", "Error: No prompt found on the chosen buyer NPC!", 4)
            return
        end
        Notify("Repz Farm", "Chosen buyer: " .. chosenBuyer.Name .. ". Starting sale...", 4)
        task.spawn(function()
            local char = LPLR.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local startPos = hrp.Position
            local targetPos = getPromptPosition(prompt) or chosenBuyer:GetPivot().Position
            BYPASS_TP(targetPos)
            task.wait(0.3)
            local selling = true
            while selling do
                local repTool = nil
                for _, tool in ipairs(LPLR.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                        repTool = tool
                        break
                    end
                end
                if not repTool then
                    for _, tool in ipairs(LPLR.Character:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:match("Rep$") or tool.Name:match("Rep")) then
                            repTool = tool
                            break
                        end
                    end
                end
                if not repTool then
                    selling = false
                    break
                end
                local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:UnequipTools()
                    task.wait(0.1)
                    hum:EquipTool(repTool)
                    task.wait(0.2)
                end
                triggerPrompt(prompt)
                task.wait(0.3)
            end
            Notify("Repz Farm", "All repz sold! Returning to start position...", 4)
            BYPASS_TP(startPos)
        end)
    end)
end; buildRepzFarm(); buildRepzFarm_2(); buildRepzFarm_3()
function buildChickenFarm()
    local C_CHICK         = CreateCard(pfa, "Chicken Farm", "right", 3)
    local chickenActive   = false
    local chickenThread   = nil

    local FASTFOOD_SHIRT  = "rbxassetid://18344742658"
    local JOB_BOARD_POS   = Vector3.new(-905, 5, -1561)
    local CUT_CHICKEN_POS = Vector3.new(-849, 5, -1568)
    local BOX_DEPOSIT_POS = Vector3.new(-857, 5, -1552)
    local WORK_POS        = Vector3.new(-860, 5, -1554)
    local TARGET_STOCK    = 25
    local COOK_WAIT       = 30

    local function getChar()
        local charFolder = workspace:FindFirstChild("Characters")
        return (charFolder and charFolder:FindFirstChild(LPLR.Name))
            or LPLR.Character
            or workspace:FindFirstChild(LPLR.Name)
    end

    local function getShirt()
        local char = getChar()
        if not char then return nil end
        local shirt = char:FindFirstChildOfClass("Shirt")
        return shirt and shirt.ShirtTemplate
    end

    local function readStock()
        local ok, val = pcall(function()
            local jobAssets  = workspace:FindFirstChild("JobAssets")
            local ffFolder   = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
            local meatHolder = ffFolder and ffFolder:FindFirstChild("MeatHolder")
            local bbGui      = meatHolder and meatHolder:FindFirstChild("BillboardGui")
            local lbl        = bbGui and bbGui:FindFirstChild("TextLabel")
            return lbl and tonumber(lbl.Text:match("Stock:%s*(%d+)"))
        end)
        return ok and val or nil
    end

    local function hasRawDrumstick()
        local inBackpack = LPLR.Backpack:FindFirstChild("Raw Drumstick")
        local char = getChar()
        local inChar = char and char:FindFirstChild("Raw Drumstick")
        return (inBackpack or inChar) ~= nil
    end

    local function doMinigameClicks()
        local mouse = LPLR:GetMouse()
        local ok, conns = pcall(getconnections, mouse.Button1Down)
        if not ok or not conns or #conns == 0 then return end
        local tapGame = nil
        pcall(function()
            tapGame = LPLR.PlayerGui.Minigames.Mainframe.TapGame
        end)
        for i = 1, 40 do
            if not chickenActive then break end
            if tapGame and not tapGame.Visible then break end
            for _, conn in ipairs(conns) do
                pcall(function() conn:Fire() end)
            end
            task.wait(0.05)
        end
    end

    pcall(function()
        local FastfoodRE = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Fastfood")
        if FastfoodRE and FastfoodRE.OnClientEvent then
            FastfoodRE.OnClientEvent:Connect(function(msg)
                if msg == "StartMinigame" and chickenActive then
                    task.spawn(doMinigameClicks)
                end
            end)
        end

        local tapGame = nil
        pcall(function() tapGame = LPLR.PlayerGui.Minigames.Mainframe.TapGame end)
        if tapGame then
            tapGame:GetPropertyChangedSignal("Visible"):Connect(function()
                if tapGame.Visible and chickenActive then
                    task.spawn(doMinigameClicks)
                end
            end)
        end
    end)

    local function getRawChickenPrompt()
        local ffFolder = workspace:FindFirstChild("JobAssets") and
            workspace.JobAssets:FindFirstChild("Fastfood Worker")
        local chicken  = ffFolder and ffFolder:FindFirstChild("Raw Chicken")
        local handle   = chicken and chicken:FindFirstChild("Handle")
        return handle and
            (handle:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChild("ProximityPrompt"))
    end

    local function cutAndDepositChicken()
        tpClassic(CFrame.new(CUT_CHICKEN_POS))
        task.wait(0.3)

        local startTime = tick()
        while chickenActive and not hasRawDrumstick() and (tick() - startTime < 15) do
            local tapGame = nil
            pcall(function() tapGame = LPLR.PlayerGui.Minigames.Mainframe.TapGame end)
            if tapGame and tapGame.Visible then
                task.spawn(doMinigameClicks)
                task.wait(0.3)
            end

            local prompt = getRawChickenPrompt()
            if prompt and prompt.Enabled then
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    FORCE_HOLD(prompt)
                end
            end
            task.wait(0.4)
        end

        if hasRawDrumstick() then
            tpClassic(CFrame.new(BOX_DEPOSIT_POS))
            task.wait(0.3)

            pcall(function()
                local jobAssets  = workspace:FindFirstChild("JobAssets")
                local ffFolder   = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
                local meatHolder = ffFolder and ffFolder:FindFirstChild("MeatHolder")
                local prompt     = meatHolder and
                    (meatHolder:FindFirstChildOfClass("ProximityPrompt") or meatHolder:FindFirstChild("ProximityPrompt"))
                if prompt then
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        FORCE_HOLD(prompt)
                    end
                end
            end)
            task.wait(0.5)
        end
    end

    local function fireCook()
        local prompt = nil
        pcall(function()
            local jobAssets = workspace:FindFirstChild("JobAssets")
            local ffFolder  = jobAssets and jobAssets:FindFirstChild("Fastfood Worker")
            local cookPart  = ffFolder and ffFolder:FindFirstChild("Cook Prompt")
            prompt          = cookPart and
                (cookPart:FindFirstChildOfClass("ProximityPrompt") or cookPart:FindFirstChild("ProximityPrompt"))
        end)
        if not prompt then return end
        for i = 1, 3 do
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    FORCE_HOLD(prompt)
                end
            end)
            task.wait(0.1)
        end
    end

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "ChickenStatus"
    statusLabel.Size = UDim2.new(1, -10, 0, 18)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = C_CHICK

    local function setStatus(txt, col)
        statusLabel.Text = "Status: " .. txt
        statusLabel.TextColor3 = col or Color3.fromRGB(150, 150, 150)
    end

    CreateToggle(C_CHICK, "Auto Chicken Farm", false, "ChickenFarmToggle", function(v)
        chickenActive = v

        if not v then
            if chickenThread then
                task.cancel(chickenThread)
                chickenThread = nil
            end
            setStatus("Idle")
            Notify("Chicken Farm", "Stopped.", 3)
            return
        end

        Notify("Chicken Farm", "Starting...", 3)

        chickenThread = task.spawn(function()
            setStatus("Checking job...", Color3.fromRGB(255, 255, 255))
            if getShirt() ~= FASTFOOD_SHIRT then
                setStatus("Going to job board...", Color3.fromRGB(255, 255, 255))
                Notify("Chicken Farm", "Applying for Fastfood job...", 3)

                local tpPos = JOB_BOARD_POS
                pcall(function()
                    local boardFolder = workspace:FindFirstChild("JobBoard") and
                        workspace.JobBoard:FindFirstChild("Fastfood Worker")
                    local board = boardFolder and boardFolder:FindFirstChild("Fastfood Worker")
                    if board then
                        local p = board:IsA("BasePart") and board.Position or board:GetPivot().Position
                        tpPos = p + Vector3.new(0, 3, 0)
                    end
                end)

                tpClassic(CFrame.new(tpPos))
                task.wait(0.5)

                local prompt = nil
                for attempt = 1, 10 do
                    pcall(function()
                        local boardFolder = workspace:FindFirstChild("JobBoard") and
                            workspace.JobBoard:FindFirstChild("Fastfood Worker")
                        local board = boardFolder and boardFolder:FindFirstChild("Fastfood Worker")
                        if board then
                            prompt = board:FindFirstChildOfClass("ProximityPrompt") or
                                board:FindFirstChild("ProximityPrompt")
                        end
                    end)
                    if prompt then break end
                    task.wait(0.5)
                end

                if prompt then
                    if fireproximityprompt then
                        pcall(fireproximityprompt, prompt)
                    else
                        FORCE_HOLD(prompt)
                    end
                    task.wait(2)
                end

                if getShirt() ~= FASTFOOD_SHIRT then
                    setStatus("Failed to get job!", Color3.fromRGB(230, 60, 60))
                    Notify("Chicken Farm", "Could not get Fastfood job!", 4)
                    chickenActive = false
                    return
                end
                setStatus("Job acquired!", Color3.fromRGB(80, 200, 80))
                task.wait(0.5)
            else
                setStatus("Already Fastfood Worker!", Color3.fromRGB(80, 200, 80))
                task.wait(0.5)
            end

            setStatus("Going to work area...", Color3.fromRGB(255, 255, 255))
            tpClassic(CFrame.new(WORK_POS))
            task.wait(0.5)

            while chickenActive do
                local stock = readStock()
                if stock == nil then
                    setStatus("Can't read stock!", Color3.fromRGB(230, 60, 60))
                    task.wait(2)
                elseif stock <= 0 then
                    -- Stock is empty (0), fill the box up to 25
                    local needed = TARGET_STOCK
                    setStatus("Filling box: 0 / " .. TARGET_STOCK, Color3.fromRGB(255, 255, 255))
                    for i = 1, needed do
                        if not chickenActive then break end
                        cutAndDepositChicken()
                        local curS = readStock()
                        if curS and curS >= TARGET_STOCK then break end
                        task.wait(0.1)
                    end
                    task.wait(0.3)
                else
                    -- Stock still has chicken, continue cooking!
                    tpClassic(CFrame.new(WORK_POS))
                    task.wait(0.3)

                    setStatus("Firing cook prompt...", Color3.fromRGB(255, 165, 0))
                    fireCook()

                    for i = COOK_WAIT, 1, -1 do
                        if not chickenActive then break end
                        local s = readStock()
                        setStatus(
                            "Cook wait " .. i .. "s | Stock: " .. (s or "?"),
                            Color3.fromRGB(255, 165, 0)
                        )
                        task.wait(1)
                    end
                end

                task.wait(0.1)
            end

            setStatus("Idle")
        end)
    end)
end; buildChickenFarm()

function buildCandyFarm()
    local C_MONEY = CreateCard(pfa, "Candy Farm", "right", 4)
    local moneyGenActive = false
    local moneyGenThread = nil
    local stopFarmToSell = false
    local isSelling = false
    local COOKER_GROUPS = {
        { -- Grupo 1
            Vector3.new(495.2908020019531, 5.11527156829834, 267.7255859375),
            Vector3.new(498.7786865234375, 4.535792350769043, 268.0061950683594),
            Vector3.new(494.12335205078125, 5.115273475646973, 272.8432312011719),
            Vector3.new(497.9498596191406, 5.11527156829834, 273.17803955078125)
        },
        { -- Grupo 2
            Vector3.new(543.3556518554688, 4.721816062927246, 271.8525085449219),
            Vector3.new(547.5324096679688, 5.115273475646973, 272.29620361328125),
            Vector3.new(542.4951171875, 5.064774513244629, 277.0752868652344),
            Vector3.new(546.7152099609375, 4.721816062927246, 277.522705078125)
        },
        { -- Grupo 3
            Vector3.new(435.8268737792969, 4.535792350769043, 267.76763916015625),
            Vector3.new(432.0003662109375, 4.535792350769043, 267.4328308105469),
            Vector3.new(436.3055114746094, 4.721816062927246, 262.4868469238281),
            Vector3.new(432.82928466796875, 5.11527156829834, 262.2609558105469)
        },
        { -- Grupo 4
            Vector3.new(516.6300659179688, 4.721816062927246, 274.890625),
            Vector3.new(512.7918701171875, 4.535792350769043, 274.50115966796875),
            Vector3.new(517.0970458984375, 4.721816062927246, 269.55517578125),
            Vector3.new(513.6207885742188, 5.11527156829834, 269.32928466796875)
        },
        { -- Grupo 5
            Vector3.new(449.3459167480469, 4.721816062927246, 269.0040283203125),
            Vector3.new(452.8221740722656, 5.11527156829834, 269.2298889160156),
            Vector3.new(450.2064208984375, 5.064774513244629, 263.7812805175781),
            Vector3.new(453.6393737792969, 4.721816062927246, 264.0033264160156)
        },
        { -- Grupo 6
            Vector3.new(477.1398010253906, 4.721816062927246, 271.4356384277344),
            Vector3.new(480.5726623535156, 5.064774513244629, 271.6577453613281),
            Vector3.new(477.606689453125, 4.721816062927246, 266.1002197265625),
            Vector3.new(481.44488525390625, 4.535792350769043, 266.4896545410156)
        }
    }
    local function getChar()
        local charFolder = workspace:FindFirstChild("Characters")
        return (charFolder and charFolder:FindFirstChild(LPLR.Name))
            or LPLR.Character
            or workspace:FindFirstChild(LPLR.Name)
    end
    local function safeTeleport(pos)
        local cf = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
        tpClassic(cf)
        pcall(function()
            local char = getChar()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end)
    end
    local function purchaseItem(name)
        if LPLR.Backpack:FindFirstChild(name) or (LPLR.Character and LPLR.Character:FindFirstChild(name)) then
            return
        end
        local RepStorage = game:GetService("ReplicatedStorage")
        local Event = getSleitnickNet() and getSleitnickNet():FindFirstChild("RE/Convenience")
        for i = 1, 5 do
            Event:FireServer("PurchasePablo", { name = name, category = "Items" })
            task.wait(0.4)
            if LPLR.Backpack:FindFirstChild(name) or (LPLR.Character and LPLR.Character:FindFirstChild(name)) then
                return
            end
        end
    end
    local function equipItem(name)
        local char = getChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local tool = LPLR.Backpack:FindFirstChild(name)
        if tool and hum then hum:EquipTool(tool) end
    end
    local function isNumzTool(name)
        if not name then return false end
        return name:lower():find("num") ~= nil
    end
    local function findAnyNumzTool()
        if LPLR.Backpack then
            for _, item in ipairs(LPLR.Backpack:GetChildren()) do
                if isNumzTool(item.Name) then return item end
            end
        end
        local char = getChar()
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and isNumzTool(item.Name) then return item end
            end
        end
        return nil
    end
    local function findCookerAtPosition(targetPos)
        local area = workspace.Map:FindFirstChild("CookingArea")
        if not area then return nil end
        local closest, closestDist = nil, 4
        for _, desc in ipairs(area:GetDescendants()) do
            if desc.Name == "GasCooker" or desc:FindFirstChild("GasCooker") then
                local gc = desc.Name == "GasCooker" and desc or desc.GasCooker
                local part = gc:IsA("BasePart") and gc or gc:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local dist = (part.Position - targetPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = desc
                    end
                end
            end
        end
        return closest
    end
    local function isCookerOwnedByMe(c)
        if not c then return false end
        local gc = c:FindFirstChild("GasCooker") or c
        local ownerAttr = c:GetAttribute("Owner") or gc:GetAttribute("Owner") or c:GetAttribute("Player") or
            gc:GetAttribute("Player")
        if ownerAttr then
            if typeof(ownerAttr) == "Instance" and ownerAttr == LPLR then return true end
            local str = tostring(ownerAttr)
            if str == LPLR.Name or str == tostring(LPLR.UserId) then return true end
        end
        for _, childName in ipairs({ "Owner", "Player", "ClaimedBy", "User" }) do
            local valObj = c:FindFirstChild(childName) or gc:FindFirstChild(childName)
            if valObj then
                if valObj:IsA("ObjectValue") and valObj.Value == LPLR then return true end
                if valObj:IsA("StringValue") and valObj.Value == LPLR.Name then return true end
                if (valObj:IsA("IntValue") or valObj:IsA("NumberValue")) and tonumber(valObj.Value) == LPLR.UserId then return true end
            end
        end
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pr then
            local objText = pr.ObjectText or ""
            if objText ~= "" and (objText:find(LPLR.Name) or (LPLR.DisplayName and objText:find(LPLR.DisplayName))) then
                return true
            end
        end
        return false
    end
    local function isCookerOwnedByOther(c)
        if not c then return false end
        if isCookerOwnedByMe(c) then return false end
        local gc = c:FindFirstChild("GasCooker") or c
        local ownerAttr = c:GetAttribute("Owner") or gc:GetAttribute("Owner") or c:GetAttribute("Player") or
            gc:GetAttribute("Player")
        if ownerAttr then
            if typeof(ownerAttr) == "Instance" and ownerAttr ~= LPLR then return true end
            local str = tostring(ownerAttr)
            if str ~= "" and str ~= LPLR.Name and str ~= tostring(LPLR.UserId) then return true end
        end
        for _, childName in ipairs({ "Owner", "Player", "ClaimedBy", "User" }) do
            local valObj = c:FindFirstChild(childName) or gc:FindFirstChild(childName)
            if valObj then
                if valObj:IsA("ObjectValue") and valObj.Value and valObj.Value ~= LPLR then return true end
                if valObj:IsA("StringValue") and valObj.Value ~= "" and valObj.Value ~= LPLR.Name then return true end
                if (valObj:IsA("IntValue") or valObj:IsA("NumberValue")) and valObj.Value ~= 0 and tonumber(valObj.Value) ~= LPLR.UserId then return true end
            end
        end
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pr then
            local objText = pr.ObjectText or ""
            if objText ~= "" and not objText:find(LPLR.Name) and not (LPLR.DisplayName and objText:find(LPLR.DisplayName)) and not objText:lower():find("gas cooker") then
                return true
            end
        end
        return false
    end
    local function countMyOwnedCookers()
        local area = workspace.Map:FindFirstChild("CookingArea")
        if not area then return 0 end
        local counted = {}
        local count = 0
        for _, desc in ipairs(area:GetDescendants()) do
            if desc.Name == "GasCooker" or desc:FindFirstChild("GasCooker") then
                local mainObj = desc
                if desc.Parent and desc.Parent.Name == "GasCooker" then
                    mainObj = desc.Parent
                end
                if not counted[mainObj] then
                    counted[mainObj] = true
                    if isCookerOwnedByMe(mainObj) then
                        count = count + 1
                    end
                end
            end
        end
        return count
    end
    local function isCookerUsableByMe(c)
        if not c then return false end
        if isCookerOwnedByMe(c) then return true end
        if isCookerOwnedByOther(c) then return false end
        local gc = c:FindFirstChild("GasCooker") or c
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not pr then return false end
        if pr.ActionText == "Claim Cooker" or pr.ActionText == "Pour Water" then
            return true
        end
        return false
    end
    local function isCookerFree(c)
        if not c then return false end
        if isCookerOwnedByOther(c) then return false end
        local gc = c:FindFirstChild("GasCooker") or c
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not pr then return false end
        if pr.ActionText == "Claim Cooker" or pr.ActionText == "Pour Water" then
            return true
        end
        return false
    end
    local function DisableCollision(Object)
        if not Object then return end
        pcall(function()
            if Object:IsA("BasePart") then
                Object.CanCollide = false
            end
            for _, Descendant in ipairs(Object:GetDescendants()) do
                if Descendant:IsA("BasePart") then
                    Descendant.CanCollide = false
                end
            end
        end)
    end
    local function disableCookerTableCollisions()
        pcall(function()
            local Map = workspace:FindFirstChild("Map")
            local CookingArea = Map and Map:FindFirstChild("CookingArea")
            if CookingArea then
                for _, Object in ipairs(CookingArea:GetDescendants()) do
                    if Object.Name == "Table" then
                        DisableCollision(Object)
                    end
                end
            end
            if Map then
                for _, Object in ipairs(Map:GetChildren()) do
                    if Object.Name == "Table" then
                        DisableCollision(Object)
                    end
                end
            end
        end)
    end
    local function findUnusedGroupOfThree()
        local bestGroup, bestIdx, maxMyCookers = nil, nil, -1
        for gIdx, groupPositions in ipairs(COOKER_GROUPS) do
            local cookersInGroup = {}
            local allUsable = true
            local myCookersInGroup = 0
            for _, pos in ipairs(groupPositions) do
                local cooker = findCookerAtPosition(pos)
                if cooker and isCookerUsableByMe(cooker) then
                    table.insert(cookersInGroup, cooker)
                    if isCookerOwnedByMe(cooker) then
                        myCookersInGroup = myCookersInGroup + 1
                    end
                else
                    allUsable = false
                    break
                end
            end
            if allUsable and #cookersInGroup >= 3 then
                table.sort(cookersInGroup, function(a, b)
                    local aMine = isCookerOwnedByMe(a) and 1 or 0
                    local bMine = isCookerOwnedByMe(b) and 1 or 0
                    return aMine > bMine
                end)
                if myCookersInGroup > maxMyCookers then
                    maxMyCookers = myCookersInGroup
                    bestGroup = { cookersInGroup[1], cookersInGroup[2], cookersInGroup[3] }
                    bestIdx = gIdx
                end
            end
        end
        return bestGroup, bestIdx
    end
    local function teleportToGroup(groupIdx)
        if not groupIdx or not COOKER_GROUPS[groupIdx] then return end
        local pos = COOKER_GROUPS[groupIdx][1]
        safeTeleport(CFrame.new(pos + Vector3.new(0, 3, 0)))
        task.wait(0.3)
    end
    local function ensureAtGroup(groupIdx)
        local char = getChar()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and groupIdx and COOKER_GROUPS[groupIdx] then
            local pos = COOKER_GROUPS[groupIdx][1]
            if (hrp.Position - pos).Magnitude > 15 then
                safeTeleport(CFrame.new(pos + Vector3.new(0, 3, 0)))
                task.wait(0.3)
            end
        end
    end
    local function processSingleCookerSetup(c)
        if stopFarmToSell or not moneyGenActive or not c then return false end
        local gc = c:FindFirstChild("GasCooker") or c
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not pr or not pr.Parent then return false end
        local action = pr.ActionText or ""
        if action == "Claim Cooker" then
            if not isCookerOwnedByMe(c) then
                local claimStart = tick()
                repeat
                    if pr and pr.Parent and pr.ActionText == "Claim Cooker" then
                        fireproximityprompt(pr)
                    end
                    task.wait(0.35)
                until stopFarmToSell or not moneyGenActive or not pr.Parent or isCookerOwnedByMe(c) or pr.ActionText ~= "Claim Cooker" or (tick() - claimStart > 6)
                task.wait(0.3)
            end
            action = pr and pr.Parent and pr.ActionText or ""
        end
        if stopFarmToSell or not moneyGenActive then return false end
        if action == "Pour Water" then
            purchaseItem("Water Gallon")
            purchaseItem("Flavor Packet")
            if stopFarmToSell or not moneyGenActive then return false end
            equipItem("Water Gallon")
            local wStart = tick()
            repeat
                if pr and pr.Parent and pr.ActionText == "Pour Water" then
                    fireproximityprompt(pr)
                end
                task.wait(0.35)
            until stopFarmToSell or not moneyGenActive or not pr.Parent or pr.ActionText ~= "Pour Water" or (tick() - wStart > 5)
            task.wait(0.2)
            action = pr and pr.Parent and pr.ActionText or ""
        end
        if stopFarmToSell or not moneyGenActive then return false end
        if action == "Pour Flavor packet" then
            purchaseItem("Flavor Packet")
            if stopFarmToSell or not moneyGenActive then return false end
            equipItem("Flavor Packet")
            local fStart = tick()
            repeat
                local char = getChar()
                if not (char and char:FindFirstChild("Flavor Packet")) then
                    equipItem("Flavor Packet")
                end
                if pr and pr.Parent and pr.ActionText == "Pour Flavor packet" then
                    fireproximityprompt(pr)
                end
                task.wait(0.35)
            until stopFarmToSell or not moneyGenActive or not pr.Parent or pr.ActionText ~= "Pour Flavor packet" or (tick() - fStart > 5)
            task.wait(0.2)
            action = pr and pr.Parent and pr.ActionText or ""
        end
        if stopFarmToSell or not moneyGenActive then return false end
        if action == "Boil" then
            fireproximityprompt(pr)
            task.wait(0.3)
        end
        return true
    end
    local function collectAndReloadCooker(c)
        if stopFarmToSell or not moneyGenActive or not c then return end
        local gc = c:FindFirstChild("GasCooker") or c
        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
            c:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pr and pr.ActionText == "Cut and Process Numz" then
            local cutStart = tick()
            repeat
                if stopFarmToSell or not moneyGenActive then break end
                if pr and pr.Parent then fireproximityprompt(pr) end
                task.wait(0.35)
            until stopFarmToSell or not moneyGenActive or not pr or not pr.Parent or pr.ActionText ~= "Cut and Process Numz" or (tick() - cutStart > 15)
        end
        if stopFarmToSell or not moneyGenActive then return end
        processSingleCookerSetup(c)
    end
    local function teleportToCookingArea()
        safeTeleport(CFrame.new(485, 5, 255))
        task.wait(0.5)
    end
    local function getActiveCookersForGroup(groupIdx)
        if not groupIdx or not COOKER_GROUPS[groupIdx] then return {} end
        local groupPositions = COOKER_GROUPS[groupIdx]
        local myCookers = {}
        local freeCookers = {}
        for _, pos in ipairs(groupPositions) do
            local cooker = findCookerAtPosition(pos)
            if cooker then
                if isCookerOwnedByMe(cooker) then
                    table.insert(myCookers, cooker)
                elseif isCookerFree(cooker) and not isCookerOwnedByOther(cooker) then
                    table.insert(freeCookers, cooker)
                end
            end
        end
        local activeList = {}
        for _, c in ipairs(myCookers) do
            table.insert(activeList, c)
        end
        for _, c in ipairs(freeCookers) do
            if #activeList >= 3 then break end
            table.insert(activeList, c)
        end
        return activeList
    end
    local function runMoneyGenLoop()
        teleportToCookingArea()
        while moneyGenActive and not stopFarmToSell do
            local targetCookers, groupIdx = findUnusedGroupOfThree()
            if not targetCookers then
                task.wait(2)
            else
                teleportToGroup(groupIdx)
                disableCookerTableCollisions()
                targetCookers = getActiveCookersForGroup(groupIdx)
                for i, c in ipairs(targetCookers) do
                    if not moneyGenActive or stopFarmToSell then break end
                    processSingleCookerSetup(c)
                    task.wait(0.3)
                end
                local cookerIndex = 1
                while moneyGenActive and not stopFarmToSell do
                    ensureAtGroup(groupIdx)
                    targetCookers = getActiveCookersForGroup(groupIdx)
                    if #targetCookers == 0 then break end
                    if cookerIndex > #targetCookers then cookerIndex = 1 end
                    local c = targetCookers[cookerIndex]
                    if c then
                        local gc = c:FindFirstChild("GasCooker") or c
                        local pr = gc:FindFirstChildWhichIsA("ProximityPrompt", true) or
                            c:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if pr and (pr.ActionText == "Cut and Process Numz" or pr.ActionText == "Claim Cooker" or pr.ActionText == "Pour Water") then
                            collectAndReloadCooker(c)
                        end
                    end
                    cookerIndex = (cookerIndex % #targetCookers) + 1
                    task.wait(0.3)
                end
            end
            task.wait(0.5)
        end
    end
    local function findMyBuyer(soldBuyers)
        local nc = workspace:FindFirstChild("NumChars")
        if not nc then return nil end
        for _, c in ipairs(nc:GetChildren()) do
            if c:GetAttribute("Owner") == LPLR.Name and not soldBuyers[c] then
                return c
            end
        end
        return nil
    end
    local function hasNumz(name)
        if not name then return false end
        local inBackpack = LPLR.Backpack:FindFirstChild(name)
        local inChar = LPLR.Character and LPLR.Character:FindFirstChild(name)
        return (inBackpack or inChar) ~= nil
    end
    local function sellNumz()
        local soldBuyers = {}
        local tool = findAnyNumzTool()
        local NumzFunction = getSleitnickNet() and getSleitnickNet():FindFirstChild("RF/NumzFunction")
        local salesCount = 0

        while tool do
            local toolName = tool.Name
            local buyer = nil
            if NumzFunction then
                pcall(function() NumzFunction:InvokeServer("TrackBuyer") end)
            end
            local startFind = tick()
            repeat
                buyer = findMyBuyer(soldBuyers)
                task.wait(0.2)
            until buyer or (tick() - startFind > 8)

            local sellTimeout = tick()
            while hasNumz(toolName) and (tick() - sellTimeout < 45) do
                if not buyer or not buyer.Parent or not buyer.PrimaryPart then
                    if NumzFunction then
                        pcall(function() NumzFunction:InvokeServer("TrackBuyer") end)
                    end
                    task.wait(0.5)
                    buyer = findMyBuyer(soldBuyers)
                end

                if buyer and buyer.PrimaryPart then
                    local destPos = buyer.PrimaryPart.Position
                    local char = getChar()
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local dist = hrp and (hrp.Position - destPos).Magnitude or 999

                    if dist > 6 then
                        safeTeleport(buyer.PrimaryPart.CFrame + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                    end

                    equipItem(toolName)
                    task.wait(0.15)

                    local prompt = nil
                    pcall(function()
                        local promptFolder = buyer:FindFirstChild("Prompt")
                        prompt = (promptFolder and promptFolder:FindFirstChildWhichIsA("ProximityPrompt", true))
                            or buyer:FindFirstChildWhichIsA("ProximityPrompt", true)
                    end)

                    if prompt and prompt.Enabled ~= false then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            FORCE_HOLD(prompt)
                        end
                    end
                end

                task.wait(0.3)
            end

            if buyer then
                soldBuyers[buyer] = true
            end

            salesCount = salesCount + 1
            if salesCount % 5 == 0 then
                task.wait(8.0)
            else
                task.wait(4.0)
            end
            tool = findAnyNumzTool()
        end
    end
    local candyToggle = nil
    candyToggle = CreateToggle(C_MONEY, "Auto Candy Farm", false, "CandyFarmToggle", function(v)
        if v then
            if findAnyNumzTool() then
                moneyGenActive = false
                if candyToggle then
                    candyToggle:SET(false, true)
                end
                Notify("Candy Farm", "Sell your Numz first before starting the farm!", 4)
                return
            end
            Notify("Toggle Enabled", "Auto Candy Farm has been enabled.", 2)
            moneyGenActive = true
            moneyGenThread = task.spawn(function() runMoneyGenLoop() end)
        else
            Notify("Toggle Disabled", "Auto Candy Farm has been disabled.", 2)
            moneyGenActive = false
            if moneyGenThread then
                task.cancel(moneyGenThread)
                moneyGenThread = nil
            end
        end
    end, nil, true)
    CreateCardButton(C_MONEY, "Sell Now", function()
        if isSelling then return end
        isSelling = true
        stopFarmToSell = true
        task.spawn(function()
            task.wait(0.5)
            if findAnyNumzTool() then
                sellNumz()
            else
                Notify("Candy Farm", "No Numz tools to sell!", 3)
                task.wait(2)
            end
            stopFarmToSell = false
            isSelling = false
            if moneyGenActive then
                moneyGenThread = task.spawn(function() runMoneyGenLoop() end)
            end
        end)
    end)
end; buildCandyFarm()

function buildJailCleanFarm()
    local C_JAIL = CreateCard(pfa, "Jail Clean Farm", "right", 2)
    local jailActive = false
    local jailThread = nil
    function getPrisonModel()
        return safeGet(workspace, { "Map", "Prison", "Intertior", "Structure", "Model" }) or
            safeGet(workspace, { "Map", "Prison", "Interior", "Structure", "Model" })
    end

    function isNearPrison()
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
            workspace:FindFirstChild(LPLR.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local tablesFolder = safeGet(workspace, { "Map", "Prison", "Intertior", "Tables", "Tables" }) or
            safeGet(workspace, { "Map", "Prison", "Interior", "Tables", "Tables" })
        if tablesFolder then
            for _, child in ipairs(tablesFolder:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    local pos = child:IsA("BasePart") and child.Position or child:GetPivot().Position
                    if (hrp.Position - pos).Magnitude < 1500 then
                        return true
                    end
                end
            end
            if tablesFolder:IsA("Model") or tablesFolder:IsA("BasePart") then
                local pos = tablesFolder:IsA("BasePart") and tablesFolder.Position or
                    tablesFolder:GetPivot().Position
                if (hrp.Position - pos).Magnitude < 1500 then
                    return true
                end
            end
        end
        local prison = getPrisonModel()
        if prison then
            if (hrp.Position - prison:GetPivot().Position).Magnitude < 1500 then
                return true
            end
        end
        local folder = safeGet(workspace, { "CleanWork", "PrisonPuddles" })
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                local pos = child:IsA("BasePart") and child.Position or
                    (child:IsA("Model") and child:GetPivot().Position)
                if pos and (hrp.Position - pos).Magnitude < 1500 then
                    return true
                end
            end
        end
        return false
    end

    function getAvailablePuddles()
        local folder = safeGet(workspace, { "CleanWork", "PrisonPuddles" })
        if not folder then return {} end
        local puddles = {}
        for _, child in ipairs(folder:GetChildren()) do
            local prompt = child:FindFirstChild("Clean") or child:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                table.insert(puddles, { model = child, prompt = prompt })
            end
        end
        return puddles
    end

    local jailToggle
    jailToggle = CreateToggle(C_JAIL, "Auto Clean Puddles", false, "JailCleanToggle", function(v)
        if v then
            if not isNearPrison() then
                Notify("Jail Farm", "You must be inside the Prison to enable this farm!", 4)
                if jailToggle and jailToggle.SET then jailToggle:SET(false, true) end
                return false
            end
            jailActive = true
            jailThread = task.spawn(function()
                while jailActive do
                    local stepSuccess, err = pcall(function()
                        if not isNearPrison() then
                            Notify("Jail Farm", "Error: You are not inside the Prison!", 4)
                            jailActive = false
                            if jailToggle and jailToggle.SET then jailToggle:SET(false, true) end
                            pcall(function()
                                local charFolder = workspace:FindFirstChild("Characters")
                                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                                    workspace:FindFirstChild(LPLR.Name)
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.Anchored = false end
                            end)
                            return
                        end
                        local puddles = getAvailablePuddles()
                        if #puddles == 0 then
                            Notify("Jail Farm", "No puddles to clean. Waiting...", 4)
                            task.wait(3)
                            return
                        end
                        local charFolder = workspace:FindFirstChild("Characters")
                        local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                            workspace:FindFirstChild(LPLR.Name)
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then
                            task.wait(1)
                            return
                        end
                        local closestPuddle = nil
                        local minDist = 99999
                        for _, puddle in ipairs(puddles) do
                            local pos = getPromptPosition(puddle.prompt)
                            if pos then
                                local dist = (hrp.Position - pos).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closestPuddle = puddle
                                end
                            end
                        end
                        if closestPuddle then
                            local targetPos = getPromptPosition(closestPuddle.prompt)
                            if targetPos then
                                Notify("Jail Farm", "Cleaning puddle...", 2)
                                tpClassic(targetPos)
                                task.wait(0.2)
                                triggerPrompt(closestPuddle.prompt)
                                local startWait = tick()
                                while tick() - startWait < 10 and jailActive do
                                    task.wait(0.1)
                                end
                            end
                        end
                    end)
                    if not stepSuccess then
                        warn("Jail Farm error: " .. tostring(err))
                        task.wait(2)
                    end
                    task.wait(0.5)
                end
            end)
        else
            jailActive = false
            if jailThread then
                task.cancel(jailThread)
                jailThread = nil
            end
            pcall(function()
                local charFolder = workspace:FindFirstChild("Characters")
                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                    workspace:FindFirstChild(LPLR.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end)
        end
    end)
end; buildJailCleanFarm()

function buildHouseRobberyFarm()
    local C_HOUSE_ROB = CreateCard(pfa, "House Robbery Farm", "left", 5)

    local houseRobActive = false
    local houseRobThread = nil
    local currentPlate = nil
    local blacklist = {}

    local function getChar()
        local charFolder = workspace:FindFirstChild("Characters")
        return (charFolder and charFolder:FindFirstChild(LPLR.Name))
            or LPLR.Character
            or workspace:FindFirstChild(LPLR.Name)
    end

    local function cleanupPlate()
        if currentPlate then
            pcall(function() currentPlate:Destroy() end)
            currentPlate = nil
        end
        pcall(function()
            local old = workspace:FindFirstChild("TempRobberyPlate")
            if old then old:Destroy() end
        end)
    end

    local function createPlate(targetPos)
        cleanupPlate()
        pcall(function()
            local plate = Instance.new("Part")
            plate.Name = "TempRobberyPlate"
            plate.Size = Vector3.new(10, 1, 10)
            plate.Position = targetPos - Vector3.new(0, 3.5, 0)
            plate.Material = Enum.Material.Asphalt
            plate.Transparency = 1
            plate.Anchored = true
            plate.CanCollide = true
            plate.Parent = workspace
            currentPlate = plate
        end)
    end

    local function getRoomFolder(houseName)
        return safeGet(workspace, { "HouseRobberies", "Rooms", houseName })
    end

    local function findPrompt(parent, name)
        if not parent then return nil end
        local child = parent:FindFirstChild(name)
        if child then
            if child:IsA("ProximityPrompt") then return child end
            local p = child:FindFirstChildOfClass("ProximityPrompt") or child:FindFirstChild("ProximityPrompt")
            if p then return p end
        end
        for _, desc in ipairs(parent:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and (desc.Name == name or desc.Parent.Name == name) then
                return desc
            end
        end
        return nil
    end

    local function exitHouseBeforeSelling(house)
        if not house then return true end

        local transitionFired = false
        local conn
        pcall(function()
            local event = game:GetService("ReplicatedStorage").Modules.Packages._Index["sleitnick_net@0.2.0"]
                .net["RE/Transition"]
            conn = event.OnClientEvent:Connect(function()
                transitionFired = true
            end)
        end)

        local attempt = 0
        while houseRobActive do
            attempt = attempt + 1

            local room = getRoomFolder(house.Name)
            local leavePrompt = room and findPrompt(room, "Leave")

            if not room or not leavePrompt or not leavePrompt.Parent then
                if conn then pcall(function() conn:Disconnect() end) end
                task.wait(1.5)
                return true
            end

            local leavePos = getPromptPosition(leavePrompt)
            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if transitionFired or (hrp and leavePos and (hrp.Position - leavePos).Magnitude > 80) then
                if conn then pcall(function() conn:Disconnect() end) end
                task.wait(1.5)
                return true
            end

            if leavePos and (attempt % 5 == 1) then
                tpClassic(leavePos)
                task.wait(0.15)
            end

            pcall(function()
                if hrp then hrp.Anchored = false end
            end)

            triggerPrompt(leavePrompt)
            task.wait(0.3)
        end

        if conn then pcall(function() conn:Disconnect() end) end
        return true
    end

    local function forceUnequipAllTools()
        pcall(function()
            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
            local backpack = LPLR.Backpack
            if char and backpack then
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Tool") then
                        child.Parent = backpack
                    end
                end
            end
        end)
    end

    local function isRobberyLoot(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local nameLower = tool.Name:lower()
        if tool.Name == "Drill" or tool.Name == "Phone" or tool.Name == "Fists" then
            return false
        end
        if nameLower:find("key") then
            return false
        end
        if tool:FindFirstChildOfClass("LocalScript", true) or tool:FindFirstChildOfClass("Script", true) or tool:FindFirstChildOfClass("ModuleScript", true) then
            return false
        end
        local weaponPatterns = {
            "ARPistol", "Draco", "G17", "G22 DB", "G43X Beam", "Tec-9", "Draco Drum", "G19 Clear EXT",
            "Springfield Hellcat"
        }
        for _, pat in ipairs(weaponPatterns) do
            if nameLower:find(pat:lower()) then
                return false
            end
        end
        if nameLower:match("rep") then
            return false
        end
        return true
    end

    local function sellInventory(npcPrompt)
        if not npcPrompt then return end
        local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local toolsToSell = {}
        for _, child in ipairs(LPLR.Backpack:GetChildren()) do
            if isRobberyLoot(child) then
                table.insert(toolsToSell, child)
            end
        end
        for _, child in ipairs(LPLR.Character:GetChildren()) do
            if isRobberyLoot(child) then
                table.insert(toolsToSell, child)
            end
        end

        if #toolsToSell == 0 then return end

        local npcPos = getPromptPosition(npcPrompt) or Vector3.new(-1151, 5, 654)
        tpClassic(npcPos)
        task.wait(0.2)

        for _, tool in ipairs(toolsToSell) do
            if tool.Parent == LPLR.Backpack then
                hum:EquipTool(tool)
                task.wait(0.15)
            end

            triggerPrompt(npcPrompt)
            task.wait(0.15)
        end
    end

    CreateToggle(C_HOUSE_ROB, "House Robbery Farm", false, "HouseRobberyFarmToggle", function(v)
        houseRobActive = v
        if houseRobThread then
            task.cancel(houseRobThread)
            houseRobThread = nil
        end

        if not v then
            cleanupPlate()
            pcall(function()
                local charFolder = workspace:FindFirstChild("Characters")
                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                    workspace:FindFirstChild(LPLR.Name)
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Anchored = false
                        end
                    end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Sit = false end
                end
            end)
            Notify("House Robbery", "Farm disabled. Character released.", 3)
        end

        if houseRobActive then
            houseRobThread = task.spawn(function()
                pcall(function()
                    local charFolder = workspace:FindFirstChild("Characters")
                    local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                        workspace:FindFirstChild(LPLR.Name)
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = false end
                end)

                while houseRobActive do
                    local stepSuccess, err = pcall(function()
                        local availableHouse = nil
                        local housesFolder = safeGet(workspace, { "HouseRobberies", "Houses" })
                        if housesFolder then
                            for _, house in ipairs(housesFolder:GetChildren()) do
                                if not blacklist[house.Name] or (tick() - blacklist[house.Name] > 60) then
                                    local robPrompt = findPrompt(house, "RobPrompt")
                                    local enterPrompt = findPrompt(house, "Enter")
                                    if robPrompt and enterPrompt then
                                        if robPrompt.Enabled and not enterPrompt.Enabled then
                                            availableHouse = house
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        if not availableHouse then
                            cleanupPlate()
                            pcall(function()
                                local charFolder = workspace:FindFirstChild("Characters")
                                local char = charFolder and charFolder:FindFirstChild(LPLR.Name) or LPLR.Character or
                                    workspace:FindFirstChild(LPLR.Name)
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.Anchored = false end
                            end)
                            Notify("House Robbery", "Waiting for available house...", 5)
                            task.wait(5)
                            return
                        end

                        local drill = LPLR.Backpack:FindFirstChild("Drill") or
                            (LPLR.Character and LPLR.Character:FindFirstChild("Drill"))
                        if not drill then
                            Notify("House Robbery", "Drill not found. Purchasing...", 3)
                            local HardwareEvent = game:GetService("ReplicatedStorage").Modules.Packages._Index
                                ["sleitnick_net@0.2.0"].net["RE/Hardware"]
                            if HardwareEvent then
                                HardwareEvent:FireServer("Purchase", { name = "Drill", category = "Tools" })

                                local startWaitDrill = tick()
                                while not drill and (tick() - startWaitDrill < 6) do
                                    drill = LPLR.Backpack:FindFirstChild("Drill") or
                                        (LPLR.Character and LPLR.Character:FindFirstChild("Drill"))
                                    task.wait(0.1)
                                end
                            end
                        end

                        if not drill then
                            Notify("House Robbery", "Error: Failed to obtain Drill!", 4)
                            task.wait(3)
                            return
                        end

                        local enterPrompt = findPrompt(availableHouse, "Enter")
                        local robPrompt = findPrompt(availableHouse, "RobPrompt")
                        if not enterPrompt or not robPrompt then
                            Notify("House Robbery", "Error: House prompts missing!", 4)
                            return
                        end

                        local doorPos = getPromptPosition(enterPrompt) or getPromptPosition(robPrompt)
                        if not doorPos then
                            Notify("House Robbery", "Error: Could not resolve door position!", 4)
                            return
                        end

                        tpClassic(doorPos)
                        task.wait(0.2)

                        local hum = LPLR.Character and LPLR.Character:FindFirstChildOfClass("Humanoid")
                        if drill.Parent == LPLR.Backpack and hum then
                            hum:EquipTool(drill)
                        end
                        task.wait(0.3)

                        local startWaitUnlock = tick()
                        while robPrompt.Enabled and robPrompt.Parent and tick() - startWaitUnlock < 8 do
                            triggerPrompt(robPrompt)
                            task.wait(0.2)
                        end
                        task.wait(0.2)

                        local leavePrompt = nil
                        local startWaitEnter = tick()
                        while tick() - startWaitEnter < 10 do
                            local room = getRoomFolder(availableHouse.Name)
                            leavePrompt = room and findPrompt(room, "Leave")
                            if leavePrompt then break end

                            if enterPrompt.Enabled then
                                triggerPrompt(enterPrompt)
                            end
                            task.wait(0.25)
                        end

                        if not leavePrompt then
                            Notify("House Robbery", "Error: Failed to confirm room entry!", 4)
                            return
                        end

                        pcall(function()
                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = false end
                        end)

                        forceUnequipAllTools()
                        task.wait(0.2)

                        local roomFolder = getRoomFolder(availableHouse.Name)
                        if not roomFolder or not roomFolder:FindFirstChild("Robbable") then
                            Notify("House Robbery", "Error: Room folder or Robbable container not found!", 4)
                            return
                        end

                        local heavyItems = { "TV", "TV2", "Fridge", "Microwave" }

                        -- 1. Grab FIRST heavy item
                        local firstHeavyPrompt = nil
                        for _, itemName in ipairs(heavyItems) do
                            local item = roomFolder.Robbable:FindFirstChild(itemName)
                            local grabPrompt = item and findPrompt(item, "Grab")
                            if grabPrompt and grabPrompt.Enabled then
                                firstHeavyPrompt = grabPrompt
                                break
                            end
                        end

                        if firstHeavyPrompt then
                            forceUnequipAllTools()
                            task.wait(0.05)

                            local grabAttempt = 0
                            while firstHeavyPrompt.Enabled and firstHeavyPrompt.Parent and houseRobActive do
                                grabAttempt = grabAttempt + 1

                                local pos = getPromptPosition(firstHeavyPrompt) or
                                    (firstHeavyPrompt.Parent:IsA("BasePart") and firstHeavyPrompt.Parent.Position or firstHeavyPrompt.Parent:GetPivot().Position)

                                if pos and (grabAttempt % 5 == 1) then
                                    tpClassic(pos)
                                    task.wait(0.1)
                                end

                                pcall(function()
                                    local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                    if hrp then hrp.Anchored = false end
                                end)

                                forceUnequipAllTools()
                                triggerPrompt(firstHeavyPrompt)
                                task.wait(0.15)
                            end

                            forceUnequipAllTools()
                            task.wait(0.05)
                        end

                        -- 2. Grab ALL Light items
                        for _, child in ipairs(roomFolder.Robbable:GetChildren()) do
                            if not houseRobActive then break end
                            if not table.find(heavyItems, child.Name) then
                                local grabPrompt = findPrompt(child, "Grab")
                                if grabPrompt and grabPrompt.Enabled then
                                    forceUnequipAllTools()
                                    task.wait(0.05)

                                    local grabAttempt = 0
                                    while grabPrompt.Enabled and grabPrompt.Parent and houseRobActive do
                                        grabAttempt = grabAttempt + 1

                                        local pos = getPromptPosition(grabPrompt) or
                                            (child:IsA("BasePart") and child.Position or child:GetPivot().Position)

                                        if pos and (grabAttempt % 5 == 1) then
                                            tpClassic(pos)
                                            task.wait(0.1)
                                        end

                                        pcall(function()
                                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                            if hrp then hrp.Anchored = false end
                                        end)

                                        forceUnequipAllTools()
                                        triggerPrompt(grabPrompt)
                                        task.wait(0.15)
                                    end

                                    forceUnequipAllTools()
                                    task.wait(0.05)
                                end
                            end
                        end

                        -- 3. Scan for remaining heavy items
                        local remainingHeavyNames = {}
                        for _, itemName in ipairs(heavyItems) do
                            local item = roomFolder.Robbable:FindFirstChild(itemName)
                            local grabPrompt = item and findPrompt(item, "Grab")
                            if grabPrompt and grabPrompt.Enabled then
                                table.insert(remainingHeavyNames, itemName)
                            end
                        end

                        -- 4. Exit house & Sell first load
                        local exitSuccess = exitHouseBeforeSelling(availableHouse)
                        if not exitSuccess then
                            houseRobActive = false
                            return
                        end

                        tpClassic(Vector3.new(-1151, 5, 654))
                        pcall(function()
                            local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Anchored = false end
                        end)
                        task.wait(0.3)

                        local npc = safeGet(workspace, { "NPC", "Pawn Npc" })
                        local npcPrompt = npc and
                            (findPrompt(npc, "Prompt") or findPrompt(npc, "ProximityPrompt") or npc:FindFirstChildOfClass("ProximityPrompt"))

                        if npcPrompt then
                            local sellAttempts = 0
                            while sellAttempts < 5 and houseRobActive do
                                local hasTools = false
                                for _, child in ipairs(LPLR.Backpack:GetChildren()) do
                                    if isRobberyLoot(child) then
                                        hasTools = true; break
                                    end
                                end
                                if not hasTools then
                                    for _, child in ipairs(LPLR.Character:GetChildren()) do
                                        if isRobberyLoot(child) then
                                            hasTools = true; break
                                        end
                                    end
                                end

                                if not hasTools then break end

                                sellInventory(npcPrompt)
                                sellAttempts = sellAttempts + 1
                                task.wait(0.3)
                            end
                        end

                        -- 5. Return for remaining heavy items
                        for _, heavyName in ipairs(remainingHeavyNames) do
                            if not houseRobActive then break end

                            local enterPrompt = findPrompt(availableHouse, "Enter")
                            if enterPrompt then
                                local doorPos = getPromptPosition(enterPrompt)
                                if doorPos then
                                    tpClassic(doorPos); task.wait(0.2)
                                end

                                local startReEnter = tick()
                                while enterPrompt.Enabled and (tick() - startReEnter < 6) and houseRobActive do
                                    triggerPrompt(enterPrompt)
                                    task.wait(0.3)
                                end

                                local room = getRoomFolder(availableHouse.Name)
                                local leavePrompt = room and findPrompt(room, "Leave")
                                if leavePrompt then
                                    pcall(function()
                                        local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then hrp.Anchored = false end
                                    end)

                                    local freshRoom = getRoomFolder(availableHouse.Name)
                                    local item = freshRoom and freshRoom:FindFirstChild("Robbable") and
                                        freshRoom.Robbable:FindFirstChild(heavyName)
                                    local grabPrompt = item and findPrompt(item, "Grab")

                                    if grabPrompt and grabPrompt.Enabled then
                                        forceUnequipAllTools()
                                        task.wait(0.05)

                                        local grabAttempt = 0
                                        while grabPrompt.Enabled and grabPrompt.Parent and houseRobActive do
                                            grabAttempt = grabAttempt + 1

                                            local pos = getPromptPosition(grabPrompt) or
                                                (item:IsA("BasePart") and item.Position or item:GetPivot().Position)

                                            if pos and (grabAttempt % 5 == 1) then
                                                tpClassic(pos)
                                                task.wait(0.1)
                                            end

                                            pcall(function()
                                                local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                                if hrp then hrp.Anchored = false end
                                            end)

                                            forceUnequipAllTools()
                                            triggerPrompt(grabPrompt)
                                            task.wait(0.15)
                                        end
                                        forceUnequipAllTools()
                                        task.wait(0.05)
                                    end

                                    exitHouseBeforeSelling(availableHouse)

                                    tpClassic(Vector3.new(-1151, 5, 654))
                                    pcall(function()
                                        local char = LPLR.Character or workspace:FindFirstChild(LPLR.Name)
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then hrp.Anchored = false end
                                    end)
                                    task.wait(0.3)

                                    if npcPrompt then
                                        local sellAttempts = 0
                                        while sellAttempts < 5 and houseRobActive do
                                            local hasTools = false
                                            for _, child in ipairs(LPLR.Backpack:GetChildren()) do
                                                if isRobberyLoot(child) then
                                                    hasTools = true; break
                                                end
                                            end
                                            if not hasTools then
                                                for _, child in ipairs(LPLR.Character:GetChildren()) do
                                                    if isRobberyLoot(child) then
                                                        hasTools = true; break
                                                    end
                                                end
                                            end
                                            if not hasTools then break end

                                            sellInventory(npcPrompt)
                                            sellAttempts = sellAttempts + 1
                                            task.wait(0.3)
                                        end
                                    end
                                end
                            end
                        end

                        Notify("House Robbery", "House fully cleared! Finished robbery.", 5)
                        blacklist[availableHouse.Name] = tick()
                        task.wait(1)
                    end)

                    if not stepSuccess then
                        warn("House Robbery Farm error: " .. tostring(err))
                        task.wait(2)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end)
end; buildHouseRobberyFarm()

function buildRapFarm()
    local C_RAP = CreateCard(pfa, "Rap Farm (Auto Rapper)", "right", 6)

    local rapNote = Instance.new("TextLabel")
    rapNote.Size = UDim2.new(1, -10, 0, 0)
    rapNote.AutomaticSize = Enum.AutomaticSize.Y
    rapNote.BackgroundTransparency = 1
    rapNote.Text =
    "📋 INSTRUCTIONS:\n1. Enable this toggle first.\n2. Go to the Studio location.\n3. Start a recording session.\n4. Select a beat (Killa or T-House).\n5. The script will automatically hit every beat with Perfect timing!"
    rapNote.TextColor3 = Color3.fromRGB(170, 170, 190)
    rapNote.Font = Enum.Font.Gotham
    rapNote.TextSize = 11
    rapNote.TextXAlignment = Enum.TextXAlignment.Left
    rapNote.TextYAlignment = Enum.TextYAlignment.Top
    rapNote.TextWrapped = true
    rapNote.Parent = C_RAP

    local rapActive = false
    local rapConn = nil
    local nodeData = {}
    local childAddedConn = nil
    local childRemovedConn = nil

    local KEYS = {
        [1] = Enum.KeyCode.H,
        [2] = Enum.KeyCode.J,
        [3] = Enum.KeyCode.K,
        [4] = Enum.KeyCode.L,
    }

    local function pressKey(idx)
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, KEYS[idx], false, game)
            vim:SendKeyEvent(false, KEYS[idx], false, game)
        end)
    end

    local function getIntersection(node, target)
        local nPos  = node.AbsolutePosition
        local nSize = node.AbsoluteSize
        local tPos  = target.AbsolutePosition
        local tSize = target.AbsoluteSize

        local ix    = math.max(0, math.min(nPos.X + nSize.X, tPos.X + tSize.X) - math.max(nPos.X, tPos.X))
        local iy    = math.max(0, math.min(nPos.Y + nSize.Y, tPos.Y + tSize.Y) - math.max(nPos.Y, tPos.Y))

        return math.min(ix, iy)
    end

    local function getRating(intersect)
        if intersect > 40 then
            return "Perfect"
        elseif intersect > 15 then
            return "Okay"
        elseif intersect > 5 then
            return "Bad"
        else
            return "Miss"
        end
    end

    local function startAutoRap()
        if rapConn then rapConn:Disconnect() end
        nodeData = {}

        local CS = game:GetService("CollectionService")

        rapConn = RS.Heartbeat:Connect(function()
            if not rapActive then return end
            local ui = LPLR.PlayerGui:FindFirstChild("RapUI")
            if not ui then return end
            local Game = ui:FindFirstChild("MainFrame") and ui.MainFrame:FindFirstChild("Game")
            if not Game or not Game.Visible then return end
            local BG     = Game:FindFirstChild("BG")
            local Holder = BG and BG:FindFirstChild("Holder")
            if not BG or not Holder then return end

            for _, node in ipairs(BG:GetChildren()) do
                if node:IsA("ImageLabel") and node.Visible then
                    local okT, tags = pcall(CS.GetTags, CS, node)
                    if okT and tags then
                        local idx = nil
                        for _, tag in ipairs(tags) do
                            local n = tag:match("Node (%d+)")
                            if n then
                                idx = tonumber(n)
                                break
                            end
                        end

                        if idx then
                            local id   = tostring(node)
                            local curY = node.AbsolutePosition.Y

                            if not nodeData[id] then
                                nodeData[id] = { pressed = false, lastY = curY, prevIntersect = 0 }
                            end

                            local data = nodeData[id]

                            if curY < data.lastY - 100 then
                                data.pressed       = false
                                data.prevIntersect = 0
                            end
                            data.lastY = curY

                            if not data.pressed then
                                local target = Holder:FindFirstChild(tostring(idx))
                                if target then
                                    local dist = (node.AbsolutePosition - target.AbsolutePosition).Magnitude
                                    if dist <= 70 then
                                        local intersect = getIntersection(node, target)
                                        local rating    = getRating(intersect)

                                        local peaked    = intersect < data.prevIntersect and
                                            data.prevIntersect > 15

                                        if rating == "Perfect" or peaked then
                                            data.pressed = true
                                            pressKey(idx)
                                        end

                                        data.prevIntersect = intersect
                                    else
                                        data.prevIntersect = 0
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function stopAutoRap()
        if rapConn then
            rapConn:Disconnect()
            rapConn = nil
        end
        nodeData = {}
    end

    CreateToggle(C_RAP, "Auto Rapper (Rap Farm)", false, "AutoRapperToggle", function(v)
        rapActive = v
        if v then
            Notify("Rap Farm", "Rap Farm enabled. Waiting for studio record (RapUI)...", 5)

            if childAddedConn then childAddedConn:Disconnect() end
            if childRemovedConn then childRemovedConn:Disconnect() end

            childAddedConn = LPLR.PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "RapUI" and rapActive then
                    Notify("Rap Farm", "Rap minigame detected! Auto Rapper active.", 4)
                    task.wait(1)
                    startAutoRap()
                end
            end)

            childRemovedConn = LPLR.PlayerGui.ChildRemoved:Connect(function(child)
                if child.Name == "RapUI" then
                    Notify("Rap Farm", "Rap minigame ended.", 3)
                    stopAutoRap()
                end
            end)

            if LPLR.PlayerGui:FindFirstChild("RapUI") then
                Notify("Rap Farm", "Rap minigame detected! Auto Rapper active.", 4)
                startAutoRap()
            end
        else
            stopAutoRap()
            if childAddedConn then
                childAddedConn:Disconnect()
                childAddedConn = nil
            end
            if childRemovedConn then
                childRemovedConn:Disconnect()
                childRemovedConn = nil
            end
            Notify("Rap Farm", "Rap Farm disabled.", 3)
        end
    end)
end; buildRapFarm()

function buildSettingsTab()
    pbyp = CreateTab("Settings", "Utilities and Settings")
    local ccif = CreateCard(pbyp, "Custom Interface")
    local togBg = CreateToggle(ccif, "Enable Custom Image", true, "EnableImage", function(toggled)
        Config.EnableImage = toggled
        bgImg.Visible = toggled
        SaveConfig()
    end)
    togBg.Keybind.Visible = false
    if Config.Toggles and Config.Toggles["EnableImage"] ~= nil then
        bgImg.Visible = Config.Toggles["EnableImage"]
        Config.EnableImage = Config.Toggles["EnableImage"]
    end
    local togBell = CreateToggle(ccif, "Show Updates Bell", true, "ShowUpdatesBell", function(toggled)
        getgenv().ShowUpdatesBell = toggled
        if updatesBell then updatesBell.Visible = toggled end
    end)
    togBell.Keybind.Visible = false
    if Config.Toggles and Config.Toggles["ShowUpdatesBell"] ~= nil then
        getgenv().ShowUpdatesBell = Config.Toggles["ShowUpdatesBell"]
        if updatesBell then updatesBell.Visible = getgenv().ShowUpdatesBell end
    end
    local sldTrans = CreateSlider(ccif, "Interface Transparency", 0, 100, 50, "Transparency", function(val)
        Config.Transparency = val
        bgImg.ImageTransparency = val / 100
        main.BackgroundTransparency = val / 100
        SaveConfig()
    end)
    local preview = Instance.new("ImageLabel")
    preview.Size = UDim2.new(1, 0, 0, 60)
    preview.BackgroundTransparency = 1
    preview.Image = bgImg.Image
    preview.ScaleType = Enum.ScaleType.Crop
    preview.Parent = ccif:FindFirstChild("BBox") or ccif
    local pcn = Instance.new("UICorner")
    pcn.CornerRadius = UDim.new(0, 4)
    pcn.Parent = preview
    local inputImg = CreateInput(ccif, "Image Asset ID", "CustomImage", Config.CustomImage)
    inputImg.Box.FocusLost:Connect(function()
        local inputText = inputImg.Box.Text
        local match = string.match(inputText, "%d+")
        if match then
            local newId = "rbxassetid://" .. match
            inputImg.Box.Text = newId
            bgImg.Image = newId
            preview.Image = newId
            Config.CustomImage = newId
            SaveConfig()
        else
            inputImg.Box.Text = bgImg.Image
        end
    end)
    local cthm = CreateCard(pbyp, "Themes / Fonts")
    CreateDropdown(cthm, "Theme Color", colorOptions, "ThemeColorIdx", 9, function(val)
        SharedThemeColor = val
        ApplyTheme()
    end)
    CreateDropdown(cthm, "Font Style", fontOptions, "FontIdx", 1, function(val)
        SharedThemeFont = val
        ApplyTheme()
    end)
    local cnotif = CreateCard(pbyp, "Notifications")
    local togNotif = CreateToggle(cnotif, "Enable Notifications", true, "NotificationsEnabled", function(v)
        Config.NotificationsEnabled = v
        SaveConfig()
    end)
    togNotif.Keybind.Visible = false
    if Config.Toggles and Config.Toggles["NotificationsEnabled"] ~= nil then
        Config.NotificationsEnabled = Config.Toggles["NotificationsEnabled"]
    end
    local notifPosOptions = {
        { Name = "Bottom Right", Value = "Bottom Right" },
        { Name = "Bottom Left",  Value = "Bottom Left" },
        { Name = "Top Right",    Value = "Top Right" },
        { Name = "Top Left",     Value = "Top Left" }
    }
    local currentPosIdx = 1
    for i, opt in ipairs(notifPosOptions) do
        if opt.Value == Config.NotificationPosition then
            currentPosIdx = i
            break
        end
    end
    CreateDropdown(cnotif, "Notification Position", notifPosOptions, nil, currentPosIdx, function(val)
        Config.NotificationPosition = val
        UpdateNotifPosition(val)
        SaveConfig()
        Notify("Position", "Notifications moved to " .. val, 2)
    end)
    local antiAfkConnection = nil
    CreateToggle(cnotif, "Anti AFK", false, "AntiAfkEnabled", function(v)
        if v then
            if not antiAfkConnection then
                local VirtualUser = game:GetService("VirtualUser")
                antiAfkConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end)
    local cui = CreateCard(pbyp, "UI Controls/Servers")
    local togHideUI = CreateToggle(cui, "Hide UI", false, "HideUIKey", function()
        main.Visible = not main.Visible
    end)
    togHideUI.Toggle.Visible = false
    CreateCardButton(cui, "Rejoin", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LPLR)
    end)
    CreateCardButton(cui, "Serverhop", function()
        local Http = game:GetService("HttpService")
        local TP = game:GetService("TeleportService")
        local res = game:HttpGet("https://games.roblox.com/v1/games/" ..
            game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
        local data = Http:JSONDecode(res).data
        local x = {}
        for _, v in ipairs(data) do
            if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
                x[#x + 1] = v.id
            end
        end
        if #x > 0 then
            TP:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
        else
            Notify("Server Hop", "No servers found!", 3)
        end
    end)
    CreateCardButton(cui, "Low Serverhop", function()
        local Http = game:GetService("HttpService")
        local TP = game:GetService("TeleportService")
        local res = game:HttpGet("https://games.roblox.com/v1/games/" ..
            game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = Http:JSONDecode(res).data
        local servers = {}
        for _, v in ipairs(data) do
            if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v)
            end
        end
        table.sort(servers, function(a, b) return a.playing < b.playing end)
        if #servers > 0 then
            TP:TeleportToPlaceInstance(game.PlaceId, servers[1].id)
        else
            Notify("Server", "No other servers found!", 3)
        end
    end)
end; buildSettingsTab()
ApplyTheme()
if tabs["Main"] then
    tabs["Main"].open()
end
gui.Destroying:Connect(function()
    for _, fn in ipairs(ActiveToggles) do
        pcall(fn, true)
    end
end)
