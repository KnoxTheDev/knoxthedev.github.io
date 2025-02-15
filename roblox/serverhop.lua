--// SERVICES
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

--- Rejoins the current server the player is in.
-- @function rejoinCurrentServer
-- @usage rejoinCurrentServer()
local function rejoinCurrentServer()
    print("[ServerHop] Rejoining current server...")
    TeleportService:Teleport(game.PlaceId, localPlayer)
end

--- Finds and teleports the player to a truly random public server.
-- Excludes the current server to prevent joining the same one.
-- @function hopRandomServer
-- @usage hopRandomServer()
local function hopRandomServer()
    print("[ServerHop] Searching for a new server...")

    local serverList = {} -- Stores available servers
    local cursor = "" -- Cursor for paginated requests

    --- Fetches public servers from Roblox's API.
    -- @return table List of servers
    local function fetchServers()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            cursor = result.nextPageCursor or ""
            return result.data
        end
        return {}
    end

    --- Finds a valid server that is not the current one and teleports the player.
    local function findNewServer()
        while true do
            local servers = fetchServers()

            for _, server in ipairs(servers) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    print("[ServerHop] Found new server:", server.id)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)
                    return
                end
            end

            -- If no valid server is found, retry
            if cursor == "" then
                warn("[ServerHop] No new servers found. Retrying...")
                break
            end
            task.wait(1)
        end
    end

    findNewServer()
end

return {
    rejoinCurrentServer = rejoinCurrentServer,
    hopRandomServer = hopRandomServer
}
