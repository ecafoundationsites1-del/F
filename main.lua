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
-- [1. 안티치트 우회 시스템 (Bypass Logic)]
-------------------------------------------------------
local function AntiCheatBypass()
    local gmt = getrawmetatable(game)
    if not gmt then return end -- 환경에 따라 nil일 수 있음
    
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Ban") or tostring(self):find("Cheat")) then
            return nil
        end
        return oldNamecall(self, unpack(args))
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
-- [2. 메인 결과 UI 생성 (하얀 창 및 이미지)]
-------------------------------------------------------
local function LoadMainHub()
    -- 특정 플레이어 제외 (WORPLAYTIMEEXP)
    if lp.Name == "WORPLAYTIMEEXP" then 
        print("특정 플레이어 제외로 인해 UI를 생성하지 않습니다.")
        return 
    end

    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName

    local resultFrame = Instance.new("Frame", mainGui)
    resultFrame.Size = UDim2.new(0, 400, 0, 400)
    resultFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    resultFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 하얀 창
    resultFrame.BorderSizePixel = 0
    
    -- 모서리 둥글게 (선택 사항)
    local corner = Instance.new("UICorner", resultFrame)
    corner.CornerRadius = UDim.new(0, 10)

    local resultImage = Instance.new("ImageLabel", resultFrame)
    resultImage.Size = UDim2.new(0.8, 0, 0.8, 0)
    resultImage.Position = UDim2.new(0.1, 0, 0.1, 0)
    resultImage.BackgroundTransparency = 1
    resultImage.Image = "rbxassetid://74935234571734" -- 요청하신 이미지 ID
    resultImage.ScaleType = Enum.ScaleType.Fit
end

-------------------------------------------------------
-- [3. 로딩 UI 생성]
-------------------------------------------------------
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "LoadingScreen_ECA"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 180)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 127)
stroke.Thickness = 1.5

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
        {0.4, "안티치트 시그니처 우회 중... (Namecall Hook)"},
        {0.6, "메타테이블 보호막 생성 중..."},
        {0.8, "환경 변수 무결성 체크 우회 중..."},
        {1.0, "준비 완료! 허브를 불러옵니다."}
    }

    -- 우회 로직 실행
    pcall(AntiCheatBypass)

    for _, step in ipairs(steps) do
        loadingBar:TweenSize(UDim2.new(step[1], 0, 1, 0), "Out", "Quad", 1.2)
        statusText.Text = step[2]
        task.wait(1.4) 
    end

    task.wait(0.5)
    screenGui:Destroy()
    
    -- 하얀 창 및 이미지 로드
    LoadMainHub()
end

task.spawn(startLoading)
이거 로딩소요시간얼마
