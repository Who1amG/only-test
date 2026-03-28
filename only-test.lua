--// CFrame WalkSpeed - PC & Mobile (FINAL FIX REAL) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- CONFIG
local speed = 100

-- detectar dispositivo
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- desactivar rotación automática
humanoid.AutoRotate = false

local camera = workspace.CurrentCamera
local inputDir = Vector3.zero

-- PC INPUT
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then inputDir += Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir += Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir += Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir += Vector3.new(1, 0, 0) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then inputDir -= Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir -= Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir -= Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir -= Vector3.new(1, 0, 0) end
    end)
end

-- MOVIMIENTO
RunService.Heartbeat:Connect(function(dt)
    if not hrp then return end

    local moveDir

    if isMobile then
        -- FIX REAL (sin errores)
        local move = humanoid.MoveDirection

        if move.Magnitude > 0 then
            moveDir = camera.CFrame:VectorToWorldSpace(move)
            moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
        end
    else
        local camCF = camera.CFrame
        local look = camCF.LookVector
        local right = camCF.RightVector

        look = Vector3.new(look.X, 0, look.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit

        moveDir = (right * inputDir.X) - (look * inputDir.Z)

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
    end

    if not moveDir or moveDir.Magnitude <= 0 then return end

    local newPos = hrp.Position + (moveDir * speed * dt)

    -- raycast suelo
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)

    if result then
        newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
    end

    -- rotación hacia movimiento
    local rot = CFrame.lookAt(Vector3.zero, moveDir)
    hrp.CFrame = CFrame.new(newPos) * rot

    -- estabilidad
    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)

    -- noclip suave
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
end)

print("✅ FIX FINAL: móvil ahora sigue la cámara perfecto")
print(isMobile and "📱 Mobile OK" or "⌨️ PC OK")
