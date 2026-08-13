-- WH01AM | Auto Rapper | Vice City 2
-- Anti-duplicate + Toggle UI
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CS         = game:GetService("CollectionService")
local vim        = game:GetService("VirtualInputManager")
local UIS        = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Anti-duplicate
if getgenv().WH01AM_RAP_LOADED then
    warn("[WH01AM] Auto Rapper ya está cargado")
    return
end
getgenv().WH01AM_RAP_LOADED = true

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local KEYS = {[1]=Enum.KeyCode.H,[2]=Enum.KeyCode.J,[3]=Enum.KeyCode.K,[4]=Enum.KeyCode.L}

-- En mobile el nodo es más pequeño (35px vs 68px en PC)
-- dist < 30 funciona en PC, mobile necesita proporcional
local DIST_THRESHOLD = isMobile and 15 or 30

local nodeData = {}
local rapConn  = nil
local enabled  = true

-- ══════════════════════════════════════
--  TOGGLE UI
-- ══════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name             = "WH01AM_RAP_UI"
sg.ResetOnSpawn     = false
sg.IgnoreGuiInset   = true
sg.DisplayOrder     = 999
sg.Parent           = game:GetService("CoreGui")

local btn = Instance.new("TextButton")
btn.Size                  = UDim2.new(0, 120, 0, 36)
btn.Position              = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3      = Color3.fromRGB(20, 20, 25)
btn.TextColor3            = Color3.fromRGB(80, 220, 140)
btn.Text                  = "🎤 RAP: ON"
btn.TextSize              = 14
btn.Font                  = Enum.Font.GothamBold
btn.AutoButtonColor       = false
btn.ZIndex                = 999
btn.Parent                = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(80, 220, 140)
stroke.Thickness = 1.5
stroke.Parent    = btn

-- Draggable
local dragging, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = btn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        local dist = dragging and (input.Position - dragStart).Magnitude or 0
        dragging = false
        if dist < 8 then
            enabled = not enabled
            if enabled then
                btn.Text             = "🎤 RAP: ON"
                btn.TextColor3       = Color3.fromRGB(80, 220, 140)
                stroke.Color         = Color3.fromRGB(80, 220, 140)
            else
                btn.Text             = "🎤 RAP: OFF"
                btn.TextColor3       = Color3.fromRGB(220, 80, 80)
                stroke.Color         = Color3.fromRGB(220, 80, 80)
            end
        end
    end
end)

-- ══════════════════════════════════════
--  CORE
-- ══════════════════════════════════════
local function pressKey(idx)
    vim:SendKeyEvent(true,  KEYS[idx], false, game)
    vim:SendKeyEvent(false, KEYS[idx], false, game)
end

local function startAuto()
    if rapConn then rapConn:Disconnect() end
    nodeData = {}

    rapConn = RunService.Heartbeat:Connect(function()
        if not enabled then return end

        local ui = LocalPlayer.PlayerGui:FindFirstChild("RapUI")
        if not ui then return end
        local Game = ui.MainFrame:FindFirstChild("Game")
        if not Game or not Game.Visible then return end
        local BG     = Game:FindFirstChild("BG")
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

            if curY < data.lastY - 100 then
                data.pressed = false
            end
            data.lastY = curY

            if data.pressed then continue end

            local target = Holder:FindFirstChild(tostring(idx))
            if not target then continue end

            local dist = (node.AbsolutePosition - target.AbsolutePosition).Magnitude

            if dist < DIST_THRESHOLD then
                data.pressed = true
                pressKey(idx)
            end
        end
    end)
end

local function stopAuto()
    if rapConn then rapConn:Disconnect() rapConn = nil end
    nodeData = {}
end

-- ══════════════════════════════════════
--  AUTO ACTIVAR CON RapUI
-- ══════════════════════════════════════
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "RapUI" then
        task.wait(1)
        startAuto()
    end
end)
LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "RapUI" then
        stopAuto()
    end
end)

if LocalPlayer.PlayerGui:FindFirstChild("RapUI") then startAuto() end

-- ══════════════════════════════════════
--  UNLOAD
-- ══════════════════════════════════════
getgenv().WH01AM_RAP_START  = startAuto
getgenv().WH01AM_RAP_STOP   = stopAuto
getgenv().WH01AM_RAP_UNLOAD = function()
    stopAuto()
    sg:Destroy()
    getgenv().WH01AM_RAP_LOADED = nil
    warn("[WH01AM] Auto Rapper descargado")
end

warn("[WH01AM] Auto Rapper listo — " .. (isMobile and "Mobile dist<15" or "PC dist<30"))
