-- 서비스 및 로컬 변수
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

-- 열화상 효과 설정
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-- [추가된 기능: 환경 ESP 함수] ------------------------------------
local function UpdateEnvironmentESP()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character) then
            -- 플레이어 캐릭터 내부의 파트가 아닌 경우만 처리
            local isPlayerPart = false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and obj:IsDescendantOf(p.Character) then
                    isPlayerPart = true
                    break
                end
            end

            if not isPlayerPart then
                -- 1. 이름이 "Water"인 경우 -> 빨간색
                if obj.Name == "Water" then
                    obj.Color = Color3.fromRGB(255, 0, 0)
                else
                    -- 2. 그 외 일반 파트 -> 노랑/빨강 랜덤
                    local rand = math.random(1, 2)
                    if rand == 1 then
                        obj.Color = Color3.fromRGB(255, 255, 0) -- 노랑
                    else
                        obj.Color = Color3.fromRGB(255, 0, 0) -- 빨강
                    end
                end
            end
        end
    end
end

-- ESP(벽뚫 테두리) 함수 수정
local function UpdateESP()
    -- 1. 플레이어 ESP (기존 기능)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local highlight = player.Character:FindFirstChild("ECA_ESP")
            if not highlight then
                highlight = Instance.new("Highlight", player.Character)
                highlight.Name = "ECA_ESP"
            end
            highlight.Enabled = visionEnabled
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end

    -- 2. 환경(Water 및 일반 파트) 색상 변경 (추가 기능)
    if visionEnabled then
        UpdateEnvironmentESP()
    end
end

-- 기존 UI 청소 (생략: 기존 코드와 동일)
for _, v in pairs(playerGui:GetChildren()) do
    if v.Name == uiName or v.Name == "LoadingScreen_ECA" or v.Name == "ECA_MainMenu" or v.Name == "ECA_Transition" or v.Name == "ECA_Banned_System" then
        v:Destroy()
    end
end

-------------------------------------------------------
-- [2. 밴 전용 화면 표시 함수] (기존과 동일)
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
    banImg.Image = "rbxassetid://92988766959361" 
    banImg.ImageColor3 = Color3.fromRGB(255, 0, 0)
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
-- [3. 메인 사이드바 메뉴] (기존 유지)
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
                while visionEnabled do 
                    UpdateESP() 
                    task.wait(1.5) -- 부하 방지를 위해 주기 조절
                end
                -- OFF 시 복구 로직 (옵션: 원래 색상 저장 기능이 없으므로 필요시 추가 구현)
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("ECA_ESP") then 
                        p.Character.ECA_ESP.Enabled = false 
                    end
                end
            end)
        else
            toggle.Text = "열화상 & 벽뚫: OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            thermalEffect.Enabled = false
        end
    end)
end

-- [4, 5, 6 단계 및 실행부는 기존 코드와 동일하여 생략합니다...]
-- (기존의 PlayMergeAnimation, LoadMainHub, startLoading 함수를 그대로 사용하세요)
startLoading()

