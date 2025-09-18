--[[
    DISCLAIMER: This script is for educational purposes only for the game developer.
    It demonstrates how a cheater might exploit insecure game logic.
    This will NOT work against a server with proper authority and validation.

    Functionality: Luck Modifier / Rare Item Forcing
--]]

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // ==========================================================================================
-- // EXPLOIT LOGIC
-- // The cheat doesn't change the server's random number generation. Instead, it waits for
-- // the client to receive a result (like catching a common fish) and then lies to the server
-- // about what that result was, claiming it was a rare fish instead.
-- // ==========================================================================================

-- This exploit assumes a VULNERABLE game design where:
-- 1. The server tells the client what fish they caught (e.g., "Common Fish").
-- 2. The client is then trusted to send that information BACK to the server to be added to their inventory.

-- A cheater would find the remote event responsible for finalizing the catch.
local ReelInEvent = ReplicatedStorage:WaitForChild("FishEvents"):WaitForChild("ReelIn")

-- The ID of the rarest fish in the game. A cheater can easily find this by exploring game assets.
local MYTHICAL_FISH_ID = "156"

-- Exploiters use a function called `hookfunction` or `newcclosure` to intercept function calls.
-- Here, we're intercepting the FireServer method of the ReelInEvent.
local originalFireServer = ReelInEvent.FireServer
setreadonly(ReelInEvent, false) -- Exploits need to do this to modify the object

ReelInEvent.FireServer = newcclosure(function(remote, ...)
    local args = {...}
    
    -- The original game script would call this with the actual fish caught, e.g., FireServer("Common_Tuna")
    print("[Exploit] Intercepted ReelInEvent. Original fish:", args[1])
    
    -- THE MANIPULATION:
    -- No matter what the original fish was, we change the argument to the mythical fish ID.
    args[1] = MYTHICAL_FISH_ID
    print("[Exploit] Modified argument to:", args[1])

    -- Call the original FireServer function, but with our manipulated arguments.
    -- The server, if not properly secured, will receive this and think the player legitimately caught a mythical fish.
    return originalFireServer(remote, unpack(args))
end)

setreadonly(ReelInEvent, true)

print("[Exploit] Luck modifier is active. All caught fish will be reported as Giant Squid.")

-- Now, the cheater just needs to fish normally (or use an auto-fish bot).
-- Every time the bot or player reels in a fish, this hooked function will
-- swap the common fish for the mythical one before the server is notified.

