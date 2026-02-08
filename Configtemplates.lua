--[[
    ═══════════════════════════════════════════════════════════════
    Configuration Templates - Advanced Combat System
    様々なゲームジャンル・プレイスタイル向けの設定テンプレート
    ═══════════════════════════════════════════════════════════════
]]--

local ConfigTemplates = {}

-- ═══════════════════════════════════════════════════════════════
-- FPS向け設定
-- ═══════════════════════════════════════════════════════════════

ConfigTemplates.FPS = {
    -- 競技的FPS (Counter-Strike, Valorant風)
    Competitive = {
        Aimbot = {
            Enabled = true,
            FOV = 80,
            Smoothness = 0.08,
            MaxDistance = 3500,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.11,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = false,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 3500,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 40,
            HitChance = 92,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.03,
        },
    },
    
    -- バトルロイヤル (Fortnite, Apex Legends風)
    BattleRoyale = {
        Aimbot = {
            Enabled = true,
            FOV = 150,
            Smoothness = 0.14,
            MaxDistance = 5000,
            TargetPart = "UpperTorso",
            PredictionEnabled = true,
            PredictionTime = 0.15,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 5000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 60,
            HitChance = 88,
            TargetPart = "UpperTorso",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.05,
        },
    },
    
    -- タクティカルシューター (Rainbow Six Siege風)
    Tactical = {
        Aimbot = {
            Enabled = true,
            FOV = 90,
            Smoothness = 0.1,
            MaxDistance = 3000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.09,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = false,
            Health = true,
            Distance = false,
            Tracers = false,
            MaxDistance = 3000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 50,
            HitChance = 95,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = true,
            Delay = 0.02,
        },
    },
    
    -- アリーナシューター (Quake, UT風)
    Arena = {
        Aimbot = {
            Enabled = true,
            FOV = 200,
            Smoothness = 0.06,
            MaxDistance = 4000,
            TargetPart = "UpperTorso",
            PredictionEnabled = true,
            PredictionTime = 0.18,
            VisibleCheck = false,
            TeamCheck = false,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = true,
            MaxDistance = 4000,
            TeamCheck = false,
        },
        SilentAim = {
            Enabled = false,
            FOV = 100,
            HitChance = 100,
            TargetPart = "UpperTorso",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0,
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- RPG向け設定
-- ═══════════════════════════════════════════════════════════════

ConfigTemplates.RPG = {
    -- PvP重視
    PvP = {
        Aimbot = {
            Enabled = true,
            FOV = 180,
            Smoothness = 0.16,
            MaxDistance = 6000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.13,
            VisibleCheck = false,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 6000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 80,
            HitChance = 85,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.08,
        },
    },
    
    -- PvE重視
    PvE = {
        Aimbot = {
            Enabled = true,
            FOV = 220,
            Smoothness = 0.2,
            MaxDistance = 7000,
            TargetPart = "Head",
            PredictionEnabled = false,
            PredictionTime = 0,
            VisibleCheck = false,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = true,
            MaxDistance = 7000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 100,
            HitChance = 100,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = true,
            Delay = 0.1,
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- プレイスタイル別設定
-- ═══════════════════════════════════════════════════════════════

ConfigTemplates.PlayStyle = {
    -- アグレッシブ（攻撃的）
    Aggressive = {
        Aimbot = {
            Enabled = true,
            FOV = 200,
            Smoothness = 0.1,
            MaxDistance = 3000,
            TargetPart = "UpperTorso",
            PredictionEnabled = true,
            PredictionTime = 0.12,
            VisibleCheck = false,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = false,
            Tracers = true,
            MaxDistance = 3000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 80,
            HitChance = 100,
            TargetPart = "UpperTorso",
        },
        Triggerbot = {
            Enabled = true,
            Delay = 0.02,
        },
    },
    
    -- ディフェンシブ（防御的）
    Defensive = {
        Aimbot = {
            Enabled = true,
            FOV = 120,
            Smoothness = 0.18,
            MaxDistance = 5000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.14,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 5000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 60,
            HitChance = 90,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.05,
        },
    },
    
    -- スナイパー（遠距離）
    Sniper = {
        Aimbot = {
            Enabled = true,
            FOV = 60,
            Smoothness = 0.05,
            MaxDistance = 8000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.2,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = false,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 8000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 30,
            HitChance = 100,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0,
        },
    },
    
    -- ステルス（隠密）
    Stealth = {
        Aimbot = {
            Enabled = false,
            FOV = 80,
            Smoothness = 0.3,
            MaxDistance = 4000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.11,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = false,
            Names = true,
            Health = false,
            Distance = true,
            Tracers = false,
            MaxDistance = 4000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 50,
            HitChance = 85,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.1,
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- パフォーマンス別設定
-- ═══════════════════════════════════════════════════════════════

ConfigTemplates.Performance = {
    -- 低スペックPC向け
    LowEnd = {
        Aimbot = {
            Enabled = true,
            FOV = 150,
            Smoothness = 0.15,
            MaxDistance = 3000,
            TargetPart = "UpperTorso",
            PredictionEnabled = false,
            PredictionTime = 0,
            VisibleCheck = false,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = false,
            Health = false,
            Distance = false,
            Tracers = false,
            MaxDistance = 2000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 50,
            HitChance = 100,
            TargetPart = "UpperTorso",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.05,
        },
    },
    
    -- 高スペックPC向け
    HighEnd = {
        Aimbot = {
            Enabled = true,
            FOV = 200,
            Smoothness = 0.08,
            MaxDistance = 7000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.15,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = true,
            MaxDistance = 7000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 70,
            HitChance = 95,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = true,
            Delay = 0.03,
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- 時間帯別設定（自動切り替え用）
-- ═══════════════════════════════════════════════════════════════

ConfigTemplates.TimeOfDay = {
    -- 練習時間（遊び）
    Practice = {
        Aimbot = {
            Enabled = false,
            FOV = 100,
            Smoothness = 0.3,
            MaxDistance = 3000,
            TargetPart = "UpperTorso",
            PredictionEnabled = false,
            PredictionTime = 0,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 3000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 50,
            HitChance = 50,
            TargetPart = "UpperTorso",
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.1,
        },
    },
    
    -- 真剣勝負
    Serious = {
        Aimbot = {
            Enabled = true,
            FOV = 120,
            Smoothness = 0.1,
            MaxDistance = 5000,
            TargetPart = "Head",
            PredictionEnabled = true,
            PredictionTime = 0.13,
            VisibleCheck = true,
            TeamCheck = true,
        },
        ESP = {
            Enabled = true,
            Boxes = true,
            Names = true,
            Health = true,
            Distance = true,
            Tracers = false,
            MaxDistance = 5000,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = true,
            FOV = 60,
            HitChance = 92,
            TargetPart = "Head",
        },
        Triggerbot = {
            Enabled = true,
            Delay = 0.03,
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- ヘルパー関数
-- ═══════════════════════════════════════════════════════════════

function ConfigTemplates:GetConfig(category, subcategory)
    if self[category] and self[category][subcategory] then
        return self[category][subcategory]
    end
    
    warn("Config not found:", category, subcategory)
    return nil
end

function ConfigTemplates:ListCategories()
    local categories = {}
    for category, _ in pairs(self) do
        if type(self[category]) == "table" and category ~= "GetConfig" and category ~= "ListCategories" and category ~= "ListSubcategories" then
            table.insert(categories, category)
        end
    end
    return categories
end

function ConfigTemplates:ListSubcategories(category)
    if not self[category] then
        warn("Category not found:", category)
        return {}
    end
    
    local subcategories = {}
    for subcategory, _ in pairs(self[category]) do
        if type(self[category][subcategory]) == "table" then
            table.insert(subcategories, subcategory)
        end
    end
    return subcategories
end

-- ═══════════════════════════════════════════════════════════════
-- 使用例
-- ═══════════════════════════════════════════════════════════════

--[[
使い方:

1. 基本的な使用
local config = ConfigTemplates:GetConfig("FPS", "Competitive")
local Combat = CombatModule.new(config)

2. カテゴリ一覧を取得
local categories = ConfigTemplates:ListCategories()
for _, category in ipairs(categories) do
    print(category)
end

3. サブカテゴリ一覧を取得
local subcategories = ConfigTemplates:ListSubcategories("FPS")
for _, subcategory in ipairs(subcategories) do
    print(subcategory)
end

4. ゲーム中に設定を切り替え
-- FPS Competitiveモード
ApplyConfig(ConfigTemplates.FPS.Competitive)

-- RPG PvPモード
ApplyConfig(ConfigTemplates.RPG.PvP)

-- アグレッシブプレイスタイル
ApplyConfig(ConfigTemplates.PlayStyle.Aggressive)
]]

-- ═══════════════════════════════════════════════════════════════
-- 設定適用関数
-- ═══════════════════════════════════════════════════════════════

local function ApplyConfig(config, combat)
    if not combat then
        warn("Combat instance not provided")
        return
    end
    
    -- Aimbot設定を適用
    if config.Aimbot then
        for key, value in pairs(config.Aimbot) do
            if combat.Aimbot.Config[key] ~= nil then
                combat.Aimbot.Config[key] = value
            end
        end
    end
    
    -- ESP設定を適用
    if config.ESP then
        for key, value in pairs(config.ESP) do
            if combat.ESP.Config[key] ~= nil then
                combat.ESP.Config[key] = value
            end
        end
    end
    
    -- Silent Aim設定を適用
    if config.SilentAim then
        for key, value in pairs(config.SilentAim) do
            if combat.SilentAim.Settings[key] ~= nil then
                combat.SilentAim.Settings[key] = value
            end
        end
    end
    
    -- Triggerbot設定を適用
    if config.Triggerbot then
        for key, value in pairs(config.Triggerbot) do
            if combat.Triggerbot.Settings[key] ~= nil then
                combat.Triggerbot.Settings[key] = value
            end
        end
    end
    
    print("Configuration applied successfully")
end

-- ═══════════════════════════════════════════════════════════════
-- エクスポート
-- ═══════════════════════════════════════════════════════════════

return {
    Templates = ConfigTemplates,
    ApplyConfig = ApplyConfig,
}
