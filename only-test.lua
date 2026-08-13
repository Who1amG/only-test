-- WH01AM | Auto Rapper | Vice City 2 | Multi-Resolution
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CS         = game:GetService("CollectionService")
local vim        = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local KEYS = {
    [1] = Enum.KeyCode.H,
    [2] = Enum.KeyCode.J,
    [3] = Enum.KeyCode.K,
    [4] = Enum.KeyCode.L,
}

local nodeData = {}
local rapConn  = nil

local function pressKey(idx)
    vim:SendKeyEvent(true,  KEYS[idx], false, game)
    vim:SendKeyEvent(false, KEYS[idx], false, game)
end

local function getIntersection(node, target)
    local nPos  = node.AbsolutePosition
    local nSize = node.AbsoluteSize
    local tPos  = target.AbsolutePosition
    local tSize = target.AbsoluteSize

    local ix = math.max(0, math.min(nPos.X + nSize.X, tPos.X + tSize.X) - math.max(nPos.X, tPos.X))
    local iy = math.max(0, math.min(nPos.Y + nSize.Y, tPos.Y + tSize.Y) - math.max(nPos.Y, tPos.Y))
    return math.min(ix, iy)
end

local function getIntersectionPercent(node, target)
    local intersect = getIntersection(node, target)
    local nodeSize  = math.min(node.AbsoluteSize.X, node.AbsoluteSize.Y)
    if nodeSize <= 0 then return 0 end
    return intersect / nodeSize
end

local function getRating(pct)
    if pct > 0.55 then return "Perfect"
    elseif pct > 0.20 then return "Okay"
    elseif pct > 0.07 then return "Bad"
    else return "Miss" end
end

local function startAuto()
    if rapConn then rapConn:Disconnect() end
    nodeData = {}

    rapConn = RunService.Heartbeat:Connect(function()
        local ui = LocalPlayer.PlayerGui:FindFirstChild("RapUI")
        if not ui then return end
        local Game = ui.MainFrame:FindFirstChild("Game")
        if not Game or not Game.Visible then return end
        local BG     = Game:FindFirstChild("BG")
        local Holder = BG and BG:FindFirstChild("Holder")
        if not BG or not Holder then return end

        for _, node in ipairs(BG:GetChildren()) do
            if not node:IsA("ImageLabel") or not node.Visible then continue end

            local okT, tags = pcall(CS.GetTags, CS, node)
            if not okT then continue end

            local idx = nil
            for _, tag in ipairs(tags) do
                local n = tag:match("Node (%d+)")
                if n then idx = tonumber(n) break end
            end
            if not idx then continue end

            local id   = tostring(node)
            local curY = node.AbsolutePosition.Y

            if not nodeData[id] then
                nodeData[id] = { pressed = false, lastY = curY, prevPct = 0 }
            end

            local data = nodeData[id]

            -- Resetear si reusado
            if curY < data.lastY - 50 then
                data.pressed = false
                data.prevPct = 0
            end
            data.lastY = curY

            if data.pressed then continue end

            local target = Holder:FindFirstChild(tostring(idx))
            if not target then continue end

            local pct    = getIntersectionPercent(node, target)
            local rating = getRating(pct)

            -- Presionar en Perfect O cuando el pct empieza a bajar después de subir
            local peaked = pct < data.prevPct and data.prevPct > 0.20

            if rating == "Perfect" or peaked then
                data.pressed = true
                pressKey(idx)
            end

            data.prevPct = pct
        end
    end)
end

local function stopAuto()
    if rapConn then rapConn:Disconnect() rapConn = nil end
    nodeData = {}
end

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "RapUI" then
        task.wait(1)
        startAuto()
    end
end)
LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "RapUI" then
        stopAuto()
    end
end)

if LocalPlayer.PlayerGui:FindFirstChild("RapUI") then startAuto() end

getgenv().WH01AM_RAP_START = startAuto
getgenv().WH01AM_RAP_STOP  = stopAuto

warn("[WH01AM] Auto Rapper listo — Multi-Resolution")
