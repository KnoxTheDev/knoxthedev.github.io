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
local guiOpen = true

-----------------------------------------------------------
-- QUEUE SCRIPT ON TELEPORT (Unlimited Persistence)
-----------------------------------------------------------
local function reloadScript()
    if type(queue_on_teleport) == "function" then
        queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/KnoxTheDev/knoxthedev.github.io/refs/heads/main/roblox/serverhop.lua"))()]])
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
-- MAIN FRAME (Main GUI)
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
        for _, server in ipairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceID, server.id, localPlayer)
                return
            end
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
-- CREATE SEPARATE TOGGLE FRAME
-----------------------------------------------------------
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 60, 0, 60)
toggleFrame.Position = UDim2.new(0.05, 0, 0.85, 0) -- Bottom-left corner
toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame.BackgroundTransparency = 0.2
toggleFrame.Parent = screenGui

local toggleUICorner = Instance.new("UICorner")
toggleUICorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
toggleUICorner.Parent = toggleFrame

-----------------------------------------------------------
-- CREATE BIG TOGGLE BUTTON INSIDE FRAME
-----------------------------------------------------------
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 0.5
toggleBtn.Text = "≡"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 30
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = toggleFrame

-----------------------------------------------------------
-- TOGGLE GUI OPEN/CLOSE FUNCTION (Smooth Tween)
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

toggleBtn.MouseButton1Click:Connect(toggleGUI)

-----------------------------------------------------------
-- MAKE TOGGLE FRAME DRAGGABLE
-----------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    toggleFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

toggleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)
