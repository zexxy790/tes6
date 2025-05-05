-- Dead Rails Auto Farm Script
-- Features: Auto Kill, Auto Collect, Auto Rebirth

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Player Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local DeadRailsUI = Instance.new("ScreenGui")
DeadRailsUI.Name = "DeadRailsAutoFarm"
DeadRailsUI.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.Parent = DeadRailsUI

local Title = Instance.new("TextLabel")
Title.Text = "DEAD RAILS AUTO FARM"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Toggle Buttons
local AutoKillToggle = Instance.new("TextButton")
AutoKillToggle.Text = "AUTO KILL: OFF"
AutoKillToggle.Size = UDim2.new(0.8, 0, 0, 35)
AutoKillToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
AutoKillToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
AutoKillToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoKillToggle.Font = Enum.Font.Gotham
AutoKillToggle.Parent = MainFrame

local AutoCollectToggle = Instance.new("TextButton")
AutoCollectToggle.Text = "AUTO COLLECT: OFF"
AutoCollectToggle.Size = UDim2.new(0.8, 0, 0, 35)
AutoCollectToggle.Position = UDim2.new(0.1, 0, 0.4, 0)
AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
AutoCollectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoCollectToggle.Font = Enum.Font.Gotham
AutoCollectToggle.Parent = MainFrame

local AutoRebirthToggle = Instance.new("TextButton")
AutoRebirthToggle.Text = "AUTO REBIRTH: OFF"
AutoRebirthToggle.Size = UDim2.new(0.8, 0, 0, 35)
AutoRebirthToggle.Position = UDim2.new(0.1, 0, 0.6, 0)
AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
AutoRebirthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRebirthToggle.Font = Enum.Font.Gotham
AutoRebirthToggle.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Ready"
StatusLabel.Size = UDim2.new(0.8, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

-- Variables
local autoKill = false
local autoCollect = false
local autoRebirth = false
local connections = {}

-- Functions
local function findNearestEnemy()
    local closest = nil
    local dist = math.huge
    
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyPos = enemy.HumanoidRootPart.Position
            local myPos = HumanoidRootPart.Position
            local distance = (enemyPos - myPos).Magnitude
            
            if distance < dist then
                closest = enemy
                dist = distance
            end
        end
    end
    
    return closest
end

local function attackEnemy(enemy)
    if enemy and enemy:FindFirstChild("HumanoidRootPart") then
        -- Teleport to enemy
        HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        -- Simulate attack
        VirtualInputManager:SendKeyEvent(true, "R", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "R", false, game)
    end
end

local function collectDrops()
    for _, drop in pairs(Workspace:GetChildren()) do
        if drop.Name == "Drop" and drop:FindFirstChild("TouchInterest") then
            firetouchinterest(HumanoidRootPart, drop, 0)
            firetouchinterest(HumanoidRootPart, drop, 1)
        end
    end
end

local function findRebirthButton()
    for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and (gui.Text:lower():find("rebirth") or gui.Name:lower():find("rebirth")) then
            return gui
        end
    end
    return nil
end

local function performRebirth()
    local rebirthButton = findRebirthButton()
    if rebirthButton then
        rebirthButton:FireServer()
        return true
    end
    return false
end

-- Auto Kill Function
local function startAutoKill()
    autoKill = true
    AutoKillToggle.Text = "AUTO KILL: ON"
    AutoKillToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    connections.autoKill = game:GetService("RunService").Heartbeat:Connect(function()
        local enemy = findNearestEnemy()
        if enemy then
            attackEnemy(enemy)
        end
    end)
end

local function stopAutoKill()
    autoKill = false
    AutoKillToggle.Text = "AUTO KILL: OFF"
    AutoKillToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    
    if connections.autoKill then
        connections.autoKill:Disconnect()
        connections.autoKill = nil
    end
end

-- Auto Collect Function
local function startAutoCollect()
    autoCollect = true
    AutoCollectToggle.Text = "AUTO COLLECT: ON"
    AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    connections.autoCollect = game:GetService("RunService").Heartbeat:Connect(function()
        collectDrops()
    end)
end

local function stopAutoCollect()
    autoCollect = false
    AutoCollectToggle.Text = "AUTO COLLECT: OFF"
    AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    
    if connections.autoCollect then
        connections.autoCollect:Disconnect()
        connections.autoCollect = nil
    end
end

-- Auto Rebirth Function
local function startAutoRebirth()
    autoRebirth = true
    AutoRebirthToggle.Text = "AUTO REBIRTH: ON"
    AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    connections.autoRebirth = game:GetService("RunService").Heartbeat:Connect(function()
        performRebirth()
    end)
end

local function stopAutoRebirth()
    autoRebirth = false
    AutoRebirthToggle.Text = "AUTO REBIRTH: OFF"
    AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    
    if connections.autoRebirth then
        connections.autoRebirth:Disconnect()
        connections.autoRebirth = nil
    end
end

-- Button Events
AutoKillToggle.MouseButton1Click:Connect(function()
    if autoKill then
        stopAutoKill()
    else
        startAutoKill()
    end
end)

AutoCollectToggle.MouseButton1Click:Connect(function()
    if autoCollect then
        stopAutoCollect()
    else
        startAutoCollect()
    end
end)

AutoRebirthToggle.MouseButton1Click:Connect(function()
    if autoRebirth then
        stopAutoRebirth()
    else
        startAutoRebirth()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    stopAutoKill()
    stopAutoCollect()
    stopAutoRebirth()
    DeadRailsUI:Destroy()
end)

-- Drag Functionality
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Character Handling
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

StatusLabel.Text = "Status: Initialized"
