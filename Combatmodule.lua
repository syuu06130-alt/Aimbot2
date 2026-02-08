--[[
    ═══════════════════════════════════════════════════════════════
    CombatSystem ModuleScript Version
    For ServerScriptService or ReplicatedStorage
    ═══════════════════════════════════════════════════════════════
]]--

local CombatModule = {}
CombatModule.__index = CombatModule

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

CombatModule.DefaultConfig = {
    Aimbot = {
        Enabled = false,
        FOV = 200,
        Smoothness = 0.15,
        MaxDistance = 5000,
        TargetPart = "Head",
        PredictionEnabled = true,
        PredictionTime = 0.13,
        VisibleCheck = true,
        TeamCheck = true,
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        MaxDistance = 5000,
        TeamCheck = true,
    },
    SilentAim = {
        Enabled = false,
        FOV = 50,
        HitChance = 100,
        TargetPart = "Head",
    },
    Triggerbot = {
        Enabled = false,
        Delay = 0.05,
    },
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITIES CLASS
-- ═══════════════════════════════════════════════════════════════

local Utilities = {}
Utilities.__index = Utilities

function Utilities.new()
    local self = setmetatable({}, Utilities)
    
    self.Players = game:GetService("Players")
    self.Workspace = game:GetService("Workspace")
    self.Camera = self.Workspace.CurrentCamera
    
    return self
end

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
    local screenPos, onScreen = self.Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function Utilities:IsTeamMate(player1, player2)
    if not player1.Team or not player2.Team then return false end
    return player1.Team == player2.Team
end

function Utilities:PerformRaycast(origin, direction, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    return self.Workspace:Raycast(origin, direction, raycastParams)
end

CombatModule.Utilities = Utilities

-- ═══════════════════════════════════════════════════════════════
-- TARGET MANAGER CLASS
-- ═══════════════════════════════════════════════════════════════

local TargetManager = {}
TargetManager.__index = TargetManager

function TargetManager.new(config, utilities)
    local self = setmetatable({}, TargetManager)
    
    self.Config = config or {}
    self.Utils = utilities
    self.CurrentTarget = nil
    self.LastTargetTime = 0
    self.TargetLockDuration = 0.5
    
    return self
end

function TargetManager:GetAllValidTargets(localPlayer)
    local targets = {}
    local myChar = self.Utils:GetCharacter(localPlayer)
    if not myChar then return targets end
    
    local myPos = self.Utils:GetRootPart(myChar).Position
    
    for _, player in ipairs(self.Utils.Players:GetPlayers()) do
        if player ~= localPlayer and self.Utils:IsAlive(player) then
            -- Team check
            if self.Config.TeamCheck and self.Utils:IsTeamMate(player, localPlayer) then
                continue
            end
            
            local char = self.Utils:GetCharacter(player)
            local head = self.Utils:GetHead(char)
            
            if head then
                local distance = self.Utils:GetDistance(myPos, head.Position)
                
                if distance <= self.Config.MaxDistance then
                    table.insert(targets, {
                        Player = player,
                        Character = char,
                        Head = head,
                        Distance = distance,
                    })
                end
            end
        end
    end
    
    return targets
end

function TargetManager:GetBestTarget(localPlayer)
    local targets = self:GetAllValidTargets(localPlayer)
    if #targets == 0 then return nil end
    
    local bestTarget = nil
    local bestScore = math.huge
    
    for _, targetData in ipairs(targets) do
        local screenPos, onScreen = self.Utils:WorldToScreen(targetData.Head.Position)
        
        if onScreen then
            local screenCenter = Vector2.new(
                self.Utils.Camera.ViewportSize.X / 2,
                self.Utils.Camera.ViewportSize.Y / 2
            )
            local distanceFromCenter = (screenPos - screenCenter).Magnitude
            
            if distanceFromCenter <= self.Config.FOV then
                local score = distanceFromCenter
                
                if score < bestScore then
                    bestScore = score
                    bestTarget = targetData
                end
            end
        end
    end
    
    if bestTarget then
        self.CurrentTarget = bestTarget
        self.LastTargetTime = tick()
    elseif self.CurrentTarget and (tick() - self.LastTargetTime) < self.TargetLockDuration then
        return self.CurrentTarget
    else
        self.CurrentTarget = nil
    end
    
    return bestTarget
end

function TargetManager:PredictPosition(targetData, predictionTime)
    if not targetData or not targetData.Character then return nil end
    
    local rootPart = self.Utils:GetRootPart(targetData.Character)
    if not rootPart then return targetData.Head.Position end
    
    local velocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity
    local currentPos = targetData.Head.Position
    
    return currentPos + (velocity * predictionTime)
end

CombatModule.TargetManager = TargetManager

-- ═══════════════════════════════════════════════════════════════
-- AIMBOT CLASS
-- ═══════════════════════════════════════════════════════════════

local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new(config, utilities)
    local self = setmetatable({}, Aimbot)
    
    self.Config = config
    self.Utils = utilities
    self.TargetManager = TargetManager.new(config, utilities)
    self.FOVCircle = nil
    
    self:CreateFOVCircle()
    
    return self
end

function Aimbot:CreateFOVCircle()
    if self.FOVCircle then self.FOVCircle:Remove() end
    
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Thickness = 2
    self.FOVCircle.NumSides = 64
    self.FOVCircle.Filled = false
    self.FOVCircle.Transparency = 0.7
    self.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    self.FOVCircle.Visible = false
end

function Aimbot:UpdateFOVCircle()
    if not self.FOVCircle then return end
    
    local screenCenter = Vector2.new(
        self.Utils.Camera.ViewportSize.X / 2,
        self.Utils.Camera.ViewportSize.Y / 2
    )
    
    self.FOVCircle.Position = screenCenter
    self.FOVCircle.Radius = self.Config.FOV
    self.FOVCircle.Visible = self.Config.Enabled
end

function Aimbot:SmoothAim(targetPosition)
    if not targetPosition then return end
    
    local cameraCFrame = self.Utils.Camera.CFrame
    local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
    local smoothedCFrame = cameraCFrame:Lerp(targetCFrame, self.Config.Smoothness)
    
    self.Utils.Camera.CFrame = smoothedCFrame
end

function Aimbot:IsVisible(targetPart, localPlayer)
    if not self.Config.VisibleCheck then return true end
    if not targetPart then return false end
    
    local myChar = self.Utils:GetCharacter(localPlayer)
    if not myChar then return false end
    
    local rayOrigin = self.Utils.Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin).Unit * self.Config.MaxDistance
    
    local rayResult = self.Utils:PerformRaycast(rayOrigin, rayDirection, {myChar, targetPart.Parent})
    
    return rayResult == nil or rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

function Aimbot:Update(localPlayer)
    if not self.Config.Enabled then
        self:UpdateFOVCircle()
        return
    end
    
    local targetData = self.TargetManager:GetBestTarget(localPlayer)
    
    if targetData then
        local targetPart = targetData.Character:FindFirstChild(self.Config.TargetPart) or targetData.Head
        
        if self:IsVisible(targetPart, localPlayer) then
            local aimPosition = targetPart.Position
            
            if self.Config.PredictionEnabled then
                aimPosition = self.TargetManager:PredictPosition(targetData, self.Config.PredictionTime)
            end
            
            self:SmoothAim(aimPosition)
        end
    end
    
    self:UpdateFOVCircle()
end

function Aimbot:Destroy()
    if self.FOVCircle then
        self.FOVCircle:Remove()
    end
end

CombatModule.Aimbot = Aimbot

-- ═══════════════════════════════════════════════════════════════
-- ESP CLASS
-- ═══════════════════════════════════════════════════════════════

local ESP = {}
ESP.__index = ESP

function ESP.new(config, utilities)
    local self = setmetatable({}, ESP)
    
    self.Config = config
    self.Utils = utilities
    self.ESPObjects = {}
    
    return self
end

function ESP:CreateESP(player)
    if self.ESPObjects[player] then return end
    
    local espData = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
    }
    
    -- Configure Box
    espData.Box.Thickness = 2
    espData.Box.Filled = false
    espData.Box.Color = Color3.fromRGB(255, 255, 255)
    espData.Box.Transparency = 1
    espData.Box.Visible = false
    
    -- Configure Name
    espData.Name.Size = 14
    espData.Name.Center = true
    espData.Name.Outline = true
    espData.Name.Color = Color3.fromRGB(255, 255, 255)
    espData.Name.Visible = false
    
    -- Configure Health
    espData.Health.Size = 14
    espData.Health.Center = true
    espData.Health.Outline = true
    espData.Health.Color = Color3.fromRGB(0, 255, 0)
    espData.Health.Visible = false
    
    -- Configure Distance
    espData.Distance.Size = 12
    espData.Distance.Center = true
    espData.Distance.Outline = true
    espData.Distance.Color = Color3.fromRGB(255, 255, 0)
    espData.Distance.Visible = false
    
    -- Configure Health Bar
    espData.HealthBar.Thickness = 3
    espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    espData.HealthBar.Visible = false
    
    -- Configure Tracer
    espData.Tracer.Thickness = 1
    espData.Tracer.Color = Color3.fromRGB(255, 255, 255)
    espData.Tracer.Transparency = 0.5
    espData.Tracer.Visible = false
    
    self.ESPObjects[player] = espData
end

function ESP:RemoveESP(player)
    if not self.ESPObjects[player] then return end
    
    for _, obj in pairs(self.ESPObjects[player]) do
        obj:Remove()
    end
    
    self.ESPObjects[player] = nil
end

function ESP:UpdateESP(player, localPlayer)
    if not self.Config.Enabled then return end
    if player == localPlayer then return end
    if not self.Utils:IsAlive(player) then return end
    
    -- Team check
    if self.Config.TeamCheck and self.Utils:IsTeamMate(player, localPlayer) then
        return
    end
    
    local char = self.Utils:GetCharacter(player)
    local rootPart = self.Utils:GetRootPart(char)
    local head = self.Utils:GetHead(char)
    
    if not rootPart or not head then return end
    
    local myChar = self.Utils:GetCharacter(localPlayer)
    if not myChar then return end
    
    local myPos = self.Utils:GetRootPart(myChar).Position
    local distance = self.Utils:GetDistance(myPos, rootPart.Position)
    
    if distance > self.Config.MaxDistance then return end
    
    if not self.ESPObjects[player] then
        self:CreateESP(player)
    end
    
    local espData = self.ESPObjects[player]
    
    local headPos, headOnScreen = self.Utils:WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos, rootOnScreen = self.Utils:WorldToScreen(rootPart.Position - Vector3.new(0, 3, 0))
    
    if headOnScreen and rootOnScreen then
        local height = math.abs(headPos.Y - rootPos.Y)
        local width = height / 2
        
        -- Update Box
        if self.Config.Boxes then
            espData.Box.Size = Vector2.new(width, height)
            espData.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y)
            espData.Box.Visible = true
        else
            espData.Box.Visible = false
        end
        
        -- Update Name
        if self.Config.Names then
            espData.Name.Text = player.Name
            espData.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            espData.Name.Visible = true
        else
            espData.Name.Visible = false
        end
        
        -- Update Health
        if self.Config.Health then
            local humanoid = self.Utils:GetHumanoid(char)
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            
            espData.Health.Text = tostring(healthPercent) .. "%"
            espData.Health.Position = Vector2.new(rootPos.X - width / 2 - 20, rootPos.Y)
            espData.Health.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
            espData.Health.Visible = true
            
            espData.HealthBar.From = Vector2.new(rootPos.X - width / 2 - 5, rootPos.Y)
            espData.HealthBar.To = Vector2.new(rootPos.X - width / 2 - 5, rootPos.Y + (height * (humanoid.Health / humanoid.MaxHealth)))
            espData.HealthBar.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
            espData.HealthBar.Visible = true
        else
            espData.Health.Visible = false
            espData.HealthBar.Visible = false
        end
        
        -- Update Distance
        if self.Config.Distance then
            espData.Distance.Text = math.floor(distance) .. "m"
            espData.Distance.Position = Vector2.new(headPos.X, rootPos.Y + height + 5)
            espData.Distance.Visible = true
        else
            espData.Distance.Visible = false
        end
        
        -- Update Tracers
        if self.Config.Tracers then
            local screenCenter = Vector2.new(self.Utils.Camera.ViewportSize.X / 2, self.Utils.Camera.ViewportSize.Y)
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

function ESP:Update(localPlayer)
    if not self.Config.Enabled then
        for player, _ in pairs(self.ESPObjects) do
            self:RemoveESP(player)
        end
        return
    end
    
    for _, player in ipairs(self.Utils.Players:GetPlayers()) do
        self:UpdateESP(player, localPlayer)
    end
end

function ESP:Destroy()
    for player, _ in pairs(self.ESPObjects) do
        self:RemoveESP(player)
    end
end

CombatModule.ESP = ESP

-- ═══════════════════════════════════════════════════════════════
-- MAIN CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════

function CombatModule.new(customConfig)
    local self = setmetatable({}, CombatModule)
    
    -- Merge custom config with defaults
    self.Config = customConfig or CombatModule.DefaultConfig
    
    -- Initialize utilities
    self.Utils = Utilities.new()
    
    -- Initialize systems
    self.Aimbot = Aimbot.new(self.Config.Aimbot, self.Utils)
    self.ESP = ESP.new(self.Config.ESP, self.Utils)
    
    return self
end

function CombatModule:Update(localPlayer)
    self.Aimbot:Update(localPlayer)
    self.ESP:Update(localPlayer)
end

function CombatModule:Destroy()
    self.Aimbot:Destroy()
    self.ESP:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════

return CombatModule
