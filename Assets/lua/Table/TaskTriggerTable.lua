--任务触发脚本，由策划配置
--类型相同的event不能两个接在一起（涉及到唯一性的界面）
tb.TaskTrigger = {};
--{type = "map", sid = 20000001, pos = {59,93}, radius = 5}
tb.TaskTrigger[50000007] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000001, pos = {59,0,93}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000007},
        	},
	done = {
				{type = "enterAreaMsg", pos = {59,0,93}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000004] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000001, pos = {30,0,60}, radius = 5},
	--触发的具体流程，包括
	event = {
	            
        	},
	done = {
				{type = "enterXiangwei"},
				--{type = "showLoading"},
			}
};
tb.TaskTrigger[50000014] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000001, pos = {125,0,35}, radius = 5},
	--触发的具体流程，包括
	event = {
	            
        	},
	done = {
				{type = "enterXiangwei"},
				--{type = "showLoading"},
			}
};
tb.TaskTrigger[50000018] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000001, pos = {128,0,120}, radius = 5},
	--触发的具体流程，包括
	event = {
	            
        	},
	done = {
				{type = "enterXiangwei"},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000015] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000001, pos = {146,0,74}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000015},
        	},
	done = {
				{type = "enterAreaMsg", pos = {146,0,74}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000021] = 
{
	--触发条件的定义
	trigger = {type = "npcInteract", npcSid = 30000012},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000021},
                {type = "blackScreen", sid = 1001},
			},
	done = {
				{type = "showLoading"},
				{type = "completeMsg", npcSid = 30000012, taskSid = 50000021},
			}
};

tb.TaskTrigger[50000029] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010005, pos = {129,0,36}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000029},
        	},
	done = {
				{type = "enterAreaMsg", pos = {129,0,36}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000036] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010005, pos = {15,0,84}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000036},
        	},
	done = {
				{type = "enterAreaMsg", pos = {15,0,84}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000037] = 
{
	--触发条件的定义
	trigger = {type = "taskdone"},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000037},
        	},
	done = {
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000039] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010005, pos = {56,0,92}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000039},
        	},
	done = {
				{type = "enterAreaMsg", pos = {56,0,92}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000043] = 
{
	--触发条件的定义
	trigger = {type = "taskdone"},
	--触发的具体流程，包括
	event = {
	            {type = "blackScreen", sid = 1002},
        	},
	done = {
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000052] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20000002, pos = {65,0,64}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000052},
        	},
	done = {
				{type = "enterAreaMsg", pos = {65,0,64}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000054] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010003, pos = {77,0,97}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000054},
        	},
	done = {
				{type = "enterAreaMsg", pos = {77,0,97}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000064] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010003, pos = {42,0,150}, radius = 5},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000064},
        	},
	done = {
				{type = "enterAreaMsg", pos = {42,0,150}},
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[50000067] = 
{
	--触发条件的定义
	trigger = {type = "taskdone"},
	--触发的具体流程，包括
	event = {
	            {type = "talkScreen", sid = 50000067},
	            {type = "blackScreen", sid = 1003},
        	},
	done = {
				--{type = "showLoading"},
			}
};

tb.TaskTrigger[990000031] = 
{
	--触发条件的定义
	trigger = {type = "enterArea", mapSid = 20010008, pos = {82,0,95}, radius = 5},
	--触发的具体流程，包括
	event = {
	            
        	},
	done = {
				{type = "enterXiangwei"},
			}
};