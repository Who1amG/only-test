--// CFrame WalkSpeed - PC & Móvil (FIX COMPLETO) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// CONFIG //--
local speed = 100

--// DETECTAR DISPOSITIVO //--
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// DESACTIVAR ROTACIÓN AUTO //--
humanoid.AutoRotate = false

--// VARS //--
local camera = workspace.CurrentCamera
local inputDir = Vector3.zero

--// PC INPUT //--
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then inputDir += Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir += Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir += Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir += Vector3.new(1, 0, 0) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then inputDir -= Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir -= Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir -= Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir -= Vector3.new(1, 0, 0) end
    end)
end

--// MOBILE INPUT (FIX REAL) //--
if isMobile then
    RunService.Heartbeat:Connect(function()
        local move = humanoid.MoveDirection
        if move.Magnitude > 0 then
            inputDir = Vector3.new(move.X, 0, move.Z).Unit
        else
            inputDir = Vector3.zero
        end
    end)
end

--// MOVIMIENTO CFRAME //--
RunService.Heartbeat:Connect(function(dt)
    if not hrp then return end

    local camCF = camera.CFrame

    local look = camCF.LookVector
    local right = camCF.RightVector

    look = Vector3.new(look.X, 0, look.Z).Unit
    right = Vector3.new(right.X, 0, right.Z).Unit

    -- FIX: dirección correcta
    local worldDir = (right * inputDir.X) + (look * inputDir.Z)

    if worldDir.Magnitude <= 0 then return end
    worldDir = worldDir.Unit

    local currentPos = hrp.Position
    local newPos = currentPos + (worldDir * speed * dt)

    -- Raycast suelo
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)

    if result then
        newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
    else
        newPos = Vector3.new(newPos.X, currentPos.Y, newPos.Z)
    end

    -- rotación hacia donde se mueve
    local targetRot = CFrame.lookAt(Vector3.zero, worldDir)
    hrp.CFrame = CFrame.new(newPos) * targetRot

    -- quitar colisiones para evitar trabarse
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end

    -- eliminar velocidad lateral rara
    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
end)

print("✅ CFrame WalkSpeed FIXED")
print("Velocidad:", speed)
print(isMobile and "📱 Móvil OK (joystick arreglado)" or "⌨️ PC OK")
