local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")

-- [0] 키 리스트 (여기에 키를 추가하세요)
local keyDatabase = {
	["KEY-1234"] = true,
	["카눈"] = true,
	["GUEST-999"] = true,
	["HELLO-2026"] = true
}

-- [1] 메인 UI 생성
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHubSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- [2] 드래그 기능 함수
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	userInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	userInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- [3] 키 인증 창 (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 200)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "KEY SYSTEM"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
keyBox.PlaceholderText = "여기에 키를 입력하세요..."
keyBox.Text = ""
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.Parent = mainFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.6, 0, 0, 40)
submitBtn.Position = UDim2.new(0.2, 0, 0.7, 0)
submitBtn.Text = "인증하기"
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
submitBtn.TextColor3 = Color3.new(1, 1, 1)
submitBtn.Parent = mainFrame

-- [4] 실제 기능 창 (Hub Frame - 처음엔 숨김)
local hubFrame = Instance.new("Frame")
hubFrame.Size = UDim2.new(0, 400, 0, 300)
hubFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
hubFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
hubFrame.Visible = false
hubFrame.Parent = screenGui
makeDraggable(hubFrame)

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, 0, 0, 50)
hubTitle.Text = "★ MAIN HUB ★"
hubTitle.TextSize = 20
hubTitle.TextColor3 = Color3.new(1, 1, 1)
hubTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hubTitle.Parent = hubFrame

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.8, 0, 0, 45)
speedBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
speedBtn.Text = "스피드 핵 (Speed 100)"
speedBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBtn.TextColor3 = Color3.new(1, 1, 1)
speedBtn.Parent = hubFrame

local closeHub = Instance.new("TextButton")
closeHub.Size = UDim2.new(0, 30, 0, 30)
closeHub.Position = UDim2.new(1, -35, 0, 5)
closeHub.Text = "X"
closeHub.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeHub.Parent = hubFrame

--- [로직 처리] ---

-- 기능창 닫기 버튼
closeHub.MouseButton1Click:Connect(function()
	hubFrame.Visible = false
end)

-- 기능 버튼 작동
speedBtn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = 100
		speedBtn.Text = "속도 적용됨!"
		task.wait(1)
		speedBtn.Text = "스피드 핵 (Speed 100)"
	end
end)

-- 키 인증 메인 로직
submitBtn.MouseButton1Click:Connect(function()
	-- 입력값에서 공백 제거 및 대문자로 변환
	local enteredKey = string.upper(string.gsub(keyBox.Text, "%s+", ""))
	
	local isCorrect = false
	-- 데이터베이스의 키들도 대문자로 비교
	for key, _ in pairs(keyDatabase) do
		if string.upper(key) == enteredKey then
			isCorrect = true
			break
		end
	end

	if isCorrect then
		submitBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		submitBtn.Text = "인증 성공!"
		task.wait(1)
		mainFrame.Visible = false
		hubFrame.Visible = true
	else
		submitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		submitBtn.Text = "잘못된 키입니다!"
		task.wait(1)
		submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		submitBtn.Text = "인증하기"
	end
end)
