-- Auto RPS Menu (Exploit-Ready)
-- Parent to CoreGui or StarterGui
-- Automatically counters opponent's Rock-Paper-Scissors move

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Replace with your actual RemoteEvent
local RPSRemote = ReplicatedStorage:WaitForChild("RockPaperScissorsEvent")

-- ---------- GUI ----------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoRPSMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- CoreGui if exploit

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Text = "Auto RPS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame

local autoRPS = false
ToggleButton.MouseButton1Click:Connect(function()
	autoRPS = not autoRPS
	ToggleButton.Text = autoRPS and "ON" or "OFF"
end)

-- ---------- Logic ----------
local function getWinningMove(opponentMove)
	if opponentMove == "Rock" then
		return "Paper"
	elseif opponentMove == "Paper" then
		return "Scissors"
	elseif opponentMove == "Scissors" then
		return "Rock"
	end
end

-- Table to store last move from each player
local opponentMoves = {}

-- Exploit-specific: Hook __namecall to detect opponent move
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	-- Check if someone is sending their RPS move
	if method == "FireServer" and self == RPSRemote then
		local player = args[1] -- some remotes send player first
		local move = args[2] -- assume second argument is move
		if player and player ~= LocalPlayer then
			opponentMoves[player] = move -- store opponent move
		end
	end
	
	return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Hook FireServer to automatically counter
local oldFireServer = RPSRemote.FireServer
RPSRemote.FireServer = newcclosure(function(self, move, ...)
	if autoRPS then
		-- Pick first detected opponent move
		for player, oppMove in pairs(opponentMoves) do
			if player and oppMove then
				move = getWinningMove(oppMove)
				break
			end
		end
	end
	return oldFireServer(self, move, ...)
end)

-- Optional: GUI drag
local dragging, dragInput, dragStart, startPos
local UserInputService = game:GetService("UserInputService")

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
