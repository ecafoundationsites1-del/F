-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 차단 리스트] -----------------------------------------
local uiName = "ECA_V4_Final_Fixed"
local Blacklist = {
    "EOQY8", -- 차단 대상
}

-- 기존 UI 제거
local function ClearOldUI()
    local names = {uiName, "LoadingScreen_ECA", "ECA_Banned_System"}
    for _, name in pairs(names) do
        local old = playerGui:FindFirstChild(name)
        if old then old:Destroy() end
    end
end
ClearOldUI()

-------------------------------------------------------
-- [2. 차단 시스템 UI]
-------------------------------------------------------
local function ShowBannedScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.Name = "ECA_Banned_System"
    bannedGui.DisplayOrder = 99999
    bannedGui.IgnoreGuiInset = true

    local bg = Instance.new("Frame", bannedGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.Active = true

    local banImage = Instance.new("ImageLabel", bg)
    banImage.Size = UDim2.new(0, 500, 0, 500)
    banImage.Position = UDim2.new(0.5, -250, 0.45, -250)
    banImage.BackgroundTransparency = 1
    banImage.Image = "rbxassetid://124813723172494" -- 요청하신 차단 이미지
    banImage.ScaleType = Enum.ScaleType.Fit

    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 50)
    banText.Position = UDim2.new(0, 0, 0.8, 0)
    banText.BackgroundTransparency = 1
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 40
    banText.Font = Enum.Font.SourceSansBold
    banText.Text = "ACCESS DENIED: YOU ARE BANNED"
end

-------------------------------------------------------
-- [3. 메인 허브 (인증창)]
-------------------------------------------------------
local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName

    local resultFrame = Instance.new("Frame", mainGui)
    resultFrame.Size = UDim2.new(0, 400, 0, 450)
    resultFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    resultFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", resultFrame).CornerRadius = UDim.new(0, 10)

    local resultImage = Instance.new("ImageLabel", resultFrame)
    resultImage.Size = UDim2.new(0, 320, 0, 240)
    resultImage.Position = UDim2.new(0.5, -160, 0.05, 0)
    resultImage.BackgroundTransparency = 1
    resultImage.Image = "rbxassetid://74935234571734"
    resultImage.ScaleType = Enum.ScaleType.Fit

    local correctKey = "ECA-9123"
    local keyInput = Instance.new("TextBox", resultFrame)
    keyInput.Size = UDim2.new(0.7, 0, 0, 40)
    keyInput.Position = UDim2.new(0.15, 0, 0.65, 0)
    keyInput.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    keyInput.PlaceholderText = "여기에 키를 입력하세요..."
    keyInput.Text = ""
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 5)

    local submitBtn = Instance.new("TextButton", resultFrame)
    submitBtn.Size = UDim2.new(0.7, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.15, 0, 0.78, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    submitBtn.Text = "인증하기"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 5)

    local infoText = Instance.new("TextLabel", resultFrame)
    infoText.Size = UDim2.new(1, 0, 0, 30)
    infoText.Position = UDim2.new(0, 0, 0.9, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "키를 기다리는 중..."
    infoText.Font = Enum.Font.SourceSansItalic

    submitBtn.MouseButton1Click:Connect(function()
        if keyInput.Text == correctKey then
            infoText.Text = "✅ 인증 성공!"
            infoText.TextColor3 = Color3.fromRGB(0, 180, 0)
            task.wait(1)
            print("Access Granted.")
        else
            infoText.Text = "❌ 잘못된 키입니다."
            infoText.TextColor3 = Color3.fromRGB(255, 0, 0)
            keyInput.Text = ""
        end
    end)
end

-------------------------------------------------------
-- [4. 로딩 UI 및 실행 제어]
-------------------------------------------------------
local function startLoading()
    -- 1. 밴 체크 (최우선)
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then
            ShowBannedScreen()
            return 
        end
    end

    -- 2. 로딩 UI 생성
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 420, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 127)

    local logo = Instance.new("ImageLabel", mainFrame)
    logo.Size = UDim2.new(0, 60, 0, 60)
    logo.Position = UDim2.new(0.5, -30, 0.15, 0)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://129650208804431" -- 로고 이미지

    local loadingBg = Instance.new("Frame", mainFrame)
    loadingBg.Size = UDim2.new(0.8, 0, 0, 8)
    loadingBg.Position = UDim2.new(0.1, 0, 0.65, 0)
    loadingBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local loadingBar = Instance.new("Frame", loadingBg)
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    loadingBar.BorderSizePixel = 0

    local statusText = Instance.new("TextLabel", mainFrame)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.75, 0)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.Code
    statusText.Text = "시스템 확인 중..."

    -- 3. 로딩 단계별 실행
    local steps = {
        {0.2, "보안 프로토콜 분석 중..."},
        {0.4, "안티치트 시그니처 우회 중..."},
        {0.8, "환경 변수 무결성 체크 우회 중..."},
        {1.0, "준비 완료!"}
    }

    for _, step in ipairs(steps) do
        loadingBar:TweenSize(UDim2.new(step[1], 0, 1, 0), "Out", "Quad", 1.2)
        statusText.Text = step[2]
        task.wait(1.4) 
    end

    task.wait(0.5)
    screenGui:Destroy()
    LoadMainHub()
end

task.spawn(startLoading)
