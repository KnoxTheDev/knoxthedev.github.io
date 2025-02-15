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
local currentJobId = game.JobId
local guiOpen = true

-----------------------------------------------------------
-- PERSISTENCE: QUEUE SCRIPT ON TELEPORT
-----------------------------------------------------------
local function reloadScript()
    if type(queue_on_teleport) == "function" then
        queue_on_teleport([[loadstring(game:HttpGet("https://knoxthedev.github.io/roblox/serverhopgui.lua"))()]])
    end
end
reloadScript()

-----------------------------------------------------------
-- CREATE SCREEN GUI
-----------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerHopGui"
screenGui.Parent = game:GetService("CoreGui")

-----------------------------------------------------------
-- TRANSPARENT FRAME FOR TOGGLE BUTTON
-----------------------------------------------------------
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(1, 0, 0, 50) -- Thin top bar
toggleFrame.Position = UDim2.new(0, 0, 0, 5) -- Small padding from top
toggleFrame.BackgroundTransparency = 1
toggleFrame.Parent = screenGui

-----------------------------------------------------------
-- TOGGLE BUTTON (Sleek AMOLED Dark Style)
-----------------------------------------------------------
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 120, 0, 40) -- Rectangular button
toggleButton.Position = UDim2.new(0.5, -60, 0, 5) -- Centered top with padding
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- AMOLED dark
toggleButton.BorderSizePixel = 0
toggleButton.Text = "⚙️ Toggle GUI"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = toggleFrame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = toggleButton

-----------------------------------------------------------
-- MAIN GUI FRAME
-----------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 10)
mainUICorner.Parent = mainFrame

-----------------------------------------------------------
-- TITLE LABEL
-----------------------------------------------------------
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hopper"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Parent = mainFrame

-----------------------------------------------------------
-- FUNCTION TO CREATE BUTTONS
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
    button.Visible = true -- Ensure visibility for tweening

    button.MouseButton1Click:Connect(function()
        local originalText = button.Text
        button.Text = "⏳ Teleporting..."
        task.spawn(function()
            callback()
            task.wait(1)
            button.Text = originalText
        end)
    end)

    return button
end

-----------------------------------------------------------
-- SERVER HOP FUNCTIONS
-----------------------------------------------------------
local function rejoinCurrentServer()
    TeleportService:Teleport(PlaceID, localPlayer)
end

local function hopRandomServer()
    local servers, cursor
    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end
        local data = HttpService:JSONDecode(game:HttpGet(url))
        servers = data.data
        cursor = data.nextPageCursor
        local availableServers = {}

        -- Filter out current server and gather all valid servers
        for _, server in ipairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(availableServers, server.id)
            end
        end

        -- Randomly pick a valid server
        if #availableServers > 0 then
            local randomServer = availableServers[math.random(1, #availableServers)]
            TeleportService:TeleportToPlaceInstance(PlaceID, randomServer, localPlayer)
            return
        end
        task.wait(0.5) -- Prevent rate limiting
    until not cursor
end

-----------------------------------------------------------
-- CREATE HOP BUTTONS
-----------------------------------------------------------
local rejoinBtn = createButton("RejoinButton", "Rejoin Server", UDim2.new(0.1, 0, 0.35, 0), rejoinCurrentServer)
local randomBtn = createButton("RandomButton", "Random Server", UDim2.new(0.1, 0, 0.65, 0), hopRandomServer)

-----------------------------------------------------------
-- TOGGLE GUI FUNCTION (Smooth Animation)
-----------------------------------------------------------
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function toggleGUI()
    guiOpen = not guiOpen

    if guiOpen then
        -- Expand GUI and Show Buttons
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 150), BackgroundTransparency = 0.1})
        tween:Play()

        -- Show Buttons with Animation
        rejoinBtn.Visible = true
        randomBtn.Visible = true

    else
        -- Hide Buttons First
        rejoinBtn.Visible = false
        randomBtn.Visible = false

        -- Shrink GUI
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        tween:Play()
    end
end

-----------------------------------------------------------
-- BUTTON CLICK EVENT
-----------------------------------------------------------
toggleButton.MouseButton1Click:Connect(toggleGUI)

-----------------------------------------------------------
-- DONE! GUI NOW TOGGLES WITH A SEPARATE BUTTON
-----------------------------------------------------------
