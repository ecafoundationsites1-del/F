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

-- 열화상 효과 설정 (초기 상태는 무조건 false)
local thermalEffect = Lighting:FindFirstChild("ECA_Thermal") or Instance.new("ColorCorrectionEffect")
thermalEffect.Name = "ECA_Thermal"
thermalEffect.Brightness = 0.2
thermalEffect.Contrast = 0.8
thermalEffect.Saturation = -1 
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-------------------------------------------------------
-- [추가된 기능: 환경 색상 & ESP]
-------------------------------------------------------

-- 맵 전체 블럭 랜덤 색상화
local function ApplyRandomColors()
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
                    obj.Color = (math.random(1, 2) == 1) and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end

-- 실시간 플레이어 테두리 갱신 (버그 수정: Highlight 강제 생성 및 활성화)
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("ECA_ESP")
            
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ECA_ESP"
                highlight.Parent = char
            end
            
            -- visionEnabled 값에 따라 동기화
            highlight.Enabled = visionEnabled
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.4
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-------------------------------------------------------
-- [기존 UI 및 밴/로딩 로직] ----------------------------
-------------------------------------------------------

-- 기존 UI 청소
for _, v in pairs(playerGui:GetChildren()) do
    if v.Name == uiName or v.Name == "LoadingScreen_ECA" or v.Name == "ECA_MainMenu" or v.Name == "ECA_Transition" or v.Name == "ECA_Banned_System" then
        v:Destroy()
    end
end

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
    banText.Text = "ACCESS DENIED"
    banText.TextColor3 = Color3.fromRGB(255, 0, 0)
    banText.TextSize = 60
    banText.Font = Enum.Font.SourceSansBold
    banText.BackgroundTransparency = 1
end

local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.DisplayOrder = 20000

    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", mainFrame)

    local toggle = Instance.new("TextButton", mainFrame)
    toggle.Size = UDim2.new(0, 250, 0, 60)
    toggle.Position = UDim2.new(0.27, 0, 0.4, 0) -- 위치 살짝 조정
    toggle.Text = "열화상 & 벽뚫: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 20
    Instance.new("UICorner", toggle)

    toggle.MouseButton1Click:Connect(function()
        visionEnabled = not visionEnabled
        thermalEffect.Enabled = visionEnabled -- 변수와 효과 일치시킴
        
        if visionEnabled then
            toggle.Text = "열화상 & 벽뚫: ON"
            toggle.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
            
            ApplyRandomColors()
            
            task.spawn(function()
                while visionEnabled do 
                    UpdateESP() 
                    task.wait(0.5) 
                end
            end)
        else
            toggle.Text = "열화상 & 벽뚫: OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            
            -- OFF 시 모든 ESP 즉시 끄기
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ECA_ESP") then 
                    p.Character.ECA_ESP.Enabled = false 
                end
            end
        end
    end)
end

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
        TweenService:Create(p, TweenInfo.new(0.7), {Position = targets[i]}):Play()
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
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.7, 0, 0, 40)
    input.Position = UDim2.new(0.15, 0, 0.65, 0)
    input.PlaceholderText = "ECA-9123 입력..."
    input.Text = "" -- 텍스트 초기화
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.7, 0, 0, 40)
    btn.Position = UDim2.new(0.15, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    btn.Text = "인증하기"
    
    btn.MouseButton1Click:Connect(function()
        if input.Text == correctKey then
            mainGui:Destroy()
            PlayMergeAnimation()
        end
    end)
end

local function startLoading()
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then ShowBanScreen() return end
    end
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "LoadingScreen_ECA"
    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    local status = Instance.new("TextLabel", bg)
    status.Size = UDim2.new(1, 0, 0, 50)
    status.Position = UDim2.new(0, 0, 0.5, 0)
    status.TextColor3 = Color3.fromRGB(0, 255, 127)
    status.Text = "Loading ECA V4..."
    task.wait(2)
    screenGui:Destroy()
    LoadMainHub()
end

-- 실행 시작
startLoading()

