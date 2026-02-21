-- [차단 리스트 설정] -----------------------------------------
-- 닉네임이나 유저 ID(숫자)를 입력하세요.
local Blacklist = {
    "EOQY8",           -- 닉네임으로 차단 (대소문자 상관없음)
    "EIQY8",   -- 여기에 차단할 유저 닉네임 입력
    12345678,          -- 유저 ID(숫자)로 차단 (권장: 닉네임 변경 대비)
}
-------------------------------------------------------

local function isBlacklisted(player)
    for _, v in pairs(Blacklist) do
        -- 닉네임(문자열) 비교 (대소문자 무시)
        if type(v) == "string" and string.lower(player.Name) == string.lower(v) then
            return true
        end
        -- 유저 ID(숫자) 비교
        if type(v) == "number" and player.UserId == v then
            return true
        end
    end
    return false
end

-- [수정된 로딩 로직 부분]
local function startLoading()
    -- (기존 로딩 단계 생략...)
    
    task.wait(0.5)
    screenGui:Destroy()

    -- ⚠️ 여기서 확실하게 체크!
    if isBlacklisted(lp) then
        print("Banned user detected: " .. lp.Name) -- 콘솔 확인용
        ShowBannedScreen() 
    else
        LoadMainHub()
    end
end
