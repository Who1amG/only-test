-- VEHICLE BYPASS V2 FIX MOBILE
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local bypassing = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 110)
main.Position = UDim2.new(1, -300, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Transparency = 0.5
stroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🚗 VEHICLE BYPASS V3"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "OFF"
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local methodLabel = Instance.new("TextLabel")
methodLabel.Size = UDim2.new(1, -20, 0, 16)
methodLabel.Position = UDim2.new(0, 10, 0, 65)
methodLabel.BackgroundTransparency = 1
methodLabel.Text = ""
methodLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
methodLabel.Font = Enum.Font.Gotham
methodLabel.TextSize = 11
methodLabel.TextXAlignment = Enum.TextXAlignment.Left
methodLabel.Parent = main

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 35)
btn.Position = UDim2.new(1, -130, 0, 68)
btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
btn.Text = "ACTIVAR"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.BorderSizePixel = 0
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local btnStroke = Instance.new("UIStroke", btn)
btnStroke.Color = Color3.fromRGB(255, 100, 100)
btnStroke.Transparency = 0.5
btnStroke.Thickness = 1.5

local function getCharacter()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function isVehicleSeat(seat)
    if not seat then
        return false
    end
    if not (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
        return false
    end
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder and seat:IsDescendantOf(vehiclesFolder) then
        return true
    end
    return false
end

local function forceSit(seat)
    local char = getCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or not seat then
        return
    end

    pcall(function()
        seat.Disabled = false
    end)

    if firetouchinterest then
        methodLabel.Text = "🔥 Método: TouchInterest"
        pcall(function()
            firetouchinterest(hrp, seat, 0)
            task.wait(0.05)
            firetouchinterest(hrp, seat, 1)
        end)
        task.wait(0.1)
    end

    if hum.SeatPart ~= seat then
        methodLabel.Text = "📍 Método: Teleport+Sit"
        pcall(function()
            hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.05)
            hum.Sit = true
            seat:Sit(hum)
        end)
        task.wait(0.1)
    end

    if hum.SeatPart ~= seat then
        methodLabel.Text = "🔩 Método: SeatWeld"
        pcall(function()
            local weld = Instance.new("Weld")
            weld.Name = "TempSeatWeld"
            weld.Part0 = seat
            weld.Part1 = hrp
            weld.C0 = CFrame.new(0, 0.5, 0)
            weld.Parent = seat
            hum.Sit = true
            seat:Sit(hum)
            task.delay(1, function()
                if weld and weld.Parent then
                    weld:Destroy()
                end
            end)
        end)
        task.wait(0.1)
    end

    if hum.SeatPart == seat then
        status.Text = "✅ Entrado al vehículo"
        status.TextColor3 = Color3.fromRGB(100, 255, 120)
        methodLabel.Text = "✅ Dentro del vehículo"
    else
        status.Text = "❌ Bypass falló"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        methodLabel.Text = ""
    end
end

local seatedConn
local function connectHumanoid(hum)
    if seatedConn then
        seatedConn:Disconnect()
        seatedConn = nil
    end

    seatedConn = hum.Seated:Connect(function(isSeated, seat)
        print("Seated:", isSeated, "seat:", seat and seat.Name or "nil")

        if not bypassing then
            return
        end
        if not isSeated then
            return
        end
        if not seat then
            return
        end
        if not isVehicleSeat(seat) then
            return
        end

        status.Text = "🔄 Seated detectado..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        methodLabel.Text = ""

        task.spawn(function()
            forceSit(seat)
        end)
    end)

    hum.StateChanged:Connect(function(oldState, newState)
        print("StateChanged:", oldState, "->", newState)
    end)
end

if lp.Character then
    local hum = getHumanoid()
    if hum then
        connectHumanoid(hum)
    end
end

lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        connectHumanoid(hum)
    end
end)

local function findClosestSeat()
    local hrp = getHRP()
    if not hrp then
        return nil
    end

    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then
        return nil
    end

    local closestSeat = nil
    local closestDist = 15

    for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
        for _, obj in ipairs(vehicle:GetDescendants()) do
            if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestSeat = obj
                end
            end
        end
    end

    return closestSeat
end

-- PC
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not bypassing then
        return
    end
    if input.KeyCode ~= Enum.KeyCode.E then
        return
    end

    local closestSeat = findClosestSeat()
    if not closestSeat then
        return
    end

    status.Text = "🔄 E detectado - bypassing..."
    status.TextColor3 = Color3.fromRGB(255, 200, 50)
    methodLabel.Text = ""

    task.spawn(function()
        forceSit(closestSeat)
    end)
end)

-- MOBILE / PROMPT HOLD
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, playerWhoTriggered)
    if not bypassing then
        return
    end
    if playerWhoTriggered and playerWhoTriggered ~= lp then
        return
    end

    local parent = prompt and prompt.Parent
    if parent and isVehicleSeat(parent) then
        status.Text = "📱 Hold detectado..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        methodLabel.Text = "⏳ Prompt hold began"

        task.spawn(function()
            forceSit(parent)
        end)
        return
    end

    local closestSeat = findClosestSeat()
    if closestSeat then
        status.Text = "📱 Hold detectado..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        methodLabel.Text = "⏳ Prompt hold began"

        task.spawn(function()
            forceSit(closestSeat)
        end)
    end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
    if not bypassing then
        return
    end
    if playerWhoTriggered and playerWhoTriggered ~= lp then
        return
    end

    local parent = prompt and prompt.Parent
    if parent and isVehicleSeat(parent) then
        status.Text = "📱 Prompt triggered..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        methodLabel.Text = "✅ Prompt triggered"

        task.spawn(function()
            forceSit(parent)
        end)
        return
    end

    local closestSeat = findClosestSeat()
    if closestSeat then
        status.Text = "📱 Prompt triggered..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        methodLabel.Text = "✅ Prompt triggered"

        task.spawn(function()
            forceSit(closestSeat)
        end)
    end
end)

-- Toggle
btn.MouseButton1Click:Connect(function()
    bypassing = not bypassing

    if bypassing then
        btn.Text = "DESACTIVAR"
        btn.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
        btnStroke.Color = Color3.fromRGB(100, 255, 120)
        status.Text = "ON - PC:E / Mobile:Hold"
        status.TextColor3 = Color3.fromRGB(100, 255, 120)
        methodLabel.Text = ""
    else
        btn.Text = "ACTIVAR"
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        btnStroke.Color = Color3.fromRGB(255, 100, 100)
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        methodLabel.Text = ""
    end
end)

-- Drag PC + Mobile
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
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

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            updateDrag(input)
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end
end)

print("✅ Vehicle Bypass V2 FIX cargado!")
print("💡 PC: presiona E | Móvil: haz hold al prompt del carro")
