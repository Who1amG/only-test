--// CFrame Speed (Fly Method Applied) //--

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

--// MOVIMIENTO (USANDO MÉTODO DE FLY) //--
RunService.Heartbeat:Connect(function(dt)
    if not hrp then return end

    local camCF = camera.CFrame
    local look = camCF.LookVector
    local right = camCF.RightVector

    -- plano horizontal
    look = Vector3.new(look.X, 0, look.Z).Unit
    right = Vector3.new(right.X, 0, right.Z).Unit

    local moveDir = Vector3.zero

    if isMobile then
        -- 🔥 MISMO MÉTODO QUE TU FLY
        local joyDir = humanoid.MoveDirection
        
        if joyDir.Magnitude > 0 then
            moveDir = (right * joyDir.X) + (look * joyDir.Z)
        end
    else
        moveDir = (right * inputDir.X) + (look * inputDir.Z)
    end

    if moveDir.Magnitude <= 0 then return end
    moveDir = moveDir.Unit

    local newPos = hrp.Position + (moveDir * speed * dt)

    -- suelo
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

    -- no fricción
    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)

    -- noclip
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
end)

print("✅ Speed FIX usando método de Fly (mobile perfecto)")
