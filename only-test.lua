if game.PlaceId ~= 130700367963690 and game.GameId ~= 130700367963690 then
    game:GetService("Players").LocalPlayer:Kick("BRU Are u dum? This is For Philly only bro...")
    return
end

if not getgenv().AntiCheatBypassExecuted then
    getgenv().AntiCheatBypassExecuted = true
    pcall(function()
        loadstring(game:HttpGet(
            "https://gist.githubusercontent.com/Wh01am001/b1096ae2280a45f52a7310f6ae8df69f/raw/e7ff2b7bec35701a7ea280aadb1b3c6cb6455b61/Anti.lua"))()
    end) --anti cheat bypass
end

(function()
    local cg = game:GetService("CoreGui")
    local uis = game:GetService("UserInputService")
    local ts = game:GetService("TweenService")
    local rs = game:GetService("RunService")
    local hs = game:GetService("HttpService")
    local plrs = game:GetService("Players")
    local lp = plrs.LocalPlayer
    local cam = workspace.CurrentCamera
    local lgt = game:GetService("Lighting")
    local cas = game:GetService("ContextActionService")

    if cg:FindFirstChild("UIX") then
        cg.UIX:Destroy()
    end

    local fN = "UIX"
    local fC = "UIX/Config.json"
    local fAssets = "UIX/assets"
    local hideBx, panicBx

    local cfg = {
        t = "Black",
        f = "Gotham",
        bId = "",
        bOn = false,
        bOp = 35,
        tOn = false,
        tOp = 100,
        cCOn = false,
        cCT = { 0, 0, 0.94 },
        cCA = { 0.956, 0.477, 0.69 },
        hideBind = "RightShift",
        panicBind = "RightControl",
        espBind = "",
        notifEnabled = true,
        notifPos = "Bottom Right",
        notifSound = "Ding",
        unlockMouse = false,
        houseRobCooldownEnd = 0,
        houseRobJobId = "",
        silentAimBind = "",
        aimbotBind = ""
    }

    if not isfolder(fN) then
        makefolder(fN)
    end
    if not isfolder(fAssets) then
        makefolder(fAssets)
    end

    if isfile(fC) then
        local s, d = pcall(function()
            return hs:JSONDecode(readfile(fC))
        end)
        if s and type(d) == "table" then
            for k, v in pairs(d) do
                cfg[k] = v
            end
        end
    end

    local sTck = 0
    local function sCF()
        sTck = sTck + 1
        local cTck = sTck
        task.delay(0.1, function()
            if sTck == cTck then
                pcall(function()
                    writefile(fC, hs:JSONEncode(cfg))
                end)
            end
        end)
    end

    if cfg.houseRobCooldownEnd == nil then cfg.houseRobCooldownEnd = 0 end
    if cfg.houseRobJobId == nil then cfg.houseRobJobId = "" end

    -- Resetear cooldown si se cambió de servidor (JobId diferente)
    if cfg.houseRobJobId ~= "" and cfg.houseRobJobId ~= game.JobId then
        cfg.houseRobCooldownEnd = 0
        cfg.houseRobJobId = game.JobId
        sCF()
    end
    if cfg.notifEnabled == nil then cfg.notifEnabled = true end
    if cfg.notifPos == nil then cfg.notifPos = "Bottom Right" end
    if cfg.notifSound == nil then cfg.notifSound = "Ding" end
    if cfg.unlockMouse == nil then cfg.unlockMouse = false end

    local fnts = {
        ["Gotham"] = Enum.Font.GothamMedium,
        ["SciFi"] = Enum.Font.SciFi,
        ["Code"] = Enum.Font.Code,
        ["Arcade"] = Enum.Font.Arcade,
        ["Mono"] = Enum.Font.RobotoMono,
        ["Sans"] = Enum.Font.SourceSans,
        ["Serif"] = Enum.Font.Garamond
    }

    local fntsRev = {}
    for k, v in pairs(fnts) do fntsRev[v] = k end

    local thms = {
        ["Black"] = { m = Color3.fromRGB(15, 15, 17), s = Color3.fromRGB(11, 11, 13), c = Color3.fromRGB(20, 20, 23), k = Color3.fromRGB(45, 45, 52), t = Color3.fromRGB(240, 240, 240), st = Color3.fromRGB(140, 140, 145) },
        ["Blue"] = { m = Color3.fromRGB(15, 20, 30), s = Color3.fromRGB(10, 15, 25), c = Color3.fromRGB(20, 25, 35), k = Color3.fromRGB(45, 55, 70), t = Color3.fromRGB(240, 245, 255), st = Color3.fromRGB(150, 160, 180) },
        ["White"] = { m = Color3.fromRGB(245, 245, 245), s = Color3.fromRGB(235, 235, 235), c = Color3.fromRGB(255, 255, 255), k = Color3.fromRGB(200, 200, 200), t = Color3.fromRGB(30, 30, 30), st = Color3.fromRGB(100, 100, 100) },
        ["Brown (Cake)"] = { m = Color3.fromRGB(40, 30, 25), s = Color3.fromRGB(30, 20, 15), c = Color3.fromRGB(50, 40, 35), k = Color3.fromRGB(80, 70, 60), t = Color3.fromRGB(250, 240, 230), st = Color3.fromRGB(180, 160, 150) }
    }

    local activeThm = thms[cfg.t] or thms["Black"]
    local activeFnt = fnts[cfg.f] or Enum.Font.GothamMedium

    local tm = {
        m = activeThm.m,
        s = activeThm.s,
        c = activeThm.c,
        k = activeThm.k,
        a = Color3.fromRGB(176, 92, 114),
        t = activeThm.t,
        st = activeThm.st,
        f = activeFnt
    }

    local function getAccentColor()
        if cfg.cCOn and cfg.cCA then
            return Color3.fromHSV(cfg.cCA[1], cfg.cCA[2], cfg.cCA[3])
        end
        return tm.a or Color3.fromRGB(176, 92, 114)
    end

    local allT = {}
    local allB = {}
    local allD = {}
    local allToggleResets = {}

    local function cleanupAllActiveFeatures()
        for _, tog in ipairs(allToggleResets) do
            pcall(function()
                if tog and tog.Set then
                    tog.Set(false, true)
                end
            end)
        end

        getgenv().YIX_InfEn = false
        getgenv().YIX_InfHg = false
        getgenv().YIX_GunMods_NoRecoil = false
        getgenv().YIX_GunMods_NoSpread = false
        getgenv().YIX_GunMods_NoJam = false
        getgenv().YIX_GunMods_AutoFire = false
        getgenv().YIX_InfFistStam = false
        getgenv().YIX_NoHeavyCD = false
        getgenv().YIX_InfBlock = false
        getgenv().YIX_AntiStun = false
        getgenv().YIX_AutoStomp = false
        getgenv().YIX_SpectateActive = false
        getgenv().YIX_ESPActive = false
        getgenv().YIX_CarAutoFlip = false
        getgenv().YIX_CarSpeedBoost = false
        getgenv().YIX_CarSuperBrake = false
        getgenv().YIX_CarInfGas = false
        getgenv().YIX_CarGodmode = false
        getgenv().YIX_CarFlyOn = false

        if Config then
            Config.Enabled = false
            Config.Wallbang = false
        end

        pcall(function()
            if getgenv().YIX_CleanupVisuals then
                getgenv().YIX_CleanupVisuals()
            end
        end)

        pcall(function()
            local cam = workspace.CurrentCamera
            local char = lp.Character
            if cam and char and char:FindFirstChildOfClass("Humanoid") then
                cam.CameraSubject = char:FindFirstChildOfClass("Humanoid")
            end
        end)

        pcall(function()
            local char = lp.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end)
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "UIX"
    sg.Parent = cg
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 2147483647
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global

    -- Global Notification Container & System
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "YIX_NotifContainer"
    notifContainer.Size = UDim2.new(0, 300, 1, -40)
    notifContainer.BackgroundTransparency = 1
    notifContainer.BorderSizePixel = 0
    notifContainer.ZIndex = 10000
    notifContainer.Parent = sg

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Parent = notifContainer

    local function updateNotifPos(posName)
        posName = posName or cfg.notifPos or "Bottom Right"
        if posName == "Top Right" then
            notifContainer.Position = UDim2.new(1, -20, 0, 20)
            notifContainer.AnchorPoint = Vector2.new(1, 0)
            notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        elseif posName == "Top Left" then
            notifContainer.Position = UDim2.new(0, 20, 0, 20)
            notifContainer.AnchorPoint = Vector2.new(0, 0)
            notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        elseif posName == "Bottom Left" then
            notifContainer.Position = UDim2.new(0, 20, 1, -20)
            notifContainer.AnchorPoint = Vector2.new(0, 1)
            notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        else -- Bottom Right
            notifContainer.Position = UDim2.new(1, -20, 1, -20)
            notifContainer.AnchorPoint = Vector2.new(1, 1)
            notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        end
    end
    updateNotifPos(cfg.notifPos)

    local soundUrls = {
        ["Ding"] = { url = "https://cdn.pixabay.com/audio/2026/03/02/audio_0ff77f8b5d.mp3", file = "ding.mp3" },
        ["Pop"]  = { url = "https://cdn.pixabay.com/audio/2026/03/01/audio_4182fd0ce7.mp3", file = "pop.mp3" }
    }

    local loadedAssetCache = {}

    local function isValidMp3(data)
        if type(data) ~= "string" or #data < 4 then return false end
        local header = data:sub(1, 3)
        local b1, b2 = data:byte(1), data:byte(2)
        return header == "ID3" or (b1 == 0xFF and (b2 == 0xFB or b2 == 0xF3 or b2 == 0xF2))
    end

    local function getOrDownloadSoundAsset(sndName)
        local info = soundUrls[sndName]
        if not info then return nil end

        if loadedAssetCache[sndName] then
            return loadedAssetCache[sndName]
        end

        local filePath = fAssets .. "/" .. info.file

        if isfile and isfile(filePath) then
            local getAsset = getcustomasset or getsynasset
            if getAsset then
                local ok, assetId = pcall(function() return getAsset(filePath) end)
                if ok and assetId then
                    loadedAssetCache[sndName] = assetId
                    return assetId
                end
            end
        end

        local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or
            request
        if not reqFunc then return nil end

        local success, response = pcall(function()
            return reqFunc({
                Url = info.url,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                    ["Referer"] = "https://pixabay.com/"
                }
            })
        end)

        if success and response and response.StatusCode == 200 and response.Body then
            if isValidMp3(response.Body) then
                if writefile then
                    writefile(filePath, response.Body)
                end
                local getAsset = getcustomasset or getsynasset
                if getAsset then
                    local ok, assetId = pcall(function() return getAsset(filePath) end)
                    if ok and assetId then
                        loadedAssetCache[sndName] = assetId
                        return assetId
                    end
                end
            end
        end

        return nil
    end

    local function playNotifSound(sndName)
        sndName = sndName or cfg.notifSound or "Ding"
        if sndName == "None" or not soundUrls[sndName] then return end

        task.spawn(function()
            local assetId = getOrDownloadSoundAsset(sndName)
            if assetId then
                pcall(function()
                    local sound = Instance.new("Sound")
                    sound.SoundId = assetId
                    sound.Volume = 1
                    sound.Parent = game:GetService("SoundService")
                    sound:Play()
                    sound.Ended:Connect(function()
                        sound:Destroy()
                    end)
                    task.delay(3, function()
                        if sound and sound.Parent then
                            sound:Destroy()
                        end
                    end)
                end)
            end
        end)
    end

    task.spawn(function()
        for name, _ in pairs(soundUrls) do
            getOrDownloadSoundAsset(name)
        end
    end)

    local function Notify(title, text, duration, nType)
        if cfg.notifEnabled == false then return end

        duration = duration or 3.5
        playNotifSound(cfg.notifSound)

        local isLeft = (cfg.notifPos == "Top Left" or cfg.notifPos == "Bottom Left")
        local animOffset = isLeft and -60 or 60

        local notifCard = Instance.new("CanvasGroup")
        notifCard.Name = "NotifCard"
        notifCard.Size = UDim2.new(0, 270, 0, 58)
        notifCard.Position = UDim2.new(0, animOffset, 0, 0)
        notifCard.GroupTransparency = 1
        notifCard.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        notifCard.BorderSizePixel = 0
        notifCard.ZIndex = 10001
        notifCard.Parent = notifContainer

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = notifCard

        local accentColor = tm.a or Color3.fromRGB(247, 95, 142)
        if nType == "Success" then
            accentColor = Color3.fromRGB(80, 220, 140)
        elseif nType == "Warning" then
            accentColor = Color3.fromRGB(250, 180, 50)
        elseif nType == "Error" then
            accentColor = Color3.fromRGB(240, 70, 80)
        end

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(38, 38, 46)
        cardStroke.Thickness = 1.2
        cardStroke.Parent = notifCard

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -24, 0, 18)
        titleLbl.Position = UDim2.new(0, 12, 0, 7)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title or "Notification"
        titleLbl.TextColor3 = tm.t or Color3.fromRGB(255, 255, 255)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        titleLbl.ZIndex = 10002
        titleLbl.Parent = notifCard

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -24, 0, 22)
        msgLbl.Position = UDim2.new(0, 12, 0, 25)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = text or ""
        msgLbl.TextColor3 = tm.st or Color3.fromRGB(170, 170, 180)
        msgLbl.Font = tm.f or Enum.Font.Gotham
        msgLbl.TextSize = 11
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextYAlignment = Enum.TextYAlignment.Top
        msgLbl.TextWrapped = true
        msgLbl.ZIndex = 10002
        msgLbl.Parent = notifCard

        -- Inset Progress bar at bottom
        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(1, -24, 0, 3)
        progressBg.Position = UDim2.new(0, 12, 1, -7)
        progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        progressBg.BorderSizePixel = 0
        progressBg.ZIndex = 10002
        progressBg.Parent = notifCard

        local pBgCorner = Instance.new("UICorner")
        pBgCorner.CornerRadius = UDim.new(1, 0)
        pBgCorner.Parent = progressBg

        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 1, 0)
        progressBar.BackgroundColor3 = accentColor
        progressBar.BorderSizePixel = 0
        progressBar.ZIndex = 10003
        progressBar.Parent = progressBg

        local pBarCorner = Instance.new("UICorner")
        pBarCorner.CornerRadius = UDim.new(1, 0)
        pBarCorner.Parent = progressBar

        -- Smooth Entrance animation (Slide in + Fade in)
        ts:Create(notifCard, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            GroupTransparency = 0
        }):Play()

        -- Progress bar countdown animation
        ts:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

        task.spawn(function()
            task.wait(duration)
            -- Smooth Exit animation (Slide out + Fade out)
            local exitTween = ts:Create(notifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0, animOffset, 0, 0),
                GroupTransparency = 1
            })
            exitTween:Play()
            exitTween.Completed:Connect(function()
                notifCard:Destroy()
            end)
        end)
    end
    getgenv().YIX_Notify = Notify

    local isMobile = (uis.TouchEnabled and not uis.KeyboardEnabled) or (uis.TouchEnabled and not uis.MouseEnabled)

    local mf = Instance.new("Frame")
    if isMobile then
        mf.Size = UDim2.new(0, 550, 0, 340)
        mf.Position = UDim2.new(0.5, -275, 0.5, -170)
    else
        mf.Size = UDim2.new(0, 780, 0, 480)
        mf.Position = UDim2.new(0.5, -390, 0.5, -240)
    end
    mf.BackgroundColor3 = tm.m
    mf.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
    mf.BorderSizePixel = 0
    mf.Parent = sg

    -- Mobile Floating UI Toggle/Hide Button
    local mbHideBtn = Instance.new("Frame")
    mbHideBtn.Name = "YIX_MobileHideButton"
    mbHideBtn.Size = UDim2.new(0, 42, 0, 42)
    mbHideBtn.Position = UDim2.new(0, 20, 0.5, -21)
    mbHideBtn.BackgroundColor3 = tm.m
    mbHideBtn.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
    mbHideBtn.ZIndex = 2000
    mbHideBtn.Visible = isMobile and (cfg.mbHideBtnOn ~= false)
    mbHideBtn.Parent = sg
    table.insert(allB, { mbHideBtn, "m" })

    local mbHideCorner = Instance.new("UICorner")
    mbHideCorner.CornerRadius = UDim.new(0, 8)
    mbHideCorner.Parent = mbHideBtn

    local mbHideStroke = Instance.new("UIStroke")
    mbHideStroke.Color = tm.k
    mbHideStroke.Thickness = 1.5
    mbHideStroke.Parent = mbHideBtn
    table.insert(allB, { mbHideStroke, "k" })

    local mbHideImg = Instance.new("ImageLabel")
    mbHideImg.Size = UDim2.new(0, 24, 0, 24)
    mbHideImg.Position = UDim2.new(0.5, -12, 0.5, -12)
    mbHideImg.BackgroundTransparency = 1
    mbHideImg.Image = "rbxassetid://106698881108844"
    mbHideImg.ImageColor3 = tm.t
    mbHideImg.ScaleType = Enum.ScaleType.Fit
    mbHideImg.ZIndex = 2001
    mbHideImg.Parent = mbHideBtn
    table.insert(allT, { mbHideImg, "t", true })

    do
        local dragging = false
        local dragInput, dragStart, startPos
        local dragStartVector = Vector3.new(0, 0, 0)

        mbHideBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                dragStartVector = input.Position
                startPos = mbHideBtn.Position
            end
        end)

        mbHideBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        uis.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mbHideBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        uis.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                dragging = false
                local dist = (input.Position - dragStartVector).Magnitude
                if dist < 6 then
                    mf.Visible = not mf.Visible
                end
            end
        end)
    end

    local function updateMouseLockState()
        local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
        if not isMobile then
            if cfg.unlockMouse and mf.Visible then
                uis.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow
                uis.MouseBehavior = Enum.MouseBehavior.Default
                cas:BindActionAtPriority("YIX_UnlockMouseFreezeCam", function()
                    return Enum.ContextActionResult.Sink
                end, false, 3000, Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton2)
            else
                uis.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
                cas:UnbindAction("YIX_UnlockMouseFreezeCam")
            end
        end
    end

    mf:GetPropertyChangedSignal("Visible"):Connect(updateMouseLockState)
    sg.Destroying:Connect(function()
        cas:UnbindAction("YIX_UnlockMouseFreezeCam")
        uis.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
    end)

    local mbg = Instance.new("ImageLabel")
    mbg.Size = UDim2.new(1, 0, 1, 0)
    mbg.BackgroundTransparency = 1
    mbg.ImageTransparency = cfg.bOn and (1 - (cfg.bOp / 100)) or 1
    if cfg.bId ~= "" then
        mbg.Image = "rbxassetid://" .. cfg.bId
    end
    mbg.ScaleType = Enum.ScaleType.Crop
    mbg.ZIndex = 1
    mbg.Parent = mf

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 6)
    mc.Parent = mf
    local mcr = Instance.new("UICorner")
    mcr.CornerRadius = UDim.new(0, 6)
    mcr.Parent = mbg

    local ms = Instance.new("UIStroke")
    ms.Color = Color3.fromRGB(50, 50, 60)
    ms.Thickness = 1
    ms.Parent = mf
    table.insert(allB, { ms, "k" })
    table.insert(allB, { mf, "m" })

    local scl = Instance.new("UIScale")
    scl.Scale = 0

    scl.Parent = mf

    local rh = Instance.new("ImageButton")
    rh.Size = UDim2.new(0, 16, 0, 16)
    rh.Position = UDim2.new(1, -16, 1, -16)
    rh.BackgroundTransparency = 1
    rh.Image = "rbxassetid://118135399624399"
    rh.ImageColor3 = tm.st
    rh.ZIndex = 50
    rh.Parent = mf
    table.insert(allT, { rh, "st", true })

    local rsz = false
    local rsStart, stSz
    local mS = Vector2.new(550, 340)

    rh.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            rsz = true
            rsStart = uis:GetMouseLocation() -- FIX: Usar GetMouseLocation en vez de i.Position para evitar el salto de 36px del GuiInset
            stSz = mf.AbsoluteSize
        end
    end)
    rh.MouseEnter:Connect(function() ts:Create(rh, TweenInfo.new(0.2), { ImageColor3 = tm.t }):Play() end)
    rh.MouseLeave:Connect(function() ts:Create(rh, TweenInfo.new(0.2), { ImageColor3 = tm.st }):Play() end)

    local isM = false
    local svS = mf.Size
    local svP = mf.Position

    -- ══════════════════ DRAG SYSTEM (UiDeloader Style) ══════════════════
    local function MakeDraggable(gui)
        local dragging, dragInput, dragStart, startPos

        local function isInteractive(inputPos)
            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("GuiButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame")) and obj.Visible then
                    local pos = obj.AbsolutePosition
                    local size = obj.AbsoluteSize
                    if inputPos.X >= pos.X and inputPos.X <= pos.X + size.X and inputPos.Y >= pos.Y and inputPos.Y <= pos.Y + size.Y then
                        return true
                    end
                end
            end
            return false
        end

        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if rsz or isM then return end
                if isInteractive(input.Position) then return end

                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        uis.InputChanged:Connect(function(input)
            if input == dragInput and dragging and not rsz and not isM then
                local delta = input.Position - dragStart
                local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y)
                ts:Create(gui, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { Position = targetPos })
                    :Play()
            end
        end)
    end

    MakeDraggable(mf)

    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            rsz = false
        end
    end)

    rs.RenderStepped:Connect(function()
        if rsz and not isM and rsStart and stSz then
            local mouseLoc = uis:GetMouseLocation()
            if mouseLoc and rsStart and rsStart.X and rsStart.Y then
                local deltaX = mouseLoc.X - rsStart.X
                local deltaY = mouseLoc.Y - rsStart.Y
                local minX = (mS and typeof(mS) == "Vector2" and mS.X) or 550
                local minY = (mS and typeof(mS) == "Vector2" and mS.Y) or 340
                local curX = (stSz and typeof(stSz) == "Vector2" and stSz.X) or 550
                local curY = (stSz and typeof(stSz) == "Vector2" and stSz.Y) or 340

                local nW = math.max(minX, curX + deltaX)
                local nH = math.max(minY, curY + deltaY)
                mf.Size = UDim2.new(0, nW, 0, nH)
            end
        end
    end)

    local cb = Instance.new("ImageButton")
    cb.Size = UDim2.new(0, 20, 0, 20)
    cb.Position = UDim2.new(1, -30, 0, 10)
    cb.BackgroundTransparency = 1
    cb.Image = "rbxassetid://116542333255880"
    cb.ImageColor3 = tm.st
    cb.ScaleType = Enum.ScaleType.Fit
    cb.ZIndex = 10
    cb.Parent = mf
    table.insert(allT, { cb, "st", true })

    cb.MouseButton1Click:Connect(function()
        cleanupAllActiveFeatures()
        local cI = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local cT = ts:Create(scl, cI, { Scale = 0 })
        cT:Play()
        cT.Completed:Wait()
        sg:Destroy()
    end)

    sg.Destroying:Connect(function()
        cleanupAllActiveFeatures()
    end)
    cb.MouseEnter:Connect(function()
        ts:Create(cb, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(255, 80, 80) })
            :Play()
    end)
    cb.MouseLeave:Connect(function() ts:Create(cb, TweenInfo.new(0.2), { ImageColor3 = tm.st }):Play() end)

    local mb = Instance.new("ImageButton")
    mb.Size = UDim2.new(0, 34, 0, 34)
    mb.Position = UDim2.new(1, -72, 0, 3)
    mb.BackgroundTransparency = 1
    mb.Image = "rbxassetid://81507977296060"
    mb.ImageColor3 = tm.st
    mb.ScaleType = Enum.ScaleType.Fit
    mb.ZIndex = 10
    mb.Parent = mf
    table.insert(allT, { mb, "st", true })

    mb.MouseButton1Click:Connect(function()
        if not isM then
            svS = mf.Size
            svP = mf.Position
            isM = true
            rh.Visible = false
            ts:Create(mc, TweenInfo.new(0.3), { CornerRadius = UDim.new(0, 0) }):Play()
            ts:Create(mcr, TweenInfo.new(0.3), { CornerRadius = UDim.new(0, 0) }):Play()
            ts:Create(mf, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }):Play()
        else
            isM = false
            rh.Visible = true
            ts:Create(mc, TweenInfo.new(0.3), { CornerRadius = UDim.new(0, 6) }):Play()
            ts:Create(mcr, TweenInfo.new(0.3), { CornerRadius = UDim.new(0, 6) }):Play()
            ts:Create(mf, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Size = svS, Position = svP })
                :Play()
        end
    end)
    mb.MouseEnter:Connect(function() ts:Create(mb, TweenInfo.new(0.2), { ImageColor3 = tm.t }):Play() end)
    mb.MouseLeave:Connect(function() ts:Create(mb, TweenInfo.new(0.2), { ImageColor3 = tm.st }):Play() end)

    local sb = Instance.new("Frame")
    sb.Size = UDim2.new(0, 180, 1, 0)
    sb.BackgroundColor3 = tm.s
    sb.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
    sb.BorderSizePixel = 0
    sb.ZIndex = 2
    sb.Parent = mf
    table.insert(allB, { sb, "s" })

    local sbc = Instance.new("UICorner")
    sbc.CornerRadius = UDim.new(0, 6)
    sbc.Parent = sb

    local lg = Instance.new("ImageLabel")
    lg.Size = UDim2.new(0, 140, 0, 45)
    lg.Position = UDim2.new(0.5, -70, 0, 18)
    lg.BackgroundTransparency = 1
    lg.Image = "rbxassetid://129607634200191"
    lg.ScaleType = Enum.ScaleType.Fit
    lg.ZIndex = 3
    lg.Parent = sb

    local tc = Instance.new("Frame")
    tc.Size = UDim2.new(1, -20, 1, -90)
    tc.Position = UDim2.new(0, 10, 0, 75)
    tc.BackgroundTransparency = 1
    tc.ZIndex = 3
    tc.Parent = sb

    local tcl = Instance.new("UIListLayout")
    tcl.SortOrder = Enum.SortOrder.LayoutOrder
    tcl.Padding = UDim.new(0, 6)
    tcl.Parent = tc

    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1, -200, 1, -16)
    ca.Position = UDim2.new(0, 192, 0, 8)
    ca.BackgroundTransparency = 1
    ca.ZIndex = 3
    ca.Parent = mf

    local function updT()
        local customT = cfg.cCOn and Color3.fromHSV(cfg.cCT[1], cfg.cCT[2], cfg.cCT[3]) or activeThm.t
        local customA = cfg.cCOn and Color3.fromHSV(cfg.cCA[1], cfg.cCA[2], cfg.cCA[3]) or Color3.fromRGB(176, 92, 114)
        tm.t = customT
        tm.a = customA

        for _, item in pairs(allT) do
            local obj, key, isImg = item[1], item[2], item[3]
            if obj and obj.Parent then
                if isImg then
                    obj.ImageColor3 = tm[key]
                else
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                        obj.TextColor3 = tm[key]
                        obj.Font = tm.f
                    end
                end
            end
        end
        for _, item in pairs(allB) do
            local obj, key = item[1], item[2]
            if obj and obj.Parent then
                if obj:IsA("UIStroke") then
                    obj.Color = tm[key]
                elseif obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                    obj.BackgroundColor3 = tm[key]
                    if obj == mf or obj == sb then
                        obj.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
                    end
                end
            end
        end
        for _, func in ipairs(allD) do
            func()
        end
    end

    local function cMT(n, iId, iF)
        local tb = Instance.new("TextButton")
        tb.Size = UDim2.new(1, 0, 0, 36)
        tb.BackgroundColor3 = tm.c
        tb.BackgroundTransparency = iF and 0 or 1
        tb.Text = ""
        tb.AutoButtonColor = false
        tb.ZIndex = 4
        tb.Parent = tc
        table.insert(allB, { tb, "c" })

        local tbc = Instance.new("UICorner")
        tbc.CornerRadius = UDim.new(0, 4)
        tbc.Parent = tb

        local ti = Instance.new("ImageLabel")
        ti.Size = UDim2.new(0, 16, 0, 16)
        ti.Position = UDim2.new(0, 12, 0.5, -8)
        ti.BackgroundTransparency = 1
        ti.Image = "rbxassetid://" .. iId
        ti.ImageColor3 = iF and tm.a or tm.st
        ti.ZIndex = 4
        ti.Parent = tb

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -40, 1, 0)
        tl.Position = UDim2.new(0, 38, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = n
        tl.TextColor3 = iF and tm.a or tm.st
        tl.Font = tm.f
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.ZIndex = 4
        tl.Parent = tb

        table.insert(allT, { tl, "st", false })
        table.insert(allT, { ti, "st", true })

        local pg = Instance.new("Frame")
        pg.Size = UDim2.new(1, 0, 1, 0)
        pg.BackgroundTransparency = 1
        pg.Visible = iF
        pg.ZIndex = 4
        pg.Parent = ca

        tb.MouseButton1Click:Connect(function()
            for _, c in ipairs(tc:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundTransparency = 1
                    local lbl = c:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.TextColor3 = tm.st end
                    local ic = c:FindFirstChildOfClass("ImageLabel")
                    if ic then ic.ImageColor3 = tm.st end
                end
            end
            for _, c in ipairs(ca:GetChildren()) do
                if c:IsA("Frame") then c.Visible = false end
            end
            tb.BackgroundTransparency = 0
            tl.TextColor3 = tm.a
            ti.ImageColor3 = tm.a
            pg.Visible = true
        end)

        table.insert(allD, function()
            local ac = pg.Visible
            tl.TextColor3 = ac and tm.a or tm.st
            ti.ImageColor3 = ac and tm.a or tm.st
        end)

        return pg
    end

    local function cSM(pP, sL)
        local stc = Instance.new("Frame")
        stc.Size = UDim2.new(1, -100, 0, 30)
        stc.Position = UDim2.new(0, 0, 0, 5)
        stc.BackgroundTransparency = 1
        stc.ClipsDescendants = true
        stc.ZIndex = 5
        stc.Parent = pP

        local sl = Instance.new("UIListLayout")
        sl.FillDirection = Enum.FillDirection.Horizontal
        sl.SortOrder = Enum.SortOrder.LayoutOrder
        sl.Padding = UDim.new(0, 8)
        sl.Parent = stc

        local scp = Instance.new("Frame")
        scp.Size = UDim2.new(1, 0, 1, -42)
        scp.Position = UDim2.new(0, 0, 0, 40)
        scp.BackgroundTransparency = 1
        scp.ZIndex = 5
        scp.Parent = pP

        local fst = true
        local pgs = {}

        for _, sN in ipairs(sL) do
            local sB = Instance.new("TextButton")
            sB.Size = UDim2.new(0, 80, 0, 26)
            sB.BackgroundColor3 = tm.c
            sB.BackgroundTransparency = fst and 0 or 1
            sB.Text = sN
            sB.TextColor3 = fst and tm.t or tm.st
            sB.Font = tm.f
            sB.TextSize = 12
            sB.ZIndex = 6
            sB.Parent = stc
            table.insert(allT, { sB, "st", false })
            table.insert(allB, { sB, "c" })

            local sbc = Instance.new("UICorner")
            sbc.CornerRadius = UDim.new(0, 4)
            sbc.Parent = sB

            local sP = Instance.new("ScrollingFrame")
            sP.Size = UDim2.new(1, 0, 1, 0)
            sP.BackgroundTransparency = 1
            sP.BorderSizePixel = 0
            sP.ScrollBarThickness = 3
            sP.ScrollBarImageColor3 = tm.st
            sP.CanvasSize = UDim2.new(0, 0, 0, 0)
            sP.AutomaticCanvasSize = Enum.AutomaticSize.Y
            sP.Visible = fst
            sP.ZIndex = 6
            sP.Parent = scp

            local lC = Instance.new("Frame")
            lC.Size = UDim2.new(0.5, -6, 0, 0)
            lC.AutomaticSize = Enum.AutomaticSize.Y
            lC.Position = UDim2.new(0, 0, 0, 0)
            lC.BackgroundTransparency = 1
            lC.ZIndex = 7
            lC.Parent = sP

            local lp = Instance.new("UIPadding")
            lp.PaddingLeft = UDim.new(0, 4)
            lp.PaddingRight = UDim.new(0, 6)
            lp.PaddingTop = UDim.new(0, 4)
            lp.PaddingBottom = UDim.new(0, 20)
            lp.Parent = lC

            local ll = Instance.new("UIListLayout")
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            ll.Padding = UDim.new(0, 12)
            ll.Parent = lC

            local rC = Instance.new("Frame")
            rC.Size = UDim2.new(0.5, -6, 0, 0)
            rC.AutomaticSize = Enum.AutomaticSize.Y
            rC.Position = UDim2.new(0.5, 6, 0, 0)
            rC.BackgroundTransparency = 1
            rC.ZIndex = 7
            rC.Parent = sP

            local rp = Instance.new("UIPadding")
            rp.PaddingLeft = UDim.new(0, 2)
            rp.PaddingRight = UDim.new(0, 4)
            rp.PaddingTop = UDim.new(0, 4)
            rp.PaddingBottom = UDim.new(0, 20)
            rp.Parent = rC

            local rl = Instance.new("UIListLayout")
            rl.SortOrder = Enum.SortOrder.LayoutOrder
            rl.Padding = UDim.new(0, 12)
            rl.Parent = rC

            pgs[sN] = { p = sP, l = lC, r = rC }

            sB.MouseButton1Click:Connect(function()
                for _, b in ipairs(stc:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundTransparency = 1
                        b.TextColor3 = tm.st
                    end
                end
                for _, pD in pairs(pgs) do pD.p.Visible = false end
                sB.BackgroundTransparency = 0
                sB.TextColor3 = tm.t
                sP.Visible = true
            end)

            table.insert(allD, function()
                local ac = sP.Visible
                sB.TextColor3 = ac and tm.t or tm.st
            end)

            fst = false
        end
        return pgs
    end

    local function cC(pC, t)
        local cd = Instance.new("Frame")
        cd.Size = UDim2.new(1, -2, 0, 0)
        cd.AutomaticSize = Enum.AutomaticSize.Y
        cd.BackgroundColor3 = tm.c
        cd.ZIndex = 8
        cd.Parent = pC
        table.insert(allB, { cd, "c" })

        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0, 6)
        cc.Parent = cd

        local cs = Instance.new("UIStroke")
        cs.Color = tm.k
        cs.Thickness = 1.2
        cs.Parent = cd
        table.insert(allB, { cs, "k" })

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 0, 16)
        tl.BackgroundTransparency = 1
        tl.Text = t
        tl.TextColor3 = tm.t
        tl.Font = tm.f
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Center
        tl.ZIndex = 9
        tl.Parent = cd
        table.insert(allT, { tl, "t", false })

        local lo = Instance.new("UIListLayout")
        lo.SortOrder = Enum.SortOrder.LayoutOrder
        lo.Padding = UDim.new(0, 8)
        lo.Parent = cd

        local pd = Instance.new("UIPadding")
        pd.PaddingTop = UDim.new(0, 8)
        pd.PaddingBottom = UDim.new(0, 10)
        pd.PaddingLeft = UDim.new(0, 12)
        pd.PaddingRight = UDim.new(0, 12)
        pd.Parent = cd

        return cd
    end

    local function cTog(pC, t, iD, cbk, isSetting)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -40, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 32, 0, 16)
        sw.Position = UDim2.new(1, -32, 0.5, -8)
        sw.BackgroundColor3 = iD and tm.a or Color3.fromRGB(30, 30, 35)
        sw.ZIndex = 10
        sw.Parent = fr

        local swc = Instance.new("UICorner")
        swc.CornerRadius = UDim.new(1, 0)
        swc.Parent = sw

        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 12, 0, 12)
        kn.Position = iD and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        kn.BackgroundColor3 = iD and tm.t or tm.st
        kn.ZIndex = 11
        kn.Parent = sw

        local knc = Instance.new("UICorner")
        knc.CornerRadius = UDim.new(1, 0)
        knc.Parent = kn

        local tgd = iD
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 12
        btn.Parent = fr

        local function Set(val, fireCbk)
            if tgd == val then return end
            tgd = val
            if tgd then
                ts:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = tm.a }):Play()
                ts:Create(kn, TweenInfo.new(0.2), { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = tm.t })
                    :Play()
            else
                ts:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 30, 35) }):Play()
                ts:Create(kn, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = tm.st })
                    :Play()
            end
            if fireCbk and cbk then cbk(tgd) end
        end

        btn.MouseButton1Click:Connect(function()
            Set(not tgd, true)
        end)

        table.insert(allD, function()
            sw.BackgroundColor3 = tgd and tm.a or Color3.fromRGB(30, 30, 35)
            kn.BackgroundColor3 = tgd and tm.t or tm.st
        end)

        local togObj = { Set = Set }
        if not isSetting then
            table.insert(allToggleResets, togObj)
        end

        return togObj
    end

    local function cSli(pC, t, mi, mx, df, cbk)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 38)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -50, 0, 18)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0, 50, 0, 18)
        vl.Position = UDim2.new(1, -50, 0, 0)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(df)
        vl.TextColor3 = tm.t
        vl.Font = tm.f
        vl.TextSize = 11
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.ZIndex = 10
        vl.Parent = fr
        table.insert(allT, { vl, "t", false })

        local br = Instance.new("Frame")
        br.Size = UDim2.new(1, 0, 0, 4)
        br.Position = UDim2.new(0, 0, 1, -8)
        br.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        br.ZIndex = 10
        br.Parent = fr

        local brc = Instance.new("UICorner")
        brc.CornerRadius = UDim.new(1, 0)
        brc.Parent = br

        local fl = Instance.new("Frame")
        fl.Size = UDim2.new((df - mi) / (mx - mi), 0, 1, 0)
        fl.BackgroundColor3 = tm.a
        fl.ZIndex = 11
        fl.Parent = br

        local flc = Instance.new("UICorner")
        flc.CornerRadius = UDim.new(1, 0)
        flc.Parent = fl

        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 10, 0, 10)
        kn.Position = UDim2.new(1, -5, 0.5, -5)
        kn.BackgroundColor3 = tm.t
        kn.ZIndex = 12
        kn.Parent = fl

        local knc = Instance.new("UICorner")
        knc.CornerRadius = UDim.new(1, 0)
        knc.Parent = kn

        local db = Instance.new("TextButton")
        db.Size = UDim2.new(1, 0, 0, 16)
        db.Position = UDim2.new(0, 0, 1, -14)
        db.BackgroundTransparency = 1
        db.Text = ""
        db.ZIndex = 15
        db.Parent = fr

        local slg = false

        local function uV(i)
            local px = math.clamp((i.Position.X - br.AbsolutePosition.X) / br.AbsoluteSize.X, 0, 1)
            local v = math.floor(mi + ((mx - mi) * px))

            ts:Create(fl, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Size = UDim2.new(px, 0, 1, 0) }):Play()
            vl.Text = tostring(v)

            if cbk then cbk(v) end
        end

        db.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                slg = true
                uV(i)
            end
        end)
        uis.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then slg = false end
        end)
        uis.InputChanged:Connect(function(i)
            if slg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                uV(i)
            end
        end)

        table.insert(allD, function()
            fl.BackgroundColor3 = tm.a
            kn.BackgroundColor3 = tm.t
        end)
    end

    local function cTB(pC, ph, dTxt, cbk)
        local cr = Instance.new("Frame")
        cr.Size = UDim2.new(1, 0, 0, 32)
        cr.BackgroundTransparency = 1
        cr.ZIndex = 10
        cr.Parent = pC

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = tm.m
        bg.ZIndex = 10
        bg.Parent = cr
        table.insert(allB, { bg, "m" })

        local bgc = Instance.new("UICorner")
        bgc.CornerRadius = UDim.new(0, 4)
        bgc.Parent = bg

        local bgs = Instance.new("UIStroke")
        bgs.Color = tm.k
        bgs.Parent = bg
        table.insert(allB, { bgs, "k" })

        local bx = Instance.new("TextBox")
        bx.Size = UDim2.new(1, -20, 1, 0)
        bx.Position = UDim2.new(0, 10, 0, 0)
        bx.BackgroundTransparency = 1
        bx.Text = dTxt or ""
        bx.PlaceholderText = ph
        bx.TextColor3 = tm.t
        bx.PlaceholderColor3 = tm.st
        bx.Font = tm.f
        bx.TextSize = 12
        bx.TextXAlignment = Enum.TextXAlignment.Left
        bx.ZIndex = 11
        bx.Parent = bg
        table.insert(allT, { bx, "t", false })

        bx.FocusLost:Connect(function()
            if cbk then cbk(bx.Text) end
        end)
        return bx
    end

    local isBinding = false
    local function cBind(pC, t, dTxt, cbk)
        local isMobile = (uis.TouchEnabled and not uis.KeyboardEnabled) or (uis.TouchEnabled and not uis.MouseEnabled)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Visible = not isMobile
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -60, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0, 75, 0, 16)
        bg.Position = UDim2.new(1, -75, 0.5, -8)
        bg.BackgroundColor3 = tm.m
        bg.ClipsDescendants = true
        bg.ZIndex = 10
        bg.Parent = fr
        table.insert(allB, { bg, "m" })

        local bgc = Instance.new("UICorner")
        bgc.CornerRadius = UDim.new(0, 4)
        bgc.Parent = bg

        local bgs = Instance.new("UIStroke")
        bgs.Color = tm.k
        bgs.Parent = bg
        table.insert(allB, { bgs, "k" })

        local bx = Instance.new("TextButton")
        bx.Size = UDim2.new(1, -10, 1, 0)
        bx.Position = UDim2.new(0, 5, 0, 0)
        bx.BackgroundTransparency = 1
        bx.Text = dTxt or ""
        bx.TextColor3 = tm.t
        bx.TextTruncate = Enum.TextTruncate.AtEnd
        bx.Font = tm.f
        bx.TextSize = 10
        bx.ZIndex = 11
        bx.Parent = bg
        table.insert(allT, { bx, "t", false })

        local connection
        bx.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            bx.Text = "..."
            if connection then connection:Disconnect() end
            connection = uis.InputBegan:Connect(function(input, gp)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local k = input.KeyCode.Name
                    connection:Disconnect()
                    connection = nil

                    if cbk then
                        local res = cbk(k)
                        if type(res) == "string" then
                            bx.Text = res
                        else
                            bx.Text = k
                        end
                    else
                        bx.Text = k
                    end

                    task.delay(0.1, function()
                        isBinding = false
                    end)
                end
            end)
        end)

        return bx
    end

    local function cIP(pC, dImg)
        local cr = Instance.new("Frame")
        cr.Size = UDim2.new(1, 0, 0, 80)
        cr.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
        cr.ZIndex = 10
        cr.Parent = pC

        local crc = Instance.new("UICorner")
        crc.CornerRadius = UDim.new(0, 4)
        crc.Parent = cr

        local crs = Instance.new("UIStroke")
        crs.Color = tm.k
        crs.Parent = cr
        table.insert(allB, { crs, "k" })

        local il = Instance.new("ImageLabel")
        il.Size = UDim2.new(1, 0, 1, 0)
        il.BackgroundTransparency = 1
        il.Image = dImg ~= "" and dImg or ""
        il.ScaleType = Enum.ScaleType.Crop
        il.ClipsDescendants = true
        il.ZIndex = 11
        il.Parent = cr

        local ilc = Instance.new("UICorner")
        ilc.CornerRadius = UDim.new(0, 4)
        ilc.Parent = il

        return il
    end

    local function cDD(pC, t, op, dSel, cbk)
        local cr = Instance.new("Frame")
        cr.Size = UDim2.new(1, 0, 0, 0)
        cr.AutomaticSize = Enum.AutomaticSize.Y
        cr.BackgroundTransparency = 1
        cr.ZIndex = 15
        cr.Parent = pC

        local lo = Instance.new("UIListLayout")
        lo.SortOrder = Enum.SortOrder.LayoutOrder
        lo.Padding = UDim.new(0, 4)
        lo.Parent = cr

        local hd = Instance.new("TextButton")
        hd.Size = UDim2.new(1, 0, 0, 32)
        hd.BackgroundColor3 = tm.m
        hd.Text = ""
        hd.AutoButtonColor = false
        hd.ZIndex = 16
        hd.Parent = cr
        table.insert(allB, { hd, "m" })

        local hdc = Instance.new("UICorner")
        hdc.CornerRadius = UDim.new(0, 4)
        hdc.Parent = hd

        local hds = Instance.new("UIStroke")
        hds.Color = tm.k
        hds.Parent = hd
        table.insert(allB, { hds, "k" })

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -40, 1, 0)
        tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = t .. ": " .. dSel
        tl.TextColor3 = tm.st
        tl.Font = tm.f
        tl.TextSize = 12
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.TextTruncate = Enum.TextTruncate.AtEnd
        tl.ZIndex = 17
        tl.Parent = hd
        table.insert(allT, { tl, "st", false })

        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(0, 20, 0, 20)
        ic.Position = UDim2.new(1, -25, 0.5, -10)
        ic.BackgroundTransparency = 1
        ic.Text = "+"
        ic.TextColor3 = tm.st
        ic.Font = tm.f
        ic.TextSize = 16
        ic.ZIndex = 17
        ic.Parent = hd
        table.insert(allT, { ic, "st", false })

        local oc = Instance.new("ScrollingFrame")
        oc.Size = UDim2.new(1, 0, 0, 0)
        oc.BackgroundColor3 = tm.m
        oc.Visible = false
        oc.ClipsDescendants = true
        oc.BorderSizePixel = 0
        oc.ScrollBarThickness = 3
        oc.ScrollBarImageColor3 = tm.st
        oc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        oc.CanvasSize = UDim2.new(0, 0, 0, 0)
        oc.ZIndex = 20
        oc.Parent = cr
        table.insert(allB, { oc, "m" })

        local occ = Instance.new("UICorner")
        occ.CornerRadius = UDim.new(0, 4)
        occ.Parent = oc

        local ocs = Instance.new("UIStroke")
        ocs.Color = tm.k
        ocs.Parent = oc
        table.insert(allB, { ocs, "k" })

        local ol = Instance.new("UIListLayout")
        ol.SortOrder = Enum.SortOrder.LayoutOrder
        ol.Parent = oc

        local isO = false
        hd.MouseButton1Click:Connect(function()
            isO = not isO
            local targetH = isO and math.min(#op * 28, 140) or 0
            if isO then
                oc.Visible = true
                ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, targetH) }):Play()
            else
                ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, 0) }):Play()
                task.delay(0.2, function() if not isO then oc.Visible = false end end)
            end
            ic.Text = isO and "-" or "+"
        end)

        local function populateOptions(list)
            for _, child in ipairs(oc:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, o in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, 0, 0, 28)
                ob.BackgroundTransparency = 1
                ob.Text = "  " .. o
                ob.TextColor3 = tm.t
                ob.Font = tm.f
                ob.TextSize = 12
                ob.TextXAlignment = Enum.TextXAlignment.Left
                ob.Active = true
                ob.ZIndex = 21
                ob.Parent = oc
                table.insert(allT, { ob, "t", false })

                ob.MouseEnter:Connect(function()
                    ob.TextColor3 = getAccentColor()
                end)
                ob.MouseLeave:Connect(function()
                    ob.TextColor3 = tm.t
                end)

                ob.MouseButton1Click:Connect(function()
                    tl.Text = t .. ": " .. o
                    isO = false
                    ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.new(1, 0, 0, 0) }):Play()
                    task.delay(0.2, function() if not isO then oc.Visible = false end end)
                    ic.Text = "+"
                    if cbk then cbk(o) end
                end)
            end
        end

        populateOptions(op)

        local function Refresh(nOp)
            op = nOp
            populateOptions(op)
            if isO then
                local targetH = math.min(#op * 28, 140)
                oc.Size = UDim2.new(1, 0, 0, targetH)
            end
        end

        return { Refresh = Refresh }
    end

    local function cBtn(pC, t, cbk)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 28)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -24, 1, -4)
        btn.Position = UDim2.new(0, 12, 0, 2)
        btn.BackgroundColor3 = tm.m
        btn.AutoButtonColor = false
        btn.Text = t
        btn.TextColor3 = tm.t
        btn.Font = tm.f
        btn.TextSize = 12
        btn.ZIndex = 11
        btn.Parent = fr
        table.insert(allB, { btn, "m" })
        table.insert(allT, { btn, "t", false })

        local btc = Instance.new("UICorner")
        btc.CornerRadius = UDim.new(0, 6)
        btc.Parent = btn

        local bts = Instance.new("UIStroke")
        bts.Color = tm.k
        bts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bts.Thickness = 1
        bts.Parent = btn
        table.insert(allB, { bts, "k" })

        -- Hover & Click Micro-Animations
        local isHovered = false
        btn.MouseEnter:Connect(function()
            isHovered = true
            ts:Create(bts, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = tm.a }):Play()
            ts:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(
                    math.clamp(tm.m.R * 255 + 15, 0, 255),
                    math.clamp(tm.m.G * 255 + 15, 0, 255),
                    math.clamp(tm.m.B * 255 + 20, 0, 255)
                ),
                TextColor3 = tm.a
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            isHovered = false
            ts:Create(bts, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = tm.k }):Play()
            ts:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = tm.m,
                TextColor3 = tm.t,
                Size = UDim2.new(1, -24, 1, -4),
                Position = UDim2.new(0, 12, 0, 2)
            }):Play()
        end)

        btn.MouseButton1Down:Connect(function()
            ts:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -28, 1, -6),
                Position = UDim2.new(0, 14, 0, 3)
            }):Play()
        end)

        btn.MouseButton1Up:Connect(function()
            local targetSize = isHovered and UDim2.new(1, -24, 1, -4) or UDim2.new(1, -24, 1, -4)
            local targetPos = isHovered and UDim2.new(0, 12, 0, 2) or UDim2.new(0, 12, 0, 2)
            ts:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize,
                Position = targetPos
            }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if cbk then cbk() end
        end)
        return btn
    end

    local function cCP(pC, t, defHSV, cbk)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -40, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local cbBtn = Instance.new("TextButton")
        cbBtn.Size = UDim2.new(0, 24, 0, 16)
        cbBtn.Position = UDim2.new(1, -28, 0.5, -8)
        cbBtn.BackgroundColor3 = Color3.fromHSV(defHSV[1], defHSV[2], defHSV[3])
        cbBtn.BorderSizePixel = 0
        cbBtn.Text = ""
        cbBtn.ZIndex = 10
        cbBtn.Parent = fr

        local cbc = Instance.new("UICorner")
        cbc.CornerRadius = UDim.new(0, 4)
        cbc.Parent = cbBtn

        local oc = Instance.new("Frame")
        oc.Size = UDim2.new(1, 0, 0, 0)
        oc.BackgroundColor3 = tm.m
        oc.BorderSizePixel = 0
        oc.Visible = false
        oc.ClipsDescendants = true
        oc.ZIndex = 20
        oc.Parent = pC
        table.insert(allB, { oc, "m" })

        local occ = Instance.new("UICorner")
        occ.CornerRadius = UDim.new(0, 4)
        occ.Parent = oc

        local ocs = Instance.new("UIStroke")
        ocs.Color = tm.k
        ocs.Parent = oc
        table.insert(allB, { ocs, "k" })

        local hF = Instance.new("TextButton")
        hF.Size = UDim2.new(1, -20, 0, 14)
        hF.Position = UDim2.new(0, 10, 0, 10)
        hF.BackgroundColor3 = Color3.new(1, 1, 1)
        hF.BorderSizePixel = 0
        hF.Text = ""
        hF.ZIndex = 21
        hF.Parent = oc
        local hG = Instance.new("UIGradient")
        hG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        hG.Parent = hF

        local hK = Instance.new("Frame")
        hK.Size = UDim2.new(0, 4, 1, 4)
        hK.Position = UDim2.new(defHSV[1], -2, 0, -2)
        hK.BackgroundColor3 = Color3.new(1, 1, 1)
        hK.BorderSizePixel = 0
        hK.ZIndex = 22
        hK.Parent = hF

        local svF = Instance.new("TextButton")
        svF.Size = UDim2.new(1, -20, 0, 60)
        svF.Position = UDim2.new(0, 10, 0, 30)
        svF.BackgroundColor3 = Color3.fromHSV(defHSV[1], 1, 1)
        svF.BorderSizePixel = 0
        svF.Text = ""
        svF.ZIndex = 21
        svF.Parent = oc

        local svW = Instance.new("Frame")
        svW.Size = UDim2.new(1, 0, 1, 0)
        svW.BackgroundColor3 = Color3.new(1, 1, 1)
        svW.BorderSizePixel = 0
        svW.ZIndex = 21
        svW.Parent = svF

        local svG1 = Instance.new("UIGradient")
        svG1.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
        svG1.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        svG1.Parent = svW

        local svD = Instance.new("Frame")
        svD.Size = UDim2.new(1, 0, 1, 0)
        svD.BackgroundColor3 = Color3.new(0, 0, 0)
        svD.BorderSizePixel = 0
        svD.ZIndex = 21
        svD.Parent = svF
        local svG2 = Instance.new("UIGradient")
        svG2.Rotation = 90
        svG2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        svG2.Parent = svD

        local svK = Instance.new("Frame")
        svK.Size = UDim2.new(0, 6, 0, 6)
        svK.Position = UDim2.new(defHSV[2], -3, 1 - defHSV[3], -3)
        svK.BackgroundColor3 = Color3.new(1, 1, 1)
        svK.BorderSizePixel = 0
        svK.ZIndex = 23
        svK.Parent = svF
        local svKC = Instance.new("UICorner")
        svKC.CornerRadius = UDim.new(1, 0)
        svKC.Parent = svK

        local h, s, v = defHSV[1], defHSV[2], defHSV[3]
        local md = false
        local mdH = false

        local function updC()
            local c = Color3.fromHSV(h, s, v)
            cbBtn.BackgroundColor3 = c
            svF.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            hK.Position = UDim2.new(math.clamp(h, 0, 0.99), -2, 0, -2)
            svK.Position = UDim2.new(math.clamp(s, 0, 0.99), -3, math.clamp(1 - v, 0, 0.99), -3)
            if cbk then cbk({ h, s, v }) end
        end

        hF.MouseButton1Down:Connect(function() mdH = true end)
        svF.MouseButton1Down:Connect(function() md = true end)
        svD.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                md = true
            end
        end)
        uis.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                md = false
                mdH = false
            end
        end)
        uis.InputChanged:Connect(function(i)
            if mdH and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                h = math.clamp((i.Position.X - hF.AbsolutePosition.X) / hF.AbsoluteSize.X, 0, 1)
                updC()
            elseif md and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                s = math.clamp((i.Position.X - svF.AbsolutePosition.X) / svF.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((i.Position.Y - svF.AbsolutePosition.Y) / svF.AbsoluteSize.Y, 0, 1)
                updC()
            end
        end)

        local isO = false
        cbBtn.MouseButton1Click:Connect(function()
            isO = not isO
            if isO then
                oc.Visible = true
                ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, 100) }):Play()
            else
                ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, 0) }):Play()
                task.delay(0.2, function() if not isO then oc.Visible = false end end)
            end
        end)
    end

    local fcpFrame, fcpUpdC, fcpBtn, fcpCbk, fcpBgBtn

    local function initFCP()
        fcpBgBtn = Instance.new("TextButton")
        fcpBgBtn.Size = UDim2.new(10, 0, 10, 0)
        fcpBgBtn.Position = UDim2.new(-5, 0, -5, 0)
        fcpBgBtn.BackgroundTransparency = 1
        fcpBgBtn.Text = ""
        fcpBgBtn.AutoButtonColor = false
        fcpBgBtn.ZIndex = 49
        fcpBgBtn.Visible = false
        fcpBgBtn.Parent = sg
        fcpBgBtn.MouseButton1Click:Connect(function()
            fcpBgBtn.Visible = false
            ts:Create(fcpFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 0, 0, 0) }):Play()
            task.delay(0.2, function()
                if not fcpBgBtn.Visible then fcpFrame.Visible = false end
            end)
        end)

        fcpFrame = Instance.new("Frame")
        fcpFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        fcpFrame.Size = UDim2.new(0, 0, 0, 0)
        fcpFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        fcpFrame.ClipsDescendants = true
        fcpFrame.BackgroundColor3 = tm.m
        fcpFrame.BorderSizePixel = 0
        fcpFrame.Visible = false
        fcpFrame.ZIndex = 50
        fcpFrame.Parent = sg
        table.insert(allB, { fcpFrame, "m" })

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = fcpFrame

        local s = Instance.new("UIStroke")
        s.Color = tm.k
        s.Parent = fcpFrame
        table.insert(allB, { s, "k" })

        local tb = Instance.new("Frame")
        tb.Size = UDim2.new(1, 0, 0, 30)
        tb.BackgroundTransparency = 1
        tb.ZIndex = 55
        tb.Parent = fcpFrame

        local ttl = Instance.new("TextLabel")
        ttl.Size = UDim2.new(1, -20, 1, 0)
        ttl.Position = UDim2.new(0, 10, 0, 0)
        ttl.BackgroundTransparency = 1
        ttl.Text = "Color Picker"
        ttl.TextColor3 = tm.t
        ttl.Font = tm.f
        ttl.TextSize = 14
        ttl.TextXAlignment = Enum.TextXAlignment.Left
        ttl.ZIndex = 55
        ttl.Parent = tb
        table.insert(allT, { ttl, "t", false })

        local hF = Instance.new("TextButton")
        hF.Size = UDim2.new(1, -20, 0, 14)
        hF.Position = UDim2.new(0, 10, 0, 40)
        hF.BackgroundColor3 = Color3.new(1, 1, 1)
        hF.BorderSizePixel = 0
        hF.AutoButtonColor = false
        hF.Text = ""
        hF.ZIndex = 51
        hF.Parent = fcpFrame
        local hG = Instance.new("UIGradient")
        hG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        hG.Parent = hF

        local hK = Instance.new("Frame")
        hK.Size = UDim2.new(0, 4, 1, 4)
        hK.Position = UDim2.new(0, -2, 0, -2)
        hK.BackgroundColor3 = Color3.new(1, 1, 1)
        hK.BorderSizePixel = 0
        hK.ZIndex = 52
        hK.Parent = hF

        local svF = Instance.new("TextButton")
        svF.Size = UDim2.new(1, -20, 0, 100)
        svF.Position = UDim2.new(0, 10, 0, 65)
        svF.BackgroundColor3 = Color3.new(1, 0, 0)
        svF.BorderSizePixel = 0
        svF.AutoButtonColor = false
        svF.Text = ""
        svF.ZIndex = 51
        svF.Parent = fcpFrame

        local svW = Instance.new("Frame")
        svW.Size = UDim2.new(1, 0, 1, 0)
        svW.BackgroundColor3 = Color3.new(1, 1, 1)
        svW.BorderSizePixel = 0
        svW.ZIndex = 52
        svW.Parent = svF
        local svG1 = Instance.new("UIGradient")
        svG1.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
        svG1.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        svG1.Parent = svW

        local svD = Instance.new("Frame")
        svD.Size = UDim2.new(1, 0, 1, 0)
        svD.BackgroundColor3 = Color3.new(0, 0, 0)
        svD.BorderSizePixel = 0
        svD.ZIndex = 53
        svD.Parent = svF
        local svG2 = Instance.new("UIGradient")
        svG2.Rotation = 90
        svG2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        svG2.Parent = svD

        local svK = Instance.new("Frame")
        svK.Size = UDim2.new(0, 8, 0, 8)
        svK.Position = UDim2.new(1, -4, 0, -4)
        svK.BackgroundColor3 = Color3.new(1, 1, 1)
        svK.BorderSizePixel = 0
        svK.ZIndex = 54
        svK.Parent = svF
        local svKC = Instance.new("UICorner")
        svKC.CornerRadius = UDim.new(1, 0)
        svKC.Parent = svK

        local h, s, v = 0, 1, 1
        local md = false
        local mdH = false

        fcpUpdC = function(nh, ns, nv, caller)
            h = nh or h; s = ns or s; v = nv or v
            local c = Color3.fromHSV(h, s, v)
            svF.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            hK.Position = UDim2.new(math.clamp(h, 0, 0.99), -2, 0, -2)
            svK.Position = UDim2.new(math.clamp(s, 0, 0.99), -4, math.clamp(1 - v, 0, 0.99), -4)
            if fcpBtn and caller ~= "btn" then
                fcpBtn.BackgroundColor3 = c
            end
            if fcpCbk and caller ~= "btn" then fcpCbk(c) end
        end

        hF.MouseButton1Down:Connect(function() mdH = true end)
        svF.MouseButton1Down:Connect(function() md = true end)
        svD.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then md = true end
        end)
        uis.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                md = false; mdH = false
            end
        end)
        uis.InputChanged:Connect(function(i)
            if mdH and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local px = math.clamp((i.Position.X - hF.AbsolutePosition.X) / hF.AbsoluteSize.X, 0, 1)
                fcpUpdC(px, s, v)
            elseif md and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local px = math.clamp((i.Position.X - svF.AbsolutePosition.X) / svF.AbsoluteSize.X, 0, 1)
                local py = 1 - math.clamp((i.Position.Y - svF.AbsolutePosition.Y) / svF.AbsoluteSize.Y, 0, 1)
                fcpUpdC(h, px, py)
            end
        end)
    end
    initFCP()

    local function openFCP(btn, dC, cbk)
        fcpBtn = btn
        fcpCbk = cbk
        local dh, ds, dv = dC:ToHSV()
        fcpUpdC(dh, ds, dv, "btn")
        fcpFrame.Visible = true
        if fcpBgBtn then fcpBgBtn.Visible = true end
        ts:Create(fcpFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 200, 0, 180) }):Play()
    end


    local function cTogBind(pC, t, defState, dTxt, cbk, bindCbk)
        local isMobile = (uis.TouchEnabled and not uis.KeyboardEnabled) or (uis.TouchEnabled and not uis.MouseEnabled)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = isMobile and UDim2.new(1, -40, 1, 0) or UDim2.new(1, -120, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 32, 0, 16)
        sw.Position = UDim2.new(1, -32, 0.5, -8)
        sw.BackgroundColor3 = defState and tm.a or Color3.fromRGB(30, 30, 35)
        sw.ZIndex = 10
        sw.Parent = fr

        local swc = Instance.new("UICorner")
        swc.CornerRadius = UDim.new(1, 0)
        swc.Parent = sw

        local swb = Instance.new("UIStroke")
        swb.Color = tm.k
        swb.Parent = sw
        table.insert(allB, { swb, "k" })

        local crc = Instance.new("Frame")
        crc.Size = UDim2.new(0, 12, 0, 12)
        crc.Position = UDim2.new(0, defState and 18 or 2, 0.5, -6)
        crc.BackgroundColor3 = defState and tm.t or tm.st
        crc.ZIndex = 11
        crc.Parent = sw

        local crcc = Instance.new("UICorner")
        crcc.CornerRadius = UDim.new(1, 0)
        crcc.Parent = crc

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 12
        btn.Parent = sw

        local isOn = defState

        local function toggleF(force)
            if force == "GET_STATE" then return isOn end
            if force ~= nil then
                isOn = force
            else
                isOn = not isOn
            end
            ts:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = isOn and tm.a or Color3.fromRGB(30, 30, 35) }):Play()
            ts:Create(crc, TweenInfo.new(0.2),
                { Position = UDim2.new(0, isOn and 18 or 2, 0.5, -6), BackgroundColor3 = isOn and tm.t or tm.st }):Play()
            if cbk then cbk(isOn) end
        end
        btn.MouseButton1Click:Connect(function() toggleF() end)

        table.insert(allD, function()
            sw.BackgroundColor3 = isOn and tm.a or Color3.fromRGB(30, 30, 35)
            crc.BackgroundColor3 = isOn and tm.t or tm.st
        end)

        table.insert(allToggleResets, { Set = function(val) toggleF(val) end })

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0, 50, 0, 16)
        bg.Position = UDim2.new(1, -92, 0.5, -8)
        bg.BackgroundColor3 = tm.m
        bg.ClipsDescendants = true
        bg.ZIndex = 10
        bg.Visible = not isMobile
        bg.Parent = fr
        table.insert(allB, { bg, "m" })

        local bgc = Instance.new("UICorner")
        bgc.CornerRadius = UDim.new(0, 4)
        bgc.Parent = bg

        local bgs = Instance.new("UIStroke")
        bgs.Color = tm.k
        bgs.Parent = bg
        table.insert(allB, { bgs, "k" })

        local bx = Instance.new("TextButton")
        bx.Size = UDim2.new(1, -10, 1, 0)
        bx.Position = UDim2.new(0, 5, 0, 0)
        bx.BackgroundTransparency = 1
        bx.Text = dTxt or ""
        bx.TextColor3 = tm.t
        bx.TextTruncate = Enum.TextTruncate.AtEnd
        bx.Font = tm.f
        bx.TextSize = 10
        bx.ZIndex = 11
        bx.Parent = bg
        table.insert(allT, { bx, "t", false })

        local connection
        bx.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            bx.Text = "..."
            if connection then connection:Disconnect() end
            connection = uis.InputBegan:Connect(function(input, gp)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local k = input.KeyCode.Name
                    connection:Disconnect()
                    connection = nil

                    if bindCbk then
                        local res = bindCbk(k)
                        if type(res) == "string" then
                            bx.Text = res
                        else
                            bx.Text = k
                        end
                    else
                        bx.Text = k
                    end

                    task.delay(0.1, function()
                        isBinding = false
                    end)
                end
            end)
        end)

        return toggleF, bx
    end

    local function cTogCP(pC, t, defState, defCol, cbk, cCbk)
        local fr = Instance.new("TextButton")
        fr.Size = UDim2.new(1, 0, 0, 32)
        fr.BackgroundTransparency = 1
        fr.Text = ""
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -65, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = t
        lb.TextColor3 = tm.st
        lb.Font = tm.f
        lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextTruncate = Enum.TextTruncate.AtEnd
        lb.ZIndex = 10
        lb.Parent = fr
        table.insert(allT, { lb, "st", false })

        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(0, 16, 0, 16)
        cBtn.Position = UDim2.new(1, -56, 0.5, -8)
        cBtn.BackgroundColor3 = defCol
        cBtn.BorderSizePixel = 0
        cBtn.Text = ""
        cBtn.ZIndex = 12
        cBtn.Parent = fr
        local cbc = Instance.new("UICorner")
        cbc.CornerRadius = UDim.new(0, 4)
        cbc.Parent = cBtn

        cBtn.MouseButton1Click:Connect(function()
            openFCP(cBtn, cBtn.BackgroundColor3, cCbk)
        end)

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 32, 0, 16)
        sw.Position = UDim2.new(1, -32, 0.5, -8)
        sw.BackgroundColor3 = defState and tm.a or Color3.fromRGB(30, 30, 35)
        sw.ZIndex = 10
        sw.Parent = fr
        local swc = Instance.new("UICorner")
        swc.CornerRadius = UDim.new(1, 0)
        swc.Parent = sw

        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 12, 0, 12)
        kn.Position = defState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        kn.BackgroundColor3 = defState and tm.t or tm.st
        kn.ZIndex = 11
        kn.Parent = sw

        local knc = Instance.new("UICorner")
        knc.CornerRadius = UDim.new(1, 0)
        knc.Parent = kn

        table.insert(allD, function()
            sw.BackgroundColor3 = defState and tm.a or Color3.fromRGB(30, 30, 35)
            kn.BackgroundColor3 = defState and tm.t or tm.st
        end)

        local function Set(val, fireCbk)
            if defState == val then return end
            defState = val
            if defState then
                ts:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = tm.a }):Play()
                ts:Create(kn, TweenInfo.new(0.2), { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = tm.t })
                    :Play()
            else
                ts:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 30, 35) }):Play()
                ts:Create(kn, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = tm.st })
                    :Play()
            end
            if fireCbk ~= false and cbk then cbk(defState) end
        end

        fr.MouseButton1Click:Connect(function()
            Set(not defState, true)
        end)

        return { Set = Set }
    end

    getgenv().YIX_Binds = getgenv().YIX_Binds or {}
    local function assignBind(newBind, cfgKey, togFunc, name, category, bx)
        local k = newBind:upper()
        local hBind = (cfg.hideBind or ""):upper()
        local pBind = (cfg.panicBind or ""):upper()

        if k == hBind or k == pBind or getgenv().YIX_Binds[k] then
            return cfg[cfgKey] or ""
        end

        if cfg[cfgKey] and cfg[cfgKey] ~= "" then
            getgenv().YIX_Binds[cfg[cfgKey]:upper()] = nil
        end
        cfg[cfgKey] = newBind
        getgenv().YIX_Binds[k] = { func = togFunc, name = name, category = category, cfgKey = cfgKey, bx = bx }
        if getgenv().YIX_RefreshBindsUI then getgenv().YIX_RefreshBindsUI() end
        sCF()
        return newBind
    end

    do -- Main Tab
        mT = cMT("Main", "76167307342345", true)
        mS = cSM(mT, { "Silent Aim", "Aimbot", "Gun Mods" })

        -- Executor detection for special FOV scaling (Velocity, Real, Xeno)
        local guiService = game:GetService("GuiService")
        local exeInfo = ""
        if identifyexecutor then
            pcall(function() exeInfo = tostring(identifyexecutor()):lower() end)
        elseif getexecutorname then
            pcall(function() exeInfo = tostring(getexecutorname()):lower() end)
        end
        local isSpecialExe = exeInfo:find("velocity") ~= nil or exeInfo:find("real") ~= nil or
            exeInfo:find("xeno") ~= nil

        -- Silent Aim Sub-Tab
        local Config = {
            Enabled = false,
            CamLockEnabled = false,
            ShowFOV = false,
            FOV = 100,
            TargetPart = "Head",
            WallCheck = true,
            FriendCheck = true,
            RequireTool = false,
            Smoothness = 50,
            MaxDistance = 1000,
            ExeScaleFOV = isSpecialExe,
            Wallbang = false,
            MaxWallPenetrations = 3,
            WallbangMarkLifetime = 0.5,
            MobileLockEnabled = false
        }

        local ScaleFactor = 2
        local manualLockedTarget = nil

        -- UI Fallback FOV Circle for mobile executors without Drawing API
        local uiFovCircle = Instance.new("Frame")
        uiFovCircle.Name = "UI_FOVCircle"
        uiFovCircle.BackgroundTransparency = 1
        uiFovCircle.Visible = false
        uiFovCircle.ZIndex = 500
        uiFovCircle.Parent = sg

        local uiFovCorner = Instance.new("UICorner")
        uiFovCorner.CornerRadius = UDim.new(1, 0)
        uiFovCorner.Parent = uiFovCircle

        local uiFovStroke = Instance.new("UIStroke")
        uiFovStroke.Color = Color3.fromRGB(255, 255, 255)
        uiFovStroke.Thickness = 1.5
        uiFovStroke.Parent = uiFovCircle

        -- Mobile Floating Lock Button
        local mbLockBtn = Instance.new("TextButton")
        mbLockBtn.Size = UDim2.new(0, 48, 0, 48)
        mbLockBtn.Position = UDim2.new(1, -70, 0.5, -24)
        mbLockBtn.BackgroundColor3 = tm.m
        mbLockBtn.Text = "🎯"
        mbLockBtn.TextSize = 22
        mbLockBtn.Visible = false
        mbLockBtn.ZIndex = 900
        mbLockBtn.Parent = sg
        table.insert(allB, { mbLockBtn, "m" })

        local mbLockCorner = Instance.new("UICorner")
        mbLockCorner.CornerRadius = UDim.new(1, 0)
        mbLockCorner.Parent = mbLockBtn

        local mbLockStroke = Instance.new("UIStroke")
        mbLockStroke.Color = tm.k
        mbLockStroke.Thickness = 2
        mbLockStroke.Parent = mbLockBtn
        table.insert(allB, { mbLockStroke, "k" })

        MakeDraggable(mbLockBtn)

        local isMobileDevice = uis.TouchEnabled and not uis.MouseEnabled

        local function updateMobileBtnVis()
            if not isMobileDevice then
                mbLockBtn.Visible = false
                return
            end
            mbLockBtn.Visible = Config.MobileLockEnabled or Config.Enabled or Config.CamLockEnabled
        end

        do
            local saL = mS["Silent Aim"].l
            local saR = mS["Silent Aim"].r

            local cSA1 = cC(saL, "Silent Aim")
            local silentAimTogFunc, silentAimBx
            silentAimTogFunc, silentAimBx = cTogBind(cSA1, "Enable Silent Aim", false, cfg.silentAimBind or "",
                function(v)
                    Config.Enabled = v; updateMobileBtnVis()
                    Notify("Silent Aim", "Silent Aim " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                end,
                function(v)
                    return assignBind(v, "silentAimBind", silentAimTogFunc, "Enable Silent Aim", "Silent Aim",
                        silentAimBx)
                end)
            if cfg.silentAimBind and cfg.silentAimBind ~= "" then
                getgenv().YIX_Binds[cfg.silentAimBind:upper()] = {
                    func = silentAimTogFunc,
                    name = "Enable Silent Aim",
                    category = "Silent Aim",
                    cfgKey = "silentAimBind",
                    bx = silentAimBx
                }
            end

            cTog(cSA1, "Show FOV", false, function(v)
                Config.ShowFOV = v
                Notify("Silent Aim", "Show FOV " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Wall Check", true, function(v)
                Config.WallCheck = v
                Notify("Silent Aim", "Wall Check " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Friend Check", true, function(v)
                Config.FriendCheck = v
                Notify("Silent Aim", "Friend Check " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Require Tool Equipped", false, function(v)
                Config.RequireTool = v
                Notify("Silent Aim", "Require Tool " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Enable FOV Fix", isSpecialExe, function(v)
                Config.ExeScaleFOV = v
                Notify("Silent Aim", "FOV Fix " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(cSA1, "FOV Size", 10, 500, 100, function(v) Config.FOV = v end)

            local cSA2 = cC(saR, "Target Settings")
            cDD(cSA2, "Target Part", { "Head", "HumanoidRootPart", "Torso", "Random" }, "Head",
                function(v) Config.TargetPart = v end)

            local cWB = cC(saR, "Wallbang Settings")
            cTog(cWB, "Enable Wallbang", false, function(v)
                Config.Wallbang = v
                Notify("Wallbang", "Wallbang " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(cWB, "Max Penetrations", 1, 10, 3, function(v) Config.MaxWallPenetrations = v end)
        end

        -- Aimbot Sub-Tab (Camera Lock & Mobile Lock)
        do
            local acL = mS["Aimbot"].l
            local acR = mS["Aimbot"].r
            local c1 = cC(acL, "Camera Lock Aimbot")
            local aimbotTogFunc, aimbotBx
            aimbotTogFunc, aimbotBx = cTogBind(c1, "Enable Camera Lock", false, cfg.aimbotBind or "", function(v)
                    Config.CamLockEnabled = v; updateMobileBtnVis()
                    Notify("Aimbot", "Camera Lock " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                end,
                function(v) return assignBind(v, "aimbotBind", aimbotTogFunc, "Enable Camera Lock", "Aimbot", aimbotBx) end)
            if cfg.aimbotBind and cfg.aimbotBind ~= "" then
                getgenv().YIX_Binds[cfg.aimbotBind:upper()] = {
                    func = aimbotTogFunc,
                    name = "Enable Camera Lock",
                    category = "Aimbot",
                    cfgKey = "aimbotBind",
                    bx = aimbotBx
                }
            end
            cTog(c1, "Show FOV", false, function(v)
                Config.ShowFOV = v
                Notify("Aimbot", "Show FOV " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            if isMobileDevice then
                cTog(c1, "Mobile Lock Button", true, function(v)
                    Config.MobileLockEnabled = v; updateMobileBtnVis()
                    Notify("Aimbot", "Mobile Lock Button " .. (v and "Enabled" or "Disabled"), 2,
                        v and "Success" or "Error")
                end)
            end
            cSli(c1, "FOV Size", 10, 500, 100, function(v) Config.FOV = v end)
            cSli(c1, "Max Distance", 50, 2000, 1000, function(v) Config.MaxDistance = v end)

            local c2 = cC(acR, "Camera Smoothness")
            cSli(c2, "Smoothness", 1, 100, 50, function(v) Config.Smoothness = v end)
        end

        -- ===== FOV circle (Drawing API) =====
        local fovCircle
        if Drawing then
            pcall(function()
                fovCircle = Drawing.new("Circle")
                fovCircle.Thickness = 1.5
                fovCircle.NumSides = 64
                fovCircle.Filled = false
                fovCircle.Visible = false
                fovCircle.Color = Color3.fromRGB(255, 255, 255)
            end)
        end

        local function referencePoint(forDrawing)
            local cam = workspace.CurrentCamera
            if Config.ExeScaleFOV then
                local scale = forDrawing and ScaleFactor or 1
                if uis.TouchEnabled and not uis.GamepadEnabled then
                    return cam and (cam.ViewportSize * scale / 2) or Vector2.new(0, 0)
                end
                local mp = uis:GetMouseLocation()
                local inset = guiService:GetGuiInset()
                return Vector2.new((mp.X - inset.X) * scale, (mp.Y - inset.Y) * scale)
            else
                if uis.TouchEnabled and not uis.GamepadEnabled then
                    return cam and (cam.ViewportSize / 2) or Vector2.new(0, 0)
                end
                local mp = uis:GetMouseLocation()
                return Vector2.new(mp.X, mp.Y)
            end
        end

        -- ===== Target selection =====
        local friendCache = {}
        local function isFriend(plr)
            if not Config.FriendCheck then return false end
            if friendCache[plr.UserId] ~= nil then return friendCache[plr.UserId] end
            local ok, result = pcall(function()
                return lp:IsFriendsWith(plr.UserId)
            end)
            local isF = ok and result or false
            friendCache[plr.UserId] = isF
            return isF
        end

        -- ===== Wallbang System =====
        local wallbangMarks = {}

        local function markWallbangPath(fromPos, toPos)
            if not Config.Wallbang then return end

            local char = lp.Character
            local exclude = char and { char } or {}
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = exclude

            local pos = fromPos
            local dir = toPos - fromPos
            local remaining = dir.Magnitude
            if remaining <= 0 then return end
            local unit = dir.Unit
            local hopsLeft = Config.MaxWallPenetrations or 3

            while remaining > 0 and hopsLeft > 0 do
                local result = workspace:Raycast(pos, unit * remaining, params)
                if not result then break end

                local charModel = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
                if charModel and plrs:GetPlayerFromCharacter(charModel) then
                    break
                end

                wallbangMarks[result.Instance] = tick() + (Config.WallbangMarkLifetime or 0.5)
                table.insert(exclude, result.Instance)
                params.FilterDescendantsInstances = exclude

                local traveled = (result.Position - pos).Magnitude
                pos = result.Position + unit * 0.05
                remaining = remaining - traveled
                hopsLeft = hopsLeft - 1
            end
        end

        local function hasLineOfSight(fromPos, targetPos)
            if Config.Wallbang then return true end
            if not Config.WallCheck then return true end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { lp.Character }
            local result = workspace:Raycast(fromPos, (targetPos - fromPos), params)
            if not result then return true end
            local hitChar = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
            return hitChar ~= nil and plrs:GetPlayerFromCharacter(hitChar) ~= nil
        end

        local function getPartName()
            if Config.TargetPart == "Random" then
                local parts = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }
                return parts[math.random(1, #parts)]
            end
            return Config.TargetPart or "Head"
        end

        local function getBestTarget()
            if not Config.Enabled and not Config.CamLockEnabled then return nil end

            if manualLockedTarget then
                if manualLockedTarget.Parent and manualLockedTarget.Parent:FindFirstChildOfClass("Humanoid") then
                    local hum = manualLockedTarget.Parent:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        return manualLockedTarget
                    end
                end
                manualLockedTarget = nil
                mbLockStroke.Color = tm.k
            end

            local cam = workspace.CurrentCamera
            if not cam then return nil end
            local ref = referencePoint()
            local best, bestDist = nil, Config.FOV
            local camPos = cam.CFrame.Position
            local maxDist = Config.MaxDistance or 1000

            for _, plr in ipairs(plrs:GetPlayers()) do
                local isExcludedSilent = getgenv().YIX_ExcludeSilent and getgenv().YIX_ExcludeSilent[plr.Name]
                local isExcludedAimbot = getgenv().YIX_ExcludeAimbot and getgenv().YIX_ExcludeAimbot[plr.Name]
                if plr ~= lp and not isFriend(plr) and not isExcludedSilent and not isExcludedAimbot then
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local targetPartName = getPartName()
                    local part = char and
                        (char:FindFirstChild(targetPartName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))

                    if hum and part and hum.Health > 0 then
                        local worldDist = (camPos - part.Position).Magnitude
                        if worldDist <= maxDist then
                            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - ref).Magnitude
                                if dist < bestDist and hasLineOfSight(camPos, part.Position) then
                                    best, bestDist = part, dist
                                end
                            end
                        end
                    end
                end
            end
            return best
        end

        mbLockBtn.MouseButton1Click:Connect(function()
            if manualLockedTarget then
                manualLockedTarget = nil
                mbLockStroke.Color = tm.k
            else
                local target = getBestTarget()
                if target then
                    manualLockedTarget = target
                    mbLockStroke.Color = tm.a
                end
            end
        end)

        -- ===== Equipped-gun check =====
        local hasGunEquipped = false
        local function checkEquipped(char)
            if not char then return false end
            if not Config.RequireTool then return true end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool:FindFirstChild("Settings") then
                        local ok, isGun = pcall(function() return require(tool.Settings).gunType ~= nil end)
                        if ok and isGun then return true end
                    end
                    return true
                end
            end
            return false
        end
        local function bindChar(char)
            hasGunEquipped = checkEquipped(char)
            if char then
                char.ChildAdded:Connect(function() hasGunEquipped = checkEquipped(char) end)
                char.ChildRemoved:Connect(function() hasGunEquipped = checkEquipped(char) end)
            end
        end
        if lp.Character then bindChar(lp.Character) end
        lp.CharacterAdded:Connect(bindChar)

        -- ===== Hooks: Mouse.Hit (PC) y Camera:ScreenPointToRay (mobile) =====
        if hookmetamethod and getrawmetatable then
            local Mouse = lp:GetMouse()

            local oldIndex
            oldIndex = hookmetamethod(game, "__index", function(self, key)
                if not checkcaller() then
                    if Config.Wallbang and key == "Transparency" then
                        local expire = wallbangMarks[self]
                        if expire then
                            if expire > tick() then
                                return 0.5
                            else
                                wallbangMarks[self] = nil
                            end
                        end
                    end
                    if self == Mouse and key == "Hit" then
                        if Config.Enabled and checkEquipped(lp.Character) then
                            local ok, target = pcall(getBestTarget)
                            if ok and target then
                                local origin = (lp.Character and lp.Character:FindFirstChild("Head")) and
                                    lp.Character.Head.Position or workspace.CurrentCamera.CFrame.Position
                                markWallbangPath(origin, target.Position)
                                return CFrame.new(target.Position)
                            end
                        end
                        if Config.Wallbang and checkEquipped(lp.Character) then
                            local hitCFrame = oldIndex(self, key)
                            if hitCFrame then
                                local origin = (lp.Character and lp.Character:FindFirstChild("Head")) and
                                    lp.Character.Head.Position or workspace.CurrentCamera.CFrame.Position
                                markWallbangPath(origin, hitCFrame.Position)
                            end
                            return hitCFrame
                        end
                    end
                end
                return oldIndex(self, key)
            end)

            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local cam = workspace.CurrentCamera
                if not checkcaller() then
                    if getgenv().YIX_AntiCamera and self and self.Name == "cameraZoneFunction" and (method == "FireServer" or method == "InvokeServer") then
                        local args = { ... }
                        if args[1] == true then
                            args[1] = false
                            return oldNamecall(self, unpack(args))
                        end
                    end
                    if cam and self == cam and method == "ScreenPointToRay" then
                        if Config.Enabled and checkEquipped(lp.Character) then
                            local ok, target = pcall(getBestTarget)
                            if ok and target then
                                local origin = (lp.Character and lp.Character:FindFirstChild("Head")) and
                                    lp.Character.Head.Position or cam.CFrame.Position
                                markWallbangPath(origin, target.Position)
                                return Ray.new(cam.CFrame.Position, (target.Position - cam.CFrame.Position).Unit)
                            end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
        end

        rs.RenderStepped:Connect(function()
            local showCircle = (Config.Enabled or Config.CamLockEnabled) and Config.ShowFOV

            if fovCircle then
                fovCircle.Position = referencePoint(true)
                fovCircle.Radius = Config.ExeScaleFOV and (Config.FOV * ScaleFactor) or Config.FOV
                fovCircle.Visible = showCircle
            end

            if uiFovCircle then
                uiFovCircle.Visible = showCircle and not fovCircle
                if uiFovCircle.Visible then
                    local refPos = referencePoint(false)
                    local rad = Config.FOV
                    uiFovCircle.Position = UDim2.new(0, refPos.X - rad, 0, refPos.Y - rad)
                    uiFovCircle.Size = UDim2.new(0, rad * 2, 0, rad * 2)
                end
            end

            if Config.CamLockEnabled and checkEquipped(lp.Character) then
                local targetPart = getBestTarget()
                if targetPart and targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid") then
                    local hum = targetPart.Parent:FindFirstChildOfClass("Humanoid")
                    if hum.Health > 0 then
                        local cam = workspace.CurrentCamera
                        if cam then
                            local camPos = cam.CFrame.Position
                            local targetPos = targetPart.Position
                            local targetCFrame = CFrame.new(camPos, targetPos)
                            local alpha = math.clamp((101 - (Config.Smoothness or 50)) / 100, 0.05, 1)
                            cam.CFrame = cam.CFrame:Lerp(targetCFrame, alpha)
                        end
                    end
                end
            end
        end)

        -- Gun Mods Sub-Tab
        getgenv().YIX_GunMods_NoRecoil = false
        getgenv().YIX_GunMods_NoSpread = false
        getgenv().YIX_GunMods_NoJam = false
        getgenv().YIX_GunMods_AutoFire = false
        getgenv().YIX_GunMods_FireSpeed = 1

        do
            local gm1 = cC(mS["Gun Mods"].l, "Gun Mods")
            cTog(gm1, "No Recoil", false, function(v)
                getgenv().YIX_GunMods_NoRecoil = v
                Notify("Gun Mods", "No Recoil " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "No Spread", false, function(v)
                getgenv().YIX_GunMods_NoSpread = v
                Notify("Gun Mods", "No Spread " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "No Jam", false, function(v)
                getgenv().YIX_GunMods_NoJam = v
                Notify("Gun Mods", "No Jam " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "Automatic Fire", false, function(v)
                getgenv().YIX_GunMods_AutoFire = v
                Notify("Gun Mods", "Automatic Fire " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(gm1, "Fire Speed Multiplier", 1, 20, 1, function(v) getgenv().YIX_GunMods_FireSpeed = v end)
        end

        local originalGunSettings = {}

        task.spawn(function()
            while task.wait(0.5) do
                local char = lp.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local settingsModule = tool:FindFirstChild("Settings")
                            if settingsModule and settingsModule:IsA("ModuleScript") then
                                local s, settingsTable = pcall(require, settingsModule)
                                if s and type(settingsTable) == "table" then
                                    if not originalGunSettings[settingsModule] then
                                        originalGunSettings[settingsModule] = {
                                            recoil = settingsTable.recoil or 0,
                                            spread = settingsTable.spread or 0,
                                            jamChance = settingsTable.jamChance or 0,
                                            jamIncrease = settingsTable.jamIncrease or 0,
                                            fireMode = settingsTable.fireMode or "semi",
                                            semiCooldown = settingsTable.semiCooldown or 0.1,
                                            autoCooldown = settingsTable.autoCooldown or 0.1
                                        }
                                    end

                                    local orig = originalGunSettings[settingsModule]

                                    settingsTable.recoil = getgenv().YIX_GunMods_NoRecoil and 0 or orig.recoil
                                    settingsTable.spread = getgenv().YIX_GunMods_NoSpread and 0 or orig.spread

                                    if getgenv().YIX_GunMods_NoJam then
                                        settingsTable.jamChance = 0
                                        settingsTable.jamIncrease = 0
                                    else
                                        settingsTable.jamChance = orig.jamChance
                                        settingsTable.jamIncrease = orig.jamIncrease
                                    end

                                    settingsTable.fireMode = getgenv().YIX_GunMods_AutoFire and "auto" or orig.fireMode

                                    local speedMulti = getgenv().YIX_GunMods_FireSpeed or 1
                                    settingsTable.semiCooldown = orig.semiCooldown / speedMulti
                                    settingsTable.autoCooldown = orig.autoCooldown / speedMulti
                                end
                            end
                        end
                    end
                end
            end
        end)
    end -- End Main Tab

    do  -- Farms Tab
        fT = cMT("Farms", "119601525391403", false)
        fS = cSM(fT, { "General" })
        fL = fS["General"].l
        fR = fS["General"].r
        f1 = cC(fL, "Trash Farm")

        local autoTrashOn = false
        cTog(f1, "Auto Trash", false, function(v)
            autoTrashOn = v
            if v then
                Notify("Trash Farm", "Auto Trash Farm Activated!", 3, "Success")
            else
                Notify("Trash Farm", "Auto Trash Farm Deactivated!", 3, "Error")
            end
        end)

        task.spawn(function()
            while task.wait(0.1) do
                if autoTrashOn then
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if char and hum and hrp and hum.Health > 0 then
                        local bag = char:FindFirstChild("Trash Bag") or lp.Backpack:FindFirstChild("Trash Bag")

                        if not bag then
                            -- 1. No tenemos bolsa, ir a buscarla
                            local targetPos = Vector3.new(284, 4, 795)
                            if (hrp.Position - targetPos).Magnitude > 15 then
                                local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                                if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

                                hrp.Anchored = true
                                task.wait(0.05)
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.05)
                                hrp.Anchored = false

                                if JuneEvent then
                                    firesignal(JuneEvent.OnClientEvent, false)
                                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end
                                task.wait(1) -- Esperar a que el mapa cargue los objetos
                            end

                            local getPrompt = workspace:FindFirstChild("Interactions")
                                and workspace.Interactions:FindFirstChild("toolInteractions")
                                and workspace.Interactions.toolInteractions:FindFirstChild("TrashPart")
                                and workspace.Interactions.toolInteractions.TrashPart:FindFirstChild("Interaction")

                            if getPrompt then
                                if getPrompt:IsA("ProximityPrompt") then
                                    fireproximityprompt(getPrompt)
                                elseif getPrompt:IsA("ClickDetector") then
                                    fireclickdetector(getPrompt)
                                end
                                task.wait(0.5) -- Esperar a que la bolsa aparezca
                            end
                        else
                            -- 2. Tenemos la bolsa, equiparla y venderla
                            if bag.Parent ~= char and bag.Parent ~= nil then
                                hum:EquipTool(bag)
                                task.wait(0.2)
                            end

                            local sellPart = workspace:FindFirstChild("Interactions")
                                and workspace.Interactions:FindFirstChild("sellInteractions")
                                and workspace.Interactions.sellInteractions:FindFirstChild("trashPart")
                            local sellPrompt = sellPart and sellPart:FindFirstChild("Interaction")

                            if sellPart and sellPrompt then
                                local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                                if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

                                hrp.Anchored = true
                                task.wait(0.05)
                                hrp.CFrame = sellPart.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.05)
                                hrp.Anchored = false

                                if JuneEvent then
                                    firesignal(JuneEvent.OnClientEvent, false)
                                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end

                                -- Checar seguridad: si se desequipó mientras teletransportaba, reequipamos y disparamos
                                if not char:FindFirstChild("Trash Bag") and bag.Parent ~= nil then
                                    hum:EquipTool(bag)
                                    task.wait(0.2)
                                end

                                if char:FindFirstChild("Trash Bag") then
                                    if sellPrompt:IsA("ProximityPrompt") then
                                        sellPrompt.HoldDuration = 0
                                        sellPrompt:InputHoldBegin()
                                        task.wait()
                                        sellPrompt:InputHoldEnd()
                                    elseif sellPrompt:IsA("ClickDetector") then
                                        fireclickdetector(sellPrompt)
                                    end
                                end
                                task.wait(0.5) -- Esperar a que se procese la venta (si no se vendió, repetirá el loop)
                            end
                        end
                    end
                end
            end
        end)

        -- RollbackDupe Card (under Trash Farm in Farms tab)
        local cardRollback = cC(fL, "RollbackDupe")

        local descRollback = Instance.new("TextLabel")
        descRollback.Size = UDim2.new(1, 0, 0, 0)
        descRollback.AutomaticSize = Enum.AutomaticSize.Y
        descRollback.BackgroundTransparency = 1
        descRollback.Text =
        "To use this option, you need to own the Change Name gamepass. Make sure you have it, otherwise it will not work."
        descRollback.TextColor3 = tm.st
        descRollback.Font = tm.f
        descRollback.TextSize = 11
        descRollback.TextWrapped = true
        descRollback.TextXAlignment = Enum.TextXAlignment.Left
        descRollback.ZIndex = 9
        descRollback.Parent = cardRollback
        table.insert(allT, { descRollback, "st", false })

        cBtn(cardRollback, "Start Rollback Dupe", function()
            task.spawn(function()
                local MarketplaceService = game:GetService("MarketplaceService")
                local GuiService = game:GetService("GuiService")
                local VirtualInputManager = game:GetService("VirtualInputManager")

                local GAMEPASS_ID = 1204887889

                local function activarBoton(rawButton)
                    if not rawButton then return false end

                    local button = rawButton
                    if not (button:IsA("GuiButton")) then
                        local foundBtn = rawButton:FindFirstChildOfClass("TextButton") or
                            rawButton:FindFirstChildOfClass("ImageButton") or
                            rawButton:FindFirstChildOfClass("GuiButton")
                        if foundBtn then button = foundBtn end
                    end

                    pcall(function()
                        button.Visible = true
                        button.Active = true
                        button.Selectable = true
                    end)

                    local absPos = button.AbsolutePosition
                    local absSize = button.AbsoluteSize
                    local guiInset = GuiService:GetGuiInset()

                    local clickX = absPos.X + (absSize.X / 2)
                    local clickY = absPos.Y + (absSize.Y / 2) + guiInset.Y

                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
                    end)

                    pcall(function()
                        VirtualInputManager:SendTouchEvent(1, 0, clickX, clickY, game)
                        task.wait(0.02)
                        VirtualInputManager:SendTouchEvent(1, 2, clickX, clickY, game)
                    end)

                    pcall(function() button:Activate() end)

                    if firesignal then
                        pcall(function() firesignal(button.MouseButton1Down) end)
                        pcall(function() firesignal(button.MouseButton1Up) end)
                        pcall(function() firesignal(button.MouseButton1Click) end)
                        pcall(function() firesignal(button.Activated) end)
                        pcall(function() firesignal(button.TouchTap) end)
                    end

                    if getconnections then
                        for _, evt in ipairs({ button.MouseButton1Click, button.Activated, button.MouseButton1Down, button.MouseButton1Up, button.TouchTap }) do
                            pcall(function()
                                for _, conn in ipairs(getconnections(evt)) do
                                    conn:Fire()
                                end
                            end)
                        end
                    end

                    if button.Visible and button.AbsoluteSize.X > 0 and button.AbsoluteSize.Y > 0 then
                        pcall(function()
                            GuiService.AutoSelectGuiEnabled = true
                            GuiService.SelectedObject = button
                            task.wait(0.03)

                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            task.wait(0.04)

                            GuiService.SelectedObject = nil
                            GuiService.AutoSelectGuiEnabled = false
                            GuiService.GuiNavigationEnabled = false
                        end)
                    end

                    return true
                end

                local ownsPass = false
                pcall(function()
                    ownsPass = MarketplaceService:UserOwnsGamePassAsync(lp.UserId, GAMEPASS_ID)
                end)

                if not ownsPass then
                    Notify("Rollback Dupe Error", "You need to own the 'Change Name' GamePass to use Rollback Dupe!", 4,
                        "Error")
                    return
                end

                Notify("Rollback Dupe", "Rollback Dupe executed successfully!", 3, "Success")

                local playerGui = lp:WaitForChild("PlayerGui", 5)
                local mainGUI = playerGui and playerGui:WaitForChild("MainGUI", 5)
                local clinicFrame = mainGUI and mainGUI:WaitForChild("clinicFrame", 5)

                if not clinicFrame then return end

                pcall(function()
                    clinicFrame.Visible = true
                    if clinicFrame.Parent and clinicFrame.Parent:IsA("GuiObject") then
                        clinicFrame.Parent.Visible = true
                    end
                end)

                local clinicEvent = clinicFrame:FindFirstChild("textboxEntry")
                if clinicEvent then
                    for i = 1, 3 do
                        task.spawn(function()
                            if clinicEvent:IsA("RemoteEvent") then
                                clinicEvent:FireServer("How \xED\xBE\x8C")
                            elseif clinicEvent:IsA("TextBox") then
                                clinicEvent.Text = "How \xED\xBE\x8C"
                            end
                        end)
                    end
                end

                task.wait(0.1)

                local firstNameButton = clinicFrame:WaitForChild("firstNameButton", 5)
                if firstNameButton then
                    for i = 1, 3 do
                        task.spawn(function()
                            activarBoton(firstNameButton)
                        end)
                    end
                end

                pcall(function()
                    GuiService.SelectedObject = nil
                    GuiService.AutoSelectGuiEnabled = false
                    GuiService.GuiNavigationEnabled = false
                end)
            end)
        end)

        -- House Robbery Farm
        fHouseCard = cC(fR, "House Robbery")

        local autoHouseRobOn = false
        local houseRobTog
        houseRobTog = cTog(fHouseCard, "Auto House Rob", false, function(v)
            if v then
                if cfg.houseRobJobId ~= "" and cfg.houseRobJobId ~= game.JobId then
                    cfg.houseRobCooldownEnd = 0
                    cfg.houseRobJobId = game.JobId
                    sCF()
                end

                local remaining = (cfg.houseRobCooldownEnd or 0) - os.time()
                if remaining > 0 then
                    local mins = math.floor(remaining / 60)
                    local secs = remaining % 60
                    autoHouseRobOn = false
                    if houseRobTog then houseRobTog.Set(false, true) end
                    Notify("House Robbery Cooldown",
                        string.format("Please wait %dm %ds before farming houses again!", mins, secs), 4, "Error")
                    return
                end
                autoHouseRobOn = true
                Notify("House Robbery", "Auto House Rob Activated!", 3, "Success")
            else
                autoHouseRobOn = false
                Notify("House Robbery", "Auto House Rob Deactivated!", 3, "Error")
            end
        end)

        local function tpJune(targetCFrame)
            local char = lp.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not (char and hum and hrp and hum.Health > 0) then return end

            local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
            if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

            local function doTP()
                hrp.Anchored = true
                task.wait(0.05)
                hrp.CFrame = targetCFrame
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                task.wait(0.05)
                hrp.Anchored = false
            end

            doTP()

            if JuneEvent then
                firesignal(JuneEvent.OnClientEvent, false)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end

            -- Detección de caída fuera del mapa (Re-TP inmediato si cae al vacío)
            local maxReTPs = 3
            for i = 1, maxReTPs do
                task.wait(0.05)
                if not (hrp and hrp.Parent) then break end
                local curY = hrp.Position.Y
                local targetY = targetCFrame.Position.Y
                local velY = hrp.AssemblyLinearVelocity.Y

                local isFalling = (curY < targetY - 12) or (velY < -40) or (curY < -50)
                if isFalling then
                    if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end
                    doTP()
                    if JuneEvent then
                        firesignal(JuneEvent.OnClientEvent, false)
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                else
                    break
                end
            end
        end

        local function sellToolList(toolFilter, prompt, customWait)
            local char = lp.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local bp = lp:FindFirstChild("Backpack")
            if not (char and hum and bp) then return end

            local toolsToSell = {}
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and toolFilter(t) then
                    table.insert(toolsToSell, t)
                end
            end
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and toolFilter(t) then
                    table.insert(toolsToSell, t)
                end
            end

            local waitTime = customWait or 0.25
            for _, tool in ipairs(toolsToSell) do
                if tool and tool.Parent ~= nil then
                    if tool.Parent ~= char then
                        hum:EquipTool(tool)
                        task.wait(0.2)
                        if tool.Parent ~= char then
                            tool.Parent = char
                            task.wait(0.1)
                        end
                    end
                    if prompt then
                        if prompt:IsA("ProximityPrompt") then
                            prompt.HoldDuration = 0
                            prompt:InputHoldBegin()
                            task.wait(0.05)
                            prompt:InputHoldEnd()
                        elseif prompt:IsA("ClickDetector") then
                            fireclickdetector(prompt)
                        end
                        task.wait(waitTime)
                    end
                end
            end
        end

        cBtn(fHouseCard, "Sell Items", function()
            local char = lp.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local bp = lp:FindFirstChild("Backpack")
            if not (char and hum and hrp and bp and hum.Health > 0) then return end

            local startPosCF = hrp.CFrame

            local function hasItemsMatching(filterFunc)
                local c = lp.Character
                local b = lp:FindFirstChild("Backpack")
                if b then
                    for _, t in ipairs(b:GetChildren()) do
                        if t:IsA("Tool") and filterFunc(t) then return true end
                    end
                end
                if c then
                    for _, t in ipairs(c:GetChildren()) do
                        if t:IsA("Tool") and filterFunc(t) then return true end
                    end
                end
                return false
            end

            local isMoney = function(item)
                local n = (type(item) == "string" and item) or
                    (typeof(item) == "Instance" and item:IsA("Tool") and item.Name) or
                    ""
                local lowerN = n:lower()
                return lowerN:find("dirty money") ~= nil or lowerN:find("money") ~= nil or lowerN:find("stolen") ~= nil
            end

            local isRepz = function(item)
                local n = (type(item) == "string" and item) or
                    (typeof(item) == "Instance" and item:IsA("Tool") and item.Name) or
                    ""
                return n:lower():find("repz") ~= nil
            end

            -- 1. FASE DINERO SUCIO (Repetir hasta vender TODO el dinero sucio)
            if hasItemsMatching(isMoney) then
                tpJune(CFrame.new(46, 4, 791))
                task.wait(0.2)
                tpJune(CFrame.new(46, 4, 791))
                task.wait(0.4)

                local lootPart = workspace:FindFirstChild("Interactions")
                    and workspace.Interactions:FindFirstChild("sellInteractions")
                    and workspace.Interactions.sellInteractions:FindFirstChild("lootPart")
                local lootPrompt = lootPart and
                    (lootPart:FindFirstChild("Interaction") or lootPart:FindFirstChildWhichIsA("ProximityPrompt", true))

                local moneyAttempts = 0
                while hasItemsMatching(isMoney) and moneyAttempts < 5 do
                    moneyAttempts = moneyAttempts + 1
                    sellToolList(isMoney, lootPrompt)
                    task.wait(0.4)
                end
            end

            -- 2. FASE REPLICAS / REPZ (Solo pasa si ya no queda dinero y hay repz)
            if hasItemsMatching(isRepz) then
                tpJune(CFrame.new(2487, -29, -367))
                task.wait(0.2)
                tpJune(CFrame.new(2487, -29, -367))
                task.wait(0.4)

                local repzPart = workspace:FindFirstChild("Interactions")
                    and workspace.Interactions:FindFirstChild("sellInteractions")
                    and workspace.Interactions.sellInteractions:FindFirstChild("repzPart")
                local repzPrompt = repzPart and
                    (repzPart:FindFirstChild("Interaction") or repzPart:FindFirstChildWhichIsA("ProximityPrompt", true))

                if not repzPrompt then
                    for _, desc in ipairs(workspace:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Parent:IsA("BasePart") then
                            if (desc.Parent.Position - Vector3.new(2487, -29, -367)).Magnitude < 25 then
                                repzPrompt = desc
                                break
                            end
                        end
                    end
                end

                local repzAttempts = 0
                while hasItemsMatching(isRepz) and repzAttempts < 5 do
                    repzAttempts = repzAttempts + 1
                    sellToolList(isRepz, repzPrompt)
                    task.wait(0.4)
                end
            end

            -- 3. REGRESO A LA POSICIÓN INICIAL (Si se vendió todo correctamente)
            if not hasItemsMatching(isMoney) and not hasItemsMatching(isRepz) and startPosCF then
                tpJune(startPosCF)
            end
        end)

        cBtn(fHouseCard, "Sell Guns", function()
            local char = lp.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local bp = lp:FindFirstChild("Backpack")
            if not (char and hum and hrp and bp and hum.Health > 0) then return end

            local hasBackpackEquipped = char:FindFirstChild("Backpack") or char:FindFirstChild("Duffle Bag") or
                char:FindFirstChild("Bag")
            if not hasBackpackEquipped then
                Notify("Sell Guns Error", "You need a Backpack equipped to sell guns!", 4, "Error")
                return
            end

            local function isGunTool(tool)
                if not tool then return false end
                local tName = (type(tool) == "string" and tool) or (tool:IsA("Tool") and tool.Name)
                if not tName then return false end
                if tName:upper():find("G2C") then return false end

                if type(tool) == "userdata" and tool:IsA("Tool") then
                    if tool:FindFirstChild("firearmClient") or tool:FindFirstChild("firearmServer") or tool:FindFirstChild("GunClient") or tool:FindFirstChild("GunServer") then
                        return true
                    end
                end

                local upperN = tName:upper()
                return upperN:find("AR15") or upperN:find("AR-15") or upperN:find("M9") or upperN:find("AK") or
                    upperN:find("GLOCK") or upperN:find("RIFLE") or upperN:find("PISTOL") or upperN:find("SHOTGUN")
            end

            local function hasGunsRemaining()
                local c = lp.Character
                local b = lp:FindFirstChild("Backpack")
                if b then
                    for _, t in ipairs(b:GetChildren()) do
                        if isGunTool(t) then return true end
                    end
                end
                if c then
                    for _, t in ipairs(c:GetChildren()) do
                        if isGunTool(t) then return true end
                    end
                end
                return false
            end

            if not hasGunsRemaining() then
                Notify("Sell Guns", "No guns found in inventory!", 3, "Error")
                return
            end

            local startPosCF = hrp.CFrame

            -- 1. Doble TP a zona de venta (181, 4, 957)
            tpJune(CFrame.new(181, 4, 957))
            task.wait(0.2)
            tpJune(CFrame.new(181, 4, 957))
            task.wait(0.4)

            -- 2. Buscar ProximityPrompt de SellGuns
            local sellGunsPrompt = workspace:FindFirstChild("SellGunsPart") and
                workspace.SellGunsPart:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not sellGunsPrompt then
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        if desc.Name:lower():find("gun") or (desc.Parent and desc.Parent.Name:lower():find("gun")) then
                            sellGunsPrompt = desc
                            break
                        end
                    end
                end
            end

            -- 3. Equipar y vender armas repetidamente hasta vaciar inventario
            local sellAttempts = 0
            while hasGunsRemaining() and sellAttempts < 5 do
                sellAttempts = sellAttempts + 1
                sellToolList(isGunTool, sellGunsPrompt, 0.05)
                task.wait(0.3)
            end

            -- 4. Regreso a la posición inicial una vez vendidas todas las armas
            if startPosCF then
                task.wait(0.2)
                tpJune(startPosCF)
                Notify("Sell Guns", "All guns sold successfully!", 3, "Success")
            end
        end)

        local function getStrength()
            local settings = lp:FindFirstChild("Settings")
            local abilities = settings and settings:FindFirstChild("Abilities")
            if abilities then
                local st = abilities:FindFirstChild("Strength") or abilities:GetAttribute("Strength")
                if st then
                    return type(st) == "userdata" and st.Value or st
                end
            end
            if settings and settings:FindFirstChild("Strength") then return settings.Strength.Value end
            if lp:FindFirstChild("Strength") then return lp.Strength.Value end
            return 100
        end

        task.spawn(function()
            while task.wait(0.5) do
                if autoHouseRobOn then
                    local char = lp.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if char and hum and hrp and hum.Health > 0 then
                        local currentStr = getStrength()
                        if currentStr < 50 then
                            warn("[YIX] Fuerza insuficiente (" ..
                                tostring(currentStr) .. "/50). Desactivando Auto House Rob.")
                            autoHouseRobOn = false
                        else
                            local startRobCF = hrp.CFrame
                            local houses = {}
                            for _, child in ipairs(workspace:GetChildren()) do
                                if child.Name:lower():find("houserobbery") then
                                    local cf = child:IsA("Model") and child:GetPivot() or
                                        (child:IsA("BasePart") and child.CFrame)
                                    if cf then
                                        local pos = cf.Position
                                        -- Skipear explícitamente la casa lejana inutilizable (pos: 2964, -24, 817)
                                        local isSkipped = (pos - Vector3.new(2964.3, -24.8, 817.6)).Magnitude < 200 or
                                            pos.X > 2000
                                        if not isSkipped then
                                            table.insert(houses, child)
                                        end
                                    end
                                end
                            end

                            for idx, house in ipairs(houses) do
                                if not autoHouseRobOn then break end

                                -- Realizar 2 recorridos completos en esta casa (4 en total entre las 2 casas)
                                for run = 1, 2 do
                                    if not autoHouseRobOn then break end

                                    local houseCF
                                    if house:IsA("Model") then
                                        houseCF = house:GetPivot()
                                    elseif house:IsA("BasePart") then
                                        houseCF = house.CFrame
                                    end

                                    if houseCF then
                                        tpJune(houseCF * CFrame.new(0, 3, 0))
                                        task.wait(0.8)
                                    end

                                    -- 1. KickDoor1
                                    local door1 = house:FindFirstChild("KickDoor1")
                                    if door1 then
                                        tpJune(door1.CFrame * CFrame.new(0, 0, 3))
                                        task.wait(0.2)
                                        local prompt1 = door1:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt1 then
                                            prompt1.HoldDuration = 0
                                            for k = 1, 4 do
                                                if not autoHouseRobOn then break end
                                                fireproximityprompt(prompt1)
                                                task.wait(0.15)
                                            end
                                        end
                                    end

                                    -- 2. Cash Loot (Habitacion 1)
                                    for _, desc in ipairs(house:GetChildren()) do
                                        if not autoHouseRobOn then break end
                                        if desc.Name == "Cash" then
                                            local p = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
                                            if p and desc:IsA("BasePart") then
                                                p.HoldDuration = 0
                                                tpJune(desc.CFrame * CFrame.new(0, 2, 0))
                                                task.wait(0.15)
                                                fireproximityprompt(p)
                                                task.wait(0.3)
                                            end
                                        end
                                    end

                                    -- 3. KickDoor2
                                    local door2 = house:FindFirstChild("KickDoor2")
                                    if door2 then
                                        tpJune(door2.CFrame * CFrame.new(0, 0, 3))
                                        task.wait(0.2)
                                        local prompt2 = door2:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt2 then
                                            prompt2.HoldDuration = 0
                                            for k = 1, 4 do
                                                if not autoHouseRobOn then break end
                                                fireproximityprompt(prompt2)
                                                task.wait(0.15)
                                            end
                                        end
                                    end

                                    -- 4. Habitacion 2 Loot (Duffle Bag, Box, etc.)
                                    for _, desc in ipairs(house:GetChildren()) do
                                        if not autoHouseRobOn then break end
                                        if desc.Name == "Duffle Bag" or desc.Name == "Box" or (desc.Name ~= "KickDoor1" and desc.Name ~= "KickDoor2" and desc.Name ~= "Cash" and desc:FindFirstChildWhichIsA("ProximityPrompt", true)) then
                                            local p = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
                                            if p and desc:IsA("BasePart") then
                                                p.HoldDuration = 0
                                                tpJune(desc.CFrame * CFrame.new(0, 2, 0))
                                                task.wait(0.15)
                                                fireproximityprompt(p)
                                                task.wait(0.4)
                                            end
                                        end
                                    end

                                    task.wait(0.5)
                                end
                            end

                            -- Al completar los recorridos totales, regresar a la posición inicial, activar cooldown de 10 min y apagar el toggle
                            if startRobCF then
                                tpJune(startRobCF)
                            end
                            autoHouseRobOn = false
                            cfg.houseRobCooldownEnd = os.time() + 600
                            cfg.houseRobJobId = game.JobId
                            sCF()
                            if houseRobTog then
                                houseRobTog.Set(false, true)
                            end
                            Notify("House Robbery Complete", "Finished robbing houses! 10 minute cooldown active.", 4,
                                "Success")
                        end
                    end
                end
            end
        end)
    end -- End Farms Tab

    do  -- Visuals Tab
        getgenv().YIX_ExcludeSilent = getgenv().YIX_ExcludeSilent or {}
        getgenv().YIX_ExcludeAimbot = getgenv().YIX_ExcludeAimbot or {}
        getgenv().YIX_ExcludeVisual = getgenv().YIX_ExcludeVisual or {}
        getgenv().YIX_PriorityPlayer = getgenv().YIX_PriorityPlayer or {}

        vT = cMT("Visuals", "96184323261594", false)
        vS = cSM(vT, { "ESP", "World", "Config" })
        vcL = vS["ESP"].l
        vc1 = cC(vcL, "Visual Options")

        getgenv().YIX_Priority_ShowSkull = getgenv().YIX_Priority_ShowSkull ~= false
        getgenv().YIX_Priority_SkullColor = getgenv().YIX_Priority_SkullColor or Color3.new(1, 1, 1)
        getgenv().YIX_Priority_EnableChams = getgenv().YIX_Priority_EnableChams ~= false
        getgenv().YIX_Priority_BlinkChams = getgenv().YIX_Priority_BlinkChams ~= false
        getgenv().YIX_Priority_ChamsColor = getgenv().YIX_Priority_ChamsColor or Color3.fromRGB(255, 0, 0)

        local vcL_Cfg = vS["Config"].l
        local vcR_Cfg = vS["Config"].r

        local cardConfig = cC(vcL_Cfg, "Silent/Visual Config")
        local cardPlayerSelector = cC(vcR_Cfg, "Player Selector")
        local cardPriorityCfg = cC(vcR_Cfg, "Priority Config")

        cTog(cardPriorityCfg, "Enable Skull Icon", getgenv().YIX_Priority_ShowSkull, function(v)
            getgenv().YIX_Priority_ShowSkull = v
        end)
        cCP(cardPriorityCfg, "Skull Color", { 0, 0, 1 }, function(hsv)
            getgenv().YIX_Priority_SkullColor = Color3.fromHSV(hsv[1], hsv[2], hsv[3])
        end)

        cTog(cardPriorityCfg, "Enable Priority Chams", getgenv().YIX_Priority_EnableChams, function(v)
            getgenv().YIX_Priority_EnableChams = v
        end)
        cTog(cardPriorityCfg, "Blinking Chams", getgenv().YIX_Priority_BlinkChams, function(v)
            getgenv().YIX_Priority_BlinkChams = v
        end)
        cCP(cardPriorityCfg, "Chams Color", { 0, 1, 1 }, function(hsv)
            getgenv().YIX_Priority_ChamsColor = Color3.fromHSV(hsv[1], hsv[2], hsv[3])
        end)

        local selectedPlayersMap = {}
        local togSilent, togAimbot, togVisual, togPriority
        local updateTogglesForSelectedPlayers

        local function getSelectedPlayerNames()
            local names = {}
            for pName, isSel in pairs(selectedPlayersMap) do
                if isSel then
                    table.insert(names, pName)
                end
            end
            return names
        end

        local function cMultiPlayerDD(pC, t)
            local cr = Instance.new("Frame")
            cr.Size = UDim2.new(1, 0, 0, 0)
            cr.AutomaticSize = Enum.AutomaticSize.Y
            cr.BackgroundTransparency = 1
            cr.ZIndex = 15
            cr.Parent = pC

            local lo = Instance.new("UIListLayout")
            lo.SortOrder = Enum.SortOrder.LayoutOrder
            lo.Padding = UDim.new(0, 4)
            lo.Parent = cr

            local hd = Instance.new("TextButton")
            hd.Size = UDim2.new(1, 0, 0, 32)
            hd.BackgroundColor3 = tm.m
            hd.Text = ""
            hd.AutoButtonColor = false
            hd.ZIndex = 16
            hd.Parent = cr
            table.insert(allB, { hd, "m" })

            local hdc = Instance.new("UICorner")
            hdc.CornerRadius = UDim.new(0, 4)
            hdc.Parent = hd

            local hds = Instance.new("UIStroke")
            hds.Color = tm.k
            hds.Parent = hd
            table.insert(allB, { hds, "k" })

            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, -40, 1, 0)
            tl.Position = UDim2.new(0, 10, 0, 0)
            tl.BackgroundTransparency = 1
            tl.Text = t .. ": None"
            tl.TextColor3 = tm.st
            tl.Font = tm.f
            tl.TextSize = 12
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.TextTruncate = Enum.TextTruncate.AtEnd
            tl.ZIndex = 17
            tl.Parent = hd
            table.insert(allT, { tl, "st", false })

            local ic = Instance.new("TextLabel")
            ic.Size = UDim2.new(0, 20, 0, 20)
            ic.Position = UDim2.new(1, -25, 0.5, -10)
            ic.BackgroundTransparency = 1
            ic.Text = "+"
            ic.TextColor3 = tm.st
            ic.Font = tm.f
            ic.TextSize = 16
            ic.ZIndex = 17
            ic.Parent = hd
            table.insert(allT, { ic, "st", false })

            local oc = Instance.new("ScrollingFrame")
            oc.Size = UDim2.new(1, 0, 0, 0)
            oc.BackgroundColor3 = tm.m
            oc.Visible = false
            oc.ClipsDescendants = true
            oc.BorderSizePixel = 0
            oc.ScrollBarThickness = 3
            oc.ScrollBarImageColor3 = tm.st
            oc.ZIndex = 20
            oc.Parent = cr
            table.insert(allB, { oc, "m" })

            local occ = Instance.new("UICorner")
            occ.CornerRadius = UDim.new(0, 4)
            occ.Parent = oc

            local ocs = Instance.new("UIStroke")
            ocs.Color = tm.k
            ocs.Parent = oc
            table.insert(allB, { ocs, "k" })

            local ol = Instance.new("UIListLayout")
            ol.SortOrder = Enum.SortOrder.LayoutOrder
            ol.Parent = oc

            local isO = false

            local function updateHeaderText()
                local count = 0
                local lastSelected = ""
                for pName, isSel in pairs(selectedPlayersMap) do
                    if isSel then
                        count = count + 1
                        lastSelected = pName
                    end
                end

                if count == 0 then
                    tl.Text = t .. ": None"
                elseif count == 1 then
                    tl.Text = t .. ": " .. lastSelected
                else
                    tl.Text = t .. ": (" .. count .. " Selected)"
                end
            end

            local function populateOptions()
                for _, child in ipairs(oc:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                local pList = {}
                for _, p in ipairs(plrs:GetPlayers()) do
                    if p ~= lp then
                        table.insert(pList, p.Name)
                    end
                end
                table.sort(pList)

                if #pList == 0 then
                    table.insert(pList, "No Players")
                end

                local totalH = math.min(#pList * 28, 160)
                oc.CanvasSize = UDim2.new(0, 0, 0, #pList * 28)

                for _, pName in ipairs(pList) do
                    local isSel = selectedPlayersMap[pName] or false
                    local ob = Instance.new("TextButton")
                    ob.Size = UDim2.new(1, 0, 0, 28)
                    ob.BackgroundTransparency = 1
                    ob.Text = (isSel and "  [✓] " or "  [   ] ") .. pName
                    ob.TextColor3 = isSel and getAccentColor() or tm.t
                    ob.Font = tm.f
                    ob.TextSize = 12
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.Active = true
                    ob.ZIndex = 21
                    ob.Parent = oc
                    table.insert(allT, { ob, "t", false })

                    ob.MouseEnter:Connect(function()
                        ob.TextColor3 = getAccentColor()
                    end)
                    ob.MouseLeave:Connect(function()
                        local curSel = selectedPlayersMap[pName] or false
                        ob.TextColor3 = curSel and getAccentColor() or tm.t
                    end)

                    ob.MouseButton1Click:Connect(function()
                        if pName == "No Players" then return end
                        local newSel = not (selectedPlayersMap[pName] or false)
                        selectedPlayersMap[pName] = newSel
                        ob.Text = (newSel and "  [✓] " or "  [   ] ") .. pName
                        ob.TextColor3 = newSel and getAccentColor() or tm.t

                        if not newSel then
                            getgenv().YIX_PriorityPlayer[pName] = false
                            getgenv().YIX_ExcludeSilent[pName] = false
                            getgenv().YIX_ExcludeAimbot[pName] = false
                            getgenv().YIX_ExcludeVisual[pName] = false
                        end

                        updateHeaderText()
                        if updateTogglesForSelectedPlayers then
                            updateTogglesForSelectedPlayers()
                        end
                    end)
                end

                return totalH
            end

            hd.MouseButton1Click:Connect(function()
                isO = not isO
                if isO then
                    local tH = populateOptions()
                    oc.Visible = true
                    ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.new(1, 0, 0, tH) }):Play()
                else
                    ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = UDim2.new(1, 0, 0, 0) }):Play()
                    task.delay(0.2, function() if not isO then oc.Visible = false end end)
                end
                ic.Text = isO and "-" or "+"
            end)

            plrs.PlayerAdded:Connect(function()
                if isO then populateOptions() end
                updateHeaderText()
            end)
            plrs.PlayerRemoving:Connect(function(p)
                selectedPlayersMap[p.Name] = nil
                getgenv().YIX_PriorityPlayer[p.Name] = nil
                getgenv().YIX_ExcludeSilent[p.Name] = nil
                getgenv().YIX_ExcludeAimbot[p.Name] = nil
                getgenv().YIX_ExcludeVisual[p.Name] = nil
                if isO then populateOptions() end
                updateHeaderText()
                if updateTogglesForSelectedPlayers then updateTogglesForSelectedPlayers() end
            end)

            updateHeaderText()
        end

        cMultiPlayerDD(cardPlayerSelector, "Select Players")

        updateTogglesForSelectedPlayers = function()
            local sel = getSelectedPlayerNames()
            if #sel == 0 then
                if togSilent then togSilent.Set(false, false) end
                if togAimbot then togAimbot.Set(false, false) end
                if togVisual then togVisual.Set(false, false) end
                if togPriority then togPriority.Set(false, false) end
                return
            end

            local allSilent, allAimbot, allVisual, allPriority = true, true, true, true
            for _, pName in ipairs(sel) do
                if not (getgenv().YIX_ExcludeSilent[pName]) then allSilent = false end
                if not (getgenv().YIX_ExcludeAimbot[pName]) then allAimbot = false end
                if not (getgenv().YIX_ExcludeVisual[pName]) then allVisual = false end
                if not (getgenv().YIX_PriorityPlayer[pName]) then allPriority = false end
            end

            if togSilent then togSilent.Set(allSilent, false) end
            if togAimbot then togAimbot.Set(allAimbot, false) end
            if togVisual then togVisual.Set(allVisual, false) end
            if togPriority then togPriority.Set(allPriority, false) end
        end

        togSilent = cTog(cardConfig, "Exclude from silent", false, function(v)
            local sel = getSelectedPlayerNames()
            if #sel == 0 then
                if not v then getgenv().YIX_ExcludeSilent = {} end
            else
                for _, pName in ipairs(sel) do
                    getgenv().YIX_ExcludeSilent[pName] = v
                end
            end
        end)

        togAimbot = cTog(cardConfig, "Exclude from aimbot", false, function(v)
            local sel = getSelectedPlayerNames()
            if #sel == 0 then
                if not v then getgenv().YIX_ExcludeAimbot = {} end
            else
                for _, pName in ipairs(sel) do
                    getgenv().YIX_ExcludeAimbot[pName] = v
                end
            end
        end)

        togVisual = cTog(cardConfig, "Exclude from Visual", false, function(v)
            local sel = getSelectedPlayerNames()
            if #sel == 0 then
                if not v then getgenv().YIX_ExcludeVisual = {} end
            else
                for _, pName in ipairs(sel) do
                    getgenv().YIX_ExcludeVisual[pName] = v
                end
            end
        end)

        togPriority = cTog(cardConfig, "Priority", false, function(v)
            local sel = getSelectedPlayerNames()
            if #sel == 0 then
                if not v then getgenv().YIX_PriorityPlayer = {} end
            else
                for _, pName in ipairs(sel) do
                    getgenv().YIX_PriorityPlayer[pName] = v
                end
            end
        end)

        local espOn = false
        local espNames = false
        local espDist = false

        local espChams = false
        local espLocalChams = false
        local espChamsType = "Normal"
        local espHB = false
        local espHT = false
        local espBoxes = false
        local espFilledBoxes = false
        local esp3DBoxes = false
        local espSkel = false
        local espSnap = false
        local espSnapOff = false
        local espSnapOrigin = "Down"

        local espCol = {
            Names = Color3.new(1, 1, 1),
            Dist = Color3.new(1, 1, 1),
            PChams = tm.a,
            LChams = tm.a,
            Boxes = Color3.new(1, 1, 1),
            FilledBoxes = tm.a,
            Box3D = Color3.new(1, 1, 1),
            Skel = Color3.new(1, 1, 1),
            Snap = Color3.new(1, 1, 1)
        }


        local espTogFunc, espBx
        espTogFunc, espBx = cTogBind(vc1, "Enable", false, cfg.espBind or "", function(v)
            espOn = v
            Notify("ESP", "ESP " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(v) return assignBind(v, "espBind", espTogFunc, "ESP Enable", "Visual", espBx) end)
        if cfg.espBind and cfg.espBind ~= "" then
            getgenv().YIX_Binds[cfg.espBind:upper()] = {
                func = espTogFunc,
                name =
                "ESP Enable",
                category = "Visual",
                cfgKey = "espBind",
                bx = espBx
            }
        end
        getgenv().YIX_EspTogFunc = espTogFunc

        local ptog = nil
        cTogCP(vc1, "Show Names", false, espCol.Names, function(v)
            espNames = v
            Notify("ESP", "Show Names " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Names = c end)
        cTogCP(vc1, "Distance", false, espCol.Dist, function(v)
            espDist = v
            Notify("ESP", "Distance " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Dist = c end)
        cTogCP(vc1, "Player Chams", false, espCol.PChams, function(v)
            espChams = v
            Notify("ESP", "Player Chams " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.PChams = c end)
        cTogCP(vc1, "Local Player Chams", false, espCol.LChams, function(v)
            espLocalChams = v
            Notify("ESP", "Local Player Chams " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.LChams = c end)
        cTog(vc1, "Health Bar", false, function(v)
            espHB = v
            Notify("ESP", "Health Bar " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end)
        cTog(vc1, "Health Text", false, function(v)
            espHT = v
            Notify("ESP", "Health Text " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end)
        local togBoxes, togBoxes3D

        togBoxes = cTogCP(vc1, "Boxes", false, espCol.Boxes, function(v)
            espBoxes = v
            if v and togBoxes3D then togBoxes3D.Set(false, true) end
            Notify("ESP", "Boxes " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Boxes = c end)

        cTogCP(vc1, "Filled Boxes", false, espCol.FilledBoxes, function(v)
            espFilledBoxes = v
            Notify("ESP", "Filled Boxes " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.FilledBoxes = c end)

        togBoxes3D = cTogCP(vc1, "3D Boxes", false, espCol.Box3D, function(v)
            esp3DBoxes = v
            if v and togBoxes then togBoxes.Set(false, true) end
            Notify("ESP", "3D Boxes " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Box3D = c end)

        cTogCP(vc1, "Skeleton", false, espCol.Skel, function(v)
            espSkel = v
            Notify("ESP", "Skeleton " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Skel = c end)

        local togSnapOff
        local togSnap = cTogCP(vc1, "Snaplines", false, espCol.Snap, function(v)
            espSnap = v
            if not v and togSnapOff then togSnapOff.Set(false, true) end
            Notify("ESP", "Snaplines " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end, function(c) espCol.Snap = c end)

        togSnapOff = cTog(vc1, "Off Screen Snaplines", false, function(v)
            if v and not espSnap then
                togSnapOff.Set(false, true)
                return
            end
            espSnapOff = v
        end)

        local vcR = vS["ESP"].r
        local vc2 = cC(vcR, "Visual Settings")

        local espFont = Enum.Font.Code
        local espMaxDist = 4000
        local espC = {}

        cDD(vc2, "Visual Font", { "Arcade", "System", "Plex", "Monospace" }, "Plex", function(v)
            if v == "Arcade" then
                espFont = Enum.Font.Arcade
            elseif v == "System" then
                espFont = Enum.Font.SourceSansSemibold
            elseif v == "Plex" then
                espFont = Enum.Font.Code
            elseif v == "Monospace" then
                espFont = Enum.Font.RobotoMono
            end
            for _, obs in pairs(espC) do
                if obs.text then obs.text.Font = espFont end
                if obs.hT then obs.hT.Font = espFont end
            end
        end)

        cDD(vc2, "Snapline Origin", { "Top", "Middle", "Down", "Mouse" }, "Down", function(v) espSnapOrigin = v end)

        cSli(vc2, "Visual Render Distance", 0, 4000, 4000, function(v) espMaxDist = v end)
        cDD(vc2, "Chams Material", { "Normal", "ForceField" }, "Normal", function(v) espChamsType = v end)


        local vwL = vS["World"].l
        local vwc = cC(vwL, "World Visual")

        local fbTog, fbLoopTog
        local isFBActive = false
        local origAmbient, origOutdoor, origCSB, origCST, origBright

        local function applyFB(enabled)
            if enabled then
                if not isFBActive then
                    origAmbient = lgt.Ambient
                    origOutdoor = lgt.OutdoorAmbient
                    origCSB = lgt.ColorShift_Bottom
                    origCST = lgt.ColorShift_Top
                    origBright = lgt.Brightness
                    isFBActive = true
                end
                lgt.Ambient = Color3.new(1, 1, 1)
                lgt.OutdoorAmbient = Color3.new(1, 1, 1)
                lgt.ColorShift_Bottom = Color3.new(1, 1, 1)
                lgt.ColorShift_Top = Color3.new(1, 1, 1)
                lgt.Brightness = 2
            else
                if isFBActive then
                    lgt.Ambient = origAmbient
                    lgt.OutdoorAmbient = origOutdoor
                    lgt.ColorShift_Bottom = origCSB
                    lgt.ColorShift_Top = origCST
                    lgt.Brightness = origBright
                    isFBActive = false
                end
            end
        end

        fbTog = cTog(vwc, "Enable Full Bright", false, function(v)
            if v and fbLoopTog then fbLoopTog.Set(false, true) end
            applyFB(v)
            Notify("World Visuals", "Fullbright " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end)

        fbLoopTog = cTog(vwc, "Fullbright Loop", false, function(v)
            if v and fbTog then fbTog.Set(false, true) end
            if not v then
                pcall(function() rs:UnbindFromRenderStep("YIX_FB") end)
                applyFB(false)
                Notify("World Visuals", "Fullbright Loop Disabled", 2, "Error")
            else
                rs:BindToRenderStep("YIX_FB", 2001, function()
                    applyFB(true)
                end)
                Notify("World Visuals", "Fullbright Loop Enabled", 2, "Success")
            end
        end)

        local isTimeCustom = false
        local curTime = 14
        local origTime = lgt.ClockTime

        cTog(vwc, "Enable Custom Time", false, function(v)
            isTimeCustom = v
            if v then
                origTime = lgt.ClockTime
                lgt.ClockTime = curTime
                Notify("World Visuals", "Custom Time Enabled", 2, "Success")
            else
                lgt.ClockTime = origTime
                Notify("World Visuals", "Custom Time Disabled", 2, "Error")
            end
        end)

        cSli(vwc, "Time of Day", 0, 24, 14, function(v)
            curTime = v
            if isTimeCustom then
                lgt.ClockTime = curTime
            end
        end)

        local SKY_ASSETS = {
            ["Purple Nebula"] = "rbxassetid://159454299",
            ["Night Stars"] = "rbxassetid://12064107",
            ["Cyberpunk"] = "rbxassetid://6073747120",
            ["Space"] = { Bk = "rbxassetid://16262356578", Dn = "rbxassetid://16262358026", Ft = "rbxassetid://16262360469", Lf = "rbxassetid://16262362003", Rt = "rbxassetid://16262363873", Up = "rbxassetid://16262366016" },
            ["Cartoony"] = { Bk = "rbxassetid://12879214960", Dn = "rbxassetid://12871012589", Ft = "rbxassetid://12879236088", Lf = "rbxassetid://12879246392", Rt = "rbxassetid://12879253901", Up = "rbxassetid://12871018996" }
        }

        local origSky = lgt:FindFirstChildOfClass("Sky")
        local skyCache = { Bk = "", Dn = "", Ft = "", Lf = "", Rt = "", Up = "" }
        if origSky then
            skyCache = {
                Bk = origSky.SkyboxBk,
                Dn = origSky.SkyboxDn,
                Ft = origSky.SkyboxFt,
                Lf = origSky.SkyboxLf,
                Rt = origSky
                    .SkyboxRt,
                Up = origSky.SkyboxUp
            }
        end

        local isSkyCustom = false
        local curSky = "Space"

        local function applySky()
            local s = lgt:FindFirstChildOfClass("Sky") or Instance.new("Sky", lgt)
            if not isSkyCustom then
                if origSky then
                    s.SkyboxBk = skyCache.Bk; s.SkyboxDn = skyCache.Dn; s.SkyboxFt = skyCache.Ft
                    s.SkyboxLf = skyCache.Lf; s.SkyboxRt = skyCache.Rt; s.SkyboxUp = skyCache.Up
                else
                    s:Destroy()
                end
                return
            end

            local asset = SKY_ASSETS[curSky]
            if not asset then return end

            if type(asset) == "table" then
                s.SkyboxBk = asset.Bk; s.SkyboxDn = asset.Dn; s.SkyboxFt = asset.Ft
                s.SkyboxLf = asset.Lf; s.SkyboxRt = asset.Rt; s.SkyboxUp = asset.Up
            else
                s.SkyboxBk = asset; s.SkyboxDn = asset; s.SkyboxFt = asset
                s.SkyboxLf = asset; s.SkyboxRt = asset; s.SkyboxUp = asset
            end
        end

        cTog(vwc, "Enable Custom Skybox", false, function(v)
            isSkyCustom = v
            applySky()
            Notify("World Visuals", "Custom Skybox " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
        end)

        cDD(vwc, "Skybox Theme", { "Purple Nebula", "Night Stars", "Cyberpunk", "Space", "Cartoony" }, "Space",
            function(v)
                curSky = v
                if isSkyCustom then
                    applySky()
                end
            end)


        -- ESP Logic

        local function cDLine()
            local bg = Instance.new("Frame")
            bg.AnchorPoint = Vector2.new(0.5, 0.5)
            bg.BorderSizePixel = 0
            bg.BackgroundColor3 = Color3.new(0, 0, 0)
            bg.Visible = false
            bg.ZIndex = -6
            bg.Parent = sg

            local main = Instance.new("Frame")
            main.AnchorPoint = Vector2.new(0.5, 0.5)
            main.BorderSizePixel = 0
            main.BackgroundColor3 = Color3.new(1, 1, 1)
            main.Visible = false
            main.ZIndex = -5
            main.Parent = sg

            return { bg = bg, main = main }
        end

        local function uDLine(lineObj, vis, p1, p2, col)
            if not lineObj then return end
            if vis and p1 and p2 then
                local v1 = typeof(p1) == "Vector3" and Vector2.new(p1.X, p1.Y) or p1
                local v2 = typeof(p2) == "Vector3" and Vector2.new(p2.X, p2.Y) or p2
                local center = (v1 + v2) / 2
                local len = (v1 - v2).Magnitude
                local rot = math.deg(math.atan2(v2.Y - v1.Y, v2.X - v1.X))

                lineObj.bg.Visible = true
                lineObj.bg.Position = UDim2.new(0, center.X, 0, center.Y)
                lineObj.bg.Size = UDim2.new(0, len + 2, 0, 3)
                lineObj.bg.Rotation = rot

                lineObj.main.Visible = true
                lineObj.main.Position = UDim2.new(0, center.X, 0, center.Y)
                lineObj.main.Size = UDim2.new(0, len, 0, 1)
                lineObj.main.Rotation = rot
                lineObj.main.BackgroundColor3 = col
            else
                lineObj.bg.Visible = false
                lineObj.main.Visible = false
            end
        end

        local function cArrow()
            local lbl = Instance.new("TextLabel")
            lbl.AnchorPoint = Vector2.new(0.5, 0.5)
            lbl.Size = UDim2.new(0, 24, 0, 24)
            lbl.BackgroundTransparency = 1
            lbl.Text = "▲"
            lbl.TextSize = 24
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.TextStrokeTransparency = 0
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            lbl.ZIndex = -5
            lbl.Visible = false
            lbl.Parent = sg
            return lbl
        end

        local function uArrow(arrow, vis, pos, dir, col)
            if not arrow then return end
            if vis and pos and dir then
                arrow.Visible = true
                arrow.Position = UDim2.new(0, pos.X, 0, pos.Y)
                local rot = math.deg(math.atan2(dir.Y, dir.X)) + 90
                arrow.Rotation = rot
                arrow.TextColor3 = col
            else
                arrow.Visible = false
            end
        end

        local function cDBox()
            local bg = Instance.new("Frame")
            bg.BackgroundTransparency = 1
            bg.Visible = false
            bg.ZIndex = -5
            bg.Parent = sg
            local bgs = Instance.new("UIStroke")
            bgs.Thickness = 3
            bgs.Color = Color3.new(0, 0, 0)
            bgs.Parent = bg

            local main = Instance.new("Frame")
            main.BackgroundTransparency = 1
            main.Visible = false
            main.ZIndex = -4
            main.Parent = sg
            local ms = Instance.new("UIStroke")
            ms.Thickness = 1
            ms.Color = Color3.new(1, 1, 1)
            ms.Parent = main

            local fill = Instance.new("Frame")
            fill.BorderSizePixel = 0
            fill.BackgroundTransparency = 0.5
            fill.Visible = false
            fill.ZIndex = -6
            fill.Parent = sg

            return { bg = bg, main = main, fill = fill }
        end

        local function uDBox(boxObj, vis, pos, size, col, isFilled, filledCol)
            if not boxObj then return end
            if vis and pos and size then
                boxObj.bg.Visible = true
                boxObj.bg.Position = UDim2.new(0, pos.X, 0, pos.Y)
                boxObj.bg.Size = UDim2.new(0, size.X, 0, size.Y)

                boxObj.main.Visible = true
                boxObj.main.Position = UDim2.new(0, pos.X, 0, pos.Y)
                boxObj.main.Size = UDim2.new(0, size.X, 0, size.Y)
                boxObj.main.UIStroke.Color = col

                if isFilled then
                    boxObj.fill.Visible = true
                    boxObj.fill.Position = UDim2.new(0, pos.X, 0, pos.Y)
                    boxObj.fill.Size = UDim2.new(0, size.X, 0, size.Y)
                    boxObj.fill.BackgroundColor3 = filledCol
                else
                    boxObj.fill.Visible = false
                end
            else
                boxObj.bg.Visible = false
                boxObj.main.Visible = false
                boxObj.fill.Visible = false
            end
        end

        local function cDFBox()
            local lines = {}
            for i = 1, 12 do lines[i] = cDLine() end
            return lines
        end

        local function cDSkel()
            local lines = {}
            for i = 1, 15 do lines[i] = cDLine() end
            return lines
        end

        local function rmDraw(obj)
            if not obj then return end
            if typeof(obj) == "table" then
                if obj.main then
                    pcall(function() obj.main:Destroy() end)
                    if obj.bg then pcall(function() obj.bg:Destroy() end) end
                    if obj.fill then pcall(function() obj.fill:Destroy() end) end
                else
                    for _, v in pairs(obj) do rmDraw(v) end
                end
            else
                pcall(function() obj:Destroy() end)
            end
        end

        local function hideD(obj)
            if not obj then return end
            if typeof(obj) == "table" then
                if obj.main then
                    obj.main.Visible = false
                    if obj.bg then obj.bg.Visible = false end
                    if obj.fill then obj.fill.Visible = false end
                else
                    for _, v in pairs(obj) do hideD(v) end
                end
            else
                pcall(function() obj.Visible = false end)
            end
        end

        local skelR15 = {
            { "Head",       "UpperTorso" }, { "UpperTorso", "LowerTorso" },
            { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
            { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
            { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
            { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
        }
        local skelR6 = {
            { "Head",  "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
            { "Torso", "Left Leg" }, { "Torso", "Right Leg" }
        }
        local fboxConns = {
            { 1, 2 }, { 2, 6 }, { 6, 5 }, { 5, 1 },
            { 3, 4 }, { 4, 8 }, { 8, 7 }, { 7, 3 },
            { 1, 3 }, { 2, 4 }, { 5, 7 }, { 6, 8 }
        }

        local function restoreMats(obs)
            for part, orig in pairs(obs.origMats) do
                if part then
                    if orig.parent ~= nil then
                        if part.Parent ~= orig.parent then
                            part.Parent = orig.parent
                        end
                    elseif part.Parent then
                        if part:IsA("BasePart") then
                            part.Material = orig.mat
                            part.Color = orig.col
                            if orig.texID ~= nil then part.TextureID = orig.texID end
                        elseif part:IsA("SpecialMesh") then
                            if orig.texId ~= nil then part.TextureId = orig.texId end
                        elseif part:IsA("Decal") then
                            if orig.trans ~= nil then part.Transparency = orig.trans end
                        end
                    end
                end
            end
            table.clear(obs.origMats)
        end

        local function addESP(p)
            local txt, hT, hBb, hB
            if p ~= lp then
                txt = Instance.new("TextLabel")
                txt.BackgroundTransparency = 1
                txt.Visible = false
                txt.Size = UDim2.new(0, 200, 0, 20)
                txt.TextStrokeTransparency = 0.5
                txt.TextColor3 = Color3.new(1, 1, 1)
                txt.TextSize = 13
                txt.Font = espFont
                txt.RichText = true
                txt.TextXAlignment = Enum.TextXAlignment.Center
                txt.ZIndex = -5
                txt.Parent = sg

                hT = Instance.new("TextLabel")
                hT.BackgroundTransparency = 1
                hT.Visible = false
                hT.Size = UDim2.new(0, 40, 0, 20)
                hT.TextStrokeTransparency = 0.2
                hT.TextStrokeColor3 = Color3.new(0, 0, 0)
                hT.TextColor3 = Color3.new(0, 1, 0)
                hT.TextSize = 11
                hT.Font = espFont
                hT.TextXAlignment = Enum.TextXAlignment.Right
                hT.ZIndex = -5
                hT.Parent = sg

                hBb = Instance.new("Frame")
                hBb.Visible = false
                hBb.BackgroundColor3 = Color3.new(0, 0, 0)
                hBb.BackgroundTransparency = 0.4
                hBb.BorderSizePixel = 0
                hBb.ZIndex = -5
                hBb.Parent = sg

                local hBbs = Instance.new("UIStroke")
                hBbs.Color = Color3.new(0, 0, 0)
                hBbs.Thickness = 1
                hBbs.Parent = hBb

                hB = Instance.new("Frame")
                hB.Visible = true
                hB.BackgroundColor3 = Color3.new(0, 1, 0)
                hB.BorderSizePixel = 0
                hB.ZIndex = -5
                hB.Parent = hBb
            end

            local hl = Instance.new("Highlight")
            hl.Name = "ESP_Highlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = tm.a
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Parent = sg

            local box = cDBox()
            local box3d = cDFBox()
            local skel = cDSkel()
            local snap = cDLine()
            local offSnap = cArrow()

            espC[p] = {
                text = txt,
                hT = hT,
                hBb = hBb,
                hB = hB,
                hl = hl,
                origMats = {},
                box = box,
                box3d = box3d,
                skel = skel,
                snap = snap,
                offSnap = offSnap
            }
        end

        local function rmESP(p)
            if espC[p] then
                if espC[p].text then espC[p].text:Destroy() end
                if espC[p].hT then espC[p].hT:Destroy() end
                if espC[p].hBb then espC[p].hBb:Destroy() end
                if espC[p].hl then espC[p].hl:Destroy() end
                rmDraw(espC[p].box)
                rmDraw(espC[p].box3d)
                rmDraw(espC[p].skel)
                rmDraw(espC[p].snap)
                rmDraw(espC[p].offSnap)
                restoreMats(espC[p])
                espC[p] = nil
            end
        end

        getgenv().YIX_CleanupVisuals = function()
            pcall(function() rs:UnbindFromRenderStep("YIX_ESP") end)
            pcall(function() rs:UnbindFromRenderStep("YIX_FB") end)

            if espC then
                for p, obs in pairs(espC) do
                    if obs then
                        pcall(function()
                            if obs.text then obs.text:Destroy() end
                            if obs.hT then obs.hT:Destroy() end
                            if obs.hBb then obs.hBb:Destroy() end
                            if obs.hl then obs.hl:Destroy() end
                            rmDraw(obs.box)
                            rmDraw(obs.box3d)
                            rmDraw(obs.skel)
                            rmDraw(obs.snap)
                            rmDraw(obs.offSnap)
                            restoreMats(obs)
                        end)
                    end
                end
                table.clear(espC)
            end

            pcall(function()
                for _, p in ipairs(plrs:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Head") then
                        local skull = p.Character.Head:FindFirstChild("YIX_PrioritySkull")
                        if skull then pcall(function() skull:Destroy() end) end
                    end
                end
            end)

            pcall(function()
                if applyFB then applyFB(false) end
            end)

            pcall(function()
                if isTimeCustom then
                    isTimeCustom = false
                    lgt.ClockTime = origTime
                end
            end)

            pcall(function()
                if isSkyCustom then
                    isSkyCustom = false
                    if applySky then applySky() end
                end
            end)

            getgenv().YIX_ExcludeVisual = {}
            getgenv().YIX_ExcludeSilent = {}
            getgenv().YIX_ExcludeAimbot = {}
            getgenv().YIX_PriorityPlayer = {}
            getgenv().YIX_Priority_ShowSkull = false
            getgenv().YIX_Priority_EnableChams = false
            getgenv().YIX_Priority_BlinkChams = false
        end

        for _, p in ipairs(plrs:GetPlayers()) do addESP(p) end
        plrs.PlayerAdded:Connect(addESP)
        plrs.PlayerRemoving:Connect(rmESP)



        local isAnyPriorityActive = false
        rs:BindToRenderStep("YIX_ESP", 2000, function()
            isAnyPriorityActive = false
            if getgenv().YIX_PriorityPlayer then
                for _, val in pairs(getgenv().YIX_PriorityPlayer) do
                    if val then
                        isAnyPriorityActive = true; break
                    end
                end
            end

            if not espOn and not isAnyPriorityActive then
                for p, obs in pairs(espC) do
                    if obs.text and obs.text.Visible then obs.text.Visible = false end
                    if obs.hT and obs.hT.Visible then obs.hT.Visible = false end
                    if obs.hBb and obs.hBb.Visible then obs.hBb.Visible = false end
                    if obs.hl and obs.hl.Enabled then obs.hl.Enabled = false end
                    hideD(obs.box)
                    hideD(obs.box3d)
                    hideD(obs.skel)
                    hideD(obs.snap)
                    hideD(obs.offSnap)
                    restoreMats(obs)
                end
                return
            end

            for p, obs in pairs(espC) do
                local txt = obs.text
                local hl = obs.hl
                local isLocal = p == lp
                local isExVisual = getgenv().YIX_ExcludeVisual and getgenv().YIX_ExcludeVisual[p.Name]
                local isPriority = getgenv().YIX_PriorityPlayer and getgenv().YIX_PriorityPlayer[p.Name]
                local isPriorityChamsActive = isPriority and (getgenv().YIX_Priority_EnableChams ~= false) and
                    not isExVisual

                -- Priority Skull Icon & Custom Chams
                if isPriority and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and not isExVisual then
                    local head = p.Character.Head

                    -- Skull Icon Logic
                    if getgenv().YIX_Priority_ShowSkull ~= false then
                        local skull = head:FindFirstChild("YIX_PrioritySkull")
                        if not skull then
                            skull = Instance.new("BillboardGui")
                            skull.Name = "YIX_PrioritySkull"
                            skull.Size = UDim2.new(0, 38, 0, 38)
                            skull.StudsOffset = Vector3.new(0, 2.8, 0)
                            skull.AlwaysOnTop = true
                            skull.Parent = head

                            local img = Instance.new("ImageLabel")
                            img.Name = "SkullImage"
                            img.Size = UDim2.new(1, 0, 1, 0)
                            img.BackgroundTransparency = 1
                            img.Image = "rbxassetid://132655560258806"
                            img.ScaleType = Enum.ScaleType.Fit
                            img.Parent = skull
                        end
                        skull.Enabled = true
                        local img = skull:FindFirstChild("SkullImage")
                        if img then
                            img.ImageColor3 = getgenv().YIX_Priority_SkullColor or Color3.new(1, 1, 1)
                        end
                    else
                        local skull = head:FindFirstChild("YIX_PrioritySkull")
                        if skull then skull:Destroy() end
                    end

                    -- Chams Logic
                    if isPriorityChamsActive then
                        local baseColor = getgenv().YIX_Priority_ChamsColor or Color3.fromRGB(255, 0, 0)
                        local finalColor = baseColor
                        local fillTrans = 0.0

                        if getgenv().YIX_Priority_BlinkChams ~= false then
                            local isBlink = (tick() % 0.5) < 0.25
                            fillTrans = isBlink and 0.0 or 0.55
                        end

                        if hl then
                            hl.Adornee = p.Character
                            hl.Enabled = true
                            hl.FillColor = finalColor
                            hl.FillTransparency = fillTrans
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.OutlineTransparency = 0
                        end
                    end
                else
                    if p.Character and p.Character:FindFirstChild("Head") then
                        local skull = p.Character.Head:FindFirstChild("YIX_PrioritySkull")
                        if skull then skull:Destroy() end
                    end
                end

                if isExVisual then
                    if txt then
                        txt.Visible = false
                        if obs.hBb then obs.hBb.Visible = false end
                        if obs.hT then obs.hT.Visible = false end
                        hideD(obs.box)
                        hideD(obs.box3d)
                        hideD(obs.skel)
                        hideD(obs.snap)
                        hideD(obs.offSnap)
                    end
                    if hl and not isPriorityChamsActive then hl.Enabled = false end
                    restoreMats(obs)
                elseif espOn and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local hrp = p.Character.HumanoidRootPart
                    local head = p.Character.Head

                    if not isPriorityChamsActive then
                        -- Standard Chams Logic
                        local shouldChams = (isLocal and espLocalChams) or (not isLocal and espChams)
                        local chamCol = isLocal and espCol.LChams or espCol.PChams
                        if shouldChams then
                            if espChamsType == "Normal" then
                                if hl then
                                    hl.Adornee = p.Character
                                    hl.Enabled = true
                                    hl.FillColor = chamCol
                                    hl.FillTransparency = 0
                                end
                                restoreMats(obs)
                            elseif espChamsType == "ForceField" then
                                if hl then hl.Enabled = false end
                                for _, part in ipairs(p.Character:GetChildren()) do
                                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
                                        if not obs.origMats[part] then
                                            local origData = { mat = part.Material, col = part.Color }
                                            if part:IsA("MeshPart") then origData.texID = part.TextureID end
                                            obs.origMats[part] = origData
                                        end
                                        if part.Material ~= Enum.Material.ForceField then
                                            part.Material = Enum.Material.ForceField
                                        end
                                        if part.Color ~= chamCol then
                                            part.Color = chamCol
                                        end
                                        if part:IsA("MeshPart") and part.TextureID ~= "" then
                                            part.TextureID = ""
                                        end
                                    end
                                end
                            end
                        else
                            if hl then hl.Enabled = false end
                            restoreMats(obs)
                        end
                    end

                    -- ESP Text Logic
                    if txt then
                        local headPos, visHead = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                        local rootPos, visRoot = cam:WorldToViewportPoint(hrp.Position)

                        if visRoot or visHead then
                            local dist = math.floor((cam.CFrame.Position - hrp.Position).Magnitude)
                            if dist <= espMaxDist then
                                -- Ultra-Fast Direct 2D Bounding Box Calculation
                                local topPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                                local botPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
                                local hgt = math.abs(botPos.Y - topPos.Y)
                                local wid = hgt * 0.6
                                headPos = Vector2.new(topPos.X, topPos.Y)

                                -- Name & Distance
                                local str = ""
                                local nH = math.floor(espCol.Names.R * 255) ..
                                    "," .. math.floor(espCol.Names.G * 255) .. "," .. math.floor(espCol.Names.B * 255)
                                local dH = math.floor(espCol.Dist.R * 255) ..
                                    "," .. math.floor(espCol.Dist.G * 255) .. "," .. math.floor(espCol.Dist.B * 255)

                                if espNames then
                                    str = str ..
                                        "<font color=\"rgb(" .. nH .. ")\">" .. p.Name .. "</font> "
                                end
                                if espDist then str = str .. "<font color=\"rgb(" .. dH .. ")\">[" .. dist .. "m]</font>" end

                                if str ~= "" and visHead then
                                    txt.Text = str
                                    txt.Position = UDim2.new(0, headPos.X - 100, 0, headPos.Y - 10)
                                    txt.Visible = true
                                else
                                    txt.Visible = false
                                end

                                -- Health Data
                                local hp = math.floor(p.Character.Humanoid.Health)
                                local maxHp = math.floor(p.Character.Humanoid.MaxHealth)
                                local hpPct = hp / maxHp
                                local hpColor = Color3.fromHSV(hpPct * 0.3, 1, 1) -- Red to Green

                                -- Health Bar
                                if espHB then
                                    obs.hBb.Size = UDim2.new(0, 3, 0, hgt)
                                    obs.hBb.Position = UDim2.new(0, headPos.X - wid / 2 - 6, 0, headPos.Y)
                                    obs.hB.Size = UDim2.new(1, 0, hpPct, 0)
                                    obs.hB.Position = UDim2.new(0, 0, 1 - hpPct, 0)
                                    obs.hB.BackgroundColor3 = hpColor
                                    obs.hBb.Visible = true
                                else
                                    obs.hBb.Visible = false
                                end

                                -- Health Text
                                if espHT then
                                    obs.hT.Text = tostring(hp)
                                    obs.hT.TextColor3 = hpColor
                                    if espHB then
                                        obs.hT.Position = UDim2.new(0, headPos.X - wid / 2 - 48, 0,
                                            headPos.Y + (hgt * (1 - hpPct)) - 10)
                                    else
                                        obs.hT.Position = UDim2.new(0, headPos.X - wid / 2 - 44, 0,
                                            headPos.Y + (hgt / 2) - 10)
                                    end
                                    obs.hT.Visible = true
                                else
                                    obs.hT.Visible = false
                                end

                                -- Boxes
                                -- Boxes & Filled Boxes
                                if espBoxes then
                                    uDBox(obs.box, true, Vector2.new(headPos.X - wid / 2, headPos.Y),
                                        Vector2.new(wid, hgt),
                                        espCol.Boxes, espFilledBoxes, espCol.FilledBoxes)
                                else
                                    hideD(obs.box)
                                end

                                -- 3D Boxes
                                if esp3DBoxes and hrp then
                                    local bc, bs = p.Character:GetBoundingBox()
                                    local hs = bs / 2
                                    local c = {
                                        bc * CFrame.new(hs.X, hs.Y, hs.Z), bc * CFrame.new(-hs.X, hs.Y, hs.Z),
                                        bc * CFrame.new(hs.X, -hs.Y, hs.Z), bc * CFrame.new(-hs.X, -hs.Y, hs.Z),
                                        bc * CFrame.new(hs.X, hs.Y, -hs.Z), bc * CFrame.new(-hs.X, hs.Y, -hs.Z),
                                        bc * CFrame.new(hs.X, -hs.Y, -hs.Z), bc * CFrame.new(-hs.X, -hs.Y, -hs.Z)
                                    }
                                    local sc = {}
                                    local aV = true
                                    for i = 1, 8 do
                                        local pos, vis = cam:WorldToViewportPoint(c[i].Position)
                                        sc[i] = Vector2.new(pos.X, pos.Y)
                                        if not vis or pos.Z < 0 then aV = false end
                                    end
                                    if aV then
                                        for i, v in ipairs(fboxConns) do
                                            uDLine(obs.box3d[i], true, sc[v[1]], sc[v[2]], espCol.Box3D)
                                        end
                                    else
                                        hideD(obs.box3d)
                                    end
                                else
                                    hideD(obs.box3d)
                                end

                                -- Skeleton
                                if espSkel then
                                    local rig = p.Character:FindFirstChild("UpperTorso") and skelR15 or skelR6
                                    for i, v in ipairs(rig) do
                                        local p1 = p.Character:FindFirstChild(v[1])
                                        local p2 = p.Character:FindFirstChild(v[2])
                                        if p1 and p2 then
                                            local pos1, vis1 = cam:WorldToViewportPoint(p1.Position)
                                            local pos2, vis2 = cam:WorldToViewportPoint(p2.Position)
                                            if vis1 and vis2 and pos1.Z > 0 and pos2.Z > 0 then
                                                uDLine(obs.skel[i], true, pos1, pos2, espCol.Skel)
                                            else
                                                uDLine(obs.skel[i], false)
                                            end
                                        else
                                            uDLine(obs.skel[i], false)
                                        end
                                    end
                                    for i = #rig + 1, 15 do uDLine(obs.skel[i], false) end
                                else
                                    hideD(obs.skel)
                                end
                            else
                                txt.Visible = false
                                obs.hBb.Visible = false
                                obs.hT.Visible = false
                                hideD(obs.box)
                                hideD(obs.box3d)
                                hideD(obs.skel)
                            end
                        else
                            txt.Visible = false
                            obs.hBb.Visible = false
                            obs.hT.Visible = false
                            hideD(obs.box)
                            hideD(obs.box3d)
                            hideD(obs.skel)
                        end

                        -- Snaplines
                        if espSnap then
                            local originPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                            if espSnapOrigin == "Top" then
                                originPos = Vector2.new(cam.ViewportSize.X / 2, 0)
                            elseif espSnapOrigin == "Middle" then
                                originPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            elseif espSnapOrigin == "Mouse" then
                                local ms = uis:GetMouseLocation()
                                originPos = ms
                            end

                            if visRoot then
                                uDLine(obs.snap, true, originPos, Vector2.new(rootPos.X, rootPos.Y), espCol.Snap)
                                hideD(obs.offSnap)
                            else
                                hideD(obs.snap)
                                if espSnapOff then
                                    local objSpace = cam.CFrame:PointToObjectSpace(hrp.Position)
                                    local ang = math.atan2(objSpace.Y, objSpace.X)
                                    local dir = Vector2.new(math.cos(ang), -math.sin(ang))
                                    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                                    local radius = math.min(center.X, center.Y) * 0.8
                                    local arrowPos = center + dir * radius
                                    uArrow(obs.offSnap, true, arrowPos, dir, espCol.Snap)
                                else
                                    hideD(obs.offSnap)
                                end
                            end
                        else
                            hideD(obs.snap)
                            hideD(obs.offSnap)
                        end
                    end
                else
                    if txt then
                        txt.Visible = false
                        obs.hBb.Visible = false
                        obs.hT.Visible = false
                        hideD(obs.box)
                        hideD(obs.box3d)
                        hideD(obs.skel)
                        hideD(obs.snap)
                        hideD(obs.offSnap)
                    end
                    if hl and not isPriorityChamsActive then hl.Enabled = false end
                    restoreMats(obs)
                end
            end
        end)
    end -- End Visuals Tab

    do  -- Misc Tab
        msT = cMT("Misc", "75166528118709", false)
        msS = cSM(msT, { "General", "Shop" })

        mcL = msS["General"].l
        mc1 = cC(mcL, "Utilities")

        local antiFallOn = true
        local afTogFunc, afBx
        afTogFunc, afBx = cTogBind(mc1, "Anti-Fall Damage", true, cfg.afBind or "", function(v)
            antiFallOn = v
        end, function(v) return assignBind(v, "afBind", afTogFunc, "Anti-Fall Damage", "Utilities", afBx) end)
        if cfg.afBind and cfg.afBind ~= "" then
            getgenv().YIX_Binds[cfg.afBind:upper()] = {
                func = afTogFunc,
                name =
                "Anti-Fall Damage",
                category = "Utilities",
                cfgKey = "afBind",
                bx = afBx
            }
        end

        getgenv().YIX_AntiCamera = false
        local acTogFunc, acBx
        acTogFunc, acBx = cTogBind(mc1, "Anti-Camera", false, cfg.acBind or "", function(v)
            getgenv().YIX_AntiCamera = v
            if v then
                task.spawn(function()
                    local camEvent = game:GetService("ReplicatedStorage"):FindFirstChild("cameraZoneFunction")
                    if camEvent then
                        pcall(function()
                            camEvent:FireServer(false, "\xE2\x80\x8E Pr\xE2\x80\x8E 1V\xE2\x80\x8E 4t3\xE2\x80\x8E ")
                        end)
                    end
                end)
            end
        end, function(v) return assignBind(v, "acBind", acTogFunc, "Anti-Camera", "Utilities", acBx) end)
        if cfg.acBind and cfg.acBind ~= "" then
            getgenv().YIX_Binds[cfg.acBind:upper()] = {
                func = acTogFunc,
                name = "Anti-Camera",
                category = "Utilities",
                cfgKey = "acBind",
                bx = acBx
            }
        end

        getgenv().YIX_Godmode = false
        local godTogFunc, godBx
        godTogFunc, godBx = cTogBind(mc1, "Inf safe zone", false, cfg.godBind or "", function(v)
            getgenv().YIX_Godmode = v
            local safeEvent = game:GetService("ReplicatedStorage"):FindFirstChild("safeModeFunction")
            local settings = lp:FindFirstChild("Settings")
            local settings2 = settings and settings:FindFirstChild("Settings")

            local targets = { lp, settings, settings2 }

            if v then
                if safeEvent then
                    pcall(function()
                        safeEvent:FireServer(true, "\xE2\x80\x8E Pr\xE2\x80\x8E 1V\xE2\x80\x8E 4t3\xE2\x80\x8E ")
                    end)
                end
                for _, t in ipairs(targets) do
                    if t then
                        pcall(function()
                            t:SetAttribute("BlankSafe", true)
                            t:SetAttribute("GodMode", true)
                            t:SetAttribute("SafeZoneState", "SAFE")
                        end)
                    end
                end
            else
                for _, t in ipairs(targets) do
                    if t then
                        pcall(function()
                            t:SetAttribute("BlankSafe", false)
                            t:SetAttribute("GodMode", false)
                            t:SetAttribute("SafeZoneState", "NONE")
                        end)
                    end
                end
                if safeEvent then
                    pcall(function()
                        safeEvent:FireServer(false, "\xE2\x80\x8E Pr\xE2\x80\x8E 1V\xE2\x80\x8E 4t3\xE2\x80\x8E ")
                    end)
                end
            end
        end, function(v) return assignBind(v, "godBind", godTogFunc, "Inf safe zone", "Utilities", godBx) end)
        if cfg.godBind and cfg.godBind ~= "" then
            getgenv().YIX_Binds[cfg.godBind:upper()] = {
                func = godTogFunc,
                name = "Inf safe zone",
                category = "Utilities",
                cfgKey = "godBind",
                bx = godBx
            }
        end

        getgenv().YIX_Noclip = false
        local noclipConnection
        local ncTogFunc, ncBx
        local defaultCollideParts = {
            Torso = true,
            UpperTorso = true,
            LowerTorso = true,
            Head = true
        }

        ncTogFunc, ncBx = cTogBind(mc1, "Noclip", false, cfg.ncBind or "", function(v)
            getgenv().YIX_Noclip = v
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            if v then
                noclipConnection = rs.Stepped:Connect(function()
                    if getgenv().YIX_Noclip and lp.Character then
                        for _, part in ipairs(lp.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if lp.Character then
                    for _, part in ipairs(lp.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = defaultCollideParts[part.Name] or false
                        end
                    end
                end
            end
        end, function(v) return assignBind(v, "ncBind", ncTogFunc, "Noclip", "Utilities", ncBx) end)
        if cfg.ncBind and cfg.ncBind ~= "" then
            getgenv().YIX_Binds[cfg.ncBind:upper()] = {
                func = ncTogFunc,
                name = "Noclip",
                category = "Utilities",
                cfgKey = "ncBind",
                bx = ncBx
            }
        end

        getgenv().YIX_InfEn = false
        local infEnTogFunc, infEnBx
        infEnTogFunc, infEnBx = cTogBind(mc1, "Infinite Energy", false, cfg.infEnBind or "", function(v)
            getgenv().YIX_InfEn = v
        end, function(v) return assignBind(v, "infEnBind", infEnTogFunc, "Infinite Energy", "Utilities", infEnBx) end)
        if cfg.infEnBind and cfg.infEnBind ~= "" then
            getgenv().YIX_Binds[cfg.infEnBind:upper()] = {
                func = infEnTogFunc,
                name = "Infinite Energy",
                category = "Utilities",
                cfgKey = "infEnBind",
                bx = infEnBx
            }
        end

        getgenv().YIX_InfHg = false
        local infHgTogFunc, infHgBx
        infHgTogFunc, infHgBx = cTogBind(mc1, "Infinite Food", false, cfg.infHgBind or "", function(v)
            getgenv().YIX_InfHg = v
        end, function(v) return assignBind(v, "infHgBind", infHgTogFunc, "Infinite Food", "Utilities", infHgBx) end)
        if cfg.infHgBind and cfg.infHgBind ~= "" then
            getgenv().YIX_Binds[cfg.infHgBind:upper()] = {
                func = infHgTogFunc,
                name = "Infinite Food",
                category = "Utilities",
                cfgKey = "infHgBind",
                bx = infHgBx
            }
        end
        msL_Shop = msS["Shop"].l
        msR_Shop = msS["Shop"].r

        cardMarket = cC(msL_Shop, "Market Shop")
        cardGuapo = cC(msR_Shop, "Guapo Shop")
        cardFreedomGuns = cC(msL_Shop, "Freedom Guns")
        cardFreedomAmmo = cC(msR_Shop, "Freedom Ammo")

        local function buyShopItem(frameName, rawItemName, contentFolder)
            local itemName = rawItemName:gsub("%s*%(%$.*%)", "")
            local gui = lp.PlayerGui:FindFirstChild("MainGUI")
            if not gui then return end
            local shopFrame = gui:FindFirstChild(frameName)
            if not shopFrame then return end

            local mouseSound = gui:FindFirstChild("mouseClick")
            local oldVol
            if mouseSound and mouseSound:IsA("Sound") then
                oldVol = mouseSound.Volume
                mouseSound.Volume = 0
            end
            local stockFrame = shopFrame:FindFirstChild("stockFrame")
            local stock
            if stockFrame then
                if contentFolder then stock = stockFrame:FindFirstChild(contentFolder) end
                if not stock then
                    stock = stockFrame:FindFirstChild("Content") or stockFrame:FindFirstChild("Content1") or
                        stockFrame:FindFirstChild("Content2")
                end
            end
            local trimmed = itemName:match("^%s*(.-)%s*$")
            local itemBtn = stock and (stock:FindFirstChild(itemName) or stock:FindFirstChild(trimmed))

            if not itemBtn and stock then
                for _, child in ipairs(stock:GetChildren()) do
                    if child.Name:lower() == itemName:lower() or child.Name:lower() == trimmed:lower() then
                        itemBtn = child
                        break
                    end
                end
            end

            local purchaseBtn = shopFrame:FindFirstChild("productFrame")
                and shopFrame.productFrame:FindFirstChild("contentFrame")
                and shopFrame.productFrame.contentFrame:FindFirstChild("purchaseButton")

            if itemBtn and purchaseBtn then
                local guiService = game:GetService("GuiService")
                local vim = game:GetService("VirtualInputManager")

                itemBtn.Selectable = true
                purchaseBtn.Selectable = true

                guiService.SelectedObject = itemBtn
                guiService.GuiNavigationEnabled = true
                guiService.SelectedObject = itemBtn
                task.wait(0.08)
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

                task.wait(0.15)

                guiService.SelectedObject = purchaseBtn
                task.wait(0.05)
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

                guiService.SelectedObject = nil
            end

            if mouseSound and oldVol then
                task.delay(0.1, function()
                    mouseSound.Volume = oldVol
                end)
            end
        end

        -- Market Shop Controls
        local martItems = {
            " Fresh Lemon ($50)",
            "Black Latex Gloves ($25)",
            "Blue Latex Gloves ($25)",
            "Cola Pop ($6)",
            "Deli Burger ($15)",
            "Deli Taco ($8)",
            "Fresh Mango ($100)",
            "Fresh Watermelon ($175)",
            "Lighter ($35)",
            "Pepsi Pop ($6)",
            "Pizza ($20)",
            "Playing Dice ($50)",
            "Sprite Pop ($6)",
            "Water Bottle ($20)",
            "White Latex Gloves ($25)"
        }
        local qtyOptions = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

        local selMartItem = martItems[1]
        local selMartQty = 1

        cDD(cardMarket, "MiniMart Item", martItems, selMartItem, function(v)
            selMartItem = v
        end)

        local rowMarket = Instance.new("Frame")
        rowMarket.Size = UDim2.new(1, 0, 0, 26)
        rowMarket.BackgroundTransparency = 1
        rowMarket.ZIndex = 10
        rowMarket.Parent = cardMarket

        local leftMarket = Instance.new("Frame")
        leftMarket.Size = UDim2.new(0.6, 6, 1, 0)
        leftMarket.Position = UDim2.new(0, -6, 0, 0)
        leftMarket.BackgroundTransparency = 1
        leftMarket.ZIndex = 10
        leftMarket.Parent = rowMarket

        local rightMarket = Instance.new("Frame")
        rightMarket.Size = UDim2.new(0.4, 6, 1, 0)
        rightMarket.Position = UDim2.new(0.6, -6, 0, 0)
        rightMarket.BackgroundTransparency = 1
        rightMarket.ZIndex = 10
        rightMarket.Parent = rowMarket

        cBtn(leftMarket, "Buy Item", function()
            for i = 1, selMartQty do
                buyShopItem("miniMartFrame", selMartItem)
                if i < selMartQty then task.wait(0.2) end
            end
        end)

        cDD(rightMarket, "QTY", qtyOptions, "1", function(v)
            selMartQty = tonumber(v) or 1
        end)

        -- Guapo Shop Controls
        local guapoItems = {
            "Bape Filament ($2000)",
            "Basic Filament ($25)",
            "Blue Raspberry Nade ($450)",
            "Can Of Spraypaint ($250)",
            "Chrome Filament ($2250)",
            "Designer Filament ($150)",
            "Empty Shoe Box ($60)",
            "Exclusive Filament ($250)",
            "Galaxy Filament ($750)",
            "Gelatin ($240)",
            "Granny Cookie Dough ($13500)",
            "Grape Nade ($800)",
            "Koyard Filament ($9000)",
            "Lighter ($55)",
            "Lime Nade ($275)",
            "Metal Shelf ($1500)",
            "Retro Filament ($50)",
            "Rior Filament ($5000)",
            "Supreme Filament ($1425)"
        }
        local selGuapoItem = guapoItems[1]
        local selGuapoQty = 1

        cDD(cardGuapo, "Guapo Item", guapoItems, selGuapoItem, function(v)
            selGuapoItem = v
        end)

        local rowGuapo = Instance.new("Frame")
        rowGuapo.Size = UDim2.new(1, 0, 0, 26)
        rowGuapo.BackgroundTransparency = 1
        rowGuapo.ZIndex = 10
        rowGuapo.Parent = cardGuapo

        local leftGuapo = Instance.new("Frame")
        leftGuapo.Size = UDim2.new(0.6, 6, 1, 0)
        leftGuapo.Position = UDim2.new(0, -6, 0, 0)
        leftGuapo.BackgroundTransparency = 1
        leftGuapo.ZIndex = 10
        leftGuapo.Parent = rowGuapo

        local rightGuapo = Instance.new("Frame")
        rightGuapo.Size = UDim2.new(0.4, 6, 1, 0)
        rightGuapo.Position = UDim2.new(0.6, -6, 0, 0)
        rightGuapo.BackgroundTransparency = 1
        rightGuapo.ZIndex = 10
        rightGuapo.Parent = rowGuapo

        cBtn(leftGuapo, "Buy Item", function()
            for i = 1, selGuapoQty do
                buyShopItem("guapoFrame", selGuapoItem)
                if i < selGuapoQty then task.wait(0.2) end
            end
        end)

        cDD(rightGuapo, "QTY", qtyOptions, "1", function(v)
            selGuapoQty = tonumber(v) or 1
        end)

        -- Freedom Guns Controls
        do
            local gunItems = {
                "G26 ($750)",
                "S&W Snub ($1000)",
                "G17 Gen3 ($1250)",
                "G17 Gen5 ($1450)",
                "Hellcat Extended ($1500)",
                "Colt M1911 ($1850)",
                "G17 EDC ($2150)",
                "Baretta M9 ($2250)",
                "Springfield XD9 ($2450)",
                "G43x ($2750)",
                "G43x DJ ($3250)",
                "G19x Drum ($3450)",
                "Canik TP9 ($3800)",
                "Micro-ARP 9 ($3899)",
                "Draco 9s ($4000)",
                "G40 Gen4 ($4200)",
                "G20 G-Flex ($4499)",
                "Micro AR-Pistol ($4650)",
                "Micro Draco ($5000)",
                "G40 VectMag ($5170)",
                "G21 VectMag ($5850)",
                "M16 Rifle ($12400)",
                "AR15 Rifle ($15750)",
                "300 Blackout ($24000)",
                "PLR 16 ($35000)"
            }
            local selGunItem = gunItems[1]
            local selGunQty = 1

            cDD(cardFreedomGuns, "Freedom Gun", gunItems, selGunItem, function(v)
                selGunItem = v
            end)

            local rowGuns = Instance.new("Frame")
            rowGuns.Size = UDim2.new(1, 0, 0, 26)
            rowGuns.BackgroundTransparency = 1
            rowGuns.ZIndex = 10
            rowGuns.Parent = cardFreedomGuns

            local leftGuns = Instance.new("Frame")
            leftGuns.Size = UDim2.new(0.6, 6, 1, 0)
            leftGuns.Position = UDim2.new(0, -6, 0, 0)
            leftGuns.BackgroundTransparency = 1
            leftGuns.ZIndex = 10
            leftGuns.Parent = rowGuns

            local rightGuns = Instance.new("Frame")
            rightGuns.Size = UDim2.new(0.4, 6, 1, 0)
            rightGuns.Position = UDim2.new(0.6, -6, 0, 0)
            rightGuns.BackgroundTransparency = 1
            rightGuns.ZIndex = 10
            rightGuns.Parent = rowGuns

            cBtn(leftGuns, "Buy Gun", function()
                for i = 1, selGunQty do
                    buyShopItem("freedomTacticalFrame", selGunItem, "Content1")
                    if i < selGunQty then task.wait(0.2) end
                end
            end)

            cDD(rightGuns, "QTY", qtyOptions, "1", function(v)
                selGunQty = tonumber(v) or 1
            end)
        end

        -- Freedom Ammo Controls
        do
            local ammoItems = {
                ".22 Box ($65)",
                ".357 Box ($95)",
                "9mm Box ($100)",
                ".40 Box ($125)",
                "10mm Box ($130)",
                ".45 Box ($150)",
                "5.7 Box ($180)",
                "7.62 Box ($250)",
                "5.56 Box ($275)",
                ".300 Box ($280)"
            }
            local selAmmoItem = ammoItems[1]
            local selAmmoQty = 1

            cDD(cardFreedomAmmo, "Freedom Ammo", ammoItems, selAmmoItem, function(v)
                selAmmoItem = v
            end)

            local rowAmmo = Instance.new("Frame")
            rowAmmo.Size = UDim2.new(1, 0, 0, 26)
            rowAmmo.BackgroundTransparency = 1
            rowAmmo.ZIndex = 10
            rowAmmo.Parent = cardFreedomAmmo

            local leftAmmo = Instance.new("Frame")
            leftAmmo.Size = UDim2.new(0.6, 6, 1, 0)
            leftAmmo.Position = UDim2.new(0, -6, 0, 0)
            leftAmmo.BackgroundTransparency = 1
            leftAmmo.ZIndex = 10
            leftAmmo.Parent = rowAmmo

            local rightAmmo = Instance.new("Frame")
            rightAmmo.Size = UDim2.new(0.4, 6, 1, 0)
            rightAmmo.Position = UDim2.new(0.6, -6, 0, 0)
            rightAmmo.BackgroundTransparency = 1
            rightAmmo.ZIndex = 10
            rightAmmo.Parent = rowAmmo

            cBtn(leftAmmo, "Buy Ammo", function()
                for i = 1, selAmmoQty do
                    buyShopItem("freedomTacticalFrame", selAmmoItem, "Content2")
                    if i < selAmmoQty then task.wait(0.2) end
                end
            end)

            cDD(rightAmmo, "QTY", qtyOptions, "1", function(v)
                selAmmoQty = tonumber(v) or 1
            end)
        end

        if hookmetamethod and not getgenv().YIX_NamecallHooked then
            getgenv().YIX_NamecallHooked = true
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = { ... }

                if not checkcaller() and method == "GetAttribute" then
                    if getgenv().YIX_InfEn and args[1] == "Energy" then
                        return 100
                    elseif getgenv().YIX_InfHg and args[1] == "Hunger" then
                        return 100
                    end
                end

                return oldNamecall(self, unpack(args))
            end))
        end

        task.spawn(function()
            while task.wait(3) do
                if getgenv().YIX_InfHg then
                    local char = lp.Character
                    local bp = lp:FindFirstChild("Backpack")

                    local function processFood(parent)
                        if not parent then return end
                        for _, item in ipairs(parent:GetChildren()) do
                            if item:IsA("Tool") and item:FindFirstChild("Event") then
                                pcall(function()
                                    item.Event:FireServer("portions", math.huge)
                                end)
                            end
                        end
                    end

                    processFood(char)
                    processFood(bp)
                end
            end
        end)

        local wsOn = false
        local wsVal = 50
        local wsTogFunc, wsBx
        wsTogFunc, wsBx = cTogBind(mc1, "WalkSpeed Bypass", false, cfg.wsBind or "", function(v)
            wsOn = v
        end, function(v) return assignBind(v, "wsBind", wsTogFunc, "WalkSpeed Bypass", "Utilities", wsBx) end)
        if cfg.wsBind and cfg.wsBind ~= "" then
            getgenv().YIX_Binds[cfg.wsBind:upper()] = {
                func = wsTogFunc,
                name =
                "WalkSpeed Bypass",
                category = "Utilities",
                cfgKey = "wsBind",
                bx = wsBx
            }
        end

        cSli(mc1, "WalkSpeed", 16, 150, 50, function(v)
            wsVal = v
        end)

        local flyOn = false
        local flyVal = 50
        local flyConn
        local jumpConn
        local isJumping = false
        local flyPos = Vector3.new(0, 0, 0)

        local flyTogFunc, flyBx
        flyTogFunc, flyBx = cTogBind(mc1, "Player Fly", false, cfg.flyBind or "", function(v)
            flyOn = v
            if flyOn then
                antiFallOn = true
            end

            local char = lp.Character

            if not flyOn then
                if flyConn then
                    flyConn:Disconnect(); flyConn = nil
                end
                if jumpConn then
                    jumpConn:Disconnect(); jumpConn = nil
                end
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.PlatformStand = false
                end
            else
                if char and char:FindFirstChild("HumanoidRootPart") then
                    flyPos = char.HumanoidRootPart.Position
                    char.Humanoid.PlatformStand = true
                end
                isJumping = false
                jumpConn = uis.JumpRequest:Connect(function()
                    isJumping = true
                end)
                flyConn = rs.Heartbeat:Connect(function(dt)
                    local cChar = lp.Character
                    if not cChar then return end
                    local hum = cChar:FindFirstChild("Humanoid")
                    local hrp = cChar:FindFirstChild("HumanoidRootPart")
                    if not hum or not hrp then return end

                    hum.PlatformStand = true
                    local cam = workspace.CurrentCamera
                    local moveDir = hum.MoveDirection
                    local flyVelocity = Vector3.new(0, 0, 0)

                    if moveDir.Magnitude > 0 then
                        local camCF = cam.CFrame
                        local lookFlat = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
                        if lookFlat.Magnitude == 0 then lookFlat = Vector3.new(0, 0, -1) end
                        local flatCamCF = CFrame.new(camCF.Position, camCF.Position + lookFlat)
                        local rel = flatCamCF:VectorToObjectSpace(moveDir)
                        local dir = (camCF.LookVector * -rel.Z) + (camCF.RightVector * rel.X)
                        if dir.Magnitude > 0 then dir = dir.Unit end
                        flyVelocity = dir * flyVal
                    end

                    local vertSpeed = flyVal * 0.8
                    local upVal = 0
                    if isJumping then
                        upVal = vertSpeed
                        isJumping = false
                    elseif uis:IsKeyDown(Enum.KeyCode.LeftShift) then
                        upVal = -vertSpeed
                    end

                    if upVal ~= 0 then
                        flyVelocity = Vector3.new(flyVelocity.X, upVal, flyVelocity.Z)
                    end

                    if (hrp.Position - flyPos).Magnitude > 10 then
                        flyPos = hrp.Position
                    end

                    flyPos = flyPos + (flyVelocity * dt)

                    local camLookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                    local targetCFrame
                    if camLookFlat.Magnitude > 0 then
                        targetCFrame = CFrame.new(flyPos, flyPos + camLookFlat.Unit)
                    else
                        targetCFrame = CFrame.new(flyPos)
                    end

                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = targetCFrame
                end)
            end
        end, function(v) return assignBind(v, "flyBind", flyTogFunc, "Player Fly", "Utilities", flyBx) end)
        if cfg.flyBind and cfg.flyBind ~= "" then
            getgenv().YIX_Binds[cfg.flyBind:upper()] = {
                func = flyTogFunc,
                name =
                "Player Fly",
                category = "Utilities",
                cfgKey = "flyBind",
                bx = flyBx
            }
        end
        cSli(mc1, "Fly Speed", 16, 200, 50, function(v) flyVal = v end)

        local fallingEventFired = false
        rs.Stepped:Connect(function()
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end

            if getgenv().YIX_InfEn then
                local e = char:FindFirstChild("Energy") or char:FindFirstChild("Stamina") or lp:FindFirstChild("Energy")
                if e and (e:IsA("IntValue") or e:IsA("NumberValue")) then
                    e.Value = 100
                end
            end

            if getgenv().YIX_InfHg then
                local h = char:FindFirstChild("Hunger") or lp:FindFirstChild("Hunger")
                if h and (h:IsA("IntValue") or h:IsA("NumberValue")) then
                    h.Value = 100
                end
            end

            if wsOn and not flyOn then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (moveDir * (wsVal / 100))
                end
            end
            if antiFallOn and not flyOn then
                if hrp.Velocity.Y < -30 and hum.Health > 0 then
                    if not fallingEventFired then
                        fallingEventFired = true
                        local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                        if JuneEvent then
                            firesignal(JuneEvent.OnClientEvent, true)
                        end
                    end
                elseif hrp.Velocity.Y > -5 then
                    if fallingEventFired then
                        fallingEventFired = false
                        local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                        if JuneEvent then
                            firesignal(JuneEvent.OnClientEvent, false)
                        end
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end
        end)

        mcR = msS["General"].r
        mc2 = cC(mcR, "Teleports")

        local tpLocs = {
            ["trash job 🗑️"] = CFrame.new(290.59, 12.08, 795.76),
            ["gun store 🔫"] = CFrame.new(193.62, 13.57, 952.45),
            ["laundry 🧦"] = CFrame.new(2462.37, -22.28, -1333.07),
            ["sell stolen items 💼"] = CFrame.new(44.43, 11.95, 788.31),
            ["barber shop ✂️"] = CFrame.new(-1888.77, -6.30, -2839.55),
            ["stolen ovens 🧺"] = CFrame.new(3122.21, -21.36, 2362.67),
            ["pvp ☠️"] = CFrame.new(-774.08, 4.18, 1091.93),
            ["cookies 🍪"] = CFrame.new(425.32, 6.28, 1355.10),
            ["wood job 🪓"] = CFrame.new(700.74, 4.18, 834.31),
            ["car dealer 🚗"] = CFrame.new(619.16, 4.21, 354.77),
            ["basket ball area 🏀"] = CFrame.new(487.82, 4.23, 334.49),
            ["gas station ⛽"] = CFrame.new(285.64, 3.95, 322.75),
            ["P Mobile 📱"] = CFrame.new(695.58, 8.22, -73.90),
            ["BiteWay 🥖"] = CFrame.new(2503.06, -38.05, -1160.59),
            ["Hair salon 💇‍♀️"] = CFrame.new(799.98, 4.20, 960.70),
            ["car tune 🏎️"] = CFrame.new(997.19, 4.20, 825.74),
            ["Lucky Strike 🎱"] = CFrame.new(1155.28, 4.21, 572.98),
            ["Clothes Store 👕"] = CFrame.new(883.59, 4.28, -310.33),
            ["Sell Repz 🛍️"] = CFrame.new(2492.18, -20.35, -369.60),
            ["Gym 💪"] = CFrame.new(3159.20, -24.99, 1738.37),
            ["guapo 🕺"] = CFrame.new(171.39, 4.15, -164.59),
            ["printers 🖨️"] = CFrame.new(-134.91, 4.18, 161.99),
            ["tatto 💉"] = CFrame.new(-1888.85, -4.16, -2839.32),
            ["mop job 🧹"] = CFrame.new(2457.02, -27.46, -2033.97),
            ["bank 🏦"] = CFrame.new(-471.95, 4.19, -425.91),
            ["Clinic 🏥"] = CFrame.new(51.30, 4.03, -2259.24),
            ["Post Office 📨"] = CFrame.new(1833.22, -24.30, -2832.88),
            ["chop shop 🚗"] = CFrame.new(-908.76, 4.20, 489.44),
            ["ice box 🧊"] = CFrame.new(-1278.87, 4.18, 520.06),
            ["Confirm kills 💀"] = CFrame.new(-1278.28, 8.22, 522.22),
            ["Black Market 1 🏴"] = CFrame.new(-2562.15, 4.08, 903.27),
            ["Black Market 2 🏴"] = CFrame.new(-469.28, 15.44, 783.90)
        }
        local tpNames = {
            "trash job 🗑️", "gun store 🔫", "laundry 🧦", "sell stolen items 💼", "barber shop ✂️", "stolen ovens 🧺",
            "pvp ☠️", "cookies 🍪", "wood job 🪓", "car dealer 🚗", "basket ball area 🏀", "gas station ⛽", "P Mobile 📱",
            "BiteWay 🥖", "Hair salon 💇‍♀️", "car tune 🏎️", "Lucky Strike 🎱", "Clothes Store 👕", "Sell Repz 🛍️", "Gym 💪",
            "guapo 🕺", "printers 🖨️", "tatto 💉", "mop job 🧹", "bank 🏦", "Clinic 🏥", "Post Office 📨", "chop shop 🚗",
            "ice box 🧊", "Confirm kills 💀", "Black Market 1 🏴", "Black Market 2 🏴"
        }

        local selTp = tpNames[1]
        cDD(mc2, "Location", tpNames, selTp, function(v)
            selTp = v
        end)

        cBtn(mc2, "Teleport", function()
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local target = tpLocs[selTp]
                if target then
                    local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                    if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

                    hrp.Anchored = true
                    task.wait(0.05)
                    hrp.CFrame = target
                    task.wait(0.05)
                    hrp.Anchored = false

                    if JuneEvent then
                        firesignal(JuneEvent.OnClientEvent, false)
                        if char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end
                end
            end
        end)

        cardFists = cC(mcR, "Fists Utilities")

        getgenv().YIX_InfFistStam = false
        cTog(cardFists, "Infinite Combat Stamina", false, function(v)
            getgenv().YIX_InfFistStam = v
            if v then
                task.spawn(function()
                    while getgenv().YIX_InfFistStam do
                        local fists = lp.Character and
                            (lp.Character:FindFirstChild("Fists") or lp.Backpack:FindFirstChild("Fists"))
                        local values = fists and fists:FindFirstChild("Values")
                        if values then
                            pcall(function() values:SetAttribute("Stamina", 100) end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end)

        getgenv().YIX_NoHeavyCD = false
        cTog(cardFists, "No Heavy Cooldown", false, function(v)
            getgenv().YIX_NoHeavyCD = v
            if v then
                task.spawn(function()
                    while getgenv().YIX_NoHeavyCD do
                        local fists = lp.Character and
                            (lp.Character:FindFirstChild("Fists") or lp.Backpack:FindFirstChild("Fists"))
                        local values = fists and fists:FindFirstChild("Values")
                        if values then
                            pcall(function() values:SetAttribute("HeavyCooldown", 100) end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end)

        getgenv().YIX_InfBlock = false
        cTog(cardFists, "Infinite Block Health", false, function(v)
            getgenv().YIX_InfBlock = v
            if v then
                task.spawn(function()
                    while getgenv().YIX_InfBlock do
                        local fists = lp.Character and
                            (lp.Character:FindFirstChild("Fists") or lp.Backpack:FindFirstChild("Fists"))
                        local values = fists and fists:FindFirstChild("Values")
                        if values then
                            pcall(function() values:SetAttribute("BlockHealth", 100) end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end)

        getgenv().YIX_AntiStun = false
        cTog(cardFists, "Anti-Stun", false, function(v)
            getgenv().YIX_AntiStun = v
            if v then
                task.spawn(function()
                    while getgenv().YIX_AntiStun do
                        local fists = lp.Character and
                            (lp.Character:FindFirstChild("Fists") or lp.Backpack:FindFirstChild("Fists"))
                        local values = fists and fists:FindFirstChild("Values")
                        if values then
                            pcall(function() values:SetAttribute("Stunned", false) end)
                        end
                        local settings2 = lp:FindFirstChild("Settings") and lp.Settings:FindFirstChild("Settings")
                        if settings2 then
                            pcall(function() settings2:SetAttribute("HoldStill", false) end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end)

        getgenv().YIX_AutoStomp = false
        cTog(cardFists, "Auto Stomp", false, function(v)
            getgenv().YIX_AutoStomp = v
            if v then
                task.spawn(function()
                    while getgenv().YIX_AutoStomp do
                        local fists = lp.Character and
                            (lp.Character:FindFirstChild("Fists") or lp.Backpack:FindFirstChild("Fists"))
                        local event = fists and fists:FindFirstChild("Event")
                        if event then
                            pcall(function()
                                event:FireServer("Stomp")
                            end)
                        end
                        task.wait(0.3)
                    end
                end)
            end
        end)
    end -- End Misc Tab

    do  -- Other Tab
        oT = cMT("Other", "129185588770092", false)
        oS = cSM(oT, { "Extra", "Cars Mods" })
        ocL = oS["Extra"].l
        carL = oS["Cars Mods"].l
        carR = oS["Cars Mods"].r

        cardPlayers = cC(ocL, "Players")

        local playerList = {}
        for _, p in ipairs(plrs:GetPlayers()) do
            if p ~= lp then table.insert(playerList, p.Name) end
        end
        table.sort(playerList)
        if #playerList == 0 then table.insert(playerList, "None") end

        local selectedPlayerName = playerList[1]

        local function getPlayerList()
            local list = {}
            for _, p in ipairs(plrs:GetPlayers()) do
                if p ~= lp then table.insert(list, p.Name) end
            end
            table.sort(list)
            if #list == 0 then table.insert(list, "None") end
            return list
        end

        local invGui = nil
        local openInventoryUI

        local plrDD
        plrDD = cDD(cardPlayers, "Select Player", playerList, selectedPlayerName, function(v)
            selectedPlayerName = v
            if getgenv().YIX_SpectateActive then
                local cam = workspace.CurrentCamera
                local targetPlr = plrs:FindFirstChild(selectedPlayerName)
                if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid") then
                    cam.CameraSubject = targetPlr.Character:FindFirstChildOfClass("Humanoid")
                end
            end
            local activeParent = cg:FindFirstChild("UIX") or lp:FindFirstChildOfClass("PlayerGui"):FindFirstChild("UIX") or
                invGui
            if activeParent and activeParent:FindFirstChild("PlayerInventoryFrame") then
                openInventoryUI()
            end
        end)

        local function refreshPlayerDD()
            local newList = getPlayerList()
            if not table.find(newList, selectedPlayerName) then
                selectedPlayerName = newList[1] or "None"
            end
            pcall(function() plrDD.Refresh(newList) end)
        end
        plrs.PlayerAdded:Connect(refreshPlayerDD)
        plrs.PlayerRemoving:Connect(refreshPlayerDD)

        -- 1. Teleport to Player (First under dropdown)
        cBtn(cardPlayers, "Teleport to Player", function()
            if not selectedPlayerName or selectedPlayerName == "None" then return end
            local targetPlr = plrs:FindFirstChild(selectedPlayerName)
            if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
                local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = targetPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end)

        -- 2. Dynamic Spectate Player
        getgenv().YIX_SpectateActive = false
        cTog(cardPlayers, "Spectate Player", false, function(v)
            getgenv().YIX_SpectateActive = v
            Notify("Player", "Spectate " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            local cam = workspace.CurrentCamera
            if v then
                local targetPlr = plrs:FindFirstChild(selectedPlayerName)
                if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid") then
                    cam.CameraSubject = targetPlr.Character:FindFirstChildOfClass("Humanoid")
                end
            else
                if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    cam.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
                end
            end
        end)

        -- Auto-switch camera if target character respawns
        plrs.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c)
                if getgenv().YIX_SpectateActive and p.Name == selectedPlayerName then
                    task.wait(0.5)
                    local cam = workspace.CurrentCamera
                    local hum = c:WaitForChild("Humanoid", 5)
                    if hum then cam.CameraSubject = hum end
                end
            end)
        end)

        -- 3. Show Player Inventory (Top-Level, Dynamic & Draggable Position Saved)
        openInventoryUI = function()
            if not selectedPlayerName or selectedPlayerName == "None" then return end
            local targetPlr = plrs:FindFirstChild(selectedPlayerName)
            if not targetPlr then return end

            local targetParent = cg:FindFirstChild("UIX") or lp:FindFirstChildOfClass("PlayerGui"):FindFirstChild("UIX")
            if not targetParent then
                if invGui then invGui:Destroy() end
                invGui = Instance.new("ScreenGui")
                invGui.Name = "YIX_PlayerInventory"
                invGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                invGui.DisplayOrder = 999999
                invGui.ResetOnSpawn = false
                local parentSuccess = pcall(function() invGui.Parent = cg end)
                if not parentSuccess then pcall(function() invGui.Parent = lp:FindFirstChildOfClass("PlayerGui") end) end
                targetParent = invGui
            end

            if targetParent:FindFirstChild("PlayerInventoryFrame") then
                targetParent.PlayerInventoryFrame:Destroy()
            end

            local mainFrame = Instance.new("Frame")
            mainFrame.Name = "PlayerInventoryFrame"
            mainFrame.Size = UDim2.new(0, 310, 0, 120)
            if lastInvPosition then
                mainFrame.Position = lastInvPosition
            else
                mainFrame.Position = UDim2.new(0.5, 120, 0.35, 0)
            end
            mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
            mainFrame.BorderSizePixel = 0
            mainFrame.Active = true
            mainFrame.Draggable = true
            mainFrame.ZIndex = 9000
            mainFrame.Parent = targetParent

            mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
                lastInvPosition = mainFrame.Position
            end)

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = mainFrame

            local stroke = Instance.new("UIStroke")
            stroke.Color = tm.a or Color3.fromRGB(247, 95, 142)
            stroke.Thickness = 1.2
            stroke.Parent = mainFrame

            -- Header Bar
            local headerBar = Instance.new("Frame")
            headerBar.Size = UDim2.new(1, 0, 0, 46)
            headerBar.BackgroundTransparency = 1
            headerBar.BorderSizePixel = 0
            headerBar.ZIndex = 9001
            headerBar.Parent = mainFrame

            local headerLine = Instance.new("Frame")
            headerLine.Size = UDim2.new(1, -20, 0, 1)
            headerLine.Position = UDim2.new(0, 10, 1, -1)
            headerLine.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
            headerLine.BorderSizePixel = 0
            headerLine.ZIndex = 9001
            headerLine.Parent = headerBar

            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size = UDim2.new(0, 32, 0, 32)
            avatarImg.Position = UDim2.new(0, 10, 0.5, -16)
            avatarImg.BackgroundTransparency = 1
            avatarImg.Image = "rbxassetid://6031763426"
            avatarImg.ZIndex = 9002
            avatarImg.Parent = headerBar

            local avCorner = Instance.new("UICorner")
            avCorner.CornerRadius = UDim.new(1, 0)
            avCorner.Parent = avatarImg

            task.spawn(function()
                local s, content = pcall(function()
                    return plrs:GetUserThumbnailAsync(targetPlr.UserId, Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100)
                end)
                if s and content then avatarImg.Image = content end
            end)

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, -95, 0, 18)
            titleLbl.Position = UDim2.new(0, 48, 0, 5)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = targetPlr.DisplayName
            titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextSize = 13
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
            titleLbl.ZIndex = 9002
            titleLbl.Parent = headerBar

            local subTitleLbl = Instance.new("TextLabel")
            subTitleLbl.Size = UDim2.new(1, -95, 0, 16)
            subTitleLbl.Position = UDim2.new(0, 48, 0, 23)
            subTitleLbl.BackgroundTransparency = 1
            subTitleLbl.Text = "@" .. targetPlr.Name
            subTitleLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
            subTitleLbl.Font = tm.f
            subTitleLbl.TextSize = 11
            subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            subTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
            subTitleLbl.ZIndex = 9002
            subTitleLbl.Parent = headerBar

            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(0, 26, 0, 26)
            closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
            closeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            closeBtn.Font = Enum.Font.GothamBold
            closeBtn.TextSize = 12
            closeBtn.ZIndex = 9005
            closeBtn.Parent = headerBar

            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 6)
            closeCorner.Parent = closeBtn

            closeBtn.MouseEnter:Connect(function()
                closeBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 80)
                closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
            closeBtn.MouseLeave:Connect(function()
                closeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
                closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            end)
            closeBtn.MouseButton1Click:Connect(function()
                mainFrame:Destroy()
                if invGui then
                    invGui:Destroy()
                    invGui = nil
                end
            end)

            -- Scroll Container
            local scroll = Instance.new("ScrollingFrame")
            scroll.Size = UDim2.new(1, -16, 1, -54)
            scroll.Position = UDim2.new(0, 8, 0, 50)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = tm.a or Color3.fromRGB(247, 95, 142)
            scroll.ZIndex = 9001
            scroll.Parent = mainFrame

            local scrollPadding = Instance.new("UIPadding")
            scrollPadding.PaddingLeft = UDim.new(0, 4)
            scrollPadding.PaddingRight = UDim.new(0, 6)
            scrollPadding.PaddingTop = UDim.new(0, 4)
            scrollPadding.PaddingBottom = UDim.new(0, 8)
            scrollPadding.Parent = scroll

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 6)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = scroll

            local itemsFound = 0

            local function addItemCard(toolObj, isEquipped)
                itemsFound = itemsFound + 1

                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -10, 0, 36)
                card.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                card.BorderSizePixel = 0
                card.ZIndex = 9002
                card.Parent = scroll

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = UDim.new(0, 6)
                cardCorner.Parent = card

                local cardStroke = Instance.new("UIStroke")
                cardStroke.Color = isEquipped and (tm.a or Color3.fromRGB(247, 95, 142)) or Color3.fromRGB(42, 42, 52)
                cardStroke.Thickness = 1
                cardStroke.Parent = card

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, -85, 1, 0)
                nameLbl.Position = UDim2.new(0, 12, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = toolObj and toolObj.Name or "Unknown Item"
                nameLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
                nameLbl.Font = Enum.Font.GothamMedium
                nameLbl.TextSize = 12
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex = 9003
                nameLbl.Parent = card

                if isEquipped then
                    local badge = Instance.new("Frame")
                    badge.Size = UDim2.new(0, 64, 0, 18)
                    badge.Position = UDim2.new(1, -70, 0.5, -9)
                    badge.BackgroundColor3 = tm.a or Color3.fromRGB(247, 95, 142)
                    badge.ZIndex = 9003
                    badge.Parent = card

                    local badgeCorner = Instance.new("UICorner")
                    badgeCorner.CornerRadius = UDim.new(0, 4)
                    badgeCorner.Parent = badge

                    local badgeLbl = Instance.new("TextLabel")
                    badgeLbl.Size = UDim2.new(1, 0, 1, 0)
                    badgeLbl.BackgroundTransparency = 1
                    badgeLbl.Text = "EQUIPPED"
                    badgeLbl.TextColor3 = Color3.fromRGB(15, 15, 18)
                    badgeLbl.Font = Enum.Font.GothamBold
                    badgeLbl.TextSize = 9
                    badgeLbl.ZIndex = 9004
                    badgeLbl.Parent = badge
                end
            end

            -- Read equipped items from character
            if targetPlr.Character then
                for _, child in ipairs(targetPlr.Character:GetChildren()) do
                    if child:IsA("Tool") then
                        addItemCard(child, true)
                    end
                end
            end

            -- Read items from backpack
            local bp = targetPlr:FindFirstChild("Backpack")
            if bp then
                for _, child in ipairs(bp:GetChildren()) do
                    if child:IsA("Tool") then
                        addItemCard(child, false)
                    end
                end
            end

            if itemsFound == 0 then
                local emptyLbl = Instance.new("TextLabel")
                emptyLbl.Size = UDim2.new(1, 0, 0, 40)
                emptyLbl.BackgroundTransparency = 1
                emptyLbl.Text = "📦 Inventory is empty"
                emptyLbl.TextColor3 = Color3.fromRGB(140, 140, 150)
                emptyLbl.Font = tm.f
                emptyLbl.TextSize = 12
                emptyLbl.ZIndex = 9002
                emptyLbl.Parent = scroll
            end

            -- Calculate Responsive Sizing for Mobile & Desktop
            local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
            local targetWidth = math.min(viewport.X - 30, 310)
            local calcContentHeight = (itemsFound > 0) and (itemsFound * 42) or 44
            local maxAllowedHeight = math.clamp(viewport.Y - 50, 110, 360)
            local targetWindowHeight = math.clamp(50 + calcContentHeight + 16, 110, maxAllowedHeight)

            scroll.CanvasSize = UDim2.new(0, 0, 0, calcContentHeight)
            mainFrame.Size = UDim2.new(0, targetWidth, 0, targetWindowHeight)

            if not lastInvPosition then
                mainFrame.Position = UDim2.new(0.5, -(targetWidth / 2), 0.5, -(targetWindowHeight / 2))
            end
        end

        cBtn(cardPlayers, "Show Player Inventory", function()
            openInventoryUI()
        end)

        -- 4. Fling Player (Estilo Deluxe Fling de Fling.lua)
        cBtn(cardPlayers, "Fling Player", function()
            if not selectedPlayerName or selectedPlayerName == "None" then return end
            local TargetPlayer = plrs:FindFirstChild(selectedPlayerName)
            if not TargetPlayer or TargetPlayer == lp then return end

            task.spawn(function()
                local Character = lp.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local RootPart = Humanoid and Humanoid.RootPart or
                    (Character and Character:FindFirstChild("HumanoidRootPart"))
                local camera = workspace.CurrentCamera

                if not (Character and Humanoid and RootPart and Humanoid.Health > 0) then return end

                local TCharacter = TargetPlayer.Character
                if not TCharacter then return end

                local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
                local TRootPart = THumanoid and
                    (THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart") or TCharacter:FindFirstChild("Torso") or TCharacter:FindFirstChild("UpperTorso"))
                local THead = TCharacter:FindFirstChild("Head") or TCharacter:FindFirstChild("UpperTorso")
                local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
                local Handle = Accessory and Accessory:FindFirstChild("Handle")

                local oldPos = RootPart.CFrame

                -- Fling Deluxe Protect Part & Gyro
                local loopProtect = Instance.new("Part")
                loopProtect.Size = Vector3.new(1, 1, 1)
                loopProtect.Transparency = 1
                loopProtect.CanCollide = false
                loopProtect.Anchored = false
                loopProtect.Parent = camera

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = RootPart
                weld.Part1 = loopProtect
                weld.Parent = loopProtect

                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                bodyGyro.D = 1000
                bodyGyro.P = 2000
                bodyGyro.Parent = loopProtect

                -- Camera Subject Focus
                if THead then
                    camera.CameraSubject = THead
                elseif Handle then
                    camera.CameraSubject = Handle
                elseif THumanoid then
                    camera.CameraSubject = THumanoid
                end

                local FPos = function(BasePart, Pos, Ang)
                    RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                    Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                    RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                    RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                end

                local SFBasePart = function(BasePart)
                    local TimeToWait = 2
                    local Time = tick()
                    local Angle = 0
                    repeat
                        if RootPart and THumanoid and TCharacter and TCharacter.Parent then
                            if BasePart.Velocity.Magnitude < 50 then
                                Angle = Angle + 100
                                FPos(BasePart,
                                    CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart,
                                    CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart,
                                    CFrame.new(2.25, 1.5, -2.25) +
                                    THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart,
                                    CFrame.new(-2.25, -1.5, 2.25) +
                                    THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,
                                    CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                            else
                                FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0),
                                    CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                FPos(BasePart,
                                    CFrame.new(0, -1.5, -(TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0)),
                                    CFrame.Angles(0, 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, 1.5, TRootPart and TRootPart.Velocity.Magnitude / 1.25 or 0),
                                    CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                task.wait()
                            end
                        else
                            break
                        end
                    until not BasePart or not BasePart.Parent or BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= plrs or TargetPlayer.Character ~= TCharacter or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0 or tick() > Time + TimeToWait
                end

                local OrgDestroyHeight = workspace.FallenPartsDestroyHeight
                pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)

                local BV = Instance.new("BodyVelocity")
                BV.Parent = RootPart
                BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
                BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)

                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                if TRootPart and THead then
                    if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                        SFBasePart(THead)
                    else
                        SFBasePart(TRootPart)
                    end
                elseif TRootPart and not THead then
                    SFBasePart(TRootPart)
                elseif not TRootPart and THead then
                    SFBasePart(THead)
                elseif not TRootPart and not THead and Accessory and Handle then
                    SFBasePart(Handle)
                end

                if BV then BV:Destroy() end
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                camera.CameraSubject = Humanoid

                repeat
                    if RootPart and oldPos then
                        RootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)
                        Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, 0.5, 0))
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        for _, x in ipairs(Character:GetChildren()) do
                            if x:IsA("BasePart") then
                                x.Velocity = Vector3.new(0, 0, 0)
                                x.RotVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                    task.wait()
                until not RootPart or (RootPart.Position - oldPos.Position).Magnitude < 25

                pcall(function() workspace.FallenPartsDestroyHeight = OrgDestroyHeight end)
                if loopProtect then loopProtect:Destroy() end
            end)
        end)

        -- Car Utilities Card (Cars Mods Sub-Tab)
        local cardCarUtil = cC(carL, "Car Utilities")

        local carFlyOn = false
        local carFlySpeed = 80
        local carFlyConn = nil

        local carFlyTogFunc, carFlyBx
        carFlyTogFunc, carFlyBx = cTogBind(cardCarUtil, "Enable Car Fly", false, cfg.carFlyBind or "", function(v)
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            local isSeatVehicle = seat and (seat:IsA("VehicleSeat") or seat:FindFirstAncestorOfClass("Model") ~= nil)

            if v and not isSeatVehicle then
                carFlyOn = false
                getgenv().YIX_CarFlyOn = false
                if typeof(carFlyTogFunc) == "function" then
                    carFlyTogFunc(false, true)
                elseif type(carFlyTogFunc) == "table" and carFlyTogFunc.Set then
                    carFlyTogFunc.Set(false, true)
                end
                Notify("Car Fly Error", "You must be inside a vehicle seat to enable Car Fly!", 3, "Error")
                return
            end

            carFlyOn = v
            getgenv().YIX_CarFlyOn = v
            Notify("Car Mods", "Car Fly " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")

            local veh = seat and (seat:FindFirstAncestorOfClass("Model") or seat.Parent)
            local primary = veh and (veh.PrimaryPart or seat)

            if not v then
                if carFlyConn then
                    carFlyConn:Disconnect(); carFlyConn = nil
                end
                if primary then
                    pcall(function()
                        if primary:FindFirstChild("YIX_CarFlyGyro") then primary.YIX_CarFlyGyro:Destroy() end
                        if primary:FindFirstChild("YIX_CarFlyVel") then primary.YIX_CarFlyVel:Destroy() end
                        primary.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end)
                end
                return
            end

            task.spawn(function()
                local bg = Instance.new("BodyGyro")
                bg.Name = "YIX_CarFlyGyro"
                bg.MaxTorque = Vector3.new(1, 1, 1) * math.huge
                bg.P = 10000

                local bv = Instance.new("BodyVelocity")
                bv.Name = "YIX_CarFlyVel"
                bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
                bv.P = 5000

                if carFlyConn then carFlyConn:Disconnect() end

                carFlyConn = rs.Heartbeat:Connect(function()
                    local c = lp.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local s = h and h.SeatPart
                    local vModel = s and (s:FindFirstAncestorOfClass("Model") or s.Parent)
                    local root = vModel and (vModel.PrimaryPart or s)

                    if not carFlyOn or not getgenv().YIX_CarFlyOn or not root then
                        bg:Destroy()
                        bv:Destroy()
                        if carFlyConn then
                            carFlyConn:Disconnect(); carFlyConn = nil
                        end
                        return
                    end

                    bg.Parent = root
                    bv.Parent = root

                    local cam = workspace.CurrentCamera
                    bg.CFrame = cam.CFrame

                    local moveVec = Vector3.new(0, 0, 0)
                    if uis:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0, 1, 0) end

                    if moveVec.Magnitude > 0 then
                        bv.Velocity = moveVec.Unit * carFlySpeed
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end)
        end, function(v) return assignBind(v, "carFlyBind", carFlyTogFunc, "Enable Car Fly", "Cars Mods", carFlyBx) end)
        if cfg.carFlyBind and cfg.carFlyBind ~= "" then
            getgenv().YIX_Binds[cfg.carFlyBind:upper()] = {
                func = carFlyTogFunc,
                name = "Enable Car Fly",
                category =
                "Cars Mods",
                cfgKey = "carFlyBind",
                bx = carFlyBx
            }
        end

        cSli(cardCarUtil, "Car Fly Speed", 10, 300, 80, function(v) carFlySpeed = v end)

        getgenv().YIX_CarAutoFlip = false
        local carFlipTogFunc, carFlipBx
        carFlipTogFunc, carFlipBx = cTogBind(cardCarUtil, "Auto-Flip Vehicle", false, cfg.carFlipBind or "", function(v)
                getgenv().YIX_CarAutoFlip = v
                Notify("Car Mods", "Auto-Flip " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                if v then
                    task.spawn(function()
                        while getgenv().YIX_CarAutoFlip do
                            local char = lp.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local seat = hum and hum.SeatPart
                            if seat then
                                local veh = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                                local root = veh and (veh.PrimaryPart or seat)
                                if root and root.CFrame.UpVector.Y < 0.2 then
                                    pcall(function()
                                        local pos = root.Position + Vector3.new(0, 3, 0)
                                        local look = root.CFrame.LookVector
                                        root.CFrame = CFrame.new(pos, pos + Vector3.new(look.X, 0, look.Z))
                                        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    end)
                                end
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end,
            function(v) return assignBind(v, "carFlipBind", carFlipTogFunc, "Auto-Flip Vehicle", "Cars Mods", carFlipBx) end)
        if cfg.carFlipBind and cfg.carFlipBind ~= "" then
            getgenv().YIX_Binds[cfg.carFlipBind:upper()] = {
                func = carFlipTogFunc,
                name = "Auto-Flip Vehicle",
                category =
                "Cars Mods",
                cfgKey = "carFlipBind",
                bx = carFlipBx
            }
        end

        getgenv().YIX_CarSpeedBoost = false
        local carBoostPower = 2
        local carBoostTogFunc, carBoostBx
        carBoostTogFunc, carBoostBx = cTogBind(cardCarUtil, "Speed & Torque Boost", false, cfg.carBoostBind or "",
            function(v)
                getgenv().YIX_CarSpeedBoost = v
                Notify("Car Mods", "Speed Boost " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                if v then
                    task.spawn(function()
                        while getgenv().YIX_CarSpeedBoost do
                            local char = lp.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local seat = hum and hum.SeatPart
                            if seat and seat:IsA("VehicleSeat") and seat.Throttle > 0 then
                                local veh = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                                local root = veh and (veh.PrimaryPart or seat)
                                if root then
                                    pcall(function()
                                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity +
                                            (root.CFrame.LookVector * (carBoostPower * seat.Throttle * 0.8))
                                    end)
                                end
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end,
            function(v)
                return assignBind(v, "carBoostBind", carBoostTogFunc, "Speed & Torque Boost", "Cars Mods",
                    carBoostBx)
            end)
        if cfg.carBoostBind and cfg.carBoostBind ~= "" then
            getgenv().YIX_Binds[cfg.carBoostBind:upper()] = {
                func = carBoostTogFunc,
                name = "Speed & Torque Boost",
                category =
                "Cars Mods",
                cfgKey = "carBoostBind",
                bx = carBoostBx
            }
        end

        cSli(cardCarUtil, "Boost Multiplier", 1, 10, 2, function(v) carBoostPower = v end)

        getgenv().YIX_CarSuperBrake = false
        local carBrakeTogFunc, carBrakeBx
        carBrakeTogFunc, carBrakeBx = cTogBind(cardCarUtil, "Super Handbrake", false, cfg.carBrakeBind or "", function(v)
                getgenv().YIX_CarSuperBrake = v
                Notify("Car Mods", "Super Handbrake " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                if v then
                    task.spawn(function()
                        while getgenv().YIX_CarSuperBrake do
                            local char = lp.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local seat = hum and hum.SeatPart
                            if seat and seat:IsA("VehicleSeat") and (seat.Throttle < 0 or uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.P)) then
                                local veh = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                                local root = veh and (veh.PrimaryPart or seat)
                                if root then
                                    pcall(function()
                                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.4
                                    end)
                                end
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end,
            function(v) return assignBind(v, "carBrakeBind", carBrakeTogFunc, "Super Handbrake", "Cars Mods", carBrakeBx) end)
        if cfg.carBrakeBind and cfg.carBrakeBind ~= "" then
            getgenv().YIX_Binds[cfg.carBrakeBind:upper()] = {
                func = carBrakeTogFunc,
                name = "Super Handbrake",
                category =
                "Cars Mods",
                cfgKey = "carBrakeBind",
                bx = carBrakeBx
            }
        end

        getgenv().YIX_CarInfGas = false
        local carGasTogFunc, carGasBx
        carGasTogFunc, carGasBx = cTogBind(cardCarUtil, "Infinite Fuel / Gas", false, cfg.carGasBind or "", function(v)
                getgenv().YIX_CarInfGas = v
                Notify("Car Mods", "Infinite Fuel " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                if v then
                    task.spawn(function()
                        while getgenv().YIX_CarInfGas do
                            local char = lp.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local seat = hum and hum.SeatPart
                            local veh = seat and (seat:FindFirstAncestorOfClass("Model") or seat.Parent)
                            if veh then
                                pcall(function()
                                    if veh:FindFirstChild("Fuel") then veh.Fuel.Value = 100 end
                                    if veh:FindFirstChild("Gas") then veh.Gas.Value = 100 end
                                    veh:SetAttribute("Fuel", 100)
                                    veh:SetAttribute("Gas", 100)
                                end)
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end,
            function(v) return assignBind(v, "carGasBind", carGasTogFunc, "Infinite Fuel / Gas", "Cars Mods", carGasBx) end)
        if cfg.carGasBind and cfg.carGasBind ~= "" then
            getgenv().YIX_Binds[cfg.carGasBind:upper()] = {
                func = carGasTogFunc,
                name = "Infinite Fuel / Gas",
                category =
                "Cars Mods",
                cfgKey = "carGasBind",
                bx = carGasBx
            }
        end

        getgenv().YIX_CarGodmode = false
        local carGodTogFunc, carGodBx
        carGodTogFunc, carGodBx = cTogBind(cardCarUtil, "Vehicle Godmode", false, cfg.carGodBind or "", function(v)
            getgenv().YIX_CarGodmode = v
            Notify("Car Mods", "Vehicle Godmode " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            if v then
                task.spawn(function()
                    while getgenv().YIX_CarGodmode do
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local seat = hum and hum.SeatPart
                        local veh = seat and (seat:FindFirstAncestorOfClass("Model") or seat.Parent)
                        if veh then
                            pcall(function()
                                if veh:FindFirstChild("Health") then veh.Health.Value = 1000 end
                                if veh:FindFirstChild("EngineHealth") then veh.EngineHealth.Value = 1000 end
                                veh:SetAttribute("Health", 1000)
                                veh:SetAttribute("EngineHealth", 1000)
                            end)
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end, function(v) return assignBind(v, "carGodBind", carGodTogFunc, "Vehicle Godmode", "Cars Mods", carGodBx) end)
        if cfg.carGodBind and cfg.carGodBind ~= "" then
            getgenv().YIX_Binds[cfg.carGodBind:upper()] = {
                func = carGodTogFunc,
                name = "Vehicle Godmode",
                category =
                "Cars Mods",
                cfgKey = "carGodBind",
                bx = carGodBx
            }
        end

        cBtn(cardCarUtil, "Teleport to My Vehicle", function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local vehiclesFolder = workspace:FindFirstChild("Vehicles")
            local targetCar = vehiclesFolder and vehiclesFolder:FindFirstChild(lp.Name .. "'s Vehicle")

            if not targetCar and vehiclesFolder then
                for _, child in ipairs(vehiclesFolder:GetChildren()) do
                    if child.Name:lower():find(lp.Name:lower()) then
                        targetCar = child
                        break
                    end
                end
            end

            if not targetCar then
                Notify("Vehicle Error", "You do not own a vehicle or it is too far away!", 4, "Error")
                return
            end

            local seat = targetCar:FindFirstChildOfClass("VehicleSeat") or targetCar:FindFirstChild("DriveSeat") or
                targetCar:FindFirstChildWhichIsA("BasePart", true)
            local targetCF = seat and seat.CFrame or (targetCar.PrimaryPart and targetCar.PrimaryPart.CFrame)

            if not targetCF then
                Notify("Vehicle Error", "Could not find driver seat or position for " .. targetCar.Name .. "!", 4,
                    "Error")
                return
            end

            pcall(function()
                local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

                hrp.Anchored = true
                task.wait(0.05)
                hrp.CFrame = targetCF * CFrame.new(0, 2.5, 0)
                task.wait(0.05)
                hrp.Anchored = false

                if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and char:FindFirstChildOfClass("Humanoid") then
                    seat:Sit(char:FindFirstChildOfClass("Humanoid"))
                end

                if JuneEvent then
                    firesignal(JuneEvent.OnClientEvent, false)
                    if char:FindFirstChildOfClass("Humanoid") then
                        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)

            Notify("Vehicle Teleport", "Successfully teleported to " .. targetCar.Name .. "!", 3, "Success")
        end)

        cBtn(cardCarUtil, "Hop / Jump Vehicle", function()
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if seat then
                local veh = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                local root = veh and (veh.PrimaryPart or seat)
                if root then
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50,
                            root.AssemblyLinearVelocity.Z)
                    end)
                end
            end
        end)

        -- Bypass Locked Cars Card (Right Column of Cars Mods Sub-Tab)
        local cardBypassLock = cC(carR, "Bypass Locked Cars")

        local refreshVehDD
        local isRefreshing = false

        local function isCarOccupied(veh)
            local seat = veh:FindFirstChildOfClass("VehicleSeat") or veh:FindFirstChild("DriveSeat") or
                veh:FindFirstChildWhichIsA("Seat", true)
            if seat and seat:IsA("Seat") then
                return seat.Occupant ~= nil
            end
            return false
        end

        local function getOtherVehiclesList()
            local list = {}
            local vehiclesFolder = workspace:FindFirstChild("Vehicles")
            local myChar = lp.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if vehiclesFolder then
                local myCarName = (lp.Name .. "'s Vehicle"):lower()
                local myNameLower = lp.Name:lower()

                for _, veh in ipairs(vehiclesFolder:GetChildren()) do
                    if veh:IsA("Model") then
                        local vehName = veh.Name
                        local nameLower = vehName:lower()
                        if not nameLower:find(myCarName) and not nameLower:find(myNameLower) then
                            local part = veh:FindFirstChildOfClass("VehicleSeat") or veh:FindFirstChild("DriveSeat") or
                                veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart", true)
                            local dist = (myHRP and part) and (part.Position - myHRP.Position).Magnitude or 0
                            if (not myHRP) or dist <= 500 then
                                if not isCarOccupied(veh) then
                                    table.insert(list, vehName)
                                end
                            end
                        end
                    end
                end
            end
            table.sort(list)
            if #list == 0 then table.insert(list, "None") end
            return list
        end

        local boundSeats = {}
        local function bindSeat(seat)
            if seat and not boundSeats[seat] then
                boundSeats[seat] = true
                seat:GetPropertyChangedSignal("Occupant"):Connect(function()
                    if not isRefreshing then
                        isRefreshing = true
                        task.defer(function()
                            refreshVehDD()
                            isRefreshing = false
                        end)
                    end
                end)
            end
        end

        local function setupSeatListeners(veh)
            if not veh or not veh:IsA("Model") then return end
            local seat = veh:FindFirstChildOfClass("VehicleSeat") or veh:FindFirstChild("DriveSeat") or
                veh:FindFirstChildWhichIsA("Seat", true)
            if seat then
                bindSeat(seat)
            end
        end

        local otherVehList = getOtherVehiclesList()
        local selectedVehName = otherVehList[1] or "None"

        local vehDD
        vehDD = cDD(cardBypassLock, "Select Other Car", otherVehList, selectedVehName, function(v)
            selectedVehName = v
        end)

        function refreshVehDD()
            local newList = getOtherVehiclesList()
            if not table.find(newList, selectedVehName) then
                selectedVehName = newList[1] or "None"
            end
            pcall(function() vehDD.Refresh(newList) end)
        end

        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if vehiclesFolder then
            for _, veh in ipairs(vehiclesFolder:GetChildren()) do
                setupSeatListeners(veh)
            end
            vehiclesFolder.ChildAdded:Connect(function(child)
                task.wait(0.2)
                setupSeatListeners(child)
                refreshVehDD()
            end)
            vehiclesFolder.ChildRemoved:Connect(function()
                if not isRefreshing then
                    isRefreshing = true
                    task.defer(function()
                        refreshVehDD()
                        isRefreshing = false
                    end)
                end
            end)
        end

        cBtn(cardBypassLock, "Teleport & Sit in Car", function()
            if not selectedVehName or selectedVehName == "None" then
                Notify("Bypass Error", "Please select a valid vehicle first!", 3, "Error")
                return
            end

            local vFolder = workspace:FindFirstChild("Vehicles")
            local targetCar = vFolder and vFolder:FindFirstChild(selectedVehName)

            if not targetCar and vFolder then
                for _, child in ipairs(vFolder:GetChildren()) do
                    if child.Name == selectedVehName then
                        targetCar = child
                        break
                    end
                end
            end

            if not targetCar then
                Notify("Bypass Error", "Vehicle not found in workspace!", 3, "Error")
                return
            end

            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end

            local seat = targetCar:FindFirstChildOfClass("VehicleSeat") or targetCar:FindFirstChild("DriveSeat") or
                targetCar:FindFirstChildWhichIsA("Seat", true)

            if not seat then
                Notify("Bypass Error", "Could not find driver seat for " .. targetCar.Name .. "!", 3, "Error")
                return
            end

            local targetCF = seat.CFrame or (targetCar.PrimaryPart and targetCar.PrimaryPart.CFrame)
            if not targetCF then
                Notify("Bypass Error", "Could not find position for " .. targetCar.Name .. "!", 3, "Error")
                return
            end

            pcall(function()
                local JuneEvent = game:GetService("ReplicatedStorage"):FindFirstChild("JuneEvent")
                if JuneEvent then firesignal(JuneEvent.OnClientEvent, true) end

                hrp.Anchored = true
                task.wait(0.05)
                hrp.CFrame = targetCF * CFrame.new(0, 2.5, 0)
                task.wait(0.05)
                hrp.Anchored = false

                if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
                    seat:Sit(hum)
                end

                if JuneEvent then
                    firesignal(JuneEvent.OnClientEvent, false)
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)

            Notify("Bypass Locked Car", "Successfully entered " .. targetCar.Name .. "!", 3, "Success")
        end)
    end -- End Cars Mods Tab

    do  -- Settings Tab
        sT = cMT("Settings", "115052390034117", false)
        sS = cSM(sT, { "Menu", "Config" })
        scL = sS["Menu"].l
        scR = sS["Menu"].r

        bc = cC(scL, "Background Image")
        cTog(bc, "Transparent UI", cfg.tOn, function(v)
            cfg.tOn = v
            mf.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
            sb.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
            sCF()
        end, true)

        cTog(bc, "Enable Background", cfg.bOn, function(v)
            cfg.bOn = v
            if cfg.bOn and cfg.bId ~= "" then
                mbg.ImageTransparency = 1 - (cfg.bOp / 100)
            else
                mbg.ImageTransparency = 1
            end
            sCF()
        end, true)

        local bPr = cIP(bc, cfg.bId ~= "" and ("rbxassetid://" .. cfg.bId) or "")
        cTB(bc, "Roblox ID...", cfg.bId, function(txt)
            local id = txt:match("%d+")
            if id then
                cfg.bId = id
                local fullId = "rbxassetid://" .. id
                bPr.Image = fullId
                if cfg.bOn then
                    mbg.Image = fullId
                    mbg.ImageTransparency = 1 - (cfg.bOp / 100)
                end
            else
                cfg.bId = ""
                bPr.Image = ""
                mbg.Image = ""
                mbg.ImageTransparency = 1
            end
            sCF()
        end)

        cSli(bc, "UI Transparency", 0, 100, cfg.tOp or 100, function(v)
            cfg.tOp = v
            if cfg.tOn then
                mf.BackgroundTransparency = (cfg.tOp or 100) / 100
                sb.BackgroundTransparency = (cfg.tOp or 100) / 100
            end
            sCF()
        end)

        cSli(bc, "Background Opacity", 0, 100, cfg.bOp, function(v)
            cfg.bOp = v
            if cfg.bOn and cfg.bId ~= "" then
                mbg.ImageTransparency = 1 - (cfg.bOp / 100)
            end
            sCF()
        end)

        local cardNotif = cC(scL, "Notification Settings")

        cTog(cardNotif, "Enable Notifications", cfg.notifEnabled == true, function(v)
            cfg.notifEnabled = v
            sCF()
        end, true)

        cDD(cardNotif, "Notification Position", { "Top Right", "Bottom Right", "Top Left", "Bottom Left" },
            cfg.notifPos or "Bottom Right", function(v)
                cfg.notifPos = v
                updateNotifPos(v)
                sCF()
            end)

        cDD(cardNotif, "Notification Sound", { "None", "Ding", "Pop" }, cfg.notifSound or "Ding", function(v)
            cfg.notifSound = v
            playNotifSound(v)
            sCF()
        end)

        cBtn(cardNotif, "Test Notification", function()
            Notify("YIX System", "Notification system is working perfectly!", 3.5, "Info")
        end)

        local thc = cC(scR, "Theme & Fonts")
        cDD(thc, "Theme", { "Black", "Blue", "White", "Brown (Cake)" }, cfg.t, function(val)
            if thms[val] then
                cfg.t = val
                activeThm = thms[val]
                tm.m = activeThm.m
                tm.s = activeThm.s
                tm.c = activeThm.c
                tm.k = activeThm.k
                tm.t = activeThm.t
                tm.st = activeThm.st
                updT()
                sCF()
            end
        end)

        cDD(thc, "Font", { "Gotham", "SciFi", "Code", "Arcade", "Mono", "Sans", "Serif" }, cfg.f, function(val)
            if fnts[val] then
                cfg.f = val
                tm.f = fnts[val]
                updT()
                sCF()
            end
        end)

        ccP = cC(scR, "Other")

        abWindow = Instance.new("Frame")
        abWindow.Size = UDim2.new(0, 250, 0, 300)
        abWindow.Position = UDim2.new(0.5, 150, 0.5, -150)
        abWindow.BackgroundColor3 = tm.m
        abWindow.Visible = false
        abWindow.ZIndex = 50
        abWindow.Parent = sg
        table.insert(allB, { abWindow, "m" })

        local abCorner = Instance.new("UICorner")
        abCorner.CornerRadius = UDim.new(0, 6)
        abCorner.Parent = abWindow

        local abStroke = Instance.new("UIStroke")
        abStroke.Color = tm.k
        abStroke.Parent = abWindow
        table.insert(allB, { abStroke, "k" })

        local abTop = Instance.new("Frame")
        abTop.Size = UDim2.new(1, 0, 0, 30)
        abTop.BackgroundTransparency = 1
        abTop.ZIndex = 51
        abTop.Parent = abWindow

        local abTitle = Instance.new("TextLabel")
        abTitle.Size = UDim2.new(1, -40, 1, 0)
        abTitle.Position = UDim2.new(0, 20, 0, 0)
        abTitle.BackgroundTransparency = 1
        abTitle.Text = "Active Binds⌨️"
        abTitle.TextColor3 = tm.st
        abTitle.Font = tm.f
        abTitle.TextSize = 14
        abTitle.TextXAlignment = Enum.TextXAlignment.Center
        abTitle.ZIndex = 52
        abTitle.Parent = abTop
        table.insert(allT, { abTitle, "st", false })

        local abClose = Instance.new("TextButton")
        abClose.Size = UDim2.new(0, 20, 0, 20)
        abClose.Position = UDim2.new(1, -25, 0, 5)
        abClose.BackgroundTransparency = 1
        abClose.Text = "X"
        abClose.TextColor3 = tm.st
        abClose.Font = tm.f
        abClose.TextSize = 14
        abClose.ZIndex = 52
        abClose.Parent = abTop
        table.insert(allT, { abClose, "st", false })

        abClose.MouseButton1Click:Connect(function()
            abWindow.Visible = false
            if getgenv().YIX_ActiveBindsToggle and type(getgenv().YIX_ActiveBindsToggle) == "table" and getgenv().YIX_ActiveBindsToggle.Set then
                getgenv().YIX_ActiveBindsToggle.Set(false, false)
            end
        end)

        local abScroll = Instance.new("ScrollingFrame")
        abScroll.Size = UDim2.new(1, -20, 1, -40)
        abScroll.Position = UDim2.new(0, 10, 0, 35)
        abScroll.BackgroundTransparency = 1
        abScroll.ScrollBarThickness = 2
        abScroll.ScrollBarImageColor3 = tm.st
        abScroll.ZIndex = 51
        abScroll.Parent = abWindow
        table.insert(allB, { abScroll, "st" })

        local abList = Instance.new("UIListLayout")
        abList.SortOrder = Enum.SortOrder.LayoutOrder
        abList.Padding = UDim.new(0, 5)
        abList.Parent = abScroll

        MakeDraggable(abWindow)

        getgenv().YIX_RefreshBindsUI = function()
            if isMobile then
                abWindow.Visible = false
                return
            end
            for _, v in pairs(abScroll:GetChildren()) do
                if v:IsA("Frame") or v:IsA("TextLabel") then
                    v:Destroy()
                end
            end
            getgenv().YIX_ActiveBindsLabels = {}

            local binds = getgenv().YIX_Binds
            if not binds then return end

            local categorized = {}
            for k, v in pairs(binds) do
                local cat = v.category or "Unknown"
                if not categorized[cat] then categorized[cat] = {} end
                table.insert(categorized[cat], { key = k, info = v })
            end

            for cat, list in pairs(categorized) do
                local catLbl = Instance.new("TextLabel")
                catLbl.Size = UDim2.new(1, 0, 0, 20)
                catLbl.BackgroundTransparency = 1
                catLbl.Text = "- " .. cat .. " -"
                catLbl.TextColor3 = tm.a
                catLbl.Font = tm.f
                catLbl.TextSize = 12
                catLbl.ZIndex = 52
                catLbl.Parent = abScroll
                table.insert(allT, { catLbl, "a", false })

                for _, b in pairs(list) do
                    local itemFr = Instance.new("Frame")
                    itemFr.Size = UDim2.new(1, 0, 0, 25)
                    itemFr.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                    itemFr.ZIndex = 52
                    itemFr.Parent = abScroll

                    local itemCorner = Instance.new("UICorner")
                    itemCorner.CornerRadius = UDim.new(0, 4)
                    itemCorner.Parent = itemFr

                    local itemLbl = Instance.new("TextLabel")
                    itemLbl.Size = UDim2.new(1, -40, 1, 0)
                    itemLbl.Position = UDim2.new(0, 10, 0, 0)
                    itemLbl.BackgroundTransparency = 1
                    itemLbl.Text = b.info.name .. " (" .. b.key .. ")"
                    itemLbl.TextColor3 = tm.t
                    itemLbl.Font = tm.f
                    itemLbl.TextSize = 12
                    itemLbl.TextXAlignment = Enum.TextXAlignment.Left
                    itemLbl.ZIndex = 53
                    itemLbl.Parent = itemFr
                    table.insert(allT, { itemLbl, "t", false })
                    table.insert(getgenv().YIX_ActiveBindsLabels, { lbl = itemLbl, func = b.info.func })

                    local delBtn = Instance.new("TextButton")
                    delBtn.Size = UDim2.new(0, 30, 0, 15)
                    delBtn.Position = UDim2.new(1, -35, 0.5, -7.5)
                    delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    delBtn.Text = "DEL"
                    delBtn.TextColor3 = Color3.new(1, 1, 1)
                    delBtn.Font = tm.f
                    delBtn.TextSize = 10
                    delBtn.ZIndex = 53
                    delBtn.Parent = itemFr

                    local delCorner = Instance.new("UICorner")
                    delCorner.CornerRadius = UDim.new(0, 4)
                    delCorner.Parent = delBtn

                    delBtn.MouseButton1Click:Connect(function()
                        cfg[b.info.cfgKey] = ""
                        if b.info.bx then b.info.bx.Text = "" end
                        getgenv().YIX_Binds[b.key] = nil
                        sCF()
                        getgenv().YIX_RefreshBindsUI()
                    end)
                end
            end

            abScroll.CanvasSize = UDim2.new(0, 0, 0, abList.AbsoluteContentSize.Y + 10)
        end

        abList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            abScroll.CanvasSize = UDim2.new(0, 0, 0, abList.AbsoluteContentSize.Y + 10)
        end)

        if isMobile then
            cTog(ccP, "Enable Hide Button", cfg.mbHideBtnOn ~= false, function(v)
                cfg.mbHideBtnOn = v
                sCF()
                if mbHideBtn then mbHideBtn.Visible = v end
            end, true)
        else
            local abTogFunc = cTog(ccP, "Show Active Binds", false, function(v)
                abWindow.Visible = v
                if v then getgenv().YIX_RefreshBindsUI() end
            end, true)
            getgenv().YIX_ActiveBindsToggle = abTogFunc
        end

        if not isMobile then
            cTog(ccP, "Unlock Mouse", cfg.unlockMouse == true, function(v)
                cfg.unlockMouse = v
                sCF()
                updateMouseLockState()
            end, true)
        end

        cTog(ccP, "Enable Custom Colors", cfg.cCOn, function(v)
            cfg.cCOn = v
            updT()
            sCF()
        end, true)
        cCP(ccP, "Text Color", cfg.cCT, function(hsv)
            cfg.cCT = hsv
            if cfg.cCOn then updT() end
            sCF()
        end)
        cCP(ccP, "Accent Color", cfg.cCA, function(hsv)
            cfg.cCA = hsv
            if cfg.cCOn then updT() end
            sCF()
        end)
    end -- End Settings Tab

    do
        if not isMobile then
            hideBx = cBind(ccP, "Hide bin", cfg.hideBind or "RightShift", function(v)
                return assignBind(v, "hideBind", function(force)
                    if force == "GET_STATE" then return not mf.Visible end
                end, "Hide UI", "Menu")
            end)
            if cfg.hideBind and cfg.hideBind ~= "" then
                getgenv().YIX_Binds[cfg.hideBind:upper()] = {
                    func = function(force) if force == "GET_STATE" then return not mf.Visible end end,
                    name = "Hide UI",
                    category = "Menu",
                    cfgKey = "hideBind",
                    bx = hideBx
                }
            end

            panicBx = cBind(ccP, "Panic Close bin", cfg.panicBind or "RightControl", function(v)
                return assignBind(v, "panicBind", nil, "Panic Close", "Menu")
            end)
            if cfg.panicBind and cfg.panicBind ~= "" then
                getgenv().YIX_Binds[cfg.panicBind:upper()] = {
                    func = nil,
                    name = "Panic Close",
                    category = "Menu",
                    cfgKey = "panicBind",
                    bx = panicBx
                }
            end
        end
    end

    local oI = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if cfg.cCOn then
        updT()
    end
    ts:Create(scl, oI, { Scale = 1 }):Play()

    if not isMobile then
        if getgenv().YIX_KeyListener then pcall(function() getgenv().YIX_KeyListener:Disconnect() end) end
        getgenv().YIX_KeyListener = uis.InputBegan:Connect(function(input, gp)
            if not gp and input.UserInputType == Enum.UserInputType.Keyboard and not isBinding then
                -- Auto-disconnect if UI is destroyed
                if not mf or not mf:IsDescendantOf(game) then
                    if getgenv().YIX_KeyListener then
                        getgenv().YIX_KeyListener:Disconnect()
                        getgenv().YIX_KeyListener = nil
                    end
                    return
                end

                local hBind = cfg.hideBind or "RightShift"
                local pBind = cfg.panicBind or "RightControl"
                local eBind = cfg.espBind or ""

                if input.KeyCode.Name:upper() == pBind:upper() then
                    cleanupAllActiveFeatures()
                    if cg:FindFirstChild("UIX") then
                        cg.UIX:Destroy()
                    end
                elseif input.KeyCode.Name:upper() == hBind:upper() then
                    mf.Visible = not mf.Visible
                else
                    if getgenv().YIX_Binds and getgenv().YIX_Binds[input.KeyCode.Name:upper()] then
                        getgenv().YIX_Binds[input.KeyCode.Name:upper()].func()
                    end
                end
            end
        end)
    end

    rs.RenderStepped:Connect(function()
        if abWindow and abWindow.Visible and getgenv().YIX_ActiveBindsLabels then
            for _, tbl in ipairs(getgenv().YIX_ActiveBindsLabels) do
                local isActive = false
                if tbl.func then
                    pcall(function() isActive = tbl.func("GET_STATE") end)
                end
                if isActive then
                    tbl.lbl.TextColor3 = tm.a
                else
                    tbl.lbl.TextColor3 = tm.t
                end
            end
        end
    end)

    updateMouseLockState()
end)()
