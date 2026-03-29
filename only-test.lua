--// CFly basado en tu método original (SIN TOOL) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera

local speed = 80
local flying = false
local connection
local pos

-- activar fly
local function START_CFLY()
    if flying then return end
    flying = true

    pos = root.Position
    humanoid.PlatformStand = true

    connection = RunService.Heartbeat:Connect(function()
        local cf = cam.CFrame.Rotation

        -- 🔥 MÉTODO ORIGINAL (EL BUENO)
        local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * speed)

        local direction
        if dir.Magnitude == 0 then
            direction = Vector3.zero
        else
            direction = cf:VectorToWorldSpace(
                Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude
            )
        end

        pos = pos + direction

        root.CFrame = CFrame.new(
            pos,
            cam.CFrame.Position + (pos - cam.CFrame.Position) * 2
        )

        -- eliminar física
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- noclip
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

-- desactivar fly
local function STOP_CFLY()
    flying = false
    humanoid.PlatformStand = false

    if connection then
        connection:Disconnect()
        connection = nil
    end
end

-- AUTO START (puedes cambiarlo si quieres toggle)
START_CFLY()

print("✅ CFly activo (tu método original, FIXED)")
