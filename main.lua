-- [서비스 및 변수 설정]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

local CORRECT_KEY = "ECA-1222211"
local uiName = "ECA_V4_Final_Fixed"

-- [기존 UI 제거]
local oldGui = gethui():FindFirstChild(uiName) or game:GetService("CoreGui"):FindFirstChild(uiName)
if oldGui then oldGui:Destroy() end

-------------------------------------------------------
-- [1. 안티치트 우회 시스템 (Bypass Logic)]
-------------------------------------------------------
local function AntiCheatBypass()
    local gmt = getrawmetatable(game)
    if not gmt then return end
    
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        -- 보안 관련 리모트 이벤트 차단
        if method == "FireServer" and (tostring(self):find("Check") or tostring(self):find("Ban") or tostring(self):find("Cheat")) then
            return nil
        end
        return oldNamecall(self, unpack(args))
    end)
    
    local oldIndex = gmt.__index
    gmt.__index = newcclosure(function(t, k)
        -- 감지 시도 시 기본값 반환
        if not checkcaller() and t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
            if k == "WalkSpeed" then return 16 end
            if k == "JumpPower" then return 50 end
        end
        return oldIndex(t, k)
    end)
    
    setreadonly(gmt, true)
    print("[ECA] 안티치트 우회 활성화 완료")
end

-------------------------------------------------------
-- [2. 블록 합체 애니메이션 및 최종 UI]
-------------------------------------------------------
local function FinalAssemble(parentGui)
    local screenCenter = UDim2.new(0.5, 0, 0.5, 0)
    local blocks = {}
    -- 4개 방향에서 날아올 위치
    local startPos = {
        UDim2.new(0, -150, 0, -150), -- 좌상
        UDim2.new(1, 150, 0, -150),  -- 우상
        UDim2.new(0, -150, 1, 150),  -- 좌하
        UDim2.new(1, 150, 1, 150)   -- 우하
    }

    for i = 1, 4 do
        local b = Instance.new("Frame", parentGui)
        b.Size = UDim2.new(0, 60, 0, 60)
        b.Position = startPos[i]
        b.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        b.BorderSizePixel = 0
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        table.insert(blocks, b)
        
        -- 중앙 합체 트윈
        TweenService:Create(b, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = screenCenter,
            Rotation = 450,
            Size = UDim2.new(0, 120, 0, 120),
            BackgroundTransparency = 0.5
        }):Play()
    end

    task.wait(1.2)
    for _, v in pairs(blocks) do v:Destroy() end

    -- 최종 활성화 UI (여기에 핵 메뉴를 넣으세요)
    local finalMenu = Instance.new("Frame", parentGui)
    finalMenu.Size = UDim2.new(0, 300, 0, 100)
    finalMenu.Position = screenCenter
    finalMenu.AnchorPoint = Vector2.new(0.5, 0.5)
    finalMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", finalMenu)
    
    local txt = Instance.new("TextLabel", finalMenu)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = "ECA V4 ACTIVATED"
    txt.TextColor3 = Color3.fromRGB(0, 255, 127)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 24
    txt.BackgroundTransparency = 1
end

-------------------------------------------------------
-- [3. 메인 인증 UI (하얀 창)]
-------------------------------------------------------
local function LoadMainHub()
    if lp.Name == "WORPLAYTIMEEXP" then return end

    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName

    local mainFrame = Instance.new("Frame", mainGui)
    mainFrame.Size = UDim2.new(0, 400, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

    -- 이미지
    local img = Instance.new("ImageLabel", mainFrame)
    img.Size = UDim2.new(0.7, 0, 0.5, 0)
    img.Position = UDim2.new(0.15, 0, 0.05, 0)
    img.Image = "rbxassetid://74935234571734"
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit

    -- 키 입력
    local input = Instance.new("TextBox", mainFrame)
    input.Size = UDim2.new(0.8, 0, 0, 45)
    input.Position = UDim2.new(0.1, 0, 0.65, 0)
    input.PlaceholderText = "키 코드를 입력하세요"
    input.Text = ""
    input.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    input.Font = Enum.Font.SourceSans
    input.TextSize = 20
    Instance.new("UICorner", input)

    -- 인증 버튼
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.8, 0, 0, 50)
    btn.Position = UDim2.new(0.1, 0, 0.8, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    btn.Text = "인증하기"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if input.Text == CORRECT_KEY then
            mainFrame:Destroy()
            FinalAssemble(mainGui)
        else
            btn.Text = "인증 실패!"
            btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(1)
            btn.Text = "인증하기"
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
        end
    end)
end

-------------------------------------------------------
-- [4. 로딩 및 실행]
-------------------------------------------------------
local function startLoading()
    -- 1단계: 안티치트 우회 먼저 실행
    pcall(AntiCheatBypass)

    -- 2단계: 로딩 스크린 (생략 가능하나 연출을 위해 유지)
    -- ... (기존 로딩 UI 로직과 동일) ...
    
    -- 예시로 바로 실행
    LoadMainHub()
end

task.spawn(startLoading)

