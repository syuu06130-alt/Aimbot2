--[[
    ═══════════════════════════════════════════════════════════════
    クイックスタートガイド - Advanced Combat System v3.0
    ═══════════════════════════════════════════════════════════════
]]--

-- ═══════════════════════════════════════════════════════════════
-- 方法1: 最も簡単な使い方 (初心者向け)
-- ═══════════════════════════════════════════════════════════════

--[[
    1. CombatSystem.luaの全コードをコピー
    2. Roblox Executorに貼り付けて実行
    3. GUIが自動で開きます
    4. 各機能のトグルをONにして使用
]]--

-- ═══════════════════════════════════════════════════════════════
-- 方法2: ModuleScriptを使った使い方 (推奨)
-- ═══════════════════════════════════════════════════════════════

--[[
    セットアップ手順:
    1. ReplicatedStorageに"CombatModule"という名前でModuleScriptを作成
    2. CombatModule.luaのコードを貼り付け
    3. StarterPlayerScriptsにLocalScriptを作成
    4. 以下のコードを使用
]]--

-- LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- モジュールをロード
local CombatModule = require(ReplicatedStorage:WaitForChild("CombatModule"))

-- インスタンス作成
local Combat = CombatModule.new()

local LocalPlayer = Players.LocalPlayer

-- メインループ
RunService.RenderStepped:Connect(function()
    Combat:Update(LocalPlayer)
end)

-- クリーンアップ
LocalPlayer.CharacterRemoving:Connect(function()
    Combat:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
-- 方法3: カスタム設定での使用 (上級者向け)
-- ═══════════════════════════════════════════════════════════════

-- カスタム設定を作成
local myCustomConfig = {
    Aimbot = {
        Enabled = true,          -- 自動で有効化
        FOV = 180,               -- 広めのFOV
        Smoothness = 0.12,       -- 滑らかな動き
        MaxDistance = 4500,      -- 中距離まで
        TargetPart = "Head",     -- ヘッドショット優先
        PredictionEnabled = true,
        PredictionTime = 0.14,   -- 少し長めの予測
        VisibleCheck = true,     -- 壁越しは無視
        TeamCheck = true,        -- チームメイトは無視
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,         -- パフォーマンス重視
        MaxDistance = 3500,
        TeamCheck = true,
    },
}

-- カスタム設定でインスタンス作成
local CustomCombat = CombatModule.new(myCustomConfig)

RunService.RenderStepped:Connect(function()
    CustomCombat:Update(LocalPlayer)
end)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: リアルタイム設定変更
-- ═══════════════════════════════════════════════════════════════

-- 戦闘中に設定を変更
Combat.Aimbot.Config.FOV = 150              -- FOVを狭める
Combat.Aimbot.Config.Smoothness = 0.08      -- より高速に

-- ESPをトグル
Combat.ESP.Config.Enabled = not Combat.ESP.Config.Enabled

-- Silent Aimを有効化
Combat.SilentAim.Settings.Enabled = true
Combat.SilentAim.Settings.HitChance = 90    -- 90%の確率でヒット

-- ═══════════════════════════════════════════════════════════════
-- 使用例: キーバインド設定
-- ═══════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")

-- キーボードショートカット
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Aimbot トグル
    if input.KeyCode == Enum.KeyCode.F1 then
        Combat.Aimbot.Config.Enabled = not Combat.Aimbot.Config.Enabled
        print("Aimbot:", Combat.Aimbot.Config.Enabled and "ON" or "OFF")
    end
    
    -- F2: ESP トグル
    if input.KeyCode == Enum.KeyCode.F2 then
        Combat.ESP.Config.Enabled = not Combat.ESP.Config.Enabled
        print("ESP:", Combat.ESP.Config.Enabled and "ON" or "OFF")
    end
    
    -- F3: Silent Aim トグル
    if input.KeyCode == Enum.KeyCode.F3 then
        Combat.SilentAim.Settings.Enabled = not Combat.SilentAim.Settings.Enabled
        print("Silent Aim:", Combat.SilentAim.Settings.Enabled and "ON" or "OFF")
    end
    
    -- F4: Triggerbot トグル
    if input.KeyCode == Enum.KeyCode.F4 then
        Combat.Triggerbot.Settings.Enabled = not Combat.Triggerbot.Settings.Enabled
        print("Triggerbot:", Combat.Triggerbot.Settings.Enabled and "ON" or "OFF")
    end
    
    -- LeftShift + RightShift: 全機能トグル
    if input.KeyCode == Enum.KeyCode.LeftShift and UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        local newState = not Combat.Aimbot.Config.Enabled
        Combat.Aimbot.Config.Enabled = newState
        Combat.ESP.Config.Enabled = newState
        Combat.SilentAim.Settings.Enabled = newState
        Combat.Triggerbot.Settings.Enabled = newState
        print("All Systems:", newState and "ON" or "OFF")
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: 特定条件での自動有効化
-- ═══════════════════════════════════════════════════════════════

-- 武器を持っている時だけAimbotを有効化
local function UpdateAimbotByWeapon()
    local character = LocalPlayer.Character
    if not character then return end
    
    local weapon = character:FindFirstChildOfClass("Tool")
    Combat.Aimbot.Config.Enabled = weapon ~= nil
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(UpdateAimbotByWeapon)
    character.ChildRemoved:Connect(UpdateAimbotByWeapon)
end)

-- 特定の敵が近くにいる時だけESPを有効化
local function UpdateESPByProximity()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local nearbyEnemy = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                if distance < 100 then
                    nearbyEnemy = true
                    break
                end
            end
        end
    end
    
    Combat.ESP.Config.Enabled = nearbyEnemy
end

RunService.Heartbeat:Connect(UpdateESPByProximity)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: デバッグ情報の表示
-- ═══════════════════════════════════════════════════════════════

-- 画面上にデバッグ情報を表示
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatDebug"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local DebugLabel = Instance.new("TextLabel")
DebugLabel.Size = UDim2.new(0, 300, 0, 200)
DebugLabel.Position = UDim2.new(0, 10, 0, 10)
DebugLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DebugLabel.BackgroundTransparency = 0.5
DebugLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugLabel.TextSize = 14
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugLabel.Parent = ScreenGui

-- デバッグ情報を更新
RunService.RenderStepped:Connect(function()
    local target = Combat.Aimbot.TargetManager:GetBestTarget(LocalPlayer)
    
    local debugText = string.format([[
═══ Combat System Debug ═══
Aimbot: %s
ESP: %s
Silent Aim: %s
Triggerbot: %s

Current Target: %s
FOV: %d
Smoothness: %.2f
FPS: %d
]],
        Combat.Aimbot.Config.Enabled and "✓ ON" or "✗ OFF",
        Combat.ESP.Config.Enabled and "✓ ON" or "✗ OFF",
        Combat.SilentAim.Settings.Enabled and "✓ ON" or "✗ OFF",
        Combat.Triggerbot.Settings.Enabled and "✓ ON" or "✗ OFF",
        target and target.Player.Name or "None",
        Combat.Aimbot.Config.FOV,
        Combat.Aimbot.Config.Smoothness,
        math.floor(1 / RunService.RenderStepped:Wait())
    )
    
    DebugLabel.Text = debugText
end)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: プリセット設定
-- ═══════════════════════════════════════════════════════════════

local Presets = {
    -- 精密射撃モード
    Precision = {
        Aimbot = {
            Enabled = true,
            FOV = 80,
            Smoothness = 0.08,
            MaxDistance = 3000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.1,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = false,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 3000,
        },
    },
    
    -- 近接戦闘モード
    CQB = {
        Aimbot = {
            Enabled = true,
            FOV = 200,
            Smoothness = 0.2,
            MaxDistance = 1500,
            TargetPart = "UpperTorso",
            PredictionEnabled = false,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = false,
            Tracers = true,
            MaxDistance = 1500,
        },
    },
    
    -- ステルスモード
    Stealth = {
        Aimbot = {
            Enabled = false,
            FOV = 50,
            Smoothness = 0.3,
            MaxDistance = 5000,
        },
        ESP = {
            Enabled = true,
            Boxes = false,
            Names = true,
            Health = false,
            Distance = true,
            Tracers = false,
            MaxDistance = 5000,
        },
    },
}

-- プリセットを適用する関数
local function ApplyPreset(presetName)
    local preset = Presets[presetName]
    if not preset then
        warn("Preset not found:", presetName)
        return
    end
    
    -- Aimbot設定を適用
    for key, value in pairs(preset.Aimbot) do
        Combat.Aimbot.Config[key] = value
    end
    
    -- ESP設定を適用
    for key, value in pairs(preset.ESP) do
        Combat.ESP.Config[key] = value
    end
    
    print("Preset applied:", presetName)
end

-- 使用例
ApplyPreset("Precision")  -- 精密射撃モードを適用

-- キーで切り替え
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        ApplyPreset("Precision")
    elseif input.KeyCode == Enum.KeyCode.Two then
        ApplyPreset("CQB")
    elseif input.KeyCode == Enum.KeyCode.Three then
        ApplyPreset("Stealth")
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: パフォーマンスモニター
-- ═══════════════════════════════════════════════════════════════

local PerformanceMonitor = {
    FrameTimes = {},
    MaxSamples = 60,
}

function PerformanceMonitor:Update(deltaTime)
    table.insert(self.FrameTimes, deltaTime)
    
    if #self.FrameTimes > self.MaxSamples then
        table.remove(self.FrameTimes, 1)
    end
end

function PerformanceMonitor:GetAverageFPS()
    if #self.FrameTimes == 0 then return 0 end
    
    local sum = 0
    for _, time in ipairs(self.FrameTimes) do
        sum = sum + time
    end
    
    local avgTime = sum / #self.FrameTimes
    return math.floor(1 / avgTime)
end

function PerformanceMonitor:OptimizeSettings()
    local fps = self:GetAverageFPS()
    
    if fps < 30 then
        -- 低FPS: 設定を軽くする
        Combat.ESP.Config.Tracers = false
        Combat.ESP.Config.Distance = false
        Combat.ESP.Config.MaxDistance = 2000
        Combat.Aimbot.Config.MaxDistance = 3000
        print("Performance mode: Low settings applied")
    elseif fps > 60 then
        -- 高FPS: 設定を上げる
        Combat.ESP.Config.Tracers = true
        Combat.ESP.Config.Distance = true
        Combat.ESP.Config.MaxDistance = 5000
        Combat.Aimbot.Config.MaxDistance = 5000
        print("Performance mode: High settings applied")
    end
end

-- パフォーマンスモニターを実行
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local deltaTime = currentTime - lastTime
    lastTime = currentTime
    
    PerformanceMonitor:Update(deltaTime)
end)

-- 5秒ごとに自動最適化
task.spawn(function()
    while true do
        task.wait(5)
        PerformanceMonitor:OptimizeSettings()
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 使用例: チャットコマンド
-- ═══════════════════════════════════════════════════════════════

local TextChatService = game:GetService("TextChatService")

local function HandleCommand(message)
    local args = string.split(message, " ")
    local command = args[1]:lower()
    
    if command == "/aimbot" then
        Combat.Aimbot.Config.Enabled = not Combat.Aimbot.Config.Enabled
        return "Aimbot: " .. (Combat.Aimbot.Config.Enabled and "ON" or "OFF")
    elseif command == "/esp" then
        Combat.ESP.Config.Enabled = not Combat.ESP.Config.Enabled
        return "ESP: " .. (Combat.ESP.Config.Enabled and "ON" or "OFF")
    elseif command == "/fov" and args[2] then
        local fov = tonumber(args[2])
        if fov then
            Combat.Aimbot.Config.FOV = math.clamp(fov, 10, 500)
            return "FOV set to: " .. Combat.Aimbot.Config.FOV
        end
    elseif command == "/smooth" and args[2] then
        local smooth = tonumber(args[2])
        if smooth then
            Combat.Aimbot.Config.Smoothness = math.clamp(smooth, 0.01, 1)
            return "Smoothness set to: " .. Combat.Aimbot.Config.Smoothness
        end
    elseif command == "/preset" and args[2] then
        ApplyPreset(args[2])
        return "Preset applied: " .. args[2]
    elseif command == "/help" then
        return [[
Commands:
/aimbot - Toggle aimbot
/esp - Toggle ESP
/fov [value] - Set FOV (10-500)
/smooth [value] - Set smoothness (0.01-1)
/preset [name] - Apply preset (Precision/CQB/Stealth)
]]
    end
end

-- TextChat対応
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(message)
        if message.TextSource.UserId == LocalPlayer.UserId then
            local result = HandleCommand(message.Text)
            if result then
                print(result)
            end
        end
    end)
end

print("═══════════════════════════════════════════════════════════════")
print("Quick Start Guide loaded!")
print("Press F1-F4 to toggle features")
print("Type /help for chat commands")
print("═══════════════════════════════════════════════════════════════")
