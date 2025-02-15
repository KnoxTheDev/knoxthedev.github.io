-- Check if the GUI is already loaded
if getgenv().KnoxyHubGuiLoaded then
    return
end
getgenv().KnoxyHubGuiLoaded = true

-- Function to create the GUI
local function createKnoxyHubGUI()
    -- Load the Rayfield library
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    -- Create the main window
    local Window = Rayfield:CreateWindow({
        Name = "KNOXY HUB",
        LoadingTitle = "KNOXY HUB Loading",
        LoadingSubtitle = "by Knoxy",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "KNOXY_HUB_Config", -- Folder to save configurations
            FileName = "KNOXY_HUB_Settings"
        },
        Discord = {
            Enabled = false,
            Invite = "", -- Discord invite code (if applicable)
            RememberJoins = true
        },
        KeySystem = false, -- Set to true if you want to use a key system
        KeySettings = {
            Title = "KNOXY HUB Key System",
            Subtitle = "Enter your key",
            Note = "Join the Discord for the key",
            FileName = "KNOXY_HUB_Key",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = {"YourKeyHere"} -- Replace with your actual key or keys
        }
    })

    -- Create a tab
    local MainTab = Window:CreateTab("Main", 4483362458) -- Tab name and optional icon

    -- Add a section to the tab
    local MainSection = MainTab:CreateSection("Server Hopping")

    -- Services
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")

    -- Player and game details
    local localPlayer = Players.LocalPlayer
    local PlaceID = game.PlaceId
    local currentJobId = game.JobId

    -- Function to rejoin the current server
    local function rejoinCurrentServer()
        TeleportService:Teleport(PlaceID, localPlayer)
    end

    -- Function to hop to a random server
    local function hopRandomServer()
        local servers = {}
        local cursor = ""
        local foundServer = false

        while not foundServer do
            local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            local response = HttpService:JSONDecode(game:HttpGet(url))

            if response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= currentJobId then
                        table.insert(servers, server.id)
                    end
                end
            end

            if response.nextPageCursor then
                cursor = response.nextPageCursor
            else
                break
            end

            task.wait(0.5) -- To prevent hitting request limits
        end

        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(PlaceID, randomServer, localPlayer)
        else
            print("No available servers found.")
        end
    end

    -- Add the "Rejoin Server" button
    MainTab:CreateButton({
        Name = "Rejoin Server",
        Info = "Reconnects you to the current server",
        Interact = 'Click',
        Callback = function()
            rejoinCurrentServer()
        end
    })

    -- Add the "Random Server" button
    MainTab:CreateButton({
        Name = "Random Server",
        Info = "Connects you to a different server",
        Interact = 'Click',
        Callback = function()
            hopRandomServer()
        end
    })
end

-- Queue the GUI creation function to run upon teleport
if syn and syn.queue_on_teleport then
    syn.queue_on_teleport([[loadstring(game:HttpGet("https://knoxthedev.github.io/roblox/loader.lua"))()]])
elseif queue_on_teleport then
    queue_on_teleport([[loadstring(game:HttpGet("https://knoxthedev.github.io/roblox/loader.lua"))()]])
else
    warn("queue_on_teleport function is not available.")
end

-- Create the GUI initially
createKnoxyHubGUI()
