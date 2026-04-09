-- =============================================
--  Auto Private Server Rejoin Script (2026)
--  Security Kick + WiFi Drop Handler
--  GitHub Style - Config at the top
-- =============================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ================== CONFIG ==================
-- Change these values only:

local PS_SHARE_LINK = "https://www.roblox.com/share?code=24f26a509c0fa34db33a24b1b3d6e7f0&type=Server"

local INTERVAL_SECONDS = 300    -- Rejoin every 5 minutes (recommended)
                                 -- 180 = 3 min, 600 = 10 min, etc.

local START_DELAY = 12           -- Seconds to wait after joining before starting the timer
-- ===========================================

-- Extract private server code
local privateServerCode = PS_SHARE_LINK:match("code=([^&]+)")
if not privateServerCode then
    error("❌ Failed to extract private server code from link!")
end

print("✅ Auto PS Rejoin Loaded")
print("   Private Server Code:", privateServerCode)
print("   Rejoin Interval:", INTERVAL_SECONDS, "seconds")

local function rejoinPS()
    print("🚀 Attempting to rejoin your private server...")

    -- Primary method (most stable)
    local success, err = pcall(function()
        TeleportService:TeleportToPrivateServer(game.PlaceId, privateServerCode, {player})
    end)

    if not success then
        warn("Primary teleport failed:", err)
        
        -- Fallback 1: Share link method
        task.wait(1)
        pcall(function()
            TeleportService:TeleportToPrivateServerFromLink(PS_SHARE_LINK, {player})
        end)
        
        -- Fallback 2: Normal game teleport
        task.wait(2)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    else
        print("✅ Teleport request sent successfully")
    end
end

-- Timed rejoin loop
task.spawn(function()
    task.wait(START_DELAY)
    while true do
        task.wait(INTERVAL_SECONDS)
        rejoinPS()
    end
end)

-- Strong security kick detection
task.spawn(function()
    while true do
        task.wait(1)
        local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
        if promptGui and promptGui:FindFirstChild("Prompt") and promptGui.Prompt.Visible then
            print("⚠️ Kick/Security prompt detected! Rejoining in 3 seconds...")
            task.wait(3)
            rejoinPS()
        end
    end
end)

-- Extra safety
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        print("PlayerRemoving detected → Rejoining")
        task.wait(2)
        rejoinPS()
    end
end)

print("✅ Script is fully active with security kick protection.")
