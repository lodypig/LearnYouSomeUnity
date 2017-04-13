
function commonEnum.CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end

function commonEnum.CreatEnumTableEx(tbl) 
    local enumtbl = {}     
    for i, v in pairs(tbl) do 
        enumtbl[i] = v 
    end 
    return enumtbl 
end

--参考 任务表中的 task_module_type 列
commonEnum.taskModuleTypeName = {
	"主线",
	"悬赏",
    "魔龙岛",
};

commonEnum.taskModuleType = {
	"ZhuXian",
	"XuanShang",
    "QuYu",
}
commonEnum.taskModuleType = commonEnum.CreatEnumTable(commonEnum.taskModuleType,0)
--用的时候可以直接 commonEnum.taskModuleType.ZhuXian, 值为1

--[task_module_type][quality]
commonEnum.taskColor = {"#f1f1f1ff","#4ba918ff","#1d97f5ff","#b940ffff","#e68829ff"};

commonEnum.taskType = {
	"KillNpc",--击杀npc
    "KillNpcGatherItem",--击杀npc收集物品
    "KillConditionNpc",--击杀满足条件npc
    "KillConditionNpcGatherItem",--击杀满足条件npc收集物品
    "DialogueNpc",--对话npc
    "GatherItem",--采集有物品
    "GatherNoItem",--采集无物品
    "ExploreRegion",--探索区域
    "PassOnItemGain",--传递物品得到
    "PassOnItmeLost",--传递物品失去
    "UseItem",--使用物品
    "ReachLevel",--达到等级
}
commonEnum.taskType = commonEnum.CreatEnumTable(commonEnum.taskType,0)

commonEnum.NpcType = {
	["NpcType_Normal"] = 0,
	["NpcType_Elite"] = 1,
	["NpcType_Boss"] = 2,
	["NpcType_FBNormal"] = 3,
	["NpcType_FBElite"] = 4,
	["NpcType_FBBoss"] = 5,
	["NpcType_Other"] = 6,
    ["NpcType_Small"] = 7,
	["NpcType_Guide"] = 8,

	["NpcType_Interaction"] = 100,
	["NpcType_Trigger"] = 101,
	["NpcType_Gather"] = 102
}

-- 头顶称号类型
commonEnum.TitleType = {
    ["HeadTitle_None"] = 0,                     --不显示称号
    ["HeadTitle_EliteMonster"] = 1,             --精英怪显示“精英”
    ["HeadTitle_WorldBoss"] = 2,                --世界BOSS显示“世界BOSS”
    ["HeadTitle_FubenBoss"] = 3,                --副本BOSS显示“副本BOSS”
    ["HeadTitle_CBTMonster"] = 4,               --藏宝图守护兽、四散魔物显示“宝藏魔物”
    ["HeadTitle_SmallBoss"] = 5                 --小BOSS显示“头目”
}
commonEnum.NpcType = commonEnum.CreatEnumTableEx(commonEnum.NpcType)


commonEnum.EquipFlagSprite = 
{
    "tb_kejianding",
    "dk_weijianding", --可鉴定
    "tb_kezhuangbei",
    "tb_kexilian",
    "tb_kezhuanyi",
    "dk_suipian",
    "tb_yizhuangbei",
    "tb_yisunhuai"
}

commonEnum.EquipFlag =
{
    "none",
    "identify", --可鉴定
    "CouldWear",
    "CouldXilian",
    "CouldZhuanyi",
    "OrangePiece",
    "Wear",
    "Broken"
}
commonEnum.EquipFlag = commonEnum.CreatEnumTable(commonEnum.EquipFlag,0)


commonEnum.NpcShowType = 
{
    "const",--常驻
    "before_task_complete",--任务完成之前显示   
    "after_task_complete" --任务完成后显示
}
commonEnum.NpcShowType = commonEnum.CreatEnumTable(commonEnum.NpcShowType)
