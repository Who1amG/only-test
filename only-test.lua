--// CFrame WalkSpeed - PC & Móvil (JOYSTICK ARREGLADO) //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// CONFIGURACIÓN //--
local speed = 100

--// DETECTAR DISPOSITIVO //--
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// SOLO DESACTIVAR ROTACIÓN AUTO //--
humanoid.AutoRotate = false

--// VARIABLES //--
local camera = workspace.CurrentCamera
local inputDir = Vector3.zero

--// PC: TECLAS //--
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then inputDir = inputDir + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir = inputDir + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir = inputDir + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir = inputDir + Vector3.new(1, 0, 0) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then inputDir = inputDir - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then inputDir = inputDir - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then inputDir = inputDir - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then inputDir = inputDir - Vector3.new(1, 0, 0) end
    end)
end

--// MÓVIL: JOYSTICK NATIVO (ARREGLADO) //--
if isMobile then
    RunService.Heartbeat:Connect(function()
        local move = humanoid.MoveDirection
        if move.Magnitude > 0 then
            -- INVERTIR Z para que joystick funcione correctamente
            inputDir = Vector3.new(move.X, 0, -move.Z).Unit
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
    
    local worldDir = (right * inputDir.X) - (look * inputDir.Z)
    
    if worldDir.Magnitude > 0.1 then
        worldDir = worldDir.Unit
        
        local currentPos = hrp.Position
        local newPos = currentPos + (worldDir * speed * dt)
        
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)
        
        if result then
            newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
        else
            newPos = Vector3.new(newPos.X, currentPos.Y, newPos.Z)
        end
        
        local targetRot = CFrame.lookAt(Vector3.zero, worldDir)
        hrp.CFrame = CFrame.new(newPos) * targetRot
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
    end
end)

print("✅ CFrame WalkSpeed - Joystick móvil arreglado!")
print("Velocidad:", speed)
print(isMobile and "📱 Modo Móvil activo" or "⌨️ Modo PC activo")
