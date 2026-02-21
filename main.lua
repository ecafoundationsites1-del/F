-- [서비스 및 로컬 변수]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 변수] -----------------------------------------------
local uiName = "ECA_V4_Complete_Edition"
local Blacklist = { "EOQY8" }
local correctKey = "ECA-9123"
local visionEnabled = false

-- 팀 관련 상태 변수
local currentTeamName = nil
local isTeamLeader = false

-- 열화상 효과 설정
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-------------------------------------------------------
-- [기능 함수들]
-------------------------------------------------------

-- 환경 색상 변경
local function UpdateEnvironmentColors()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local isCharacterPart = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and obj:IsDescendantOf(player.Character) then
                    isCharacterPart = true
                    break
                end
            end
            if not isCharacterPart then
                if obj.Name == "Water" then
                    obj.Color = Color3.fromRGB(255, 0, 0)
                else
                    local rand = math.random(1, 2)
                    obj.Color = (rand == 1) and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end

-- ESP 업데이트
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
    if visionEnabled then UpdateEnvironmentColors() end
end

-- 무전기 하단 메시지 UI
local function ShowRadioMessage(senderName, message)
    local radioGui = playerGui:FindFirstChild("ECA_RadioDisplay")
    if not radioGui then
        radioGui = Instance.new("ScreenGui", playerGui)
        radioGui.Name = "ECA_RadioDisplay"
    end

    local msgFrame = Instance.new("Frame", radioGui)
    msgFrame.Size = UDim2.new(0, 350, 0, 45)
    msgFrame.Position = UDim2.new(0.5, -175, 1, 10) -- 시작 위치 (밑으로 숨김)
    msgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    msgFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", msgFrame)
    local stroke = Instance.new("UIStroke", msgFrame)
    stroke.Color = Color3.fromRGB(0, 255, 127)
    stroke.Thickness = 1.5

    local txt = Instance.new("TextLabel", msgFrame)
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "<b>[RADIO] " .. senderName .. "</b>: " .. message
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextSize = 16
    txt.RichText = true
    txt.Font = Enum.Font.SourceSans
    txt.TextXAlignment = Enum.TextXAlignment.Left

    -- 등장 애니메이션
    msgFrame:TweenPosition(UDim2.new(0.5, -175, 0.85, 0), "Out", "Back", 0.5, true)
    
    task.delay(4, function()
        msgFrame:TweenPosition(UDim2.new(0.5, -175, 1, 10), "In", "Sine", 0.5, true, function()
            msgFrame:Destroy()
        end)
    end)
end

-- 채팅 감지 로직
lp.Chatted:Connect(function(msg)
    if currentTeamName and msg:sub(1, 6) == "/team " then
        local actualMsg = msg:sub(7)
        if actualMsg ~= "" then
            ShowRadioMessage(lp.Name, actualMsg)
        end
    end
end)

-------------------------------------------------------
-- [2. 밴 화면]
-------------------------------------------------------
local function ShowBanScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.Name = "ECA_Banned_System"
    bannedGui.IgnoreGuiInset = true
    bannedGui.DisplayOrder = 99999

    local bg = Instance.new("Frame", bannedGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 0, 0)

    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 50)
    banText.Position = UDim2.new(0, 0, 0.5, -25)
    banText.Text = "ACCESS DENIED\nBLACKISTED"
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 50
    banText.Font = Enum.Font.SourceSansBold
    banText.BackgroundTransparency = 1
end

-------------------------------------------------------
-- [3. 메인 메뉴 (사이드바 + 무전기)]
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

    -- 사이드바
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

    -- 컨텐츠 영역 부모
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1, -160, 1, -20)
    contentFrame.Position = UDim2.new(0, 155, 0, 10)
    contentFrame.BackgroundTransparency = 1

    -- [페이지 1: 비주얼]
    local visualPage = Instance.new("Frame", contentFrame)
    visualPage.Size = UDim2.new(1, 0, 1, 0)
    visualPage.BackgroundTransparency = 1
    visualPage.Visible = true

    local toggle = Instance.new("TextButton", visualPage)
    toggle.Size = UDim2.new(0, 250, 0, 60)
    toggle.Position = UDim2.new(0.5, -125, 0.4, -30)
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

    -- [페이지 2: 무전기]
    local radioPage = Instance.new("Frame", contentFrame)
    radioPage.Size = UDim2.new(1, 0, 1, 0)
    radioPage.BackgroundTransparency = 1
    radioPage.Visible = false

    local teamBox = Instance.new("TextBox", radioPage)
    teamBox.Size = UDim2.new(0.8, 0, 0, 40)
    teamBox.Position = UDim2.new(0.1, 0, 0.2, 0)
    teamBox.PlaceholderText = "팀 이름을 입력하세요..."
    teamBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    teamBox.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", teamBox)

    local makeBtn = Instance.new("TextButton", radioPage)
    makeBtn.Size = UDim2.new(0.8, 0, 0, 45)
    makeBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
    makeBtn.Text = "팀 만들기 (라디오 활성화)"
    makeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    makeBtn.TextColor3 = Color3.new(1,1,1)
    makeBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", makeBtn)

    local statusLbl = Instance.new("TextLabel", radioPage)
    statusLbl.Size = UDim2.new(1, 0, 0, 30)
    statusLbl.Position = UDim2.new(0, 0, 0.7, 0)
    statusLbl.Text = "현재 소속된 팀 없음"
    statusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLbl.BackgroundTransparency = 1

    makeBtn.MouseButton1Click:Connect(function()
        if teamBox.Text ~= "" then
            currentTeamName = teamBox.Text
            isTeamLeader = true
            statusLbl.Text = "활성화 팀: " .. currentTeamName .. " (팀장)"
            statusLbl.TextColor3 = Color3.fromRGB(0, 255, 127)
            makeBtn.Text = "팀 생성됨"
            makeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)

    -- 사이드바 전환 버튼들
    local btnVisual = Instance.new("TextButton", sideBar)
    btnVisual.Size = UDim2.new(1, -10, 0, 40)
    btnVisual.Position = UDim2.new(0, 5, 0, 60)
    btnVisual.Text = "Visuals"
    btnVisual.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btnVisual.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnVisual)

    local btnRadio = Instance.new("TextButton", sideBar)
    btnRadio.Size = UDim2.new(1, -10, 0, 40)
    btnRadio.Position = UDim2.new(0, 5, 0, 105)
    btnRadio.Text = "Radio Team"
    btnRadio.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btnRadio.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnRadio)

    btnVisual.MouseButton1Click:Connect(function()
        visualPage.Visible = true
        radioPage.Visible = false
    end)

    btnRadio.MouseButton1Click:Connect(function()
        visualPage.Visible = false
        radioPage.Visible = true
    end)
end

-------------------------------------------------------
-- [기존 연출 및 로딩 로직 유지]
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

local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    mainGui.DisplayOrder = 10000

    local frame = Instance.new("Frame", mainGui)
    frame.Size = UDim2.new(0, 400, 0, 450)
    frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", frame)

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
        if input.Text:match("^%s*(.-)%s*$") == correctKey then
            mainGui:Destroy()
            PlayMergeAnimation()
        else
            input.Text = ""
        end
    end)
end

local function startLoading()
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then
            ShowBanScreen()
            return 
        end
    end

    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"
    screenGui.IgnoreGuiInset = true

    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)

    local barBg = Instance.new("Frame", bg)
    barBg.Size = UDim2.new(0.4, 0, 0, 4)
    barBg.Position = UDim2.new(0.3, 0, 0.5, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

    task.spawn(function()
        bar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 3)
        task.wait(3.2)
        screenGui:Destroy()
        LoadMainHub()
    end)
end

startLoading()

