local item = 1;
local equipment = 2;
tb.TaskTable = tb.TaskTable or {};

tb.TaskTable[50000001] =  {sid = 50000001,
		name = "破碎梦境",
        type = 1,
        succeed = 50000002,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 800,
        exp_award = 50,
        items_award = {},
        sorting = 100,
        task_des = "询问前方的女孩",
        task_text1 = "询问前方的女孩",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100003}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100004}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100005}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000001 , v2 = 50000001, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000002] =  {sid = 50000002,
		name = "寻觅长老",
        type = 1,
        succeed = 50000003,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 10,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 1960,
        exp_award = 50,
        items_award = {},
        sorting = 100,
        task_des = "寻找迪恩长老",
        task_text1 = "寻找迪恩长老",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100009}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100010}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100011}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000002 , v2 = 50000002, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000003] =  {sid = 50000003,
		name = "不知去向",
        type = 1,
        succeed = 50000004,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 15,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 3120,
        exp_award = 50,
        items_award = {},
        sorting = 100,
        task_des = "问问守仓库的拉尔",
        task_text1 = "问问守仓库的拉尔",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100027}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100028}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100029}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000003 , v2 = 50000003, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000004] =  {sid = 50000004,
		name = "幽影之谕",
        type = 1,
        succeed = 50000005,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 20,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 20040001,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败影子使魔",
        task_text1 = "击败影子使魔",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070001 , v2 = 5, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000005] =  {sid = 50000005,
		name = "惊魂未定",
        type = 1,
        succeed = 50000006,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 25,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 4280,
        exp_award = 100,
        items_award = {},
        sorting = 100,
        task_des = "与拉尔对话",
        task_text1 = "与拉尔对话",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100024}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100025}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100026}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000003 , v2 = 50000005, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000006] =  {sid = 50000006,
		name = "馈赠之物",
        type = 1,
        succeed = 50000007,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 30,
	    task_module_type = 1,
        task_type = 7,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 5440,
        exp_award = 100,
        items_award = {},
        sorting = 100,
        task_des = "拾取拉尔的馈赠",
        task_text1 = "拾取拉尔的馈赠",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100021}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100022}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100023}}},
            
        },
        successCondition = {
            {type = 7, v1 = 30010001 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000007] =  {sid = 50000007,
		name = "古月之桥",
        type = 1,
        succeed = 50000008,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 35,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 6600,
        exp_award = 200,
        items_award = {},
        sorting = 100,
        task_des = "越过古月桥",
        task_text1 = "越过古月桥",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20000001 , v2 = {58.1,94.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000008] =  {sid = 50000008,
		name = "霜之恶魔",
        type = 1,
        succeed = 50000009,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 40,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "驱散成群的冰霜食人魔",
        task_text1 = "驱散成群的冰霜食人魔",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001002 , v2 = 10, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000009] =  {sid = 50000009,
		name = "束缚之咒",
        type = 1,
        succeed = 50000010,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 45,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 7760,
        exp_award = 200,
        items_award = {},
        sorting = 100,
        task_des = "帮助迪恩长老",
        task_text1 = "帮助迪恩长老",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100012}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100013}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100014}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000004 , v2 = 50000009, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000010] =  {sid = 50000010,
		name = "雪之精灵",
        type = 1,
        succeed = 50000011,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 50,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "获取雪精灵翅膀",
        task_text1 = "获取雪精灵翅膀",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001003 , v2 = 10, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000011] =  {sid = 50000011,
		name = "解除咒印",
        type = 1,
        succeed = 50000012,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 55,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 8920,
        exp_award = 300,
        items_award = {},
        sorting = 100,
        task_des = "把精灵翅膀交给薇娜",
        task_text1 = "把精灵翅膀交给薇娜",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100018}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100019}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100020}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000005 , v2 = 50000011, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000012] =  {sid = 50000012,
		name = "光明弃徒",
        type = 1,
        succeed = 50000013,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 60,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 10080,
        exp_award = 300,
        items_award = {},
        sorting = 100,
        task_des = "询问迪恩长老状况",
        task_text1 = "询问迪恩长老状况",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000004 , v2 = 50000012, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000013] =  {sid = 50000013,
		name = "烈火村庄",
        type = 1,
        succeed = 50000014,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 65,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 11240,
        exp_award = 400,
        items_award = {},
        sorting = 100,
        task_des = "向峰顶进发守护银白之神",
        task_text1 = "向峰顶进发守护银白之神",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100015}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100016}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100017}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000006 , v2 = 50000013, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000014] =  {sid = 50000014,
		name = "抵御外敌",
        type = 1,
        succeed = 50000015,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 70,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 20040002,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败魔龙的爪牙",
        task_text1 = "击败魔龙的爪牙",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070002 , v2 = 10, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000015] =  {sid = 50000015,
		name = "锐意前行",
        type = 1,
        succeed = 50000016,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 75,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 12400,
        exp_award = 400,
        items_award = {},
        sorting = 100,
        task_des = "看看峰顶发生了什么",
        task_text1 = "看看峰顶发生了什么",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20000001 , v2 = {146.1,74.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000016] =  {sid = 50000016,
		name = "魔能水晶",
        type = 1,
        succeed = 50000017,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 80,
	    task_module_type = 1,
        task_type = 7,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 13560,
        exp_award = 500,
        items_award = {},
        sorting = 100,
        task_des = "获取魔能水晶的能量",
        task_text1 = "获取魔能水晶的能量",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100006}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100007}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100008}}},
            
        },
        successCondition = {
            {type = 7, v1 = 30010002 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000017] =  {sid = 50000017,
		name = "光暗之争",
        type = 1,
        succeed = 50000018,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 85,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 14720,
        exp_award = 500,
        items_award = {},
        sorting = 100,
        task_des = "响应永恒使徒的号召",
        task_text1 = "响应永恒使徒的号召",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000011 , v2 = 50000017, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000018] =  {sid = 50000018,
		name = "湮日潮汐",
        type = 1,
        succeed = 50000019,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 90,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 20040003,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败潮汐狂徒",
        task_text1 = "击败潮汐狂徒",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070003 , v2 = 14, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000019] =  {sid = 50000019,
		name = "沉睡之地",
        type = 1,
        succeed = 50000020,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 95,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 15880,
        exp_award = 500,
        items_award = {},
        sorting = 100,
        task_des = "准备最后之战",
        task_text1 = "准备最后之战",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000012 , v2 = 50000019, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000020] =  {sid = 50000020,
		name = "银白之神",
        type = 1,
        succeed = 50000021,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 1,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "通过副本唤醒银白之神",
        task_text1 = "通过副本唤醒银白之神",
        task_tips = "需要唤醒银白之神才能继续",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000021] =  {sid = 50000021,
		name = "破碎山谷",
        type = 1,
        succeed = 50000022,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 17500,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "对普拉尔进行最后一击",
        task_text1 = "对普拉尔进行最后一击",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000012 , v2 = 50000021, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000022] =  {sid = 50000022,
		name = "光咏之城",
        type = 1,
        succeed = 50000023,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 21250,
        exp_award = 1000,
        items_award = {},
        sorting = 100,
        task_des = "与薇娜对话",
        task_text1 = "与薇娜对话",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000017 , v2 = 50000022, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000023] =  {sid = 50000023,
		name = "永恒使徒",
        type = 1,
        succeed = 50000024,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 5,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 25000,
        exp_award = 1300,
        items_award = {},
        sorting = 100,
        task_des = "找永恒使徒询问情况",
        task_text1 = "找永恒使徒询问情况",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000019 , v2 = 50000023, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000024] =  {sid = 50000024,
		name = "智慧使徒",
        type = 1,
        succeed = 50000025,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 10,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 28750,
        exp_award = 1400,
        items_award = {},
        sorting = 100,
        task_des = "寻求智慧使徒帮助",
        task_text1 = "寻求智慧使徒帮助",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000020 , v2 = 50000024, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000025] =  {sid = 50000025,
		name = "疯狂之谜",
        type = 1,
        succeed = 50000026,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 15,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 32500,
        exp_award = 1200,
        items_award = {},
        sorting = 100,
        task_des = "去微风平原看看发生了什么",
        task_text1 = "去微风平原看看发生了什么",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000046 , v2 = 50000025, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000026] =  {sid = 50000026,
		name = "公平交易",
        type = 1,
        succeed = 50000027,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 20,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 36250,
        exp_award = 1200,
        items_award = {},
        sorting = 100,
        task_des = "和附近的人调查情况",
        task_text1 = "和附近的人调查情况",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000047 , v2 = 50000026, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000027] =  {sid = 50000027,
		name = "驱逐地精",
        type = 1,
        succeed = 50000028,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 25,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败哥布林",
        task_text1 = "击败哥布林",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001008 , v2 = 15, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000028] =  {sid = 50000028,
		name = "追问消息",
        type = 1,
        succeed = 50000029,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 30,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 40000,
        exp_award = 1300,
        items_award = {},
        sorting = 100,
        task_des = "回去告诉农奴",
        task_text1 = "回去告诉农奴",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000047 , v2 = 50000028, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000029] =  {sid = 50000029,
		name = "觊觎之影",
        type = 1,
        succeed = 50000030,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 35,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 43750,
        exp_award = 1400,
        items_award = {},
        sorting = 100,
        task_des = "去北面看看",
        task_text1 = "去北面看看",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20010005 , v2 = {129.1,36.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000030] =  {sid = 50000030,
		name = "宵小之徒",
        type = 1,
        succeed = 50000031,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 40,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败邪恶强盗",
        task_text1 = "击败邪恶强盗",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070011 , v2 = 15, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000031] =  {sid = 50000031,
		name = "伤势严重",
        type = 1,
        succeed = 50000032,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 45,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 47500,
        exp_award = 1500,
        items_award = {},
        sorting = 100,
        task_des = "看看汤姆杰瑞的情况",
        task_text1 = "看看汤姆杰瑞的情况",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000026 , v2 = 50000031, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000032] =  {sid = 50000032,
		name = "域外商人",
        type = 1,
        succeed = 50000033,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 50,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 51250,
        exp_award = 1500,
        items_award = {},
        sorting = 100,
        task_des = "找商人拿到药剂",
        task_text1 = "找商人拿到药剂",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000030 , v2 = 50000032, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000033] =  {sid = 50000033,
		name = "紫兰鹰羽",
        type = 1,
        succeed = 50000034,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 55,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "收集紫兰鹰羽",
        task_text1 = "收集紫兰鹰羽",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001009 , v2 = 18, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000034] =  {sid = 50000034,
		name = "药剂大师",
        type = 1,
        succeed = 50000035,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 60,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 55000,
        exp_award = 3400,
        items_award = {},
        sorting = 100,
        task_des = "把东西交给药剂大师",
        task_text1 = "把东西交给药剂大师",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000045 , v2 = 50000034, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000035] =  {sid = 50000035,
		name = "材料缺失",
        type = 1,
        succeed = 50000036,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 65,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "收集林地女妖的翅膀",
        task_text1 = "收集林地女妖的翅膀",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001010 , v2 = 18, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000036] =  {sid = 50000036,
		name = "寻觅树种",
        type = 1,
        succeed = 50000037,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 70,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 58750,
        exp_award = 3800,
        items_award = {},
        sorting = 100,
        task_des = "寻找树灵种子的所在地",
        task_text1 = "寻找树灵种子的所在地",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20010005 , v2 = {15.1,84.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000037] =  {sid = 50000037,
		name = "狂怒树灵",
        type = 1,
        succeed = 50000038,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 75,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败狂怒树灵",
        task_text1 = "击败狂怒树灵",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001006 , v2 = 18, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000038] =  {sid = 50000038,
		name = "树灵种子",
        type = 1,
        succeed = 50000039,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 80,
	    task_module_type = 1,
        task_type = 7,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 62500,
        exp_award = 2100,
        items_award = {{item,{10020001,15}},{item,{10020002,10}}},
        sorting = 100,
        task_des = "采集树灵种子",
        task_text1 = "采集树灵种子",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 7, v1 = 30010003 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000039] =  {sid = 50000039,
		name = "疯狂魔咒",
        type = 1,
        succeed = 50000040,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 85,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 66250,
        exp_award = 2100,
        items_award = {},
        sorting = 100,
        task_des = "准备回去交还药剂",
        task_text1 = "准备回去交还药剂",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20010005 , v2 = {56.1,92.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000040] =  {sid = 50000040,
		name = "背叛之子",
        type = 1,
        succeed = 50000041,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 90,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 70000,
        exp_award = 2300,
        items_award = {},
        sorting = 100,
        task_des = "追上前方的汤姆杰瑞",
        task_text1 = "追上前方的汤姆杰瑞",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000031 , v2 = 50000040, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000041] =  {sid = 50000041,
		name = "黑暗之心",
        type = 1,
        succeed = 50000042,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 91,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败迪恩长老",
        task_text1 = "击败迪恩长老",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000042] =  {sid = 50000042,
		name = "永恒诅咒",
        type = 1,
        succeed = 50000043,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 92,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 73750,
        exp_award = 2300,
        items_award = {},
        sorting = 100,
        task_des = "质问迪恩长老",
        task_text1 = "质问迪恩长老",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000031 , v2 = 50000042, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000043] =  {sid = 50000043,
		name = "不死宝藏",
        type = 1,
        succeed = 50000044,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "通过副本唤醒智慧之神",
        task_text1 = "通过副本唤醒智慧之神",
        task_tips = "需要唤醒智慧之神才能继续",
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100030}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100031}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100032}}},
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000044] =  {sid = 50000044,
		name = "心灵之遗",
        type = 1,
        succeed = 50000045,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 2,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 78000,
        exp_award = 2700,
        items_award = {},
        sorting = 100,
        task_des = "安慰德卡",
        task_text1 = "安慰德卡",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100054}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100055}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100056}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000032 , v2 = 50000044, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000045] =  {sid = 50000045,
		name = "偶露风声",
        type = 1,
        succeed = 50000046,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 79130,
        exp_award = 2800,
        items_award = {},
        sorting = 100,
        task_des = "与薇娜对话",
        task_text1 = "与薇娜对话",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100060}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100061}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100062}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000017 , v2 = 50000045, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000046] =  {sid = 50000046,
		name = "神的契约",
        type = 1,
        succeed = 50000047,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 4,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 80260,
        exp_award = 2000,
        items_award = {},
        sorting = 100,
        task_des = "把消息告诉永恒使徒",
        task_text1 = "把消息告诉永恒使徒",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000019 , v2 = 50000046, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000047] =  {sid = 50000047,
		name = "记忆之晶",
        type = 1,
        succeed = 50000048,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 8,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 81390,
        exp_award = 2000,
        items_award = {},
        sorting = 100,
        task_des = "询问智慧使徒",
        task_text1 = "询问智慧使徒",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000020 , v2 = 50000047, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000048] =  {sid = 50000048,
		name = "水晶视野",
        type = 1,
        succeed = 50000049,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 12,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 82520,
        exp_award = 2000,
        items_award = {},
        sorting = 100,
        task_des = "跟上夏莉看看",
        task_text1 = "跟上夏莉看看",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000022 , v2 = 50000048, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000049] =  {sid = 50000049,
		name = "别有所图",
        type = 1,
        succeed = 50000050,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 16,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 83650,
        exp_award = 3200,
        items_award = {},
        sorting = 100,
        task_des = "询问莱温特水晶球的状况",
        task_text1 = "询问莱温特水晶球的状况",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000022 , v2 = 50000049, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000050] =  {sid = 50000050,
		name = "捣蛋小鬼",
        type = 1,
        succeed = 50000051,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 20,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "教训教训捣蛋鬼",
        task_text1 = "教训教训捣蛋鬼",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070012 , v2 = 25, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000051] =  {sid = 50000051,
		name = "禁忌之海",
        type = 1,
        succeed = 50000052,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 24,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 84780,
        exp_award = 3300,
        items_award = {},
        sorting = 100,
        task_des = "把消息告诉智慧使徒",
        task_text1 = "把消息告诉智慧使徒",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100036}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100037}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100038}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000022 , v2 = 50000051, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000052] =  {sid = 50000052,
		name = "魔龙之息",
        type = 1,
        succeed = 50000053,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 28,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 85910,
        exp_award = 1500,
        items_award = {},
        sorting = 100,
        task_des = "探查一下夏莉行踪",
        task_text1 = "探查一下夏莉行踪",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20000002 , v2 = {65.1,64.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000053] =  {sid = 50000053,
		name = "智慧之遗",
        type = 1,
        succeed = 50000054,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 32,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 87040,
        exp_award = 2500,
        items_award = {},
        sorting = 100,
        task_des = "与智慧使徒对话",
        task_text1 = "与智慧使徒对话",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100039}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100040}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100041}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000020 , v2 = 50000053, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000054] =  {sid = 50000054,
		name = "愤怒之潮",
        type = 1,
        succeed = 50000055,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 36,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 88170,
        exp_award = 3000,
        items_award = {},
        sorting = 100,
        task_des = "赶往禁忌之海",
        task_text1 = "赶往禁忌之海",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20010003 , v2 = {77.1,97.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000055] =  {sid = 50000055,
		name = "晶蓝海马",
        type = 1,
        succeed = 50000056,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 40,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "驱散晶蓝海马",
        task_text1 = "驱散晶蓝海马",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001012 , v2 = 25, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000056] =  {sid = 50000056,
		name = "娜迦驻地",
        type = 1,
        succeed = 50000057,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 44,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 89300,
        exp_award = 3500,
        items_award = {},
        sorting = 100,
        task_des = "询问智慧使徒",
        task_text1 = "询问智慧使徒",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100042}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100043}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100044}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000034 , v2 = 50000056, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000057] =  {sid = 50000057,
		name = "倒戈相向",
        type = 1,
        succeed = 50000058,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 48,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 90430,
        exp_award = 4000,
        items_award = {},
        sorting = 100,
        task_des = "寻找娜迦驻地",
        task_text1 = "寻找娜迦驻地",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000037 , v2 = 50000057, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000058] =  {sid = 50000058,
		name = "剑拔弩张",
        type = 1,
        succeed = 50000059,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 52,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败娜迦海妖",
        task_text1 = "击败娜迦海妖",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001015 , v2 = 25, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000059] =  {sid = 50000059,
		name = "误会冰释",
        type = 1,
        succeed = 50000060,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 56,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 91560,
        exp_award = 8000,
        items_award = {{item,{10020001,10}}},
        sorting = 100,
        task_des = "与娜迦统领对话",
        task_text1 = "与娜迦统领对话",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100045}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100046}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100047}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000036 , v2 = 50000059, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000060] =  {sid = 50000060,
		name = "潮汐海魔",
        type = 1,
        succeed = 50000061,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 60,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击杀并驱逐海魔",
        task_text1 = "击杀并驱逐海魔",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31001013 , v2 = 25, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000061] =  {sid = 50000061,
		name = "守护之力",
        type = 1,
        succeed = 50000062,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 64,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 92690,
        exp_award = 4000,
        items_award = {},
        sorting = 100,
        task_des = "与娜迦统领对话",
        task_text1 = "与娜迦统领对话",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100048}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100049}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100050}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000036 , v2 = 50000061, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000062] =  {sid = 50000062,
		name = "破碎水晶",
        type = 1,
        succeed = 50000063,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 68,
	    task_module_type = 1,
        task_type = 7,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 93820,
        exp_award = 4000,
        items_award = {},
        sorting = 100,
        task_des = "熄灭结界水晶",
        task_text1 = "熄灭结界水晶",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 7, v1 = 30010004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000063] =  {sid = 50000063,
		name = "密语之声",
        type = 1,
        succeed = 50000064,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 72,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 94950,
        exp_award = 4000,
        items_award = {},
        sorting = 100,
        task_des = "告诉智慧使徒情况",
        task_text1 = "告诉智慧使徒情况",
        task_tips = nil,
        specReward = {
            
            ["soldier"] = {career = "soldier", sex = 0 , award = {{equipment,100051}}},
            
            ["bowman"] = {career = "bowman", sex = 0 , award = {{equipment,100052}}},
            
            ["magician"] = {career = "magician", sex = 0 , award = {{equipment,100053}}},
            
        },
        successCondition = {
            {type = 5, v1 = 30000034 , v2 = 50000063, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000064] =  {sid = 50000064,
		name = "深渊结界",
        type = 1,
        succeed = 50000065,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 76,
	    task_module_type = 1,
        task_type = 8,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 96080,
        exp_award = 4000,
        items_award = {},
        sorting = 100,
        task_des = "找到封印地的夏莉",
        task_text1 = "找到封印地的夏莉",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 8, v1 = 20010003 , v2 = {42.1,150.6}, v3 = 5, v4 = 0},
            
        },
    	};
tb.TaskTable[50000065] =  {sid = 50000065,
		name = "潮汐党徒",
        type = 1,
        succeed = 50000066,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 80,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败湮日使者",
        task_text1 = "击败湮日使者",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070008 , v2 = 20, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000066] =  {sid = 50000066,
		name = "过往之罪",
        type = 1,
        succeed = 50000067,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 84,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 97210,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "了解真相",
        task_text1 = "了解真相",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000038 , v2 = 50000066, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000067] =  {sid = 50000067,
		name = "恶魇之潮",
        type = 1,
        succeed = 50000068,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 88,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "击败夏莉",
        task_text1 = "击败夏莉",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31070009 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000068] =  {sid = 50000068,
		name = "深海巨魔",
        type = 1,
        succeed = 50000069,
	    accept_autogo = 1,
        level_min = 1,
        level_max = 100,
        chapter = 3,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 100,
        task_des = "通过副本唤醒勇气之神",
        task_text1 = "通过副本唤醒勇气之神",
        task_tips = "需要唤醒勇气之神才能继续",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000069] =  {sid = 50000069,
		name = "安息之忘",
        type = 1,
        succeed = 50000070,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 4,
        progress = 0,
	    task_module_type = 1,
        task_type = 5,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 11000,
        items_award = {},
        sorting = 100,
        task_des = "看看智慧使徒还好么",
        task_text1 = "看看智慧使徒还好么",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 5, v1 = 30000042 , v2 = 50000069, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000070] =  {sid = 50000070,
		name = "长夜祭祀",
        type = 1,
        succeed = 50000071,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 4,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到35级",
        task_text1 = "达到35级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 35 , v2 = 35, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000071] =  {sid = 50000071,
		name = "战争之神",
        type = 1,
        succeed = 50000072,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 4,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒战争之神",
        task_text1 = "唤醒战争之神",
        task_tips = "前往唤醒战争之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000072] =  {sid = 50000072,
		name = "混沌悲歌",
        type = 1,
        succeed = 50000073,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 5,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到40级",
        task_text1 = "达到40级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 40 , v2 = 40, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000073] =  {sid = 50000073,
		name = "力量之神",
        type = 1,
        succeed = 50000074,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 5,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒力量之神",
        task_text1 = "唤醒力量之神",
        task_tips = "前往唤醒力量之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000074] =  {sid = 50000074,
		name = "死亡奥秘",
        type = 1,
        succeed = 50000075,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 6,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到45级",
        task_text1 = "达到45级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 45 , v2 = 45, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000075] =  {sid = 50000075,
		name = "迅风之神",
        type = 1,
        succeed = 50000076,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 6,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒迅风之神",
        task_text1 = "唤醒迅风之神",
        task_tips = "前往唤醒迅风之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000076] =  {sid = 50000076,
		name = "死亡奥秘",
        type = 1,
        succeed = 50000077,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 7,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到50级",
        task_text1 = "达到50级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 50 , v2 = 50, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000077] =  {sid = 50000077,
		name = "捍卫之神",
        type = 1,
        succeed = 50000078,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 7,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒捍卫之神",
        task_text1 = "唤醒捍卫之神",
        task_tips = "前往唤醒捍卫之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000078] =  {sid = 50000078,
		name = "世界之心",
        type = 1,
        succeed = 50000079,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 8,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到55级",
        task_text1 = "达到55级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 55 , v2 = 55, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000079] =  {sid = 50000079,
		name = "秘密之神",
        type = 1,
        succeed = 50000080,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 8,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒秘密之神",
        task_text1 = "唤醒秘密之神",
        task_tips = "前往唤醒秘密之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000080] =  {sid = 50000080,
		name = "绝地红潮",
        type = 1,
        succeed = 50000081,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 9,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到60级",
        task_text1 = "达到60级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 60 , v2 = 60, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000081] =  {sid = 50000081,
		name = "秘密之神",
        type = 1,
        succeed = 50000082,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 9,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒元素之神",
        task_text1 = "唤醒元素之神",
        task_tips = "前往唤醒元素之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000082] =  {sid = 50000082,
		name = "绝地红潮",
        type = 1,
        succeed = 50000083,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 10,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到65级",
        task_text1 = "达到65级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 65 , v2 = 65, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000083] =  {sid = 50000083,
		name = "秘密之神",
        type = 1,
        succeed = 50000084,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 10,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒判决之神",
        task_text1 = "唤醒判决之神",
        task_tips = "前往唤醒判决之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000084] =  {sid = 50000084,
		name = "绝地红潮",
        type = 1,
        succeed = 50000085,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 11,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到70级",
        task_text1 = "达到70级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 70 , v2 = 70, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000085] =  {sid = 50000085,
		name = "秘密之神",
        type = 1,
        succeed = 50000086,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 11,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒阔海之神",
        task_text1 = "唤醒阔海之神",
        task_tips = "前往唤醒阔海之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000086] =  {sid = 50000086,
		name = "绝地红潮",
        type = 1,
        succeed = 50000087,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 12,
        progress = 50,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "达到75级",
        task_text1 = "达到75级",
        task_tips = "通过活动提升等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 75 , v2 = 75, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[50000087] =  {sid = 50000087,
		name = "秘密之神",
        type = 1,
        succeed = 50000088,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 12,
        progress = 100,
	    task_module_type = 1,
        task_type = 1,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 77500,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "唤醒治愈之神",
        task_text1 = "唤醒治愈之神",
        task_tips = "前往唤醒治愈之神吧",
        specReward = {
            
        },
        successCondition = {
            {type = 1, v1 = 31040004 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[990000030] =  {sid = 990000030,
		name = "勇者试炼",
        type = 1,
        succeed = 990000030,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 0,
        progress = 0,
	    task_module_type = 1,
        task_type = 12,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 78800,
        exp_award = 20000000,
        items_award = {},
        sorting = 100,
        task_des = "进行副本挑战与魔龙岛血战获得丰厚奖励吧！",
        task_text1 = "进行副本挑战与魔龙岛血战获得丰厚奖励吧！",
        task_tips = "参加各类活动提升自己的等级吧",
        specReward = {
            
        },
        successCondition = {
            {type = 12, v1 = 80 , v2 = 80, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[990000031] =  {sid = 990000031,
		name = "夺取宝藏",
        type = 1,
        succeed = 50000070,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 5,
        progress = 0,
	    task_module_type = 1,
        task_type = 16,
        quality = 4,
	xiangwei_sceneid = 20040004,
        money_award = 50000,
        exp_award = 10000,
        items_award = {},
        sorting = 100,
        task_des = "在地图中寻找被标记的玩家，夺取其挂机获得的宝藏",
        task_text1 = "在地图中寻找被标记的玩家，夺取其挂机获得的宝藏",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 16, v1 = 31001001 , v2 = 990000031, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[10086] =  {sid = 10086,
		name = "采集水晶",
        type = 1,
        succeed = 10001,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 0,
        progress = 0,
	    task_module_type = 1,
        task_type = 7,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 1,
        exp_award = 1,
        items_award = {{item,{10020003,5}}},
        sorting = 100,
        task_des = "",
        task_text1 = "采集魔晶矿石",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 7, v1 = 80010001 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[10090] =  {sid = 10090,
		name = "子任务测试",
        type = 1,
        succeed = 10091,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 0,
        progress = 0,
	    task_module_type = 1,
        task_type = 15,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 1,
        exp_award = 1,
        items_award = {{item,{10020003,5}}},
        sorting = 100,
        task_des = "完成身手敏捷，冰霜巨人，力大无穷三个任务",
        task_text1 = "",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 15, v1 = 0 , v2 = 10001, v3 = 0, v4 = 0},
            
            {type = 15, v1 = 0 , v2 = 10002, v3 = 0, v4 = 0},
            
            {type = 15, v1 = 0 , v2 = 10003, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[10091] =  {sid = 10091,
		name = "操作测试",
        type = 1,
        succeed = 0,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 0,
        progress = 0,
	    task_module_type = 1,
        task_type = 16,
        quality = 4,
	xiangwei_sceneid = 0,
        money_award = 1,
        exp_award = 1,
        items_award = {{item,{10020003,5}}},
        sorting = 100,
        task_des = "点击主界面的背包按钮",
        task_text1 = "",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 16, v1 = 0 , v2 = 10091, v3 = 0, v4 = 0},
            
        },
    	};
tb.TaskTable[90000] =  {sid = 90000,
		name = "宝藏任务",
        type = 1,
        succeed = 0,
	    accept_autogo = 0,
        level_min = 1,
        level_max = 100,
        chapter = 0,
        progress = 0,
	    task_module_type = 1,
        task_type = 14,
        quality = 3,
	xiangwei_sceneid = 0,
        money_award = 0,
        exp_award = 0,
        items_award = {},
        sorting = 300,
        task_des = "找到宝藏",
        task_text1 = "找到宝藏",
        task_tips = nil,
        specReward = {
            
        },
        successCondition = {
            {type = 14, v1 = 0 , v2 = 1, v3 = 0, v4 = 0},
            
        },
    	}