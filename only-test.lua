--// CFrame WalkSpeed - PC & Móvil (CORREGIDO) //--
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

--// SOLO DESACTIVAR ROTACIÓN AUTO, NO FÍSICA //--
humanoid.AutoRotate = false
-- NO usar PlatformStand = true (eso causa caída)

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

--// MÓVIL: JOYSTICK NATIVO //--
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

--// MOVIMIENTO CFRAME CON GRAVEDAD //--
RunService.Heartbeat:Connect(function(dt)
    if not hrp then return end
    
    local camCF = camera.CFrame
    local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
    
    -- Convertir input a dirección mundo
    local worldDir = (right * inputDir.X) + (look * inputDir.Z)
    
    if worldDir.Magnitude > 0 then
        worldDir = worldDir.Unit
        
        -- MOVER EN X Y Z, PERO MANTENER Y (altura) CON RAYCAST
        local currentPos = hrp.Position
        local newPos = currentPos + (worldDir * speed * dt)
        
        -- RAYCAST HACIA ABAJO PARA ENCONTRAR SUELO
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)
        
        if result then
            -- Hay suelo, mantener altura sobre él
            newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
        else
            -- No hay suelo, mantener altura actual
            newPos = Vector3.new(newPos.X, currentPos.Y, newPos.Z)
        end
        
        -- Aplicar CFrame
        local targetRot = CFrame.lookAt(Vector3.zero, worldDir)
        hrp.CFrame = CFrame.new(newPos) * targetRot
        
        -- Noclip solo para paredes, no para suelo
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        
        -- Resetear velocidad para evitar acumulación
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
    end
end)

print("✅ CFrame WalkSpeed corregido!")
print("Velocidad:", speed)
print(isMobile and "📱 Modo Móvil" or "⌨️ Modo PC")
