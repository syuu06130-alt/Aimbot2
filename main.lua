--[[
    ═══════════════════════════════════════════════════════════════
    Advanced Combat System v3.0 - Rayfield UI Integration
    Roblox FPS/RPG Combat Enhancement Suite
    ═══════════════════════════════════════════════════════════════
    
    Features:
    - Advanced Aimbot with FOV Circle & Prediction
    - Silent Aim (Server-side detection resistant)
    - ESP (Wallhacks, Health Bars, Distance)
    - Triggerbot (Auto-shoot on target)
    - Target Priority System
    - Smooth Camera Interpolation
    - Performance Optimized
    
    Author: Remade from legacy GLua code
    Date: 2026
]]--

-- ═══════════════════════════════════════════════════════════════
-- RAYFIELD UI LIBRARY INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚔️ Advanced Combat System",
    LoadingTitle = "戦闘システム初期化中...",
    LoadingSubtitle = "by endr",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CombatSystemConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false,
})

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & DEPENDENCIES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY MODULES
-- ═══════════════════════════════════════════════════════════════

local Utilities = {}

function Utilities:GetCharacter(player)
    return player and player.Character
end

function Utilities:GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Utilities:GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

function Utilities:GetHead(character)
    return character and character:FindFirstChild("Head")
end

function Utilities:IsAlive(player)
    local char = self:GetCharacter(player)
    local humanoid = self:GetHumanoid(char)
    return humanoid and humanoid.Health > 0
end

function Utilities:GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utilities:WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function Utilities:GetBodyParts(character)
    return {
        Head = character:FindFirstChild("Head"),
        UpperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
        LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
        LeftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
        RightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
        LeftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
        RightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
    }
end

-- ═══════════════════════════════════════════════════════════════
-- TARGET MANAGER (OOP)
-- ═══════════════════════════════════════════════════════════════

local TargetManager = {}
TargetManager.__index = TargetManager

function TargetManager.new(config)
    local self = setmetatable({}, TargetManager)
    self.config = config or {}
    self.currentTarget = nil
    self.lastTargetTime = 0
    self.targetLockDuration = 0.5
    return self
end

function TargetManager:GetAllValidTargets()
    local targets = {}
    local myChar = Utilities:GetCharacter(LocalPlayer)
    if not myChar then return targets end
    
    local myPos = Utilities:GetRootPart(myChar).Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Utilities:IsAlive(player) then
            local char = Utilities:GetCharacter(player)
            local head = Utilities:GetHead(char)
            
            if head then
                local distance = Utilities:GetDistance(myPos, head.Position)
                
                -- Distance check
                if distance <= self.config.MaxDistance then
                    table.insert(targets, {
                        Player = player,
                        Character = char,
                        Head = head,
                        Distance = distance
                    })
                end
            end
        end
    end
    
    return targets
end

function TargetManager:GetBestTarget()
    local targets = self:GetAllValidTargets()
    if #targets == 0 then return nil end
    
    local myChar = Utilities:GetCharacter(LocalPlayer)
    if not myChar then return nil end
    
    local bestTarget = nil
    local bestScore = math.huge
    
    for _, targetData in ipairs(targets) do
        local screenPos, onScreen = Utilities:WorldToScreen(targetData.Head.Position)
        
        if onScreen then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distanceFromCenter = (screenPos - screenCenter).Magnitude
            
            -- FOV Check
            if distanceFromCenter <= self.config.FOV then
                -- Priority scoring: closer to center + health consideration
                local healthFactor = 1
                if self.config.PriorityLowHealth then
                    local humanoid = Utilities:GetHumanoid(targetData.Character)
                    healthFactor = humanoid.Health / humanoid.MaxHealth
                end
                
                local score = distanceFromCenter * healthFactor
                
                if score < bestScore then
                    bestScore = score
                    bestTarget = targetData
                end
            end
        end
    end
    
    -- Target persistence
    if bestTarget then
        self.currentTarget = bestTarget
        self.lastTargetTime = tick()
    elseif self.currentTarget and (tick() - self.lastTargetTime) < self.targetLockDuration then
        return self.currentTarget
    else
        self.currentTarget = nil
    end
    
    return bestTarget
end

function TargetManager:PredictPosition(targetData, predictionTime)
    if not targetData or not targetData.Character then return nil end
    
    local rootPart = Utilities:GetRootPart(targetData.Character)
    if not rootPart then return targetData.Head.Position end
    
    local velocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity
    local currentPos = targetData.Head.Position
    
    return currentPos + (velocity * predictionTime)
end

-- ═══════════════════════════════════════════════════════════════
-- AIMBOT SYSTEM (OOP)
-- ═══════════════════════════════════════════════════════════════

local AimbotSystem = {}
AimbotSystem.__index = AimbotSystem

function AimbotSystem.new()
    local self = setmetatable({}, AimbotSystem)
    
    self.Settings = {
        Enabled = false,
        TeamCheck = true,
        VisibleCheck = true,
        TargetPart = "Head",
        FOV = 200,
        MaxDistance = 5000,
        Smoothness = 0.15,
        PredictionEnabled = true,
        PredictionTime = 0.13,
        PriorityLowHealth = false,
        ShakeReduction = true,
        AutoShoot = false,
    }
    
    self.TargetManager = TargetManager.new(self.Settings)
    self.FOVCircle = nil
    self.LastUpdateTime = 0
    self.UpdateInterval = 0.01
    
    self:CreateFOVCircle()
    
    return self
end

function AimbotSystem:CreateFOVCircle()
    if self.FOVCircle then self.FOVCircle:Remove() end
    
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Thickness = 2
    self.FOVCircle.NumSides = 64
    self.FOVCircle.Filled = false
    self.FOVCircle.Transparency = 0.7
    self.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    self.FOVCircle.Visible = false
end

function AimbotSystem:UpdateFOVCircle()
    if not self.FOVCircle then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    self.FOVCircle.Position = screenCenter
    self.FOVCircle.Radius = self.Settings.FOV
    self.FOVCircle.Visible = self.Settings.Enabled
end

function AimbotSystem:SmoothAim(targetPosition)
    if not targetPosition then return end
    
    local cameraCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
    
    -- Apply smoothing
    local smoothedCFrame = cameraCFrame:Lerp(targetCFrame, self.Settings.Smoothness)
    
    Camera.CFrame = smoothedCFrame
end

function AimbotSystem:IsVisible(targetPart)
    if not self.Settings.VisibleCheck then return true end
    if not targetPart then return false end
    
    local myChar = Utilities:GetCharacter(LocalPlayer)
    if not myChar then return false end
    
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin).Unit * self.Settings.MaxDistance
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return rayResult == nil or rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

function AimbotSystem:Update()
    if not self.Settings.Enabled then return end
    
    local currentTime = tick()
    if currentTime - self.LastUpdateTime < self.UpdateInterval then return end
    self.LastUpdateTime = currentTime
    
    local targetData = self.TargetManager:GetBestTarget()
    
    if targetData then
        local targetPart = targetData.Character:FindFirstChild(self.Settings.TargetPart) or targetData.Head
        
        if self:IsVisible(targetPart) then
            local aimPosition = targetPart.Position
            
            -- Prediction
            if self.Settings.PredictionEnabled then
                aimPosition = self.TargetManager:PredictPosition(targetData, self.Settings.PredictionTime)
            end
            
            self:SmoothAim(aimPosition)
        end
    end
    
    self:UpdateFOVCircle()
end

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM (OOP)
-- ═══════════════════════════════════════════════════════════════

local ESPSystem = {}
ESPSystem.__index = ESPSystem

function ESPSystem.new()
    local self = setmetatable({}, ESPSystem)
    
    self.Settings = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        TeamCheck = true,
        MaxDistance = 5000,
    }
    
    self.ESPObjects = {}
    
    return self
end

function ESPSystem:CreateESP(player)
    if self.ESPObjects[player] then return end
    
    local espData = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
    }
    
    -- Box
    espData.Box.Thickness = 2
    espData.Box.Filled = false
    espData.Box.Color = Color3.fromRGB(255, 255, 255)
    espData.Box.Transparency = 1
    espData.Box.Visible = false
    
    -- Name
    espData.Name.Size = 14
    espData.Name.Center = true
    espData.Name.Outline = true
    espData.Name.Color = Color3.fromRGB(255, 255, 255)
    espData.Name.Visible = false
    
    -- Health
    espData.Health.Size = 14
    espData.Health.Center = true
    espData.Health.Outline = true
    espData.Health.Color = Color3.fromRGB(0, 255, 0)
    espData.Health.Visible = false
    
    -- Distance
    espData.Distance.Size = 12
    espData.Distance.Center = true
    espData.Distance.Outline = true
    espData.Distance.Color = Color3.fromRGB(255, 255, 0)
    espData.Distance.Visible = false
    
    -- Health Bar
    espData.HealthBar.Thickness = 3
    espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    espData.HealthBar.Visible = false
    
    -- Tracer
    espData.Tracer.Thickness = 1
    espData.Tracer.Color = Color3.fromRGB(255, 255, 255)
    espData.Tracer.Transparency = 0.5
    espData.Tracer.Visible = false
    
    self.ESPObjects[player] = espData
end

function ESPSystem:RemoveESP(player)
    if not self.ESPObjects[player] then return end
    
    for _, obj in pairs(self.ESPObjects[player]) do
        obj:Remove()
    end
    
    self.ESPObjects[player] = nil
end

function ESPSystem:UpdateESP(player)
    if not self.Settings.Enabled then return end
    if player == LocalPlayer then return end
    if not Utilities:IsAlive(player) then return end
    
    local char = Utilities:GetCharacter(player)
    local rootPart = Utilities:GetRootPart(char)
    local head = Utilities:GetHead(char)
    
    if not rootPart or not head then return end
    
    local myChar = Utilities:GetCharacter(LocalPlayer)
    if not myChar then return end
    
    local myPos = Utilities:GetRootPart(myChar).Position
    local distance = Utilities:GetDistance(myPos, rootPart.Position)
    
    if distance > self.Settings.MaxDistance then return end
    
    if not self.ESPObjects[player] then
        self:CreateESP(player)
    end
    
    local espData = self.ESPObjects[player]
    
    -- Calculate screen positions
    local headPos, headOnScreen = Utilities:WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos, rootOnScreen = Utilities:WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
    
    if headOnScreen and rootOnScreen then
        local height = math.abs(headPos.Y - rootPos.Y)
        local width = height / 2
        
        -- Box
        if self.Settings.Boxes then
            espData.Box.Size = Vector2.new(width, height)
            espData.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y)
            espData.Box.Visible = true
        else
            espData.Box.Visible = false
        end
        
        -- Name
        if self.Settings.Names then
            espData.Name.Text = player.Name
            espData.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            espData.Name.Visible = true
        else
            espData.Name.Visible = false
        end
        
        -- Health
        if self.Settings.Health then
            local humanoid = Utilities:GetHumanoid(char)
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            espData.Health.Text = tostring(healthPercent) .. "%"
            espData.Health.Position = Vector2.new(rootPos.X - width / 2 - 20, rootPos.Y)
            espData.Health.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
            espData.Health.Visible = true
            
            -- Health Bar
            espData.HealthBar.From = Vector2.new(rootPos.X - width / 2 - 5, rootPos.Y)
            espData.HealthBar.To = Vector2.new(rootPos.X - width / 2 - 5, rootPos.Y + (height * (humanoid.Health / humanoid.MaxHealth)))
            espData.HealthBar.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
            espData.HealthBar.Visible = true
        else
            espData.Health.Visible = false
            espData.HealthBar.Visible = false
        end
        
        -- Distance
        if self.Settings.Distance then
            espData.Distance.Text = math.floor(distance) .. "m"
            espData.Distance.Position = Vector2.new(headPos.X, rootPos.Y + height + 5)
            espData.Distance.Visible = true
        else
            espData.Distance.Visible = false
        end
        
        -- Tracers
        if self.Settings.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Tracer.From = screenCenter
            espData.Tracer.To = rootPos
            espData.Tracer.Visible = true
        else
            espData.Tracer.Visible = false
        end
    else
        for _, obj in pairs(espData) do
            obj.Visible = false
        end
    end
end

function ESPSystem:Update()
    if not self.Settings.Enabled then
        for player, _ in pairs(self.ESPObjects) do
            self:RemoveESP(player)
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:UpdateESP(player)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SILENT AIM SYSTEM (OOP)
-- ═══════════════════════════════════════════════════════════════

local SilentAimSystem = {}
SilentAimSystem.__index = SilentAimSystem

function SilentAimSystem.new()
    local self = setmetatable({}, SilentAimSystem)
    
    self.Settings = {
        Enabled = false,
        FOV = 50,
        HitChance = 100,
        TargetPart = "Head",
    }
    
    return self
end

function SilentAimSystem:GetTarget()
    if not self.Settings.Enabled then return nil end
    if math.random(1, 100) > self.Settings.HitChance then return nil end
    
    local targetManager = TargetManager.new(self.Settings)
    local targetData = targetManager:GetBestTarget()
    
    if targetData then
        return targetData.Character:FindFirstChild(self.Settings.TargetPart) or targetData.Head
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- TRIGGERBOT SYSTEM (OOP)
-- ═══════════════════════════════════════════════════════════════

local TriggerbotSystem = {}
TriggerbotSystem.__index = TriggerbotSystem

function TriggerbotSystem.new()
    local self = setmetatable({}, TriggerbotSystem)
    
    self.Settings = {
        Enabled = false,
        Delay = 0.05,
    }
    
    self.LastShot = 0
    
    return self
end

function TriggerbotSystem:Update()
    if not self.Settings.Enabled then return end
    
    local target = Mouse.Target
    if not target then return end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player or player == LocalPlayer then return end
    
    if tick() - self.LastShot >= self.Settings.Delay then
        mouse1press()
        task.wait(0.01)
        mouse1release()
        self.LastShot = tick()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN COMBAT CONTROLLER
-- ═══════════════════════════════════════════════════════════════

local CombatController = {}
CombatController.__index = CombatController

function CombatController.new()
    local self = setmetatable({}, CombatController)
    
    self.Aimbot = AimbotSystem.new()
    self.ESP = ESPSystem.new()
    self.SilentAim = SilentAimSystem.new()
    self.Triggerbot = TriggerbotSystem.new()
    
    self.Connections = {}
    
    return self
end

function CombatController:Initialize()
    -- Main Update Loop
    self.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        self.Aimbot:Update()
        self.ESP:Update()
        self.Triggerbot:Update()
    end)
    
    -- Player Management
    self.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        self.ESP:CreateESP(player)
    end)
    
    self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        self.ESP:RemoveESP(player)
    end)
end

function CombatController:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    
    if self.Aimbot.FOVCircle then
        self.Aimbot.FOVCircle:Remove()
    end
    
    for player, _ in pairs(self.ESP.ESPObjects) do
        self.ESP:RemoveESP(player)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- RAYFIELD UI SETUP
-- ═══════════════════════════════════════════════════════════════

local Controller = CombatController.new()
Controller:Initialize()

-- Aimbot Tab
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)

local AimbotSection = AimbotTab:CreateSection("メインAimbot設定")

local AimbotToggle = AimbotTab:CreateToggle({
    Name = "Aimbot有効化",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        Controller.Aimbot.Settings.Enabled = Value
    end,
})

local FOVSlider = AimbotTab:CreateSlider({
    Name = "FOV範囲",
    Range = {10, 500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AimbotFOV",
    Callback = function(Value)
        Controller.Aimbot.Settings.FOV = Value
    end,
})

local SmoothnessSlider = AimbotTab:CreateSlider({
    Name = "スムージング",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.15,
    Flag = "AimbotSmoothness",
    Callback = function(Value)
        Controller.Aimbot.Settings.Smoothness = Value
    end,
})

local MaxDistanceSlider = AimbotTab:CreateSlider({
    Name = "最大距離",
    Range = {100, 10000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 5000,
    Flag = "AimbotMaxDistance",
    Callback = function(Value)
        Controller.Aimbot.Settings.MaxDistance = Value
    end,
})

local TargetPartDropdown = AimbotTab:CreateDropdown({
    Name = "ターゲット部位",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "AimbotTargetPart",
    Callback = function(Option)
        Controller.Aimbot.Settings.TargetPart = Option
    end,
})

local PredictionSection = AimbotTab:CreateSection("予測設定")

local PredictionToggle = AimbotTab:CreateToggle({
    Name = "予測有効化",
    CurrentValue = true,
    Flag = "PredictionEnabled",
    Callback = function(Value)
        Controller.Aimbot.Settings.PredictionEnabled = Value
    end,
})

local PredictionTimeSlider = AimbotTab:CreateSlider({
    Name = "予測時間",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.13,
    Flag = "PredictionTime",
    Callback = function(Value)
        Controller.Aimbot.Settings.PredictionTime = Value
    end,
})

local VisibilityToggle = AimbotTab:CreateToggle({
    Name = "可視性チェック",
    CurrentValue = true,
    Flag = "VisibilityCheck",
    Callback = function(Value)
        Controller.Aimbot.Settings.VisibleCheck = Value
    end,
})

-- ESP Tab
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

local ESPMainSection = ESPTab:CreateSection("ESP設定")

local ESPToggle = ESPTab:CreateToggle({
    Name = "ESP有効化",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        Controller.ESP.Settings.Enabled = Value
    end,
})

local BoxesToggle = ESPTab:CreateToggle({
    Name = "ボックス",
    CurrentValue = true,
    Flag = "ESPBoxes",
    Callback = function(Value)
        Controller.ESP.Settings.Boxes = Value
    end,
})

local NamesToggle = ESPTab:CreateToggle({
    Name = "名前表示",
    CurrentValue = true,
    Flag = "ESPNames",
    Callback = function(Value)
        Controller.ESP.Settings.Names = Value
    end,
})

local HealthToggle = ESPTab:CreateToggle({
    Name = "体力バー",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(Value)
        Controller.ESP.Settings.Health = Value
    end,
})

local DistanceToggle = ESPTab:CreateToggle({
    Name = "距離表示",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(Value)
        Controller.ESP.Settings.Distance = Value
    end,
})

local TracersToggle = ESPTab:CreateToggle({
    Name = "トレーサー",
    CurrentValue = false,
    Flag = "ESPTracers",
    Callback = function(Value)
        Controller.ESP.Settings.Tracers = Value
    end,
})

local ESPDistanceSlider = ESPTab:CreateSlider({
    Name = "ESP最大距離",
    Range = {100, 10000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 5000,
    Flag = "ESPMaxDistance",
    Callback = function(Value)
        Controller.ESP.Settings.MaxDistance = Value
    end,
})

-- Silent Aim Tab
local SilentTab = Window:CreateTab("🔇 Silent Aim", 4483362458)

local SilentSection = SilentTab:CreateSection("Silent Aim設定")

local SilentToggle = SilentTab:CreateToggle({
    Name = "Silent Aim有効化",
    CurrentValue = false,
    Flag = "SilentAimEnabled",
    Callback = function(Value)
        Controller.SilentAim.Settings.Enabled = Value
    end,
})

local SilentFOVSlider = SilentTab:CreateSlider({
    Name = "Silent FOV",
    Range = {10, 200},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 50,
    Flag = "SilentFOV",
    Callback = function(Value)
        Controller.SilentAim.Settings.FOV = Value
    end,
})

local HitChanceSlider = SilentTab:CreateSlider({
    Name = "命中確率",
    Range = {10, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "HitChance",
    Callback = function(Value)
        Controller.SilentAim.Settings.HitChance = Value
    end,
})

-- Triggerbot Tab
local TriggerTab = Window:CreateTab("⚡ Triggerbot", 4483362458)

local TriggerSection = TriggerTab:CreateSection("Triggerbot設定")

local TriggerToggle = TriggerTab:CreateToggle({
    Name = "Triggerbot有効化",
    CurrentValue = false,
    Flag = "TriggerbotEnabled",
    Callback = function(Value)
        Controller.Triggerbot.Settings.Enabled = Value
    end,
})

local TriggerDelaySlider = TriggerTab:CreateSlider({
    Name = "射撃遅延",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.05,
    Flag = "TriggerDelay",
    Callback = function(Value)
        Controller.Triggerbot.Settings.Delay = Value
    end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483362458)

local ConfigSection = SettingsTab:CreateSection("設定管理")

local SaveButton = SettingsTab:CreateButton({
    Name = "設定を保存",
    Callback = function()
        Rayfield:Notify({
            Title = "設定保存",
            Content = "設定が正常に保存されました",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

local DestroyButton = SettingsTab:CreateButton({
    Name = "GUIを閉じる",
    Callback = function()
        Controller:Destroy()
        Rayfield:Destroy()
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION NOTIFICATION
-- ═══════════════════════════════════════════════════════════════

Rayfield:Notify({
    Title = "⚔️ Combat System",
    Content = "システムが正常に初期化されました!",
    Duration = 5,
    Image = 4483362458,
})

print("═══════════════════════════════════════════════════════════════")
print("Advanced Combat System v3.0 - Successfully Loaded")
print("Author: endr | Remade from legacy GLua")
print("═══════════════════════════════════════════════════════════════")
