local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")

-- [1] 메인 UI 생성
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- [2] 드래그 기능 함수 (재사용 가능)
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

-- [3] 메인 창 (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

-- 닫기 버튼 (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainFrame

-- [4] 최소화된 버튼 (Small UI)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 50, 0, 50)
minBtn.Position = UDim2.new(0, 10, 0.5, -25)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.Text = "OPEN"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Visible = false
minBtn.Parent = screenGui
makeDraggable(minBtn)

-- [5] 키 시스템 UI (Main Frame 내부에 생성)
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0.4, 0)
keyBox.PlaceholderText = "여기에 키를 입력하세요..."
keyBox.Text = ""
keyBox.Parent = mainFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.4, 0, 0, 30)
submitBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
submitBtn.Text = "인증하기"
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
submitBtn.Parent = mainFrame

--- 로직 처리 ---

-- X 버튼 누를 때: 메인 숨기고 작은 UI 표시
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	minBtn.Visible = true
end)

-- 작은 UI 누를 때: 다시 메인 표시
minBtn.MouseButton1Click:Connect(function()
	minBtn.Visible = false
	mainFrame.Visible = true
end)

-- 키 인증 로직 (예시)
submitBtn.MouseButton1Click:Connect(function()
	local enteredKey = keyBox.Text
	-- 실제 구현 시 HttpService를 통해 서버의 키값과 비교해야 함
	if enteredKey == "TEST-KEY-123" then
		print("인증 성공!")
		submitBtn.Text = "성공!"
		task.wait(1)
		-- 여기에 허브의 실제 기능(스크립트 실행 등) 추가
	else
		submitBtn.Text = "틀린 키입니다!"
		task.wait(1)
		submitBtn.Text = "인증하기"
	end
end)

