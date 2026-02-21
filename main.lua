-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 차단 리스트] -----------------------------------------
local uiName = "ECA_V4_Final_Fixed"
local Blacklist = {
    "EOQY8", -- 차단 대상
}
local correctKey = "ECA-9123" -- 인증 키

-- 기존 UI 제거 함수
local function ClearOldUI()
    local names = {uiName, "LoadingScreen_ECA", "ECA_Banned_System", "ECA_Transition", "ECA_MainMenu"}
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
    -- WORPLAYTIMEEXP 유저는 밴 리스트에 있어도 통과
    if lp.Name == "WORPLAYTIMEEXP" then return end

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
    banImage.Image = "rbxassetid://124813723172494"
    banImage.ScaleType = Enum.ScaleType.Fit

    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 50)
    banText.Position = UDim2.new(0, 0, 0.8, 0)
    banText.BackgroundTransparency = 1
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 40
    banText.Font = Enum.Font.SourceSansBold
    banText.Text = "ACCESS DENIED"
end

-------------------------------------------------------
-- [3. 메인 기능 화면 (합체 연출 후 나타날 실제 UI)]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.DisplayOrder = 20000 -- 연출용 검은 칸보다 위에 뜨도록 설정
    
    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "ECA V4 PREMIUM"
    title.TextColor3 = Color3.fromRGB(0, 255, 127)
    title.BackgroundTransparency = 1
    title.TextSize = 22
    title.Font = Enum.Font.SourceSansBold
    
    local desc = Instance.new("TextLabel", mainFrame)
    desc.Size = UDim2.new(1, 0, 0, 100)
    desc.Position = UDim2.new(0, 0, 0.4, 0)
    desc.Text = "인증 성공!\n사용자: " .. lp.Name
    desc.TextColor3 = Color3.fromRGB(255, 255, 255)
    desc.BackgroundTransparency = 1
    desc.TextSize = 18
end

-------------------------------------------------------
-- [4. 인증 성공 시: 4개 칸 합체 연출]
-------------------------------------------------------
local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui)
    transGui.Name = "ECA_Transition"
    transGui.DisplayOrder = 15000 -- 인증창보다는 위, 메인메뉴보다는 아래
    transGui.IgnoreGuiInset = true

    local pieces = {}
    local startPositions = {
        UDim2.new(-0.5, 0, -0.5, 0), UDim2.new(1.5, 0, -0.5, 0),
        UDim2.new(-0.5, 0, 1.5, 0), UDim2.new(1.5, 0, 1.5, 0)
    }
    local targetPositions = {
        UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0, 0),
        UDim2.new(0, 0, 0.5, 0), UDim2.new(0.5, 0, 0.5, 0)
    }

    for i = 1, 4 do
        local p = Instance.new("Frame", transGui)
        p.Size = UDim2.new(0.5, 0, 0.5, 0)
        p.Position = startPositions[i]
        p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        p.BorderSizePixel = 0
        pieces[i] = p
    end

    for i = 1, 4 do
        TweenService:Create(pieces[i], TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPositions[i]
        }):Play()
    end
    
    task.wait(0.8)
    
    -- 칸이 다 모였을 때 메인 메뉴 미리 생성
    LoadActualMenu()
    
    task.wait(0.2)
    
    -- 검은 조각들 서서히 사라짐
    for i = 1, 4 do
        TweenService:Create(pieces[i], TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    end
    task.wait(0.5)
    transGui:Destroy()
end

-------------------------------------------------------
-- [5. 메인 허브 (인증창)]
-------------------------------------------------------
local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    mainGui.DisplayOrder = 10000

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

    local keyInput = Instance.new("TextBox", resultFrame)
    keyInput.Size = UDim2.new(0.7, 0, 0, 40)
    keyInput.Position = UDim2.new(0.15, 0, 0.65, 0)
    keyInput.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    keyInput.PlaceholderText = "ECA-9123 입력..."
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

    submitBtn.MouseButton1Click:Connect(function()
        -- [공백 제거 로직: 앞뒤 공백만 제거하여 키 비교]
        local cleanKey = keyInput.Text:match("^%s*(.-)%s*$") 
        
        if cleanKey == correctKey then
            mainGui:Destroy() -- 인증창 삭제
            PlayMergeAnimation() -- 연출 시작
        else
            keyInput.Text = "" -- 틀리면 입력창 비우기 (무반응)
        end
    end)
end

-------------------------------------------------------
-- [6. 로딩 UI 및 실행 제어]
-------------------------------------------------------
local function startLoading()
    local banned = false
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then
            banned = true
            break
        end
    end

    if banned and lp.Name ~= "WORPLAYTIMEEXP" then
        ShowBannedScreen()
        return 
    end

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
    logo.Image = "rbxassetid://129650208804431"

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

