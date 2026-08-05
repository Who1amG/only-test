-- dont touch or edit this script is a backup of my ui
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

    if cg:FindFirstChild("4k4z4") then
        cg["4k4z4"]:Destroy()
    end

    local fN = "4k4z4"
    local fC = "4k4z4/Config.json"
    local fAssets = "4k4z4/assets"
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
        unlockMouse = false
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
    sg.Name = "4k4z4"
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

        -- Smooth Entrance animation
        ts:Create(notifCard, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            GroupTransparency = 0
        }):Play()

        -- Progress bar countdown animation
        ts:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

        task.spawn(function()
            task.wait(duration)
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

    local mf = Instance.new("Frame")
    mf.Size = UDim2.new(0, 780, 0, 480)
    mf.Position = UDim2.new(0.5, -390, 0.5, -240)
    mf.BackgroundColor3 = tm.m
    mf.BackgroundTransparency = cfg.tOn and ((cfg.tOp or 100) / 100) or 0
    mf.BorderSizePixel = 0
    mf.Parent = sg

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
            rsStart = uis:GetMouseLocation()
            stSz = mf.AbsoluteSize
        end
    end)
    rh.MouseEnter:Connect(function() ts:Create(rh, TweenInfo.new(0.2), { ImageColor3 = tm.t }):Play() end)
    rh.MouseLeave:Connect(function() ts:Create(rh, TweenInfo.new(0.2), { ImageColor3 = tm.st }):Play() end)

    local isM = false
    local svS = mf.Size
    local svP = mf.Position

    -- ══════════════════ DRAG SYSTEM ══════════════════
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
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
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

        bx.MouseButton2Click:Connect(function()
            if cbk then
                local res = cbk("")
                bx.Text = type(res) == "string" and res or ""
            else
                bx.Text = ""
            end
        end)

        local connection
        bx.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            bx.Text = "..."
            if connection then connection:Disconnect() end
            connection = uis.InputBegan:Connect(function(input, gp)
                local k = nil
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    k = input.KeyCode.Name
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    k = ""
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    k = "MB3"
                end

                if k ~= nil then
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

    local openDropdownCloseFunc = nil

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

        local currentSel = dSel or (op and op[1]) or ""

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -40, 1, 0)
        tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = t .. ": " .. tostring(currentSel)
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

        local function closeDropdown()
            if not isO then return end
            isO = false
            ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(1, 0, 0, 0) }):Play()
            task.delay(0.2, function()
                if not isO then
                    oc.Visible = false
                    cr.ZIndex = 15
                    hd.ZIndex = 16
                    tl.ZIndex = 17
                    ic.ZIndex = 17
                    oc.ZIndex = 20
                end
            end)
            ic.Text = "+"
            if openDropdownCloseFunc == closeDropdown then
                openDropdownCloseFunc = nil
            end
        end

        local function toggleDropdown()
            if isO then
                closeDropdown()
            else
                if openDropdownCloseFunc then
                    openDropdownCloseFunc()
                end
                isO = true
                openDropdownCloseFunc = closeDropdown
                cr.ZIndex = 100
                hd.ZIndex = 101
                tl.ZIndex = 102
                ic.ZIndex = 102
                oc.ZIndex = 105
                oc.Visible = true
                local targetH = math.min(#op * 28, 140)
                ts:Create(oc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, targetH) }):Play()
                ic.Text = "-"
            end
        end

        hd.MouseButton1Click:Connect(toggleDropdown)

        local function populateOptions(list)
            for _, child in ipairs(oc:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, o in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, 0, 0, 28)
                ob.BackgroundTransparency = 1
                ob.Text = "  " .. tostring(o)
                ob.TextColor3 = tm.t
                ob.Font = tm.f
                ob.TextSize = 12
                ob.TextXAlignment = Enum.TextXAlignment.Left
                ob.Active = true
                ob.ZIndex = 106
                ob.Parent = oc
                table.insert(allT, { ob, "t", false })

                ob.MouseEnter:Connect(function()
                    ob.TextColor3 = getAccentColor()
                end)
                ob.MouseLeave:Connect(function()
                    ob.TextColor3 = tm.t
                end)

                ob.MouseButton1Click:Connect(function()
                    currentSel = o
                    tl.Text = t .. ": " .. tostring(o)
                    closeDropdown()
                    if cbk then cbk(o) end
                end)
            end
        end

        populateOptions(op)

        local function Set(nVal, fireCbk)
            currentSel = nVal
            tl.Text = t .. ": " .. tostring(nVal)
            if fireCbk ~= false and cbk then cbk(nVal) end
        end

        local function Get()
            return currentSel
        end

        local function Refresh(nOp, nSel)
            op = nOp or {}
            if nSel then
                currentSel = nSel
                tl.Text = t .. ": " .. tostring(nSel)
            end
            populateOptions(op)
            if isO then
                local targetH = math.min(#op * 28, 140)
                oc.Size = UDim2.new(1, 0, 0, targetH)
            end
        end

        return { Refresh = Refresh, Set = Set, Get = Get }
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
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 22)
        fr.BackgroundTransparency = 1
        fr.ZIndex = 10
        fr.Parent = pC

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -120, 1, 0)
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

        bx.MouseButton2Click:Connect(function()
            if bindCbk then
                local res = bindCbk("")
                bx.Text = type(res) == "string" and res or ""
            else
                bx.Text = ""
            end
        end)

        local connection
        bx.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            bx.Text = "..."
            if connection then connection:Disconnect() end
            connection = uis.InputBegan:Connect(function(input, gp)
                local k = nil
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    k = input.KeyCode.Name
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    k = ""
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    k = "MB3"
                end

                if k ~= nil then
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
        local raw = tostring(newBind or ""):upper()
        if raw == "" or raw == "NONE" or raw == "CLEAR" then
            if cfg[cfgKey] and cfg[cfgKey] ~= "" then
                getgenv().YIX_Binds[cfg[cfgKey]:upper()] = nil
            end
            cfg[cfgKey] = ""
            if bx then bx.Text = "" end
            if getgenv().YIX_RefreshBindsUI then getgenv().YIX_RefreshBindsUI() end
            sCF()
            return ""
        end

        local k = raw
        local hBind = (cfg.hideBind or ""):upper()
        local pBind = (cfg.panicBind or ""):upper()

        if (k == hBind and cfgKey ~= "hideBind") or (k == pBind and cfgKey ~= "panicBind") or (getgenv().YIX_Binds[k] and getgenv().YIX_Binds[k].cfgKey ~= cfgKey) then
            pcall(function()
                if getgenv().YIX_Notify then
                    getgenv().YIX_Notify("Keybind Warning", "Key '" .. k .. "' is already bound!", 2.5, "Warning")
                end
            end)
            return cfg[cfgKey] or ""
        end

        if cfg[cfgKey] and cfg[cfgKey] ~= "" then
            getgenv().YIX_Binds[cfg[cfgKey]:upper()] = nil
        end
        cfg[cfgKey] = newBind
        getgenv().YIX_Binds[k] = { func = togFunc, name = name, category = category, cfgKey = cfgKey, bx = bx }
        if bx then bx.Text = newBind end
        if getgenv().YIX_RefreshBindsUI then getgenv().YIX_RefreshBindsUI() end
        sCF()
        return newBind
    end

    -- Main Tab
    do
        local guiService = game:GetService("GuiService")
        local exeInfo = ""
        if identifyexecutor then
            pcall(function() exeInfo = tostring(identifyexecutor()):lower() end)
        elseif getexecutorname then
            pcall(function() exeInfo = tostring(getexecutorname()):lower() end)
        end
        local isSpecialExe = exeInfo:find("velocity") ~= nil or exeInfo:find("real") ~= nil or
            exeInfo:find("xeno") ~= nil

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

        -- UI Fallback FOV Circle
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
            mbLockBtn.Visible = Config.MobileLockEnabled or Config.CamLockEnabled
        end

        local mT = cMT("Main", "76167307342345", true)
        local mS = cSM(mT, { "Silent Aim", "Aimbot", "Gun Mods" })

        -- Silent Aim Sub-Tab (UI only)
        do
            local saL = mS["Silent Aim"].l
            local saR = mS["Silent Aim"].r

            local cSA1 = cC(saL, "Silent Aim")
            local silentAimTogFunc, silentAimBx
            silentAimTogFunc, silentAimBx = cTogBind(cSA1, "Enable Silent Aim", false, cfg.silentAimBind or "",
                function(v)
                    Notify("Silent Aim", "Silent Aim " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
                end,
                function(v)
                    return assignBind(v, "silentAimBind", silentAimTogFunc, "Enable Silent Aim", "Silent Aim", silentAimBx)
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
                Notify("Silent Aim", "Show FOV " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Wall Check", true, function(v)
                Notify("Silent Aim", "Wall Check " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Friend Check", true, function(v)
                Notify("Silent Aim", "Friend Check " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Require Tool Equipped", false, function(v)
                Notify("Silent Aim", "Require Tool " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(cSA1, "Enable FOV Fix", false, function(v)
                Notify("Silent Aim", "FOV Fix " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(cSA1, "FOV Size", 10, 500, 100, function(v) end)

            local cSA2 = cC(saR, "Target Settings")
            cDD(cSA2, "Target Part", { "Head", "HumanoidRootPart", "Torso", "Random" }, "Head", function(v) end)

            local cWB = cC(saR, "Wallbang Settings")
            cTog(cWB, "Enable Wallbang", false, function(v)
                Notify("Wallbang", "Wallbang " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(cWB, "Max Penetrations", 1, 10, 3, function(v) end)
        end

        -- Aimbot Sub-Tab (WITH WORKING BACKEND CODE)
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

        -- FOV circle (Drawing API)
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

        local function hasLineOfSight(fromPos, targetPos)
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
            if not Config.CamLockEnabled then return nil end

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
                local isExcludedAimbot = getgenv().YIX_ExcludeAimbot and getgenv().YIX_ExcludeAimbot[plr.Name]
                if plr ~= lp and not isFriend(plr) and not isExcludedAimbot then
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

        local hasGunEquipped = false
        local function checkEquipped(char)
            if not char then return false end
            if not Config.RequireTool then return true end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    return true
                end
            end
            return false
        end

        rs.RenderStepped:Connect(function()
            local showCircle = Config.CamLockEnabled and Config.ShowFOV

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

        -- Gun Mods Sub-Tab (UI only)
        do
            local gmL = mS["Gun Mods"].l
            local gm1 = cC(gmL, "Gun Mods")
            cTog(gm1, "No Recoil", false, function(v)
                Notify("Gun Mods", "No Recoil " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "No Spread", false, function(v)
                Notify("Gun Mods", "No Spread " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "No Jam", false, function(v)
                Notify("Gun Mods", "No Jam " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cTog(gm1, "Automatic Fire", false, function(v)
                Notify("Gun Mods", "Automatic Fire " .. (v and "Enabled" or "Disabled"), 2, v and "Success" or "Error")
            end)
            cSli(gm1, "Fire Speed Multiplier", 1, 20, 1, function(v) end)
        end
    end

    do -- Visuals Tab
        getgenv().YIX_ExcludeSilent = getgenv().YIX_ExcludeSilent or {}
        getgenv().YIX_ExcludeAimbot = getgenv().YIX_ExcludeAimbot or {}
        getgenv().YIX_ExcludeVisual = getgenv().YIX_ExcludeVisual or {}
        getgenv().YIX_PriorityPlayer = getgenv().YIX_PriorityPlayer or {}

        local vT = cMT("Visuals", "96184323261594", false)
        local vS = cSM(vT, { "ESP", "World", "Config" })
        local vcL = vS["ESP"].l
        local vc1 = cC(vcL, "Visual Options")

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
                name = "ESP Enable",
                category = "Visual",
                cfgKey = "espBind",
                bx = espBx
            }
        end
        getgenv().YIX_EspTogFunc = espTogFunc

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
                Rt = origSky.SkyboxRt,
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
    do
        local sT = cMT("Settings", "115052390034117", false)
        local sS = cSM(sT, { "Menu", "Config" })
        local scL = sS["Menu"].l
        local scR = sS["Menu"].r

        local bc = cC(scL, "Background Image")
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
            Notify("4k4z4 System", "Notification system is working perfectly!", 3.5, "Info")
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

        local ccP = cC(scR, "Other")

        local abWindow = Instance.new("Frame")
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

        local abTogFunc = cTog(ccP, "Show Active Binds", false, function(v)
            abWindow.Visible = v
            if v then getgenv().YIX_RefreshBindsUI() end
        end, true)
        getgenv().YIX_ActiveBindsToggle = abTogFunc
        local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

        if not isMobile then
            cTog(ccP, "Unlock Mouse", cfg.unlockMouse == true, function(v)
                cfg.unlockMouse = v
                sCF()
                updateMouseLockState()
            end, true)

            hideBx = cBind(ccP, "Hide UI", cfg.hideBind or "RightShift", function(v)
                return assignBind(v, "hideBind", function(force)
                    if force == "GET_STATE" then return not mf.Visible end
                end, "Hide UI", "Menu", hideBx)
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

            panicBx = cBind(ccP, "Panic Close UI", cfg.panicBind or "RightControl", function(v)
                return assignBind(v, "panicBind", nil, "Panic Close UI", "Menu", panicBx)
            end)
            if cfg.panicBind and cfg.panicBind ~= "" then
                getgenv().YIX_Binds[cfg.panicBind:upper()] = {
                    func = nil,
                    name = "Panic Close UI",
                    category = "Menu",
                    cfgKey = "panicBind",
                    bx = panicBx
                }
            end
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

        -- Config Sub-Tab Controls
        local scCL = sS["Config"].l
        local scCR = sS["Config"].r

        local cardCfg = cC(scCL, "Config Manager")
        cBtn(cardCfg, "Save Current Config", function()
            sCF()
            Notify("Config System", "Configuration saved successfully!", 2.5, "Success")
        end)

        cBtn(cardCfg, "Reset to Default Config", function()
            if isfile and isfile(fC) then
                pcall(function() delfile(fC) end)
            end
            Notify("Config System", "Config reset! Re-execute script to apply defaults.", 3.5, "Warning")
        end)
    end -- End Settings Tab

    local oI = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if cfg.cCOn then
        updT()
    end
    ts:Create(scl, oI, { Scale = 1 }):Play()

    local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
    if not isMobile then
        if getgenv().YIX_KeyListener then pcall(function() getgenv().YIX_KeyListener:Disconnect() end) end
        getgenv().YIX_KeyListener = uis.InputBegan:Connect(function(input, gp)
            if not gp and input.UserInputType == Enum.UserInputType.Keyboard and not isBinding and not uis:GetFocusedTextBox() then
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
                    if cg:FindFirstChild("4k4z4") then
                        cg["4k4z4"]:Destroy()
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
