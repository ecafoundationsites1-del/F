-- 서비스 및 로컬 변수
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [관리 및 승인 리스트]
-- 이 리스트는 서버가 아닌 클라이언트 스크립트이므로, 
-- 실제 영구 저장을 위해서는 데이터스토어 연동이 필요하나 현재는 세션 내 작동으로 구현합니다.
local WhitelistedUsers = {["WORPLAYTIMEEXP"] = true} 
local uiName = "ECA_V4_Final_Fixed"

-- UI 제거 함수
local function removeOldGui()
    local old = playerGui:FindFirstChild(uiName) or playerGui:FindFirstChild("LoadingScreen_ECA")
    if old then old:Destroy() end
end
removeOldGui()

-------------------------------------------------------
-- [1. 승인 시스템 & 메뉴 UI 생성]
-------------------------------------------------------
local function CreateMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    
    -- 메인 프레임 (네모난 블럭)
    local mainFrame = Instance.new("Frame", mainGui)
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, -0.5, 0) -- 화면 위쪽에서 시작
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner", mainFrame)
    
    -- [애니메이션: 블럭이 날아와서 합쳐짐]
    mainFrame:TweenPosition(UDim2.new(0.5, -250, 0.5, -175), "Out", "Back", 0.8)
    task.wait(0.8)

    -- 사이드바
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    
    -- 버튼 컨테이너 (애니메이션용)
    local buttonContainer = Instance.new("Frame", mainFrame)
    buttonContainer.Size = UDim2.new(1, -160, 1, -20)
    buttonContainer.Position = UDim2.new(0, 160, 0, 10)
    buttonContainer.BackgroundTransparency = 1

    -- [사이드바 메뉴: 사용자인증 (WORPLAYTIMEEXP 전용)]
    if lp.Name == "WORPLAYTIMEEXP" then
        local authTab = Instance.new("TextButton", sidebar)
        authTab.Size = UDim2.new(1, -10, 0, 40)
        authTab.Position = UDim2.new(0, 5, 0, 10)
        authTab.Text = "사용자 인증"
        authTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        authTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        authTab.MouseButton1Click:Connect(function()
            -- 기존 버튼들 청소
            for _, v in pairs(buttonContainer:GetChildren()) do v:Destroy() end
            
            local input = Instance.new("TextBox", buttonContainer)
            input.Size = UDim2.new(0.8, 0, 0, 40)
            input.Position = UDim2.new(0.1, 0, 0.2, 0)
            input.PlaceholderText = "유저 닉네임 입력..."
            input.Text = ""
            
            local approveBtn = Instance.new("TextButton", buttonContainer)
            approveBtn.Size = UDim2.new(0.8, 0, 0, 40)
            approveBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
            approveBtn.Text = "승인"
            approveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            
            approveBtn.MouseButton1Click:Connect(function()
                local targetName = input.Text
                -- 확인 창 생성
                local confirmFrame = Instance.new("Frame", mainGui)
                confirmFrame.Size = UDim2.new(0, 250, 0, 120)
                confirmFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
                confirmFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                
                local msg = Instance.new("TextLabel", confirmFrame)
                msg.Size = UDim2.new(1, 0, 0.5, 0)
                msg.Text = targetName .. "님을 승인하시겠습니까?"
                msg.TextColor3 = Color3.fromRGB(255,255,255)
                msg.BackgroundTransparency = 1
                
                local yes = Instance.new("TextButton", confirmFrame)
                yes.Size = UDim2.new(0.4, 0, 0.3, 0)
                yes.Position = UDim2.new(0.05, 0, 0.6, 0)
                yes.Text = "네"
                yes.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                
                local no = Instance.new("TextButton", confirmFrame)
                no.Size = UDim2.new(0.4, 0, 0.3, 0)
                no.Position = UDim2.new(0.55, 0, 0.6, 0)
                no.Text = "아니오"
                no.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
                
                yes.MouseButton1Click:Connect(function()
                    WhitelistedUsers[targetName] = true
                    confirmFrame:Destroy()
                    print(targetName .. " 승인 완료")
                end)
                
                no.MouseButton1Click:Connect(function() confirmFrame:Destroy() end)
            end)
        end)
    end

    -- [기타 버튼 애니메이션 등장 예시]
    for i = 1, 3 do
        local btn = Instance.new("TextButton", buttonContainer)
        btn.Size = UDim2.new(0.9, 0, 0, 45)
        btn.Position = UDim2.new(0.05, 0, 1.2, (i-1)*55) -- 아래에서 대기
        btn.Text = "기능 버튼 " .. i
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- 아래에서 위로 올라오는 애니메이션
        TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.05, 0, 0, (i-1)*55 + 10)
        }):Play()
        task.wait(0.1)
    end
end

-------------------------------------------------------
-- [2. 일반 유저용 사진 UI]
-------------------------------------------------------
local function LoadImageOnly()
    local mainGui = Instance.new("ScreenGui", playerGui)
    mainGui.Name = uiName
    local frame = Instance.new("Frame", mainGui)
    frame.Size = UDim2.new(0, 400, 0, 400)
    frame.Position = UDim2.new(0.5, -200, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(0.9, 0, 0.9, 0)
    img.Position = UDim2.new(0.05, 0, 0.05, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://74935234571734"
end

-------------------------------------------------------
-- [3. 로딩 UI 및 실행 제어]
-------------------------------------------------------
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "LoadingScreen_ECA"
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 180)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local loadingBar = Instance.new("Frame", mainFrame)
loadingBar.Size = UDim2.new(0, 0, 0, 5)
loadingBar.Position = UDim2.new(0.1, 0, 0.8, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

local function startLoading()
    loadingBar:TweenSize(UDim2.new(0.8, 0, 0, 5), "Out", "Linear", 3)
    task.wait(3.2)
    screenGui:Destroy()
    
    -- 승인 리스트에 있거나 WORPLAYTIMEEXP인 경우 메뉴 실행
    if WhitelistedUsers[lp.Name] then
        CreateMainHub()
    else
        LoadImageOnly()
    end
end

task.spawn(startLoading)

