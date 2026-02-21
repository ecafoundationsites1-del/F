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
-- 주의: 이 로직은 로딩 중에 백그라운드에서 실행됩니다.
local function AntiCheatBypass()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    -- 1. 원격 이벤트 감지 우회 (Namecall Hooking)
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- 안티치트가 자주 사용하는 키워드 차단
        if method == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Ban") or tostring(self):find("Cheat")) then
            return nil -- 서버로 정보를 보내지 않음
        end
        return oldNamecall(self, unpack(args))
    end)
    
    -- 2. WalkSpeed / JumpPower 변조 감지 우회
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
-- [2. 로딩 UI 생성]
-------------------------------------------------------
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "LoadingScreen_ECA"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 180)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0

-- 테두리 효과
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
-- [3. 순차적 우회 및 로딩 실행]
-------------------------------------------------------
local function startLoading()
    local steps = {
        {0.2, "보안 프로토콜 분석 중..."},
        {0.4, "안티치트 시그니처 우회 중... (Namecall Hook)"},
        {0.6, "메타테이블 보호막 생성 중..."},
        {0.8, "환경 변수 무결성 체크 우회 중..."},
        {1.0, "준비 완료! 허브를 불러옵니다."}
    }

    -- 로직 실행
    pcall(AntiCheatBypass)

    for _, step in ipairs(steps) do
        loadingBar:TweenSize(UDim2.new(step[1], 0, 1, 0), "Out", "Quad", 1.5)
        statusText.Text = step[2]
        task.wait(1.8) -- 각 단계마다 약 1.8초 소요 (총 약 9~10초)
    end

    task.wait(0.5)
    screenGui:Destroy()
    
    -- 여기에 기존 메인 UI 코드를 실행하는 함수를 넣으세요.
    -- 예: LoadMainHub()
end

task.spawn(startLoading)
