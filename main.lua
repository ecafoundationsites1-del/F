local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")

-- [0] 키 리스트 및 상태 관리 (서버 내 공유를 위해 StringValue 등을 활용할 수 있으나, 여기선 스크립트 변수로 처리)
-- ※ 주의: 이 방식은 해당 '게임 서버' 내에서만 유효합니다.
local keyDatabase = {
	["KEY-1234"] = {used = false},
	["KEY-ABCD"] = {used = false},
	["GUEST-999"] = {used = false},
	["HELLO-2026"] = {used = false}
}

-- [1] 메인 UI 생성
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyHub"
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

-- [3] 메인 창
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

-- 닫기 버튼
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainFrame

-- [4] 최소화된 버튼
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 50, 0, 50)
minBtn.Position = UDim2.new(0, 10, 0.5, -25)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.Text = "OPEN"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Visible = false
minBtn.Parent = screenGui
makeDraggable(minBtn)

-- [5] 키 시스템 UI
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0.4, 0)
keyBox.PlaceholderText = "키를 입력하세요 (중복 사용 불가)"
keyBox.Text = ""
keyBox.Parent = mainFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.4, 0, 0, 30)
submitBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
submitBtn.Text = "인증하기"
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
submitBtn.TextColor3 = Color3.new(1, 1, 1)
submitBtn.Parent = mainFrame

--- 로직 처리 ---

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	minBtn.Visible = true
end)

minBtn.MouseButton1Click:Connect(function()
	minBtn.Visible = false
	mainFrame.Visible = true
end)

-- 키 인증 로직
submitBtn.MouseButton1Click:Connect(function()
	local enteredKey = keyBox.Text
	local keyData = keyDatabase[enteredKey]

	if keyData then
		if keyData.used == false then
			-- [성공] 키가 존재하고 사용되지 않음
			keyData.used = true -- 사용됨으로 표시
			print(enteredKey .. " 인증 성공! 이제 이 키는 사용할 수 없습니다.")
			
			submitBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			submitBtn.Text = "인증 성공!"
			
			task.wait(1.5)
			-- 여기에 실제 허브 기능 활성화 코드 작성
			-- mainFrame:Destroy() -- 인증 후 창을 닫으려면 사용
		else
			-- [실패] 이미 사용된 키
			submitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			submitBtn.Text = "이미 사용된 키입니다!"
			task.wait(1.5)
			submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			submitBtn.Text = "인증하기"
		end
	else
		-- [실패] 존재하지 않는 키
		submitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		submitBtn.Text = "잘못된 키입니다!"
		task.wait(1.5)
		submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		submitBtn.Text = "인증하기"
	end
end)
