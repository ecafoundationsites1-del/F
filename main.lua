-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [기존 UI 제거]
local uiName = "ECA_V4_Final_Fixed"
local oldGui = gethui():FindFirstChild(uiName) or game:GetService("CoreGui"):FindFirstChild(uiName)
if oldGui then oldGui:Destroy() end

-------------------------------------------------------
-- [1. 안티치트 우회 시스템] (기존 로직 유지)
-------------------------------------------------------
local function AntiCheatBypass()
    local gmt = getrawmetatable(game)
    if not gmt then return end 
    
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Ban") or tostring(self):find("Cheat")) then
            return nil
        end
        return oldNamecall(self, unpack({...}))
    end)
    
    local oldIndex = gmt.__index
    gmt.__index = newcclosure(function(t, k)
        if not checkcaller() and t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
            if k == "WalkSpeed" then return 16 end
            if k == "JumpPower" then return 50 end
        end
        return oldIndex(t, k)
    end)
    
    setreadonly(gmt, true)
end

-------------------------------------------------------
-- [2. 메인 허브 및 키 시스템 UI]
-------------------------------------------------------
local function LoadMainHub()
    if lp.Name == "WORPLAYTIMEEXP" then return end

    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName

    -- 메인 프레임 (하얀 창)
    local resultFrame = Instance.new("Frame", mainGui)
    resultFrame.Size = UDim2.new(0, 400, 0, 450) -- 키 시스템 공간을 위해 높이 조절
    resultFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    resultFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultFrame.BorderSizePixel = 0
    Instance.new("UICorner", resultFrame).CornerRadius = UDim.new(0, 10)

    -- 상단 이미지
    local resultImage = Instance.new("ImageLabel", resultFrame)
    resultImage.Size = UDim2.new(0, 320, 0, 240)
    resultImage.Position = UDim2.new(0.5, -160, 0.05, 0)
    resultImage.BackgroundTransparency = 1
    resultImage.Image = "rbxassetid://74935234571734"
    resultImage.ScaleType = Enum.ScaleType.Fit

    -- [키 시스템 UI 요소]
    local correctKey = "ECA-9123"

    local keyInput = Instance.new("TextBox", resultFrame)
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(0.7, 0, 0, 40)
    keyInput.Position = UDim2.new(0.15, 0, 0.65, 0)
    keyInput.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    keyInput.PlaceholderText = "여기에 키를 입력하세요..."
    keyInput.Text = ""
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 18
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 5)

    local submitBtn = Instance.new("TextButton", resultFrame)
    submitBtn.Size = UDim2.new(0.7, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.15, 0, 0.78, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    submitBtn.Text = "인증하기"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.SourceSansBold
    submitBtn.TextSize = 20
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 5)

    local infoText = Instance.new("TextLabel", resultFrame)
    infoText.Size = UDim2.new(1, 0, 0, 30)
    infoText.Position = UDim2.new(0, 0, 0.9, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "키를 기다리는 중..."
    infoText.TextColor3 = Color3.fromRGB(100, 100, 100)
    infoText.Font = Enum.Font.SourceSansItalic
    infoText.TextSize = 14

    -- 키 검증 로직
    submitBtn.MouseButton1Click:Connect(function()
        if keyInput.Text == correctKey then
            infoText.Text = "✅ 인증 성공! 시스템을 활성화합니다."
            infoText.TextColor3 = Color3.fromRGB(0, 180, 0)
            task.wait(1)
            -- 여기에 인증 후 실행될 기능을 추가하세요.
            print("Access Granted.")
        else
            infoText.Text = "❌ 잘못된 키입니다. 다시 확인해주세요."
            infoText.TextColor3 = Color3.fromRGB(255, 0, 0)
            keyInput.Text = ""
        end
    end)
end

-------------------------------------------------------
-- [3. 로딩 UI 생성] (기존 로직 유지)
-------------------------------------------------------
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

-------------------------------------------------------
-- [4. 순차적 실행]
-------------------------------------------------------
local function startLoading()
    local steps = {
        {0.2, "보안 프로토콜 분석 중..."},
        {0.4, "안티치트 시그니처 우회 중..."},
        {0.8, "환경 변수 무결성 체크 우회 중..."},
        {1.0, "준비 완료!"}
    }

    pcall(AntiCheatBypass)

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

