if game.PlaceId ~= 130700367963690 and game.GameId ~= 130700367963690 then
    game:GetService("Players").LocalPlayer:Kick("BRU Are u dum? This is For Philly only bro...")
    return
end -- tha lil bro 

if not getgenv().AntiCheatBypassExecuted then
    getgenv().AntiCheatBypassExecuted = true
    pcall(function()
        loadstring(game:HttpGet(
            "https://gist.githubusercontent.com/Wh01am001/b1096ae2280a45f52a7310f6ae8df69f/raw/e7ff2b7bec35701a7ea280aadb1b3c6cb6455b61/Anti.lua"))()
    end) --anti cheat bypass
end

-- WH01AM | Silent Aim | Philly | Mobile FIXED v7
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local RS            = game:GetService("ReplicatedStorage")
local UIS           = game:GetService("UserInputService")
local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local CFG = {
    Enabled         = true,
    FOV             = isMobile and 350 or 120,
    WallCheck       = true,
    FriendCheck     = true,
    MaxDistance     = 1000,
    ShowFOV         = true,
    FOVColor        = Color3.fromRGB(255, 255, 255),
    TargetPart      = "Head",
}

local firearmRemote = RS:FindFirstChild("firearmFunction")

-- ══════════════════════════════════════
--  FRIENDLY CHECK
-- ══════════════════════════════════════
local IsPlayerFriendly = nil
pcall(function()
    local result = filtergc("function", {Name = "IsPlayerFriendly"}, true)
    if type(result) == "function" then IsPlayerFriendly = result end
end)

local friendCache = {}
local function isFriend(plr)
    if not CFG.FriendCheck then return false end
    if friendCache[plr.UserId] ~= nil then return friendCache[plr.UserId] end
    local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
    local val = ok and result or false
    friendCache[plr.UserId] = val
    return val
end

local function isEnemy(plr)
    if IsPlayerFriendly then
        local ok, friendly = pcall(IsPlayerFriendly, plr)
        if ok and friendly then return false end
    end
    if isFriend(plr) then return false end
    return true
end

-- ══════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "WH01AM_SA"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
sg.Parent = game:GetService("CoreGui")

local FOVCircle, uiFOV

if isMobile then
    uiFOV = Instance.new("Frame")
    uiFOV.AnchorPoint = Vector2.new(0.5, 0.5)
    uiFOV.BackgroundTransparency = 1
    uiFOV.Visible = false
    uiFOV.ZIndex = 500
    uiFOV.Parent = sg
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = uiFOV
    local stroke = Instance.new("UIStroke")
    stroke.Color = CFG.FOVColor
    stroke.Thickness = 1.5
    stroke.Parent = uiFOV
else
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible   = false
    FOVCircle.Color     = CFG.FOVColor
    FOVCircle.Thickness = 1
    FOVCircle.Filled    = false
    FOVCircle.NumSides  = 64
    FOVCircle.Radius    = CFG.FOV
    FOVCircle.Position  = Camera.ViewportSize / 2
end

local function updateFOVCircle()
    local show   = CFG.Enabled and CFG.ShowFOV
    local center = Camera.ViewportSize / 2
    if isMobile and uiFOV then
        uiFOV.Visible = show
        if show then
            uiFOV.Position = UDim2.new(0, center.X, 0, center.Y)
            uiFOV.Size = UDim2.new(0, CFG.FOV * 2, 0, CFG.FOV * 2)
        end
    elseif FOVCircle then
        FOVCircle.Visible  = show
        FOVCircle.Position = center
        FOVCircle.Radius   = CFG.FOV
    end
end

-- ══════════════════════════════════════
--  VISIBILITY CHECK
-- ══════════════════════════════════════
local function isVisible(targetPart)
    if not CFG.WallCheck then return true end
    local localChar = LocalPlayer.Character
    local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localHRP then return true end
    local params = RaycastParams.new()
    params.FilterType                 = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { localChar }
    params.IgnoreWater                = true
    local result = workspace:Raycast(localHRP.Position, targetPart.Position - localHRP.Position, params)
    if not result then return true end
    local hitChar = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
    return hitChar ~= nil and Players:GetPlayerFromCharacter(hitChar) ~= nil
end

-- ══════════════════════════════════════
--  TARGET SELECTION
-- ══════════════════════════════════════
local function getReferencePoint()
    if isMobile then return Camera.ViewportSize / 2 end
    local mp = UIS:GetMouseLocation()
    return Vector2.new(mp.X, mp.Y)
end

local function getBestTarget()
    if not CFG.Enabled then return nil end
    local ref      = getReferencePoint()
    local bestDist = CFG.FOV
    local bestPart = nil
    local camPos   = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not isEnemy(plr) then continue end
        local char = plr.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local bone = char and (char:FindFirstChild(CFG.TargetPart) or char:FindFirstChild("Head"))
        if not (hum and bone and hum.Health > 0) then continue end
        if (camPos - bone.Position).Magnitude > CFG.MaxDistance then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(bone.Position)
        if not onScreen then continue end
        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - ref).Magnitude
        if dist2D >= bestDist then continue end
        if not isVisible(bone) then continue end
        bestDist = dist2D
        bestPart = bone
    end
    return bestPart
end

-- ══════════════════════════════════════
--  TARGET CACHE
-- ══════════════════════════════════════
local cachedTarget = nil

RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    cachedTarget = getBestTarget()
end)

-- ══════════════════════════════════════
--  MOBILE: pre-calcular RaycastResult
--  al momento del disparo usando un raycast
--  real hacia el target — guardado en cache
--  para que el hook lo devuelva sin recursión
-- ══════════════════════════════════════
local cachedRaycastResult = nil
local isDoingTargetRaycast = false

local function computeTargetRaycast(t)
    if isDoingTargetRaycast then return nil end
    isDoingTargetRaycast = true

    local localChar = LocalPlayer.Character
    local localHead = localChar and localChar:FindFirstChild("Head")
    local origin    = localHead and localHead.Position or Camera.CFrame.Position
    local dir       = t.Position - origin

    local params = RaycastParams.new()
    params.FilterType                 = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { localChar }

    local result = workspace:Raycast(origin, dir, params)
    isDoingTargetRaycast = false

    if result then
        local hitModel = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and Players:GetPlayerFromCharacter(hitModel) then
            return result
        end
    end
    return nil
end

-- Cuando el usuario dispara en mobile, pre-calcular el resultado
-- escuchando el TouchStarted en el botón de disparo
local isShootingFrame = false

if isMobile then
    local plrGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    local mobileGui = plrGui and plrGui:FindFirstChild("MobileGUI")
    local shootBtn = mobileGui and mobileGui:FindFirstChild("shoot")

    if shootBtn then
        shootBtn.InputBegan:Connect(function()
            isShootingFrame = true
            local t = cachedTarget
            if t and t.Parent then
                cachedRaycastResult = computeTargetRaycast(t)
            end
        end)
        shootBtn.InputEnded:Connect(function()
            isShootingFrame = false
            cachedRaycastResult = nil
        end)
        warn("[WH01AM] shoot button encontrado — hook mobile activo")
    else
        warn("[WH01AM] shoot button NO encontrado — intenta después de equipar arma")
    end
end

-- ══════════════════════════════════════
--  HOOK __namecall
-- ══════════════════════════════════════
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if not checkcaller() then
        -- MOBILE: workspace:Raycast — devolver resultado pre-calculado
        -- solo cuando estamos disparando y sin recursión
        if isMobile and self == workspace and method == "Raycast" and not isDoingTargetRaycast then
            if CFG.Enabled and isShootingFrame and cachedRaycastResult then
                return cachedRaycastResult
            end
        end

        -- PC: firearmFunction
        if firearmRemote and self == firearmRemote and (method == "FireServer" or method == "InvokeServer") then
            if CFG.Enabled then
                local t = cachedTarget
                if t and t.Parent then
                    local args = { ... }
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = t.Position
                            break
                        end
                        if typeof(v) == "CFrame" then
                            args[i] = CFrame.new(t.Position)
                            break
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end))

-- ══════════════════════════════════════
--  HOOK __index — PC Mouse.Hit
-- ══════════════════════════════════════
local Mouse = LocalPlayer:GetMouse()
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if not isMobile and self == Mouse and key == "Hit" then
            if CFG.Enabled then
                local t = cachedTarget
                if t and t.Parent then
                    return CFrame.new(t.Position)
                end
            end
        end
    end
    return oldIndex(self, key)
end))

-- ══════════════════════════════════════
--  UNLOAD
-- ══════════════════════════════════════
getgenv().WH01AM_SA_UNLOAD = function()
    if FOVCircle then FOVCircle:Remove() end
    if sg then sg:Destroy() end
    cachedTarget = nil
    CFG.Enabled = false
end

warn("[WH01AM] Silent Aim listo — " .. (isMobile and "Mobile" or "PC"))
