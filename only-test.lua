--// CFrame WalkSpeed - Usa Joystick Nativo de Roblox //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// CONFIGURACIÓN //--
local settings = {
    speed = 100,           -- Tu velocidad CFrame
    enable = true,
    noclip = true,
    fly = false,
    smoothness = 0.3
}

--// VARIABLES //--
local camera = workspace.CurrentCamera
local velocity = Vector3.zero

--// DESACTIVAR MOVIMIENTO NORMAL //--
humanoid.AutoRotate = false  -- Nosotros controlamos la rotación

--// LOOP CFRAME //--
RunService.RenderStepd:Connect(function(dt)
    if not settings.enable or not hrp then return end
    
    -- OBTENER DIRECCIÓN DEL JOYSTICK NATIVO
    local moveDir = humanoid.MoveDirection  -- ← La bolita del jugador!
    
    if moveDir.Magnitude > 0 then
        -- Aplicar velocidad personalizada
        local targetVel = moveDir * settings.speed
        
        -- Suavizado
        velocity = velocity:Lerp(targetVel, settings.smoothness)
        
        -- Calcular nueva posición
        local newPos = hrp.CFrame.Position + velocity * dt
        
        -- Rotar hacia donde mira la cámara
        local lookCF = CFrame.lookAt(newPos, newPos + camera.CFrame.LookVector)
        
        if settings.fly then
            -- Modo volar: mirar hacia arriba/abajo también
            hrp.CFrame = camera.CFrame - camera.CFrame.Position + newPos
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            -- Modo caminar: solo rotación horizontal
            hrp.CFrame = CFrame.new(newPos) * CFrame.Angles(0, lookCF.Rotation.Y, 0)
        end
        
        -- Cancelar velocidad del humanoid (solo usamos la dirección)
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    else
        velocity = velocity:Lerp(Vector3.zero, 0.2)
    end
    
    -- Noclip
    if settings.noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// COMANDOS //--
getgenv().CFrameWalk = {
    SetSpeed = function(s) settings.speed = s end,
    Toggle = function() settings.enable = not settings.enable end,
    SetFly = function(v) settings.fly = v end,
    SetNoclip = function(v) settings.noclip = v end,
    GetSettings = function() return table.clone(settings) end
}

print("✅ CFrame Walk cargado!")
print("Usa el joystick normal de Roblox para moverte")
print("Comandos: CFrameWalk.SetSpeed(100), CFrameWalk.SetFly(true)")
