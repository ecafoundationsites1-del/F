-- 서비스 및 플레이어 설정
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. 전체 화면을 덮는 ScreenGui 생성
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IntegratedHubSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-----------------------------------------------------------
-- [파트 A] 로딩 화면 (UI 생성 및 애니메이션)
-----------------------------------------------------------
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 400, 0, 200)
loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = screenGui

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 50, 0, 50)
logo.Position = UDim2.new(0, 5, 0, 5)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://129650208804431"
logo.Parent = loadingFrame

local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(0.8, 0, 0, 10)
loadingBg.Position = UDim2.new(0.1, 0, 0.6, 0)
loadingBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loadingBg.Parent = loadingFrame

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
loadingBar.BorderSizePixel = 0
loadingBar.Parent = loadingBg

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0, 20)
loadingText.Position = UDim2.new(0, 0, 1, 5)
loadingText.BackgroundTransparency = 1
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.TextSize = 12
loadingText.Text = "안티치트 우회중...."
loadingText.Parent = loadingBg

-----------------------------------------------------------
-- [파트 B] 허브 메인 UI (로그인 창)
-----------------------------------------------------------
local mainHub = Instance.new("Frame")
mainHub.Size = UDim2.new(0, 300, 0, 350)
mainHub.Position = UDim2.new(0.5, -150, 0.5, -175)
mainHub.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainHub.Visible = false -- 처음엔 숨김
mainHub.Active = true
mainHub.Draggable = true -- 드래그 가능
mainHub.Parent = screenGui

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainHub

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "허브 열기"
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = screenGui

-- 입력창 생성 함수
local function createInput(placeholder, pos, isPass)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.8, 0, 0, 30)
    box.Position = pos
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.TextColor3 = Color3.new(1, 1, 1)
    if isPass then box.ClearTextOnFocus = false end
    box.Parent = mainHub
    return box
end

local idInput = createInput("아이디", UDim2.new(0.1, 0, 0.2, 0), false)
local nickInput = createInput("닉네임(본인 닉네임 입력)", UDim2.new(0.1, 0, 0.4, 0), false)
local pwInput = createInput("비밀번호", UDim2.new(0.1, 0, 0.6, 0), true)

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(0.6, 0, 0, 40)
loginBtn.Position = UDim2.new(0.2, 0, 0.8, 0)
loginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
loginBtn.Text = "계정 생성 및 저장"
loginBtn.Parent = mainHub

-----------------------------------------------------------
-- [파트 C] 실행 및 로직
-----------------------------------------------------------

-- 1. 로딩 시작
task.wait(0.5)
loadingBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 3)
task.wait(3.5)
loadingFrame:Destroy() -- 로딩창 파괴
mainHub.Visible = true -- 허브창 등장

-- 2. 파일 저장 및 로그인 로직
loginBtn.MouseButton1Click:Connect(function()
    local inputNick = nickInput.Text
    local inputPW = pwInput.Text
    local realNick = player.Name

    -- 닉네임 검증
    if inputNick ~= realNick then
        loginBtn.Text = "닉네임 불일치!"
        task.wait(1)
        loginBtn.Text = "계정 생성 및 저장"
        return
    end

    -- 폴더 및 파일 저장 (Executor 전용)
    if writefile and makefolder then
        pcall(function()
            makefolder("ECA 데이터베이스")
            makefolder("ECA 데이터베이스/플레이어 데이터")
            
            local fileName = "ECA 데이터베이스/플레이어 데이터/" .. inputNick .. ".txt"
            local dataContent = string.format("닉네임: %s\n비밀번호: %s\n아이디: %s", inputNick, inputPW, idInput.Text)
            
            writefile(fileName, dataContent)
        end)
        
        loginBtn.Text = "저장 성공! (내부 폴더)"
    else
        loginBtn.Text = "실행기 권한 없음 (파일저장 실패)"
        warn("이 실행기는 writefile을 지원하지 않습니다.")
    end

    task.wait(2)
    mainHub.Visible = false
    openBtn.Visible = true
end)

-- 3. 열기/닫기 토글
closeBtn.MouseButton1Click:Connect(function()
    mainHub.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    mainHub.Visible = true
    openBtn.Visible = false
end)

