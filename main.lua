-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 변수] -----------------------------------------------
local uiName = "ECA_V4_Complete_Edition"
local Blacklist = { "EOQY8" }
local correctKey = "ECA-9123"
local visionEnabled = false

-- 팀 관련 변수
local currentTeam = nil
local isLeader = false
local radioGui = nil

-- 열화상 효과 설정
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-------------------------------------------------------
-- [추가 기능: 환경 및 ESP]
-------------------------------------------------------
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

-------------------------------------------------------
-- [핵심 기능: 무전기 UI 시스템]
-------------------------------------------------------
local function ShowRadioMessage(senderName, message)
    if not radioGui then return end
    
    local msgLabel = Instance.new("TextLabel", radioGui.MainFrame.MessageArea)
    msgLabel.Size = UDim2.new(1, -10, 0, 25)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = "  [무전] " .. senderName .. " : " .. message
    msgLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Font = Enum.Font.Code
    msgLabel.TextSize = 14
    
    task.delay(5, function()
        TweenService:Create(msgLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(1)
        msgLabel:Destroy()
    end)
end

local function CreateRadioBottomUI()
    if playerGui:FindFirstChild("ECA_RadioHUD") then playerGui.ECA_RadioHUD:Destroy() end
    
    local hud = Instance.new("ScreenGui", playerGui)
    hud.Name = "ECA_RadioHUD"
    radioGui = hud
    
    local main = Instance.new("Frame", hud)
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 300, 0, 100)
    main.Position = UDim2.new(0.5, -150, 1, -120)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BackgroundTransparency = 0.3
    Instance.new("UICorner", main)
    
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Text = "RADIO SYSTEM ACTIVE - [" .. (currentTeam or "None") .. "]"
    title.TextColor3 = Color3.fromRGB(0, 255, 127)
    title.TextSize = 12
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1
    
    local area = Instance.new("ScrollingFrame", main)
    area.Name = "MessageArea"
    area.Size = UDim2.new(1, 0, 0.7, 0)
    area.Position = UDim2.new(0, 0, 0.25, 0)
    area.BackgroundTransparency = 1
    area.CanvasSize = UDim2.new(0, 0, 2, 0)
    area.ScrollBarThickness = 0
    
    local layout = Instance.new("UIListLayout", area)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    
    if not isLeader then main.Visible = false end -- 팀장만 상시 노출, 팀원은 메시지 올 때만 띄우기 가능
end

-- 채팅 감지 로직
lp.Chatted:Connect(function(msg)
    if currentTeam and msg:sub(1,6) == "/team " then
        local content = msg:sub(7)
        -- 실제 서버 통신 대용 (로컬 시뮬레이션: 본인에게 표시)
        ShowRadioMessage(lp.Name, content)
        if radioGui then radioGui.MainFrame.Visible = true end
    end
end)

-------------------------------------------------------
-- [2. 메인 메뉴 및 사이드바]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    
    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", mainFrame)

    -- [사이드바 영역]
    local sideBar = Instance.new("Frame", mainFrame)
    sideBar.Size = UDim2.new(0, 150, 1, 0)
    sideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", sideBar)

    local title = Instance.new("TextLabel", sideBar)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "ECA PREMIUM"
    title.TextColor3 = Color3.fromRGB(0, 255, 127)
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1

    -- [콘텐츠 영역]
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(0, 380, 0, 330)
    contentFrame.Position = UDim2.new(0, 160, 0, 10)
    contentFrame.BackgroundTransparency = 1

    -- 메인 기능 페이지
    local mainPage = Instance.new("Frame", contentFrame)
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    mainPage.BackgroundTransparency = 1

    local toggle = Instance.new("TextButton", mainPage)
    toggle.Size = UDim2.new(0, 250, 0, 60)
    toggle.Position = UDim2.new(0.5, -125, 0.4, -30)
    toggle.Text = "열화상 & 벽뚫: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 20
    Instance.new("UICorner", toggle)

    -- 무전기 페이지
    local radioPage = Instance.new("Frame", contentFrame)
    radioPage.Size = UDim2.new(1, 0, 1, 0)
    radioPage.BackgroundTransparency = 1
    radioPage.Visible = false

    local teamInput = Instance.new("TextBox", radioPage)
    teamInput.Size = UDim2.new(0.8, 0, 0, 40)
    teamInput.Position = UDim2.new(0.1, 0, 0.2, 0)
    teamInput.PlaceholderText = "팀 이름 입력..."
    teamInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    teamInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local createBtn = Instance.new("TextButton", radioPage)
    createBtn.Size = UDim2.new(0.8, 0, 0, 40)
    createBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
    createBtn.Text = "팀 만들기 (팀장)"
    createBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local joinBtn = Instance.new("TextButton", radioPage)
    joinBtn.Size = UDim2.new(0.8, 0, 0, 40)
    joinBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
    joinBtn.Text = "팀 가입하기"
    joinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- [사이드바 버튼 클릭 로직]
    local function createSideBtn(name, pos, page)
        local btn = Instance.new("TextButton", sideBar)
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, pos)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            mainPage.Visible = false
            radioPage.Visible = false
            page.Visible = true
        end)
    end

    createSideBtn("메인 기능", 60, mainPage)
    createSideBtn("무전기", 110, radioPage)

    -- 기능 로직
    toggle.MouseButton1Click:Connect(function()
        visionEnabled = not visionEnabled
        toggle.Text = visionEnabled and "열화상 & 벽뚫: ON" or "열화상 & 벽뚫: OFF"
        toggle.BackgroundColor3 = visionEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
        thermalEffect.Enabled = visionEnabled
        if visionEnabled then
            task.spawn(function()
                while visionEnabled do UpdateESP() task.wait(1) end
            end)
        end
    end)

    createBtn.MouseButton1Click:Connect(function()
        if teamInput.Text ~= "" then
            currentTeam = teamInput.Text
            isLeader = true
            CreateRadioBottomUI()
            createBtn.Text = "팀 생성됨: " .. currentTeam
            createBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        end
    end)

    joinBtn.MouseButton1Click:Connect(function()
        if teamInput.Text ~= "" then
            currentTeam = teamInput.Text
            isLeader = false
            CreateRadioBottomUI()
            joinBtn.Text = "팀 가입됨: " .. currentTeam
            joinBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        end
    end)
end

-------------------------------------------------------
-- [이후 코드는 기존과 동일 (인증 및 로딩)]
-------------------------------------------------------
local function ShowBanScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.Name = "ECA_Banned_System"
    bannedGui.IgnoreGuiInset = true
    local bg = Instance.new("Frame", bannedGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 50)
    banText.Position = UDim2.new(0, 0, 0.5, -25)
    banText.Text = "ACCESS DENIED - BLACKLISTED"
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 40
    banText.Font = Enum.Font.SourceSansBold
    banText.BackgroundTransparency = 1
end

local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui)
    transGui.IgnoreGuiInset = true
    for i = 1, 4 do
        local p = Instance.new("Frame", transGui)
        p.Size = UDim2.new(0.5, 0, 0.5, 0)
        p.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        p.Position = UDim2.new(i % 2 == 0 and 1 or -0.5, 0, i > 2 and 1 or -0.5, 0)
        TweenService:Create(p, TweenInfo.new(0.5), {Position = UDim2.new((i-1)%2*0.5,0, i>2 and 0.5 or 0,0)}):Play()
    end
    task.wait(0.6)
    LoadActualMenu()
    task.wait(0.2)
    transGui:Destroy()
end

local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    local frame = Instance.new("Frame", mainGui)
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", frame)
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.8, 0, 0, 40)
    input.Position = UDim2.new(0.1, 0, 0.4, 0)
    input.PlaceholderText = "KEY: ECA-9123"
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0.6, 0)
    btn.Text = "인증하기"
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

    btn.MouseButton1Click:Connect(function()
        if input.Text == correctKey then
            mainGui:Destroy()
            PlayMergeAnimation()
        end
    end)
end

-- 시작 실행
LoadMainHub()
