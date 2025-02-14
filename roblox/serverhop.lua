if getgenv().ServerHopGuiLoaded then
    return
end
getgenv().ServerHopGuiLoaded = true

-----------------------------------------------------------
-- SERVICES & VARIABLES
-----------------------------------------------------------
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId

-----------------------------------------------------------
-- FUNCTION TO RELOAD SCRIPT ON TELEPORT (Unlimited Persistence)
-----------------------------------------------------------
local function reloadScript()
    if type(queue_on_teleport) == "function" then
        queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/KnoxTheDev/knoxthedev.github.io/refs/heads/main/roblox/serverhop.lua"))()]])
    end
end

-- Immediately queue the script on teleport to ensure it persists.
reloadScript()

-----------------------------------------------------------
-- CREATE SCREEN GUI (Parented to CoreGui for Full Persistence)
-----------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerHopGui"
screenGui.Parent = game:GetService("CoreGui")

-----------------------------------------------------------
-- MAIN FRAME (Dark Mode UI)
-----------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-----------------------------------------------------------
-- TITLE LABEL
-----------------------------------------------------------
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hopping"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Parent = mainFrame

-----------------------------------------------------------
-- BUTTONS: REJOIN & SERVER HOP
-----------------------------------------------------------
local function createButton(name, text, pos, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = pos
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = mainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

local function rejoinCurrentServer()
    TeleportService:Teleport(PlaceID, localPlayer)
end

local function hopRandomServer()
    local servers = HttpService:JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)))
    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, localPlayer)
            return
        end
    end
end

createButton("RejoinButton", "Rejoin Server", UDim2.new(0.1, 0, 0.35, 0), rejoinCurrentServer)
createButton("RandomButton", "Random Server", UDim2.new(0.1, 0, 0.65, 0), hopRandomServer)

-----------------------------------------------------------
-- MAKE GUI DRAGGABLE
-----------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)
