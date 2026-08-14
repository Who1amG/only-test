local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CS         = game:GetService("CollectionService")
local vim        = game:GetService("VirtualInputManager")
local UIS        = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if getgenv().WH01AM_RAP_UNLOAD then getgenv().WH01AM_RAP_UNLOAD() end

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local KEYS = {[1]=Enum.KeyCode.H,[2]=Enum.KeyCode.J,[3]=Enum.KeyCode.K,[4]=Enum.KeyCode.L}
local nodeData = {}
local rapConn  = nil
local polling  = true
local enabled  = true

local CFG = {
    dist    = isMobile and 23 or 30,
    polling = 0.005, -- solo mobile
}

-- ══════════════════════════════════════
--  UI
-- ══════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "WH01AM_RAP_UI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = game:GetService("CoreGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, isMobile and 160 or 110)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.ZIndex = 999
frame.Parent = sg

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(80, 220, 140)
frameStroke.Thickness = 1.5

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎤 WH01AM RAPPER"
title.TextColor3 = Color3.fromRGB(80, 220, 140)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.ZIndex = 1000
title.Parent = frame

-- Toggle btn
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -16, 0, 26)
toggleBtn.Position = UDim2.new(0, 8, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 220, 140)
toggleBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
toggleBtn.Text = "ON"
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 1000
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(80,220,140) or Color3.fromRGB(220,80,80)
    toggleBtn.TextColor3 = enabled and Color3.fromRGB(10,10,15) or Color3.fromRGB(255,255,255)
end)

-- Slider factory
local function makeSlider(label, yPos, minVal, maxVal, currentVal, decimals, onChange)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1000
    lbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 8)
    track.Position = UDim2.new(0, 8, 0, yPos + 18)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    track.BorderSizePixel = 0
    track.ZIndex = 1000
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 220, 140)
    fill.BorderSizePixel = 0
    fill.ZIndex = 1001
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 1002
    thumb.Parent = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local function updateVal(inputPos)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local pct = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
        local val = minVal + (maxVal - minVal) * pct
        local rounded = math.floor(val * (10^decimals) + 0.5) / (10^decimals)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        lbl.Text = label .. ": " .. tostring(rounded)
        onChange(rounded)
    end

    lbl.Text = label .. ": " .. tostring(currentVal)

    local sliding = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateVal(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateVal(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Sliders
makeSlider("Dist", 62, 5, 60, CFG.dist, 1, function(v)
    CFG.dist = v
end)

if isMobile then
    makeSlider("Poll(s)", 100, 0.001, 0.05, CFG.polling, 3, function(v)
        CFG.polling = v
    end)
end

-- Draggable frame
local dragFrame = false
local dragFrameStart, dragFramePos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragFrame = true
        dragFrameStart = input.Position
        dragFramePos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragFrame and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragFrameStart
        frame.Position = UDim2.new(
            dragFramePos.X.Scale, dragFramePos.X.Offset + delta.X,
            dragFramePos.Y.Scale, dragFramePos.Y.Offset + delta.Y
        )
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragFrame = false
    end
end)

-- ══════════════════════════════════════
--  CORE
-- ══════════════════════════════════════
local function pressKey(idx)
    vim:SendKeyEvent(true, KEYS[idx], false, game)
    vim:SendKeyEvent(false, KEYS[idx], false, game)
end

local function checkNodes()
    local ui = LocalPlayer.PlayerGui:FindFirstChild("RapUI")
    if not ui then return end
    local Game = ui.MainFrame:FindFirstChild("Game")
    if not Game or not Game.Visible then return end
    local BG = Game:FindFirstChild("BG")
    local Holder = BG and BG:FindFirstChild("Holder")
    if not BG or not Holder then return end

    for _, node in ipairs(BG:GetChildren()) do
        if not node:IsA("ImageLabel") or not node.Visible then continue end
        local okT, tags = pcall(CS.GetTags, CS, node)
        if not okT then continue end
        local idx = nil
        for _, tag in ipairs(tags) do
            local n = tag:match("Node (%d+)")
            if n then idx = tonumber(n) break end
        end
        if not idx then continue end

        local id   = tostring(node)
        local curY = node.AbsolutePosition.Y

        if not nodeData[id] then
            nodeData[id] = { pressed = false, lastY = curY }
        end
        local data = nodeData[id]
        if curY < data.lastY - 100 then data.pressed = false end
        data.lastY = curY
        if data.pressed then continue end

        local target = Holder:FindFirstChild(tostring(idx))
        if not target then continue end

        local dist = (node.AbsolutePosition - target.AbsolutePosition).Magnitude
        if dist < CFG.dist then
            data.pressed = true
            pressKey(idx)
        end
    end
end

local function startAuto()
    if rapConn then pcall(function() rapConn:Disconnect() end) end
    nodeData = {}
    polling = true

    if isMobile then
        task.spawn(function()
            while polling do
                task.wait(CFG.polling)
                if enabled then checkNodes() end
            end
        end)
        rapConn = { Disconnect = function() polling = false end }
    else
        rapConn = RunService.Heartbeat:Connect(function()
            if enabled then checkNodes() end
        end)
    end
end

local function stopAuto()
    polling = false
    if rapConn then pcall(function() rapConn:Disconnect() end) end
    rapConn = nil
    nodeData = {}
end

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "RapUI" then task.wait(1) startAuto() end
end)
LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "RapUI" then stopAuto() end
end)

if LocalPlayer.PlayerGui:FindFirstChild("RapUI") then startAuto() end

getgenv().WH01AM_RAP_START = startAuto
getgenv().WH01AM_RAP_STOP = stopAuto
getgenv().WH01AM_RAP_UNLOAD = function()
    stopAuto()
    sg:Destroy()
    warn("[WH01AM] Auto Rapper descargado")
end

warn("[WH01AM] Auto Rapper Sliders — " .. (isMobile and "Mobile" or "PC"))
