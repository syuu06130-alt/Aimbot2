# 🎯 Advanced Combat System v3.0 - 完全ドキュメント

## 📋 目次
1. [概要](#概要)
2. [機能一覧](#機能一覧)
3. [インストール方法](#インストール方法)
4. [使用方法](#使用方法)
5. [設定ガイド](#設定ガイド)
6. [ModuleScript使用法](#modulescript使用法)
7. [技術詳細](#技術詳細)
8. [トラブルシューティング](#トラブルシューティング)

---

## 🎮 概要

このプロジェクトは、2年前に作成されたGarry's Mod (GLua) Aimbotコードを、Roblox Lua向けに完全リメイクした**最新の戦闘支援システム**です。

### 主な改善点
- ✅ **Rayfield UI統合** - モダンで美しいユーザーインターフェース
- ✅ **OOP設計** - 完全なオブジェクト指向プログラミング構造
- ✅ **ModuleScript対応** - 再利用可能なモジュール設計
- ✅ **高度な機能** - Aimbot、ESP、Silent Aim、Triggerbot
- ✅ **最適化済み** - パフォーマンスを考慮した実装
- ✅ **設定保存機能** - 自動設定保存/読み込み

---

## ⚔️ 機能一覧

### 1. 🎯 Aimbot (エイムボット)
- **自動エイム調整** - 最も近いターゲットに自動でエイムを合わせる
- **FOV制限** - 設定した視野角内のターゲットのみを対象
- **スムーシング** - 自然な動きでエイムを調整
- **予測システム** - ターゲットの移動を予測して先読みエイム
- **可視性チェック** - 壁越しのターゲットは無視
- **距離制限** - 設定した最大距離内のターゲットのみ

#### 設定項目
| 設定名 | 範囲 | 初期値 | 説明 |
|--------|------|--------|------|
| 有効化 | On/Off | Off | Aimbot機能の有効/無効 |
| FOV範囲 | 10-500px | 200px | ターゲット検出の視野角 |
| スムージング | 0.01-1.0 | 0.15 | エイム調整の滑らかさ (低いほど滑らか) |
| 最大距離 | 100-10000 studs | 5000 studs | ターゲット検出の最大距離 |
| ターゲット部位 | Head/Torso/HumanoidRootPart | Head | エイムを合わせる体の部位 |
| 予測有効化 | On/Off | On | 移動予測の有効/無効 |
| 予測時間 | 0.05-0.5s | 0.13s | 予測する未来の時間 |
| 可視性チェック | On/Off | On | 壁越しターゲットの除外 |

### 2. 👁️ ESP (Wallhack / 透視)
- **ボックス表示** - プレイヤーの周りに枠を表示
- **名前表示** - プレイヤー名を表示
- **体力バー** - 体力をバーとパーセンテージで表示
- **距離表示** - ターゲットまでの距離を表示
- **トレーサー** - 画面中央からターゲットへの線

#### 設定項目
| 設定名 | 範囲 | 初期値 | 説明 |
|--------|------|--------|------|
| ESP有効化 | On/Off | Off | ESP機能の有効/無効 |
| ボックス | On/Off | On | 枠の表示/非表示 |
| 名前表示 | On/Off | On | 名前の表示/非表示 |
| 体力バー | On/Off | On | 体力バーの表示/非表示 |
| 距離表示 | On/Off | On | 距離の表示/非表示 |
| トレーサー | On/Off | Off | トレーサーの表示/非表示 |
| 最大距離 | 100-10000 studs | 5000 studs | ESP表示の最大距離 |

### 3. 🔇 Silent Aim
- **非表示エイム** - カメラを動かさずに自動でターゲット
- **命中確率** - ヒット確率を調整可能
- **FOV制限** - 独立したFOV設定

#### 設定項目
| 設定名 | 範囲 | 初期値 | 説明 |
|--------|------|--------|------|
| 有効化 | On/Off | Off | Silent Aim機能の有効/無効 |
| Silent FOV | 10-200px | 50px | Silent Aimの視野角 |
| 命中確率 | 10-100% | 100% | ヒット確率 (検出回避用) |

### 4. ⚡ Triggerbot (自動射撃)
- **自動射撃** - ターゲットにカーソルが合うと自動で射撃
- **遅延設定** - 射撃までの遅延時間を設定可能

#### 設定項目
| 設定名 | 範囲 | 初期値 | 説明 |
|--------|------|--------|------|
| 有効化 | On/Off | Off | Triggerbot機能の有効/無効 |
| 射撃遅延 | 0-0.5s | 0.05s | 射撃までの遅延時間 |

---

## 📦 インストール方法

### 方法1: 直接実行 (推奨)
```lua
-- Roblox Executorに以下のコードをコピー&ペーストして実行
loadstring(game:HttpGet('YOUR_PASTEBIN_URL_HERE'))()
```

### 方法2: ローカルスクリプト
1. `CombatSystem.lua`をコピー
2. Roblox Studioで`StarterPlayer > StarterPlayerScripts`に新しい`LocalScript`を作成
3. コードを貼り付けて実行

### 方法3: ModuleScript使用
1. `ReplicatedStorage`に`ModuleScript`を作成し、名前を`CombatModule`に変更
2. `CombatModule.lua`のコードを貼り付け
3. 以下のコードで使用:

```lua
local CombatModule = require(game.ReplicatedStorage.CombatModule)
local Combat = CombatModule.new()

game:GetService("RunService").RenderStepped:Connect(function()
    Combat:Update(game.Players.LocalPlayer)
end)
```

---

## 🎮 使用方法

### 基本操作

1. **スクリプト実行**
   - コードを実行するとRayfield UIが自動で開きます
   - 初期化完了の通知が表示されます

2. **タブ操作**
   - `🎯 Aimbot` - Aimbot設定
   - `👁️ ESP` - ESP設定
   - `🔇 Silent Aim` - Silent Aim設定
   - `⚡ Triggerbot` - Triggerbot設定
   - `⚙️ 設定` - 全体設定

3. **機能の有効化**
   - 各タブで「有効化」トグルをONにする
   - スライダーで細かい設定を調整
   - 設定は自動保存されます

### 推奨設定

#### 初心者向け
```
Aimbot:
  - FOV: 150px
  - スムージング: 0.2
  - 予測: On
  - 予測時間: 0.13s

ESP:
  - 全てOn
  - トレーサー: Off
```

#### 上級者向け
```
Aimbot:
  - FOV: 100px
  - スムージング: 0.1
  - 予測: On
  - 予測時間: 0.15s

Silent Aim:
  - 有効化: On
  - 命中確率: 85% (検出回避)
```

---

## 🔧 設定ガイド

### Aimbot最適化

#### スムージング値の選び方
- **0.01-0.05**: 非常に高速 (ボットっぽく見える)
- **0.10-0.15**: バランス型 (推奨)
- **0.20-0.30**: 自然な動き
- **0.40-1.00**: 非常に滑らか (遅い)

#### FOV範囲の選び方
- **50-100px**: 精密射撃向け
- **100-200px**: バランス型 (推奨)
- **200-400px**: 広範囲カバー
- **400+px**: 画面全体

#### 予測時間の調整
```
低速移動ターゲット: 0.05-0.10s
通常移動: 0.10-0.15s
高速移動: 0.15-0.25s
```

### ESP最適化

#### パフォーマンス重視
```lua
ESP.Settings = {
    Enabled = true,
    Boxes = true,
    Names = false,      -- OFF
    Health = true,
    Distance = false,   -- OFF
    Tracers = false,    -- OFF
    MaxDistance = 3000, -- 短め
}
```

#### 情報重視
```lua
ESP.Settings = {
    Enabled = true,
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = true,
    MaxDistance = 5000,
}
```

---

## 💻 ModuleScript使用法

### 基本的な使用

```lua
-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CombatModule = require(game.ReplicatedStorage.CombatModule)
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
```

### カスタム設定での使用

```lua
local customConfig = {
    Aimbot = {
        Enabled = true,
        FOV = 150,
        Smoothness = 0.2,
        MaxDistance = 4000,
        TargetPart = "Head",
        PredictionEnabled = true,
        PredictionTime = 0.15,
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = false,
        Tracers = false,
        MaxDistance = 3000,
    },
}

local Combat = CombatModule.new(customConfig)
```

### 個別システムのアクセス

```lua
local Combat = CombatModule.new()

-- Aimbot設定変更
Combat.Aimbot.Config.FOV = 200
Combat.Aimbot.Config.Smoothness = 0.15

-- ESP設定変更
Combat.ESP.Config.Boxes = true
Combat.ESP.Config.Tracers = true

-- ターゲット取得
local target = Combat.Aimbot.TargetManager:GetBestTarget(LocalPlayer)
if target then
    print("Current target:", target.Player.Name)
end
```

---

## 🔬 技術詳細

### アーキテクチャ

```
CombatSystem
├── Utilities (ユーティリティクラス)
│   ├── GetCharacter()
│   ├── GetHumanoid()
│   ├── IsAlive()
│   ├── WorldToScreen()
│   └── PerformRaycast()
│
├── TargetManager (ターゲット管理)
│   ├── GetAllValidTargets()
│   ├── GetBestTarget()
│   └── PredictPosition()
│
├── Aimbot (エイムボットシステム)
│   ├── CreateFOVCircle()
│   ├── UpdateFOVCircle()
│   ├── SmoothAim()
│   ├── IsVisible()
│   └── Update()
│
├── ESP (透視システム)
│   ├── CreateESP()
│   ├── RemoveESP()
│   ├── UpdateESP()
│   └── Update()
│
├── SilentAim (サイレントエイムシステム)
│   └── GetTarget()
│
└── Triggerbot (自動射撃システム)
    └── Update()
```

### パフォーマンス最適化

1. **更新間隔の最適化**
   ```lua
   self.LastUpdateTime = 0
   self.UpdateInterval = 0.01  -- 10ms間隔
   ```

2. **距離による早期リターン**
   ```lua
   if distance > self.Settings.MaxDistance then return end
   ```

3. **画面外チェック**
   ```lua
   local screenPos, onScreen = WorldToScreen(position)
   if not onScreen then return end
   ```

4. **ターゲット永続化**
   ```lua
   -- 0.5秒間ターゲットをロック
   self.TargetLockDuration = 0.5
   ```

### 予測アルゴリズム

```lua
function PredictPosition(targetData, predictionTime)
    local velocity = rootPart.AssemblyLinearVelocity
    local currentPos = targetData.Head.Position
    
    -- 線形予測: 現在位置 + (速度 × 予測時間)
    return currentPos + (velocity * predictionTime)
end
```

### スムージングアルゴリズム

```lua
function SmoothAim(targetPosition)
    local cameraCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
    
    -- 線形補間 (Lerp)
    local smoothedCFrame = cameraCFrame:Lerp(targetCFrame, self.Settings.Smoothness)
    
    Camera.CFrame = smoothedCFrame
end
```

---

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. Aimbotが動作しない
**原因:**
- Aimbot有効化がOFFになっている
- FOV範囲が小さすぎる
- ターゲットが距離制限外

**解決方法:**
```lua
-- 設定を確認
Controller.Aimbot.Settings.Enabled = true
Controller.Aimbot.Settings.FOV = 200
Controller.Aimbot.Settings.MaxDistance = 5000
```

#### 2. ESPが表示されない
**原因:**
- Drawing APIがサポートされていない
- ESP有効化がOFFになっている

**解決方法:**
```lua
-- Drawing APIテスト
local testCircle = Drawing.new("Circle")
testCircle.Visible = true
testCircle.Radius = 50
testCircle.Position = Vector2.new(500, 500)
```

#### 3. パフォーマンスが悪い
**原因:**
- ESP最大距離が大きすぎる
- トレーサーがONになっている
- 多数のプレイヤーがいる

**解決方法:**
```lua
-- 最適化設定
Controller.ESP.Settings.MaxDistance = 2000
Controller.ESP.Settings.Tracers = false
Controller.ESP.Settings.Distance = false
```

#### 4. "attempt to index nil"エラー
**原因:**
- Characterがロードされていない
- パーツが見つからない

**解決方法:**
```lua
-- nil チェックを追加
local char = player.Character
if not char then return end

local head = char:FindFirstChild("Head")
if not head then return end
```

---

## 📊 コード比較: 旧版 vs 新版

### 旧版 (GLua)
```lua
-- シンプルな構造
local aimFOV = 20
local function findNearestTarget()
    -- 基本的なループ
end
```

### 新版 (Roblox Lua + OOP)
```lua
-- OOP構造
local TargetManager = {}
TargetManager.__index = TargetManager

function TargetManager.new(config)
    local self = setmetatable({}, TargetManager)
    self.config = config
    -- 高度な機能
    return self
end
```

### 主な改善点
| 項目 | 旧版 | 新版 |
|------|------|------|
| 構造 | 手続き型 | OOP |
| UI | 簡易VGUI | Rayfield (高機能) |
| 予測 | なし | あり |
| ESP | なし | フル機能 |
| 設定保存 | なし | あり |
| モジュール化 | なし | ModuleScript対応 |
| コード行数 | ~100行 | ~1200行 |

---

## 🚀 今後の拡張案

### 実装可能な追加機能

1. **RemoteEvents統合**
   ```lua
   -- サーバー側ダメージ処理
   local RemoteEvent = game.ReplicatedStorage.DamageEvent
   RemoteEvent:FireServer(target, damage)
   ```

2. **DataStore統合**
   ```lua
   -- 設定の永続化
   local DataStoreService = game:GetService("DataStoreService")
   local settingsStore = DataStoreService:GetDataStore("CombatSettings")
   ```

3. **チーム検出強化**
   ```lua
   function IsEnemy(player1, player2)
       return player1.Team ~= player2.Team
   end
   ```

4. **武器検出**
   ```lua
   function GetEquippedWeapon(character)
       return character:FindFirstChildOfClass("Tool")
   end
   ```

5. **オートパリィ (近接戦闘)**
   ```lua
   function AutoParry()
       -- 攻撃タイミングを検出してパリィ
   end
   ```

---

## 📝 ライセンスと注意事項

### ⚠️ 重要な注意事項
- このコードは**教育目的**のみで提供されています
- 公式ゲームでの使用はサービス規約違反になる可能性があります
- 使用は**自己責任**でお願いします
- アカウントBANのリスクを理解した上で使用してください

### 推奨使用環境
- プライベートサーバー
- テスト環境
- 自作ゲーム
- 学習目的

---

## 📞 サポート

### よくある質問
Q: 検出されますか?
A: Silent Aimと命中確率調整で検出リスクを軽減できますが、完全ではありません。

Q: すべてのゲームで動作しますか?
A: FPS/TPS系のゲームであれば基本的に動作しますが、ゲームごとに調整が必要な場合があります。

Q: ModuleScriptとどちらを使うべきですか?
A: 簡単に使いたい場合は通常版、カスタマイズしたい場合はModuleScript版を推奨します。

### 改善リクエスト
機能追加や改善の提案がある場合は、コメントでお知らせください。

---

**作成者: endr**  
**バージョン: 3.0**  
**最終更新: 2026年2月**  

---

**元のGLuaコードからの完全リメイクが完了しました! 🎉**
