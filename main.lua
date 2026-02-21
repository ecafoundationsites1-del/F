-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 차단 리스트] -----------------------------------------
local uiName = "ECA_V4_Final_Fixed"
local Blacklist = { "EOQY8" }
local correctKey = "ECA-9123"

-- [2. 기능 관련 변수] ---------------------------------------------
local visionEnabled = false
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-- ESP 업데이트 함수 (초록 테두리 + 벽 투과)
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local highlight = player.Character:FindFirstChild("ECA_ESP")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ECA_ESP"
                highlight.Parent = player.Character
            end
            highlight.Enabled = visionEnabled
            highlight.FillTransparency = 0.8
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

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
-- [3. 메인 기능 화면 (사이드바 메뉴)]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.DisplayOrder = 20000 -- 연출보다 위에 뜨도록 설정
    
    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    -- 사이드바
    local sideBar = Instance.new("Frame", mainFrame)
    sideBar.Size = UDim2.new(0, 150, 1, 0)
    sideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    sideBar.BorderSizePixel = 0
    Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 10)

    local titleLabel = Instance.new("TextLabel", sideBar)
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Text = "ECA V4 PREMIUM"
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.BackgroundTransparency = 1

    -- 시야 메뉴 탭 (사이드바 버튼)
    local visionTabBtn = Instance.new("TextButton", sideBar)
    visionTabBtn.Size = UDim2.new(0.9, 0, 0, 40)
    visionTabBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    visionTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    visionTabBtn.Text = "시야 (Vision)"
    visionTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    visionTabBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", visionTabBtn)

    -- 기능 토글 버튼 (메인 영역)
    local toggleBtn = Instance.new("TextButton", mainFrame)
    toggleBtn.Size = UDim2.new(0, 250, 0, 60)
    toggleBtn.Position = UDim2.new(0.45, 0, 0.4, 0) -- 사이드바 옆 중앙 배치
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggleBtn.Text = "열화상 & 벽뚫: OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 20
    toggleBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", toggleBtn)

    toggleBtn.MouseButton1Click:Connect(function()
        visionEnabled = not visionEnabled
        if visionEnabled then
            toggleBtn.Text = "열화상 & 벽뚫: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            thermalEffect.Enabled = true
            task.spawn(function()
                while visionEnabled do
                    UpdateESP()
                    task.wait(1)
                end
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Character and v.Character:FindFirstChild("ECA_ESP") then
                        v.Character.ECA_ESP.Enabled = false
                    end
                end
            end)
        else
            toggleBtn.Text = "열화상 & 벽뚫: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            thermalEffect.Enabled = false
        end
    end)
end

-------------------------------------------------------
-- [4. 인증 성공 시: 4개 칸 합체 연출]
-------------------------------------------------------
local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui)
    transGui.Name = "ECA_Transition"
    transGui.DisplayOrder = 15000
    transGui.IgnoreGuiInset = true

    local pieces = {}
    local startPos = {UDim2.new(-0.5, 0, -0.5, 0), UDim2.new(1.5, 0, -0.5, 0), UDim2.new(-0.5, 0, 1.5, 0), UDim2.new(1.5, 0, 1.5, 0)}
    local targetPos = {UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0, 0), UDim2.new(0, 0, 0.5, 0), UDim2.new(0.5, 0, 0.5, 0)}

    for i = 1, 4 do
        local p = Instance.new("Frame", transGui)
        p.Size = UDim2.new(0.5, 0, 0.5, 0)
        p.Position = startPos[i]
        p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        p.BorderSizePixel = 0
        pieces[i] = p
    end

    for i = 1, 4 do
        TweenService:Create(pieces[i], TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos[i]}):Play()
    end
    
    task.wait(0.8)
    LoadActualMenu() -- 사이드바 메뉴 호출
    task.wait(0.2)
    
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
        local cleanKey = keyInput.Text:match("^%s*(.-)%s*$") 
        if cleanKey == correctKey then
            mainGui:Destroy() -- 인증창 삭제
            PlayMergeAnimation() -- 연출 후 메뉴로 연결
        else
            keyInput.Text = ""
        end
    end)
end

-------------------------------------------------------
-- [6. 로딩 UI 및 실행 제어]
-------------------------------------------------------
local function startLoading()
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) and lp.Name ~= "WORPLAYTIMEEXP" then
            local bannedGui = Instance.new("ScreenGui", playerGui)
            bannedGui.IgnoreGuiInset = true
            local bg = Instance.new("Frame", bannedGui)
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            local banText = Instance.new("TextLabel", bg)
            banText.Size = UDim2.new(1, 0, 0, 50)
            banText.Position = UDim2.new(0, 0, 0.5, -25)
            banText.Text = "ACCESS DENIED"
            banText.TextColor3 = Color3.fromRGB(255, 0, 0)
            banText.TextSize = 50
            return 
        end
    end

    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 420, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 127)

    local loadingBar = Instance.new("Frame", mainFrame)
    loadingBar.Size = UDim2.new(0, 0, 0, 8)
    loadingBar.Position = UDim2.new(0.1, 0, 0.7, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

    loadingBar:TweenSize(UDim2.new(0.8, 0, 0, 8), "Out", "Quad", 2)
    task.wait(2.2)
    screenGui:Destroy()
    LoadMainHub()
end

task.spawn(startLoading)

