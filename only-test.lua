-- VEHICLE BYPASS ULTRA AGRESIVO
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

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
title.Text = "🚗 VEHICLE BYPASS V2"
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

-- Función de bypass sobre un asiento específico
local function forceSit(seat)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    pcall(function() seat.Disabled = false end)

    -- MÉTODO 1: firetouchinterest
    if firetouchinterest then
        methodLabel.Text = "🔥 Método: TouchInterest"
        pcall(function()
            firetouchinterest(hrp, seat, 0)
            task.wait(0.05)
            firetouchinterest(hrp, seat, 1)
        end)
        task.wait(0.1)
    end

    -- MÉTODO 2: Teleport + Sit
    if hum.SeatPart ~= seat then
        methodLabel.Text = "📍 Método: Teleport+Sit"
        pcall(function()
            hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.05)
            hum.Sit = true
        end)
        task.wait(0.1)
    end

    -- MÉTODO 3: SeatWeld manual
    if hum.SeatPart ~= seat then
        methodLabel.Text = "🔩 Método: SeatWeld"
        pcall(function()
            local weld = Instance.new("Weld")
            weld.Part0 = seat
            weld.Part1 = hrp
            weld.C0 = CFrame.new(0, 0.5, 0)
            weld.Parent = seat
            hum.Sit = true
            seat:Sit(hum)
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

-- Conectar prompt de un VehicleSeat
local connectedPrompts = {}

local function connectSeat(seat)
    local prompt = seat:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then return end
    if connectedPrompts[prompt] then return end
    connectedPrompts[prompt] = true

    prompt.InputHoldBegan:Connect(function()
        if not bypassing then return end

        status.Text = "⏳ Hold iniciado..."
        status.TextColor3 = Color3.fromRGB(255, 200, 50)

        task.wait(prompt.HoldDuration + 0.05)

        if not bypassing then return end

        status.Text = "🔄 Ejecutando bypass..."
        methodLabel.Text = ""

        task.spawn(function()
            forceSit(seat)
        end)
    end)
end

-- Conectar todos los VehicleSeats existentes
local function scanVehicles()
    for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
        for _, obj in pairs(vehicle:GetDescendants()) do
            if obj:IsA("VehicleSeat") then
                connectSeat(obj)
            end
        end
    end
end

scanVehicles()

-- Conectar carros que spawnen despues
workspace.Vehicles.ChildAdded:Connect(function(vehicle)
    task.wait(0.5) -- esperar a que el modelo cargue completo
    for _, obj in pairs(vehicle:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            connectSeat(obj)
        end
    end
    vehicle.DescendantAdded:Connect(function(obj)
        if obj:IsA("VehicleSeat") then
            connectSeat(obj)
        end
    end)
end)

-- Trigger PC: detectar E cerca de un vehículo
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not bypassing then return end
    if input.KeyCode ~= Enum.KeyCode.E then return end

    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    local closestSeat = nil
    local closestDist = 15

    for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
        for _, obj in pairs(vehicle:GetDescendants()) do
            if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestSeat = obj
                end
            end
        end
    end

    if not closestSeat then return end

    status.Text = "🔄 E detectado - bypassing..."
    status.TextColor3 = Color3.fromRGB(255, 200, 50)
    methodLabel.Text = ""

    task.spawn(function()
        forceSit(closestSeat)
    end)
end)

-- Toggle
btn.MouseButton1Click:Connect(function()
    bypassing = not bypassing

    if bypassing then
        btn.Text = "DESACTIVAR"
        btn.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
        btnStroke.Color = Color3.fromRGB(100, 255, 120)
        status.Text = "ON - Haz hold al prompt"
        status.TextColor3 = Color3.fromRGB(100, 255, 120)
        methodLabel.Text = ""
        scanVehicles() -- re-escanear al activar
    else
        btn.Text = "ACTIVAR"
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        btnStroke.Color = Color3.fromRGB(255, 100, 100)
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        methodLabel.Text = ""
    end
end)

-- Draggable
local dragging = false
local dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("✅ Vehicle Bypass V2 cargado!")
print("💡 PC: presiona E | Móvil: haz hold al prompt del carro")
