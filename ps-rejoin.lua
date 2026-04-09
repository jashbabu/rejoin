-- =============================================
--  Smart Private Server Auto Rejoin (Client)
--  Built for stability & reduced errors
-- =============================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========= CONFIG =========
local PS_LINK = "https://www.roblox.com/share?code=24f26a509c0fa34db33a24b1b3d6e7f0&type=Server"

local INTERVAL = 300        -- Time between rejoins (seconds)
local START_DELAY = 15      -- Wait after join
local RETRY_DELAY = 8       -- Delay before fallback
local GLOBAL_COOLDOWN = 20  -- Prevent spam attempts
-- ==========================

local lastTeleport = 0
local isTeleporting = false

print("✅ Smart PS Rejoin Loaded")

-- ==========================
-- Smart teleport handler
-- ==========================
local function smartRejoin(reason)
    if isTeleporting then return end

    local now = tick()
    if now - lastTeleport < GLOBAL_COOLDOWN then
        print("⏳ Cooldown active, skipping teleport")
        return
    end

    isTeleporting = true
    lastTeleport = now

    print("🚀 Rejoin triggered | Reason:", reason or "Interval")

    -- Attempt private server via link
    local success = pcall(function()
        TeleportService:TeleportToPrivateServerFromLink(PS_LINK, {player})
    end)

    if success then
        print("🔗 PS link teleport requested")
    else
        warn("❌ PS link failed, retrying fallback soon...")
        
        task.wait(RETRY_DELAY)

        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)

        print("↩️ Fallback to public server")
    end

    task.wait(5)
    isTeleporting = false
end

-- ==========================
-- Interval loop
-- ==========================
task.spawn(function()
    task.wait(START_DELAY)

    while true do
        task.wait(INTERVAL)
        smartRejoin("Interval")
    end
end)

-- ==========================
-- Kick detection
-- ==========================
task.spawn(function()
    while true do
        task.wait(1)

        local gui = CoreGui:FindFirstChild("RobloxPromptGui")
        if gui and gui:FindFirstChild("Prompt") and gui.Prompt.Visible then
            print("⚠️ Kick detected")
            task.wait(2)
            smartRejoin("Kick")
        end
    end
end)

-- ==========================
-- Player leaving fallback
-- ==========================
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        task.wait(2)
        smartRejoin("Leaving")
    end
end)

print("✅ Script running (optimized mode)")
