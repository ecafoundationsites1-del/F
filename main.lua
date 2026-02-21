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
    menuGui.DisplayOrder = 20000
    
    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
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

    local toggleBtn = Instance.new("TextButton", mainFrame)
    toggleBtn.Size = UDim2.new(0, 250, 0, 60)
    toggleBtn.Position = UDim2.new(0.45, 0, 0.4, 0)
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
                while visionEnabled do UpdateESP() task.wait(1) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Character and v.Character:FindFirstChild("ECA_ESP") then v.Character.ECA_ESP.Enabled = false end
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
-- [4. 인증 연출 및 허브]
-------------------------------------------------------
local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui)
    transGui.Name = "ECA_Transition"
    transGui.IgnoreGuiInset = true
    local pieces = {}
    local targets = {UDim2.new(0,0,0,0), UDim2.new(0.5,0,0,0), UDim2.new(0,0,0.5,0), UDim2.new(0.5,0,0.5,0)}

    for i = 1, 4 do
        local p = Instance.new("Frame", transGui)
        p.Size = UDim2.new(0.5, 0, 0.5, 0)
        p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        p.Position = UDim2.new(i % 2 == 0 and 1.5 or -0.5, 0, i > 2 and 1.5 or -0.5, 0)
        pieces[i] = p
        TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = targets[i]}):Play()
    end
    task.wait(0.8)
    LoadActualMenu()
    for i = 1, 4 do TweenService:Create(pieces[i], TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play() end
    task.wait(0.5)
    transGui:Destroy()
end

local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    local frame = Instance.new("Frame", mainGui)
    frame.Size = UDim2.new(0, 400, 0, 450)
    frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", frame)

    local resultImage = Instance.new("ImageLabel", frame)
    resultImage.Size = UDim2.new(0, 320, 0, 240)
    resultImage.Position = UDim2.new(0.5, -160, 0.05, 0)
    resultImage.Image = "rbxassetid://74935234571734"
    resultImage.BackgroundTransparency = 1

    local keyInput = Instance.new("TextBox", frame)
    keyInput.Size = UDim2.new(0.7, 0, 0, 40)
    keyInput.Position = UDim2.new(0.15, 0, 0.65, 0)
    keyInput.PlaceholderText = "ECA-9123 입력..."
    keyInput.Text = ""

    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.Size = UDim2.new(0.7, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.15, 0, 0.78, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    submitBtn.Text = "인증하기"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    submitBtn.MouseButton1Click:Connect(function()
        if keyInput.Text:match("^%s*(.-)%s*$") == correctKey then
            mainGui:Destroy()
            PlayMergeAnimation()
        else
            keyInput.Text = ""
        end
    end)
end

-------------------------------------------------------
-- [6. 로딩 UI (보강 버전)]
-------------------------------------------------------
local function startLoading()
    -- 블랙리스트 체크
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) and lp.Name ~= "WORPLAYTIMEEXP" then return end
    end

    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"
    screenGui.IgnoreGuiInset = true

    -- 전체 배경
    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

    -- 중앙 로딩 프레임
    local mainFrame = Instance.new("Frame", bg)
    mainFrame.Size = UDim2.new(0, 450, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 127)

    -- 로고 이미지 (인증창 이미지와 동일하게 사용)
    local logo = Instance.new("ImageLabel", mainFrame)
    logo.Size = UDim2.new(0, 120, 0, 120)
    logo.Position = UDim2.new(0.5, -60, 0.1, 0)
    logo.Image = "rbxassetid://74935234571734"
    logo.BackgroundTransparency = 1

    -- 버전/이름 텍스트
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0.6, 0)
    title.Text = "ECA V4 SYSTEM INITIALIZING..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.BackgroundTransparency = 1

    -- 상태 메시지
    local status = Instance.new("TextLabel", mainFrame)
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.72, 0)
    status.Text = "Checking Server..."
    status.TextColor3 = Color3.fromRGB(0, 255, 127)
    status.Font = Enum.Font.SourceSansItalic
    status.TextSize = 14
    status.BackgroundTransparency = 1

    -- 로딩 바 배경
    local barBg = Instance.new("Frame", mainFrame)
    barBg.Size = UDim2.new(0.8, 0, 0, 6)
    barBg.Position = UDim2.new(0.1, 0, 0.85, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg)

    -- 로딩 바 (움직이는 부분)
    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar)

    -- 로딩 시뮬레이션
    task.spawn(function()
        local msgs = {"Loading Assets...", "Syncing Database...", "Bypassing Anticheat...", "Ready!"}
        for i, m in ipairs(msgs) do
            status.Text = m
            bar:TweenSize(UDim2.new(i/4, 0, 1, 0), "Out", "Quad", 0.5)
            task.wait(0.6)
        end
        task.wait(0.2)
        screenGui:Destroy()
        LoadMainHub()
    end)
end

task.spawn(startLoading)

