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
-- TOGGLE BUTTON HOLDER (Draggable)
-----------------------------------------------------------
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 130, 0, 50)
toggleFrame.Position = UDim2.new(0.5, -65, 0, 5) -- Centered top
toggleFrame.BackgroundTransparency = 1
toggleFrame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "⚙️ Toggle GUI"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = toggleFrame

local uiCornerToggle = Instance.new("UICorner")
uiCornerToggle.CornerRadius = UDim.new(0, 10)
uiCornerToggle.Parent = toggleButton

-----------------------------------------------------------
-- MAIN GUI FRAME (Draggable)
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
-- BUTTONS
-----------------------------------------------------------

local function createButton(name, text, position)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = mainFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = btn

    return btn
end

local rejoinBtn = createButton("RejoinButton", "Rejoin Server", UDim2.new(0.1, 0, 0.35, 0))
local randomBtn = createButton("RandomButton", "Random Server", UDim2.new(0.1, 0, 0.65, 0))

-----------------------------------------------------------
-- DRAG FUNCTION (Smooth & Natural)
-----------------------------------------------------------
local function makeDraggable(frame)
    local dragging, dragStart, startPos, dragInput

    local function update(input)
        local delta = input.Position - dragStart
        local tween = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        })
        tween:Play()
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleFrame)

-----------------------------------------------------------
-- TOGGLE GUI
-----------------------------------------------------------
local function toggleGUI()
    guiOpen = not guiOpen
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {Position = guiOpen and UDim2.new(0.5, -150, 0.5, -75) or UDim2.new(0.5, -150, -1, -150)}
    local tween = TweenService:Create(mainFrame, tweenInfo, goal)
    tween:Play()
end

toggleButton.MouseButton1Click:Connect(toggleGUI)

-----------------------------------------------------------
-- SERVER HOPPING LOGIC
-----------------------------------------------------------
local function rejoinCurrentServer()
    rejoinBtn.Text = "Rejoining..."
    TeleportService:Teleport(PlaceID, localPlayer)
end

local function hopRandomServer()
    randomBtn.Text = "Searching..."
    local URL = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'
    local Servers = HttpService:JSONDecode(game:HttpGet(URL))

    for _, v in ipairs(Servers.data) do
        if v.id ~= currentJobId then
            TeleportService:TeleportToPlaceInstance(PlaceID, v.id, localPlayer)
            return
        end
    end

    randomBtn.Text = "No Servers Found"
    wait(2)
    randomBtn.Text = "Random Server"
end

-----------------------------------------------------------
-- BUTTON EVENTS
-----------------------------------------------------------
rejoinBtn.MouseButton1Click:Connect(rejoinCurrentServer)
randomBtn.MouseButton1Click:Connect(function()
    task.spawn(hopRandomServer)
end)
