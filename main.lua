-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 변수] -----------------------------------------------
local uiName = "ECA_V4_Complete_Edition"
local Blacklist = { "EOQY8" } -- 밴 유저 리스트
local correctKey = "ECA-9123"
local visionEnabled = false

-- 열화상 효과 설정
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-- ESP(벽뚫 테두리) 함수
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local highlight = player.Character:FindFirstChild("ECA_ESP")
            if not highlight then
                highlight = Instance.new("Highlight", player.Character)
                highlight.Name = "ECA_ESP"
            end
            highlight.Enabled = visionEnabled
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-- 기존 UI 청소
for _, v in pairs(playerGui:GetChildren()) do
    if v.Name == uiName or v.Name == "LoadingScreen_ECA" or v.Name == "ECA_MainMenu" or v.Name == "ECA_Transition" or v.Name == "ECA_Banned_System" then
        v:Destroy()
    end
end

-------------------------------------------------------
-- [2. 밴 전용 화면 표시 함수]
-------------------------------------------------------
local function ShowBanScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.Name = "ECA_Banned_System"
    bannedGui.IgnoreGuiInset = true
    bannedGui.DisplayOrder = 99999

    local bg = Instance.new("Frame", bannedGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 0, 0)

    local banImg = Instance.new("ImageLabel", bg)
    banImg.Size = UDim2.new(0, 250, 0, 250)
    banImg.Position = UDim2.new(0.5, -125, 0.4, -125)
    -- [1번째 rbxassetid: 밴 화면용]
    banImg.Image = "rbxassetid://92988766959361" 
    banImg.ImageColor3 = Color3.fromRGB(255, 0, 0) -- 빨간색 필터
    banImg.BackgroundTransparency = 1

    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 50)
    banText.Position = UDim2.new(0, 0, 0.65, 0)
    banText.Text = "ACCESS DENIED"
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 60
    banText.Font = Enum.Font.SourceSansBold
    banText.BackgroundTransparency = 1
    
    local subText = Instance.new("TextLabel", bg)
    subText.Size = UDim2.new(1, 0, 0, 30)
    subText.Position = UDim2.new(0, 0, 0.75, 0)
    subText.Text = "YOU ARE PERMANENTLY BLACKLISTED"
    subText.TextColor3 = Color3.fromRGB(150, 150, 150)
    subText.TextSize = 20
    subText.Font = Enum.Font.SourceSans
    subText.BackgroundTransparency = 1
end

-------------------------------------------------------
-- [3. 메인 사이드바 메뉴]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.DisplayOrder = 20000

    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", mainFrame)

    local sideBar = Instance.new("Frame", mainFrame)
    sideBar.Size = UDim2.new(0, 150, 1, 0)
    sideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", sideBar)

    local title = Instance.new("TextLabel", sideBar)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "ECA V4 PREMIUM"
    title.TextColor3 = Color3.fromRGB(0, 255, 127)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1

    local toggle = Instance.new("TextButton", mainFrame)
    toggle.Size = UDim2.new(0, 250, 0, 60)
    toggle.Position = UDim2.new(0.45, 0, 0.4, 0)
    toggle.Text = "열화상 & 벽뚫: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 20
    Instance.new("UICorner", toggle)

    toggle.MouseButton1Click:Connect(function()
        visionEnabled = not visionEnabled
        if visionEnabled then
            toggle.Text = "열화상 & 벽뚫: ON"
            toggle.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
            thermalEffect.Enabled = true
            task.spawn(function()
                while visionEnabled do UpdateESP() task.wait(1) end
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("ECA_ESP") then p.Character.ECA_ESP.Enabled = false end
                end
            end)
        else
            toggle.Text = "열화상 & 벽뚫: OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            thermalEffect.Enabled = false
        end
    end)
end

-------------------------------------------------------
-- [4. 인증 성공 시 합체 연출]
-------------------------------------------------------
local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui)
    transGui.Name = "ECA_Transition"
    transGui.IgnoreGuiInset = true
    transGui.DisplayOrder = 15000

    local pieces = {}
    local targets = {UDim2.new(0,0,0,0), UDim2.new(0.5,0,0,0), UDim2.new(0,0,0.5,0), UDim2.new(0.5,0,0.5,0)}

    for i = 1, 4 do
        local p = Instance.new("Frame", transGui)
        p.Size = UDim2.new(0.5, 0, 0.5, 0)
        p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        p.BorderSizePixel = 0
        p.Position = UDim2.new(i % 2 == 0 and 1.5 or -0.5, 0, i > 2 and 1.5 or -0.5, 0)
        pieces[i] = p
        TweenService:Create(p, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targets[i]}):Play()
    end
    
    task.wait(0.8)
    LoadActualMenu()
    
    for i = 1, 4 do TweenService:Create(pieces[i], TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play() end
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

    local frame = Instance.new("Frame", mainGui)
    frame.Size = UDim2.new(0, 400, 0, 450)
    frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", frame)

    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(0, 320, 0, 240)
    img.Position = UDim2.new(0.5, -160, 0.05, 0)
    -- [2번째 rbxassetid: 인증창용]
    img.Image = "rbxassetid://74935234571734" 
    img.BackgroundTransparency = 1

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.7, 0, 0, 40)
    input.Position = UDim2.new(0.15, 0, 0.65, 0)
    input.PlaceholderText = "ECA-9123 입력..."
    input.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = ""

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.7, 0, 0, 40)
    btn.Position = UDim2.new(0.15, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    btn.Text = "인증하기"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold

    btn.MouseButton1Click:Connect(function()
        -- 인증 시 블랙리스트 체크 (보안 강화)
        for _, name in pairs(Blacklist) do
            if string.lower(lp.Name) == string.lower(name) then
                mainGui:Destroy()
                ShowBanScreen()
                return
            end
        end

        if input.Text:match("^%s*(.-)%s*$") == correctKey then
            mainGui:Destroy()
            PlayMergeAnimation()
        else
            input.Text = ""
        end
    end)
end

-------------------------------------------------------
-- [6. 로딩 UI 및 초기 밴 체크]
-------------------------------------------------------
local function startLoading()
    -- 초기 접속 시 블랙리스트 체크
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then
            ShowBanScreen()
            return 
        end
    end

    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 30000

    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)

    local mainFrame = Instance.new("Frame", bg)
    mainFrame.Size = UDim2.new(0, 450, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", mainFrame)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 127)

    local logo = Instance.new("ImageLabel", mainFrame)
    logo.Size = UDim2.new(0, 140, 0, 140)
    logo.Position = UDim2.new(0.5, -70, 0.05, 0)
    -- [3번째 rbxassetid: 로딩 화면용]
    logo.Image = "rbxassetid://129650208804431" 
    logo.BackgroundTransparency = 1
    logo.ZIndex = 5

    local bypassTxt = Instance.new("TextLabel", mainFrame)
    bypassTxt.Size = UDim2.new(1, 0, 0, 20)
    bypassTxt.Position = UDim2.new(0, 0, 0.55, 0)
    bypassTxt.Text = "SECURITY SYSTEM: BYPASSING..."
    bypassTxt.TextColor3 = Color3.fromRGB(255, 50, 50)
    bypassTxt.Font = Enum.Font.Code
    bypassTxt.TextSize = 14
    bypassTxt.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0.65, 0)
    title.Text = "ECA V4 PREMIUM EDITION"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.BackgroundTransparency = 1

    local status = Instance.new("TextLabel", mainFrame)
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.75, 0)
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(0, 255, 127)
    status.TextSize = 16
    status.BackgroundTransparency = 1

    local barBg = Instance.new("Frame", mainFrame)
    barBg.Size = UDim2.new(0.8, 0, 0, 4)
    barBg.Position = UDim2.new(0.1, 0, 0.9, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    bar.BorderSizePixel = 0

    task.spawn(function()
        local steps = {
            {s = "1단계 안티치트 우회중", c = Color3.fromRGB(255, 50, 50)},
            {s = "2단계 안티치트 우회 50%", c = Color3.fromRGB(255, 200, 0)},
            {s = "3단계 우회성공", c = Color3.fromRGB(0, 255, 127)},
            {s = "4단계 불러오는중......", c = Color3.fromRGB(255, 255, 255)}
        }
        for i, step in ipairs(steps) do
            status.Text = step.s
            status.TextColor3 = step.c
            bar:TweenSize(UDim2.new(i/4, 0, 1, 0), "Out", "Quad", 0.8)
            task.wait(1.2)
        end
        task.wait(0.5)
        screenGui:Destroy()
        LoadMainHub()
    end)
end

-- 실행 시작
startLoading()
