-- UI 생성 및 초기 설정
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.Parent = playerGui

-- 메인 프레임 (검은색 중앙 UI)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 200) -- 적당한 크기
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100) -- 화면 중앙
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- 좌측 상단 이미지 (ID: 129650208804431)
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 50, 0, 50) -- 이미지 크기
logo.Position = UDim2.new(0, 5, 0, 5) -- 왼쪽 위 살짝 여백
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://129650208804431"
logo.Parent = mainFrame

-- 로딩바 배경
local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(0.8, 0, 0, 10)
loadingBg.Position = UDim2.new(0.1, 0, 0.6, 0)
loadingBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loadingBg.Parent = mainFrame

-- 실제 움직이는 로딩바
local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127) -- 로딩바 색상 (녹색계열)
loadingBar.BorderSizePixel = 0
loadingBar.Parent = loadingBg

-- 하단 작은 글씨 (안티치트 우회중....)
local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0, 20)
loadingText.Position = UDim2.new(0, 0, 1, 5)
loadingText.BackgroundTransparency = 1
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.TextSize = 12
loadingText.Text = "안티치트 우회중...."
loadingText.Parent = loadingBg

--- 로딩 애니메이션 및 로직 ---

task.wait(1) -- 시작 전 잠깐 대기

-- 로딩바 채우기 (3초 동안 실행)
loadingBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 3)

task.wait(3.5) -- 로딩 완료 후 대기

-- UI 사라짐
screenGui:Destroy()

