--物品ID
const.ChuanSongJuanZhu = 10010002;

-- 引导特殊洗练装备id
const.Special_XilianEquip = {11110020,11120020,11130020};
const.low_tire_value_threshold = 2500;
const.high_tire_value_threshold = 5000;
const.clear_tire_max_count = 5;
-- 主界面左边箭头是否收回
const.leftPanelShrink = true;
-- 新手村最后一个任务id
const.lastSid = 10009;
-- 福利领取体力增加 50 点体力
-- 悬赏任务刷新消耗钻石数量
const.reward_task_refresh_diamond_cost = 20;
-- 重置技能消耗钻石数量
const.reset_skill_diamond_cost = 50;
-- 角色免费重置技能最高等级
const.free_reset_level = 60;
-- 副本重置钻石消耗数量
const.fuben_reset_diamond_cost = 20;
-- 购买扫荡券消耗钻石个数
const.fuben_buy_sweetTicket_cost = 10;

const.fuben_award_radio = {1, 1.2, 1.4};
const.tranmit_scroll_diamond_cost = 10;
const.fuben_sweep_ticket = 10010003;
const.fuben_sweep_ticket_diamond_cost = 10;
const.fuben_hell_ticket = 10010004;
const.Dragon_heart_Sid = 10006003; 
const.Molongdao_Npc_Sid = 90010019;
const.ProtectTaskLevel = 45;
-- 钻石和强化石的购买比例，即一个强化石需要N个钻石
const.DiamondCostPerMaterial = 1;

-- 记录强化界面自动补足钻石的勾选状态
const.AutoSupplyState = false;
--强化等级最大值
const.enhanceMaxLevel = 99;

const.IsNotShow = false;

-- 藏宝图挖宝最大次数
const.CBTMaxCount = 5;
-- 藏宝图开放等级
const.CBTOpenLevel= 35

-- 创建公会钻石花费
const.createLegionCost = 988;
-- PK开放等级
const.PKOpenLevel = 30;
-- 1点杀戮值对应钻石数量
const.PKValueDiamond = 5;

-- 洗炼恢复所需钻石
const.PurifyRevertDiamond = 10;

const.OpenMenuFlag = false;
const.OpenSkillFlag = true;
const.KeepOpenMenu = false;
const.InXiangWei = false;
--离线挂机时间
const.BuyGuajiTimePrice = 5;
const.BuyGuajiTimeMax = 20;	--20小时上限
const.GuajiLevel = 30;

const.SceneBossTimeH1 = 12;
const.SceneBossTimeM1 = 30;
const.SceneBossTimeH2 = 20;
const.SceneBossTimeH1 = 30;

-- 小地图显示列表
const.CanSeeEliteTab = {}; 
const.CanSeeTeamerTab = {};
--组队最大人数
const.team_max_member = 4;
--战斗力增量
const.fightValueDelta = 0;


const.enable_zhuanjing = false;

const.ActivityId = {
	xuanShang = 100001,
	cangBaoTu = 100002,
	shiLianMiJing = 100003,
	moLongDao = 100004,
	moLongChuE = 100005,
	--野外挂机活动ID
	wild = 100006,
	--离线挂机活动ID
	outLine = 100007,
	--公会宴会活动ID
	monsterHead = 100008,
	--世界BOSS活动ID
	SceneBoss = 100009
}

const.Gem_Type = {"红宝石","黄宝石","橙宝石","粉宝石", "白宝石","绿宝石","紫宝石","蓝宝石","青宝石","黑宝石"};

const.SidToIndex = {
	[100001] = 1,
	[100002] = 2,
	[100003] = 3,
	[100004] = 4,
	[100005] = 5,
	[100006] = 6,
	[100007] = 7,
	[100008] = 8,
	[100009] = 9
}
const.IndexToSid = {100001,100002,100003,100004,100005,100006,100007,100008,100009}

-- 这里是因为从服务端传过来的activity.BossStateList中的数据一直都是第一项是第二个boss，第二项是第一个boss，第三项是第三个
const.BossIndexTranslate = {
	[1] = 2,
	[2] = 1,
	[3] = 3
}

const.BossLevel = {
	[31031001] = 35,
	[31031002] = 45,
	[31031003] = 55,
	[31031004] = 65,
	[31031005] = 75

}

const.bossIdToIndex = {
	[31031001] = 1,
	[31031002] = 2,
	[31031003] = 3,
	[31031004] = 4,
	[31031005] = 5
}

--已完成，已显示未开启，已开启活动标记
const.ActShowStart = {
	cando = 1,
	done = 2,
	showButNotStart = 3
}
-- 设置项和购买项

const.Message = {
	diamond = 1,
	money = 2,
	experience = 3,
	item = 4
}

const.NotNeedShowItemMsg = {
	"molongShop",
	"legionShop",
	"jiaoyiShop",
	"goldBox",
	"fuben"
}
-- 公会职位
const.legionPos = {
	[1] = "会长",
	[2] = "副会长",
	[3] = "执法官",
	[4] = "会员"
};

 const.maxLegionLevel = 5
-- 公会职位颜色
const.legionPosColor = {
	[1] = "ff7e28",
	[2] = "e67ce6",
	[3] = "00a8ff",
	[4] = "e4e4e4"
};

-- 世界boss对应地图mapId
const.SceneBoss_mapId = {
	[1] = 20010008,
	[2]	= 20010001,
	[3] = 20010006,
	[4] = 20010002,
	[5] = 20010004
};

const.week = 
{
	"星期日",
	"星期一",
	"星期二",
	"星期三",
	"星期四",
	"星期五",
	"星期六",
}

const.NumberTable = {"一","二","三","四","五","六","七","八","九","十"};


const.AllTips = {};

const.TIPS_Type = {
	Activity = 1,
	Email = 2,
	Juntuan = 3,
	Zudui = 4,
	Other = 5
};

const.TIPS_BG = {
	"tb_jiaohu_huodong",
	"tb_jiaohu_youjian",
	"tb_jiaohu_juntuan",
	"tb_jiaohu_zudui",
	"tb_jiaohu_huodong"
}

const.SLOT_LEVEL_BG = {
	"dk_dengji_slot_1",
	"dk_dengji_slot_2",
	"dk_dengji_slot_3",
	"dk_dengji_slot_4",
	"dk_dengji_slot_5",
	"dk_dengji_slot_1",
	"dk_dengji_slot_5"
};

const.Activity = {
	xuanshang = 1,
	cangbaotu = 2,
	molongdao = 3,
	shijieboss = 4,
	LegionAct = 5
};


const.ATTR_NAME = { 
					hit = "命中", 
					dodge = "闪避", 
					critical = "暴击", 
					tenacity = "韧性",
					phyAttack = "攻击", 
					phyAttackMin = "攻击", 	--TODO client name
					phyDefense = "防御", 
					maxHP = "生命",		--TODO client name
					block = "格挡",		--TODO server name
                    brokenBlock = "穿透",
                    attackReduceP = "抵御攻击",
                    damageAmplifyP = "增强伤害",
                    dodge = "闪避",
                    defenseReduceP = "忽视防御",
                    tenacity = "抗暴",
                    block = "格挡",
                    damageResistP = "减免伤害"            
				};

const.ATTR_PERCENT = {
					hit = false, 
					dodge = false, 
					critical = false, 
					tenacity = false,
					phyAttack = false, 
					phyAttackMin = false, 	--TODO client name
					phyDefense = false, 
					maxHP = false,		--TODO client name
					block = false,		--TODO server name
                    brokenBlock = false,
                    attackReduceP = true,
                    damageAmplifyP = true,
                    dodge = false,
                    defenseReduceP = true,
                    tenacity = false,
                    block = false,
                    damageResistP = true
};

const.ATTR_PRIORTY = {
	phyAttack = 4, 
	phyDefense = 3,
	maxHP = 1,
	hit = 2,
    dodge = 5,
    critical = 6,
    tenacity = 7,
    block = 8,
    brokenBlock = 9
}

const.bagType = {
	item = 1,
	equip = 2,
	gem = 3
}

const.LevelPicture = {
	"wz_dengji_1",
	"wz_dengji_10",
	"wz_dengji_20",
	"wz_dengji_30",
	"wz_dengji_40",
	"wz_dengji_50",
	"wz_dengji_60",
	"wz_dengji_70",
	"wz_dengji_80",
	"wz_dengji_90"
}
const.color = {
	white = "#e4e4e4FF",
	red_1 = "#ce2020",
	red = "#9c2323", --红
	yellow = "#ffe492",
	yellow_1 = "#fec113",
	blue = "#6C6CFFFF",
	gold = "#ebbd70FF",
	gray = "#6C6C6DFF",
	blue_1 = "#5d7af7FF",
	white1 = "#afac8dff"
}

--可穿戴，可洗练，无标识(表示排序权重)
const.biaoshi = {
	CouldWear = 4,
	CouldXilian = 2,
    CouldZhuanyi = 3,
	NoAttr = 1
}

--未鉴定，已鉴定，橙装碎片
const.IsIdentify = {
	Orangesuccess = 0,
	Unidentify = 1,
	Identified = 2,
	Orangepiece =3
}

const.colorObj = {
	rank_yellow = Color.New(255, 228, 146, 255),
	white = Color.New(228, 228, 228, 255),
	gray = Color.New(108, 108, 108, 255)
};

const.colorP = {
	white = Color.New(228/255, 228/255, 228/255, 1),
	gray = Color.New(108/255, 108/255, 108/255, 1)
}

const.ProfessionName = {
						soldier = "龙魂斗士", 
						bowman = "圣痕射手",
						magician = "神谕魔导"
					};

const.ProfessionName2Index = {
						soldier = 1, 
						magician = 2,
						bowman = 3,
}

const.AttackRange = {
	soldier = 2,
	magician = 6,
	bowman = 7,
}

const.RandomMoveRadius = {
	soldier = 14,
	magician = 10,
	bowman = 9,
}

const.ProfessionName2Alias = {
	soldier = "warrior", 
	magician = "mage",
	bowman = "archer",
}

const.specialty2Career = 
{
	soldier = "近战职业 攻防兼备",	
	bowman = "远程职业 策略性强",	
	magician = "远程职业 机动性强"
}

const.desc2Career =
{
	soldier = "拥有龙族战魂传承的龙魂斗士们是一往无前的冲锋者！他们是越流血就越强大的无畏者！",
	bowman = "感知到永恒之泉意志的、心灵最纯洁的人！拥有敏锐的洞察力，是大陆的守护者。",
	magician = "神族与人族的后裔，长相俊美，智慧非凡，天生英才。他们精通全系魔法，近乎神迹。"
}

const.Index2Career = {
	[0] = "soldier",
	[1] = "bowman",
	[2] = "magician"
}

const.sexName = {
	[0] = "female",
	[1] = "male",
	[2] = "female",
}

const.sexIndex = 
{
	none = 0,
	female = 1,
	male = 2
}

const.RoleModelNames = {
	"main", "Object001", "Object002", "Object003", "Object004", "Object005", "Object006", "Object007", "Object012", 
}

const.ProfessionAlias = {
	soldier = 	"warrior", 
	bowman = 	"archer",
	magician = 	"mage"
};

const.ProfessionAbility = {
	soldier = {40011001, 40011201, 40011101, 40011301}, 
	bowman = {40021001, 40021201, 40021101, 40021301},
	magician ={40031001, 40031201, 40031101, 40031301}
};


const.FootstepName = {
	
	"caodi",
	"muzhidi",
	"shadi",
	"shuimian",
	"tudi",
	"xuedi",
	"zhuanshidi",
};



const.MidEquip = {
	"tb_wuqi_diaoluo",
	"tb_erhuan_diaoluo",
	"tb_yifu_diaoluo",
	"tb_kuzi_diaoluo",
	"tb_xianglian_diaoluo",
	"tb_jiezhi_diaoluo",
	"tb_toukui_diaoluo",
	"tb_hujian_diaoluo",
	"tb_shoutao_diaoluo",
	"tb_xiezi_diaoluo"
};


const.LegionPosName = {
	"会长",
	"副会长",
	"执法官",
	"会员"
};


const.debug = AppConst.DebugMode;--true;
const.use_teleport = false;

-- 当在自动战斗进行中，使用摇杆，点击移动，自动寻路移动后，需要等待这个时间才开始自动战斗
const.wait_for_autofight = 1;
-- 当在自动战斗进行中，当前没有目标，要等待这个时间后，才进行归位操作
const.wait_for_autofight_return = 1;

const.AnimatorStateNameToId = {
	["Idle"] = 2081823275,
	["JoystickRun"] = -1824481152,
	["Run"] = 1748754976,
	["ClickRun"] = 68297929,
	["PathfindingRun"] = 1180534518,
	["Chase"] = 1463555229,
	["Return"] = -1607321031,
	["Die"] = 20298039,
	["Attack1"] = -47317214,
	["Attack2"] = 1680125592,
	["Attack3"] = 321101326,
	["Attack4"] = -1924723795,
	["Attack5"] = -96453829,
	["Attack6"] = 1665755777,
	["Skill1"] = 1246704634,
	["Skill2"] = -750362048,
	["Skill3"] = -1539222826,
	["Skill4"] = 975554421,
	["Skill5"] = 1294137315,
	["Skill6"] = -735336871,
	["AOE"] = -11610064,
	["EX"] = -1452838791,
	["Special"] = -2083125633,
	["Hit"] = 1654612129,
	["DieFly"] = 693626773,
};


const.EX_Index = 1;
const.AOE_Index = 2;
const.Special_Index = 3;

-- 每种类型的角色都有一个职业技能列表
-- Solider 代表战士
-- Bowman 代表弓手
-- Magician 代表法师
-- Kulouwang 骷髅王
-- Jiangongdifeiya 监工迪菲亚
-- 如果要添加一种新的类型，必须添加新配置
-- attack_count 代表普通攻击技能的数量，索引小于等于这个值的代表普通攻击, 大于的代表技能
-- 每个普通攻击都有一个 id, 如普攻的连击，每个攻击都有一个独立的 id
-- no_action 代表这个技能时候有动作，如果没有动作在状态机中就没有对应的状态
-- no_action 的实现不走状态机事件，只是播放一个技能
-- state 代表这个技能对应的状态机状态的名称
-- index 代表在技能列表中的索引值
const.CareerAbility = {

	["Solider"] = {

		["attack_count"] = 3,

		["skills"] = {
			{ ["id"] = 40011001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false,["skill_type"] = 1 },
			{ ["id"] = 40011003, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false,["skill_type"] = 1 },
			{ ["id"] = 40011005, ["state"] = "Attack3", ["index"] = 3, ["no_action"] = false,["skill_type"] = 1 },
			{ ["id"] = 40011201, ["state"] = "EX", ["index"] = 4, ["no_action"] = false,["skill_type"] = 2  },
			{ ["id"] = 40011101, ["state"] = "AOE", ["index"] = 5, ["no_action"] = false,["skill_type"] = 2  },
			{ ["id"] = 40011301, ["state"] = "Special", ["index"] = 6, ["no_action"] = false,["skill_type"] = 2  },
			{ ["id"] = 40001001, ["state"] = "None", ["index"] = 7, ["no_action"] = true,["skill_type"] = 3  }    -- 0.662 新增回血技能
		},
	},

	["Bowman"] = {

		["attack_count"] = 3,

		["skills"] = {
			{ ["id"] = 40021001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false,["skill_type"] = 1},
			{ ["id"] = 40021003, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false,["skill_type"] = 1},
			{ ["id"] = 40021005, ["state"] = "Attack3", ["index"] = 3, ["no_action"] = false,["skill_type"] = 1},
			{ ["id"] = 40021201, ["state"] = "EX", ["index"] = 4, ["no_action"] = false,["skill_type"] = 2},
			{ ["id"] = 40021101, ["state"] = "AOE", ["index"] = 5, ["no_action"] = false,["skill_type"] = 2},
			{ ["id"] = 40021301, ["state"] = "Special", ["index"] = 6, ["no_action"] = true,["skill_type"] = 2},
			{ ["id"] = 40001001, ["state"] = "None", ["index"] = 7, ["no_action"] = true,["skill_type"] = 3}    -- 0.662 新增回血技能
		},
	}, 

	["Magician"] = {

		["attack_count"] = 2,

		["skills"] = {
			{ ["id"] = 40031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false,["skill_type"] = 1},
			{ ["id"] = 40031003, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false,["skill_type"] = 1},
			{ ["id"] = 40031201, ["state"] = "EX", ["index"] = 3, ["no_action"] = false,["skill_type"] = 2},
			{ ["id"] = 40031101, ["state"] = "AOE", ["index"] = 4, ["no_action"] = false,["skill_type"] = 2},			
			{ ["id"] = 40031301, ["state"] = "Special", ["index"] = 5, ["no_action"] = false,["skill_type"] = 2},
			{ ["id"] = 40001001, ["state"] = "None", ["index"] = 6, ["no_action"] = true,["skill_type"] = 3}    -- 0.662 新增回血技能
		},
	}, 

	["Kulouwang"] = {

		["attack_count"] = 2,

		["skills"] = {

			{ ["id"] = 41031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41031002, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41031004, ["state"] = "Attack3", ["index"] = 3, ["no_action"] = false  },
			{ ["id"] = 41031003, ["state"] = "Attack4", ["index"] = 4, ["no_action"] = false  },
			{ ["id"] = 41031005, ["state"] = "", ["index"] = 5, ["no_action"] = true  },
		},

	},

	["Jiangongdifeiya"] = {

		["attack_count"] = 1,

		["skills"] = {

			{ ["id"] = 41041001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41041002, ["state"] = "Skill1", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41041003, ["state"] = "Skill2", ["index"] = 3, ["no_action"] = false  },
		},	

	},

	["Kuangnuqishi"] = {

		["attack_count"] = 2,

		["skills"] = {

			{ ["id"] = 41031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41031002, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41031004, ["state"] = "Skill1", ["index"] = 3, ["no_action"] = false  },
			{ ["id"] = 41031003, ["state"] = "Skill2", ["index"] = 4, ["no_action"] = false  },
			{ ["id"] = 41031005, ["state"] = "", ["index"] = 5, ["no_action"] = true  },
		},

	},

	["Shahaisishen"] = {

		["attack_count"] = 2,

		["skills"] = {

			{ ["id"] = 41031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41031002, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41031004, ["state"] = "Skill1", ["index"] = 3, ["no_action"] = false  },
			{ ["id"] = 41031003, ["state"] = "Skill3", ["index"] = 4, ["no_action"] = false  },
			{ ["id"] = 41031005, ["state"] = "", ["index"] = 5, ["no_action"] = true  },
		},

	},

	["Jijinghaiwang"] = {

		["attack_count"] = 2,

		["skills"] = {

			{ ["id"] = 41031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41031002, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41031004, ["state"] = "Skill1", ["index"] = 3, ["no_action"] = false  },
			{ ["id"] = 41031003, ["state"] = "Skill2", ["index"] = 4, ["no_action"] = false  },
			{ ["id"] = 41031005, ["state"] = "", ["index"] = 5, ["no_action"] = true  },
		},

	},

	["Taotie"] = {

		["attack_count"] = 2,

		["skills"] = {

			{ ["id"] = 41031001, ["state"] = "Attack1", ["index"] = 1, ["no_action"] = false  },
			{ ["id"] = 41031002, ["state"] = "Attack2", ["index"] = 2, ["no_action"] = false  },
			{ ["id"] = 41031004, ["state"] = "Skill1", ["index"] = 3, ["no_action"] = false  },
			{ ["id"] = 41031003, ["state"] = "Skill2", ["index"] = 4, ["no_action"] = false  },
			{ ["id"] = 41031005, ["state"] = "", ["index"] = 5, ["no_action"] = true  },
		},

	},

};


-- 掉落物品飞行特效名称
const.DropItemFlyEffectNames = {

	-- 白
    [0] = {
            
    	["ground"] = "shiqu_dimianfankui",				-- 掉落到地面上播放的光效
        ["exhibit"] = "shiqu_dimianchangtai_baise",		-- 在地面上的常态特效
        ["fly"] = "shiqu_tuowei_baise",					-- 拾取时飞向角色的拖尾特效
        ["absorb"] = "shiqu_fankui_baise"				-- 飞到角色后播放的吸收特效
    },

    -- 绿
    [1] = {
            
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_lvse",
        ["fly"] = "shiqu_tuowei_lvse",
        ["absorb"] = "shiqu_fankui_lvse"
    },
    
    -- 蓝
    [2] = {
        
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_lanse",
        ["fly"] = "shiqu_tuowei_lanse",
        ["absorb"] = "shiqu_fankui_lanse"
    },
    
    -- 紫
    [3] = {
            
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_zise",
        ["fly"] = "shiqu_tuowei_zise",
        ["absorb"] = "shiqu_fankui_zise"        
    },
    
    -- 橙
    [4] = {
            
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_chengse",
        ["fly"] = "shiqu_tuowei_chengse",
        ["absorb"] = "shiqu_fankui_chengse"        
    },

    -- 橙
    [5] = {
            
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_chengse",
        ["fly"] = "shiqu_tuowei_chengse",
        ["absorb"] = "shiqu_fankui_chengse"        
    },
    
    -- 橙
    [6] = {
          
        ["ground"] = "shiqu_dimianfankui",
        ["exhibit"] = "shiqu_dimianchangtai_chengse",
        ["fly"] = "shiqu_tuowei_chengse",
        ["absorb"] = "shiqu_fankui_chengse"        
    }
};

const.EquipModel = {
	"wuqi",
	'erhuan',
	"yifu",
	"kuzi",
	"xianglian",
	"jiezi",
	"toukui",
	"jianjia",
	"shoubi",
	"xiezi"

}

--EquipQualityColor
const.qualityColor = {
	"#f6ece4",
	"#2be42f",
	"#00a8ff",
	"#e67ce6", --"#572d8b",
	"#f0a23f",
	"#969591",
	"#f0a23f",
};

const.quality = 
{
	"white",
	"green",
	"blue",
	"purple",
	"orange",
	"unidentify",
	"orangepiece"
};
const.quality = commonEnum.CreatEnumTable(const.quality,-1);

const.brokenColor = "#ff0000";

const.taskCompleteColor = "#45d238";

const.attrColor = {
	normal = "#AAAAAAFF",
	add = const.color.blue
};

const.LEVEL_ICON = {
	[1] = "wz_level_1",
	[2] = "wz_level_2",
	[3] = "wz_level_3",
	[4] = "wz_level_4",
	[5] = "wz_level_5",
	[6] = "wz_level_6",
	[7] = "wz_level_7",
	[8] = "wz_level_8",
	[9] = "wz_level_9",
	[0] = "wz_level_0",

}
const.EQUIP_ICON = {
			[1] = "tb_buwei_zhuwuqi",
			[2] = "tb_buwei_erhuan",
			[3] = "tb_buwei_yifu",
			[4] = "tb_buwei_kuzi",
			[5] = "tb_buwei_xianglian",
			[6] = "tb_buwei_jiezhi",
			[7] = "tb_buwei_toukui",
			[8] = "tb_buwei_hujian",
			[9] = "tb_buwei_shoutao",
			[10] = "tb_buwei_xiezi",
			}



const.QUALITY_BG = { 	"dk_wupinbai",
						"dk_wupinlv",
						"dk_wupinlan",
						"dk_wupinzi",
						"dk_wupincheng",
						"dk_wupinbai",
						"dk_wupincheng",
};

const.QUALITY_A_BG = {
	"dk_wupinbai_a",
	"dk_wupinlv_a",
	"dk_wupinlan_a",
	"dk_wupinzi_a",
	"dk_wupincheng_a",
}

const.QUALITY_BG_Equip = { "dk_wupinbai_renwu",
						"dk_wupinlv_renwu",
						"dk_wupinlan_renwu",
						"dk_wupinzi_renwu",
						"dk_wupincheng_renwu",
};

const.BuWeiSize = {4, 4, 1, 1, 3, 4, 3, 2, 3, 3};
const.Quality2Name = {"白", "绿", "蓝", "紫", "橙","未鉴定","碎片"};
const.BuWei = {
	"武器",
  	"耳环",
  	"衣服",
	"裤子",
	"项链",
  	"戒指",
  	"头盔",
  	"护肩",
	"手套",
	"鞋子"
}

-- 强化默认从上到下，从左到右显示用到的转换
const.TranslateIndex = {
	[1] = 1,
	[2]	= 2,
	[3] = 5,
	[4] = 6,
	[5] = 9,
	[6] = 7,
	[7] = 8,
	[8] = 3,
	[9] = 4,
	[10] = 10,
}

const.BuweiToIndex = {
	[1] = 1,
	[2] = 2,
	[3] = 8,
	[4] = 9,
	[5] = 3,
	[6] = 4,
	[7] = 6,
	[8] = 7,
	[9] = 5,
	[10] = 10,
}

const.BuWeiIndex = {
	["武器"] = 1,
  	["耳环"] = 2,
  	["衣服"] = 3,
	["裤子"] = 4,
	["项链"] = 5,
  	["戒指"] = 6,
  	["头盔"] = 7,
  	["护肩"] = 8,
	["手套"] = 9,
	["鞋子"] = 10,
}

--排序部位对应的权重
const.BuWeiChangedIndex = {
	[1] = 9,
	[2] = 6,
	[3] = 8,
	[4] = 4, 
	[5] = 7,
	[6] = 5,
	[7] = 3,
	[8] = 2,
	[9] = 1,
	[10] = 0,
}

const.model2PrefabLevel = {
	[1] = 1,
	[10] = 1,
	[20] = 20,
	[30] = 20,
	[40] = 40,
	[45] = 40,
	[50] = 50,
	[55] = 50,
	[60] = 60,
	[65] = 60,
	[70] = 70,
	[75] = 70,
	[80] = 80,
	[85] = 80,
	[90] = 90,
	[95] = 90,
}

--为了适配资源 目前有些资源缺失
const.material2PrefabLevel = {
	[1] = 1,
	[10] = 10,
	[20] = 20,
	[30] = 30,
	[40] = 40,
	[45] = 45,
	[50] = 50,
	[55] = 55,
	[60] = 60,
	[65] = 60,
	[70] = 70,
	[75] = 70,
	[80] = 80,
	[85] = 80,
	[90] = 90,
	[95] = 90,
}



--为了适配资源 目前有些资源缺失
const.weapon2PrefabLevel = {
	[1] = 1,
	[10] = 10,
	[20] = 20,
	[30] = 30,
	[40] = 40,
	[45] = 40,
	[50] = 50,
	[55] = 50,
	[60] = 60,
	[70] = 70,
	[80] = 70,
	[90] = 70,
}

--------------------------------------------
-- 技能类型 type: 1 普攻; 2 技能
--------------------------------------------

SkillType = {};
SkillType.Normal = 1;
SkillType.Skill = 2;

const.skillType = {{SkillType.Normal,1},{SkillType.Skill,1},{SkillType.Skill,2},{SkillType.Skill,3}};
const.skillIndex = { soldier = {0, 3, 4, 5}, bowman = {0, 3, 4, 5}, magician = {0, 2, 3, 4}};
const.item_type_name = {"消耗品", "材料", "任务道具", "其他"};
const.item_type = {drug = 1, prop = 2, material = 3};

const.WEAREQUIP_COUNT = 10;

const.chatChannel = 	
{
	world = 	"[世界]",
	current = 	"[当前]",
	system =	"[系统]",
	clan =	 	"[军团]",
	team = 		"[队伍]",
	email = 	"[邮件]"
}

const.richChatChannel = 	
{
	world = 	"[#510:0]",
	system =	"[#511:0]",
	clan =	 	"[#509:0]",
	team = 		"[#508:0]",
	email =     "[#511:0]"
}

const.channelColor = 
{
	world = Color.New(230 / 255, 213 /255, 157 / 255),
	system = Color.New(255 / 255, 132 /255, 20 / 255),
	clan = Color.New(88 / 255, 220 /255, 251 / 255),
	team = Color.New(103 / 255, 240 /255, 112 / 255),
	email = Color.New(62 / 255, 206 /255, 246 / 255)
}

const.systemChannelLink = Color.New(134 / 255, 210 /255, 35 / 255)

--聊天主界面相关定义
const.mainChat = 
{
	nameColor = Color.New(155, 188, 255),
	specialColor = Color.New(255, 76, 76),
	specialColor2 = Color.New(255, 181, 23),
}

const.fubenDifficultyColor = 
{
	"#c7c7c7",
	"#ec7832",
	"#ee3131"
}


const.fubenDifficulty = 
{
	"<color=#c7c7c7>普通</color>",
	"<color=#ec7832>精英</color>",
	"<color=#ee3131>地狱</color>"
}

const.fubenDifficulty_text = 
{
	"普通",
	"精英",
	"地狱"
}

const.fubenDifficultyBg = { "dk_putong",
						"dk_jinying",
						"dk_diyu"
};

const.fubenDifficultyBg2 = { "dk_suijipipei_putong",
						"dk_suijipipei_jingying",
						"dk_suijipipei_diyu"
};

const.anchor = {
	left_top = Vector2.New(0, 1),
	left_middle = Vector2.New(0, 0.5),
	middle_top = Vector2.New(0.5, 1),
	middle_middle = Vector2.New(0.5, 0.5),

}
const.chatChannelName = {"friend", "team", "clan", "world", "system", "email"}

const.operateFloatPos = {
	chat = {pos = Vector2.New(591.3,152.5),anchorMin = const.anchor.left_middle, anchorMax = const.anchor.left_middle,  pivot = const.anchor.left_top},
	team = {pos = Vector2.New(274,-207.9),anchorMin = Vector2.New(0, 1), anchorMax = Vector2.New(0, 1), pivot = const.anchor.left_top},--(224,-201)
	head = {pos = Vector2.New(-153.2,-84.7), anchorMin = Vector2.New(0.5, 1), anchorMax = Vector2.New(0.5, 1), pivot = const.anchor.left_top},--(138,-13)
	rank = {pos = Vector2.New(-470, 238.5), anchorMin = Vector2.New(0.5, 0.5), anchorMax = Vector2.New(0.5, 0.5), pivot = const.anchor.middle_top} --(-390, 195)
};

const.levelIcon ={
	[1] = "wz_dengji_1",
	[10] = "wz_dengji_10",
	[20] = "wz_dengji_20",
	[30] = "wz_dengji_20",
	[40] = "wz_dengji_40",
	[50] = "wz_dengji_50",
	[60] = "wz_dengji_60",
	[70] = "wz_dengji_70",
	[80] = "wz_dengji_80",
	[90] = "wz_dengji_90",
	[100] = "wz_dengji_100"
} 

const.baoji_icon = {
	[0] = "wz_0_jinjie",
	[1] = "wz_1_jinjie",
	[2] = "wz_2_jinjie",
	[3] = "wz_3_jinjie",
	[4] = "wz_4_jinjie",
	[5] = "wz_5_jinjie",
	[6] = "wz_6_jinjie",
	[7] = "wz_7_jinjie",
	[8] = "wz_8_jinjie",
	[9] = "wz_9_jinjie"
}  

const.QiangHuaLevel = {
	[0] = "wz_0_qianghua",
	[1] = "wz_1_qianghua",
	[2] = "wz_2_qianghua",
	[3] = "wz_3_qianghua",
	[4] = "wz_4_qianghua",
	[5] = "wz_5_qianghua",
	[6] = "wz_6_qianghua",
	[7] = "wz_7_qianghua",
	[8] = "wz_8_qianghua",
	[9] = "wz_9_qianghua"
}

const.numercialNameToId = 
{
	diamond = 10000002,
	money = 10000001,
	stone = 10020003
}

--show_type对应的排序权重，越大越靠前
const.showTypeSortWeight = 
{
	giftBox = 400000,
	equipment = 300000,
	normalItem = 200000,
    gem = 100000
}

-- 人物小图
const.RoleImgTab  = {
		["soldier"] = {"tx_soldier_0","tx_soldier_1"},
		["bowman"] = {"tx_bowman_0","tx_bowman_1"},
		["magician"] = {"tx_magician_0","tx_magician_1"}
	};

const.str = {}; 
