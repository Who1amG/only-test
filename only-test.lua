-- WH01AM | Silent Aim | Hood Rivals
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CFG = {
    Enabled    = true,
    FOV        = 120,
    TargetPart = "Head",
    ShowFOV    = true,
    FOVColor   = Color3.fromRGB(255, 255, 255),
}

if getgenv().WH01AM_SA_UNLOAD then getgenv().WH01AM_SA_UNLOAD() end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible   = CFG.ShowFOV
FOVCircle.Color     = CFG.FOVColor
FOVCircle.Thickness = 1
FOVCircle.Filled    = false
FOVCircle.NumSides  = 64
FOVCircle.Radius    = CFG.FOV
FOVCircle.Position  = Vector2.new(0, 0)

local Camera         = workspace.CurrentCamera
local cachedTarget   = nil
local doingRaycast   = false
local rawRaycast     = workspace.Raycast
local enemyChars     = {}
local heartbeatConn  = nil

heartbeatConn = RunService.Heartbeat:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    enemyChars = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            enemyChars[plr.Character] = true
        end
    end

    local center = Camera.ViewportSize / 2
    FOVCircle.Position = center
    FOVCircle.Radius   = CFG.FOV
    FOVCircle.Visible  = CFG.Enabled and CFG.ShowFOV

    if not CFG.Enabled then cachedTarget = nil return end

    local bestPart = nil
    local bestDist = CFG.FOV

    for char in pairs(enemyChars) do
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local bone = char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head")
        if not (hum and bone and hum.Health > 0) then continue end
        local ok, screenPos, onScreen = pcall(function()
            return Camera:WorldToViewportPoint(bone.Position)
        end)
        if not ok or not onScreen then continue end
        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist2D >= bestDist then continue end
        bestDist = dist2D
        bestPart = bone
    end

    cachedTarget = bestPart
end)

local oldNC
oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if self == workspace and method == "Raycast" and not doingRaycast then
        if CFG.Enabled then
            local t = cachedTarget
            if t and t.Parent then
                doingRaycast = true

                local char   = LocalPlayer.Character
                local myHRP  = char and char:FindFirstChild("HumanoidRootPart")
                local origin = myHRP and myHRP.Position or Vector3.new(0, 0, 0)
                local dir    = t.Position - origin

                local params = RaycastParams.new()
                params.FilterType                 = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { char }

                local ok, result = pcall(rawRaycast, workspace, origin, dir, params)
                doingRaycast = false

                if ok and result then
                    local hitModel = nil
                    pcall(function()
                        hitModel = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
                    end)
                    if hitModel and enemyChars[hitModel] then
                        return result
                    end
                end
            end
        end
    end

    return oldNC(self, ...)
end))

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        CFG.Enabled = not CFG.Enabled
        warn("[WH01AM] Silent Aim: " .. tostring(CFG.Enabled))
    end
end)

getgenv().WH01AM_SA_CFG    = CFG
getgenv().WH01AM_SA_UNLOAD = function()
    if heartbeatConn then heartbeatConn:Disconnect() end
    FOVCircle:Remove()
    cachedTarget  = nil
    CFG.Enabled   = false
end

warn("[WH01AM] Silent Aim activo — X toggle | Hood Rivals")
