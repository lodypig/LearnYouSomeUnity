runTable = {};
local ENV_TYPE = {
    USER = 0,
    EQUIP = 1
};

local env_type = ENV_TYPE.USER;
local env = 0;

local put_env = function (envAndType)       
    local old = {env_type = env_type, env = env};    
    env = envAndType.env;    
    env_type = envAndType.env_type;    
    return old;
end

local run = function (fun, env, env_type, defRet) 
    local ret = defRet;    
    if (fun ~= nil) then
        local old_env;
        old_env = put_env({env_type = env_type, env = env});
        ret = fun(); 
        put_env(old_env);
    end    
    return ret;
end

runTable.getEquipScore = function (equip)
    return run(tb.EquipTable[equip.sid].score, equip, ENV_TYPE.EQUIP, 0);
end

runTable.getEquipFightPower = function (equip)     
    return run(tb.EquipTable[equip.sid].fight_power, equip, ENV_TYPE.EQUIP, 0);
end

runTable.getEquipLevel = function ()
    return env.level;
end

runTable.getEquipFJH = function () 
    local fujiahe = 0;
    local temp;
    for i = 1, #env.addAttr do
        temp = env.addAttr[i];        
        fujiahe = fujiahe + temp[2];
    end
    return fujiahe;
end