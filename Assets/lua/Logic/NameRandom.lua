--
-- 名字随机
-- chengh
--

NameRandom = {};

math.randomseed(os.time())

--根据性别获取随机名字 1-男性 0-女性
NameRandom.randomName = function(sex)
    local nameGroup = tb.NameRandomSexTable[sex];
    local randomGroup = nameGroup[math.random(#nameGroup)];
    local len = string.len(randomGroup);
    local name = "";
    for i = 1, len do
        local nameTable = tb.NameRandomTable[string.sub(randomGroup, i, i)];
        name = name .. nameTable[math.random(#nameTable)];
    end
    --对名字截断保护 最多6个字
    return name;
end




