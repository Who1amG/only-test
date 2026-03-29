--// CFrame WalkSpeed FINAL FIX REAL (igual que fly feeling) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local speed = 100

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

humanoid.AutoRotate = false

local camera = workspace.CurrentCamera
local inputDir = Vector3.zero

-- PC INPUT
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

RunService.Heartbeat:Connect(function(dt)
    if not hrp then return end

    local moveDir

    local camCF = camera.CFrame
    local look = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

    if look.Magnitude > 0 then look = look.Unit end
    if right.Magnitude > 0 then right = right.Unit end

    if isMobile then
        local move = humanoid.MoveDirection
        if move.Magnitude > 0 then
            -- 🔥 MISMO SISTEMA PARA TODO
            moveDir = (right * move.X) + (look * move.Z)
        end
    else
        if inputDir.Magnitude > 0 then
            moveDir = (right * inputDir.X) + (look * inputDir.Z)
        end
    end

    if not moveDir or moveDir.Magnitude <= 0 then return end
    moveDir = moveDir.Unit

    local newPos = hrp.Position + (moveDir * speed * dt)

    -- suelo
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -25, 0), rayParams)

    if result then
        newPos = Vector3.new(newPos.X, result.Position.Y + 3, newPos.Z)
    end

    hrp.CFrame = CFrame.new(newPos, newPos + moveDir)

    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
end)

print("✅ FINAL FIX: ahora sí sigue la cámara REAL")
