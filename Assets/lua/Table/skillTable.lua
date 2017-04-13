tb.SkillTable = {

[40031001] = {name = "闪电箭",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 6,energy = 0, icon = "tb_fashijineng_1" , 
attack_mode = "单体伤害", cd = 400, skill_describe = "基础的攻击技能，对目标造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,

},
[40031003] = {name = "闪电箭2",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 6,energy = 0, icon = "tb_fashijineng_1" , 
attack_mode = "单体伤害", cd = 400, skill_describe = "0", skill_value = 0,

},
[40031101] = {name = "能量风暴",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 6,energy = 0, icon = "tb_fashijineng_2" , 
attack_mode = "群体伤害", cd = 7000, skill_describe = "召唤能量风暴打击敌人，对目标及周围敌人造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "mage_female_AOE_01",
},
[40031201] = {name = "神之审判",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 6,energy = 0, icon = "tb_fashijineng_3" , 
attack_mode = "单体伤害", cd = 5000, skill_describe = "召唤神之力打击敌人，造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "fashi_jiao",
},
[40031301] = {name = "瞬移",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 1,target_needless = 1,is_harmless = 1,distance = 0,energy = 0, icon = "tb_fashijineng_4" , 
attack_mode = "单体伤害", cd = 5000, skill_describe = "将施法者传送到前方%s米处，冷却时间%s秒", skill_value = 2,
has_effect = true,start_effect1 = "mage_female_yidong_qidian",
},
[40011001] = {name = "斩击",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "tb_zhanshijineng_1" , 
attack_mode = "单体伤害", cd = 600, skill_describe = "基础的攻击技能，对目标造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "warrior_male_attack01",
},
[40011003] = {name = "斩击2",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "tb_zhanshijineng_1" , 
attack_mode = "单体伤害", cd = 600, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "warrior_male_attack02",
},
[40011005] = {name = "斩击3",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "tb_zhanshijineng_1" , 
attack_mode = "单体伤害", cd = 600, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "warrior_male_attack03",
},
[40011101] = {name = "雷霆震击",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "tb_zhanshijineng_2" , 
attack_mode = "群体伤害", cd = 7000, skill_describe = "以雷霆之势轰击目标，对目标及周围敌人造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "zhanshi_qungong",
},
[40011201] = {name = "毁灭打击",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 4,energy = 0, icon = "tb_zhanshijineng_3" , 
attack_mode = "单体伤害", cd = 5000, skill_describe = "手持燃烧的利刃攻击目标，造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,

},
[40011301] = {name = "冲锋",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 6.4,energy = 0, icon = "tb_zhanshijineng_4" , 
attack_mode = "单体伤害", cd = 5000, skill_describe = "手持武器快速突进到敌人位置，最大冲锋距离%s米，冷却时间%s秒", skill_value = 2,
has_effect = true,start_effect1 = "warrior_male_yidong",
},
[40021001] = {name = "劲射",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "tb_gongshoujineng_1" , 
attack_mode = "单体伤害", cd = 500, skill_describe = "基础的攻击技能，对目标造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,

},
[40021003] = {name = "劲射2",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "tb_gongshoujineng_1" , 
attack_mode = "单体伤害", cd = 500, skill_describe = "0", skill_value = 0,

},
[40021005] = {name = "劲射3",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "tb_gongshoujineng_1" , 
attack_mode = "单体伤害", cd = 500, skill_describe = "0", skill_value = 0,

},
[40021101] = {name = "箭雨",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "tb_gongshoujineng_2" , 
attack_mode = "群体伤害", cd = 7000, skill_describe = "向目标所在区域射出万千箭矢，对目标及周围敌人造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "archer_female_AOE",
},
[40021201] = {name = "天怒射击",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "tb_gongshoujineng_3" , 
attack_mode = "单体伤害", cd = 5000, skill_describe = "凝聚自然之怒射出致命一击，造成%s攻击伤害，同时附加%s点基础伤害", skill_value = 2,
has_effect = true,start_effect1 = "archer_female_EX",
},
[40021301] = {name = "迅捷",type = "Skill",sub_type = "NoAction",interrupt_auto_fight = 0,interrupt_auto_attack = 1,target_needless = 1,is_harmless = 1,distance = 0,energy = 0, icon = "tb_gongshoujineng_4" , 
attack_mode = "单体伤害", cd = 6000, skill_describe = "增加%s移动速度，持续%s秒，冷却时间%s秒", skill_value = 3,
has_effect = true,start_effect1 = "archer_female_special",
},
[40021401] = {name = "弓手buff效果",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "archer_female_special_buff",
},
[40012001] = {name = "专精·强化斩击",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "使<color=#ffdb9c>斩击</color>附带%s溅射伤害", skill_value = 0,

},
[40012002] = {name = "专精·怒火中烧",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>毁灭打击</color>命中后，延迟2秒钟对目标额外造成%s伤害", skill_value = 0,

},
[40012003] = {name = "专精·蓄力冲击",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>冲锋</color>会在目标位置产生冲击波，对目标及附近单位造成%s攻击伤害", skill_value = 0,

},
[40012004] = {name = "专精·拦截",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>冲锋</color>命中目标后，使目标移动速度降低%s，持续%s秒", skill_value = 0,

},
[40012005] = {name = "专精·拦截Buff",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>冲锋</color>命中目标后，使目标移动速度降低%s，持续%s秒", skill_value = 0,
has_effect = true,start_effect1 = "chuansongbaohu",
},
[40022001] = {name = "专精·强化劲射",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "使<color=#ffdb9c>劲射</color>附带%s溅射伤害", skill_value = 0,

},
[40022002] = {name = "专精·精确瞄准",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>天怒射击</color>命中后，延迟2秒钟对目标额外造成%s伤害", skill_value = 0,

},
[40022003] = {name = "专精·强化迅捷",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>迅捷</color>技能生效期间同时增加%s闪避率", skill_value = 0,
has_effect = true,start_effect1 = "archer_female_special_buff",
},
[40022004] = {name = "专精·自然亲和",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>迅捷</color>技能生效期间，每秒恢复%s生命值", skill_value = 0,
has_effect = true,start_effect1 = "fashijiaxue",
},
[40032001] = {name = "专精·强化闪电箭",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "使<color=#ffdb9c>闪电箭</color>附带%s溅射伤害", skill_value = 0,
has_effect = true,start_effect1 = "fashijiaxue",
},
[40032002] = {name = "专精·忏悔",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>神之审判</color>命中后，延迟2秒钟对目标额外造成%s伤害", skill_value = 0,

},
[40032003] = {name = "专精·虚空跳跃",type = "0",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>瞬移</color>后，移动速度增加s%，持续%s秒", skill_value = 0,

},
[40032005] = {name = "专精·虚空跳跃BUFF",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>瞬移</color>后，移动速度增加s%，持续%s秒", skill_value = 0,
has_effect = true,start_effect1 = "archer_female_special_buff",
},
[40032004] = {name = "专精·虚空愈合",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "<color=#ffdb9c>瞬移</color>后，每秒恢复%s生命值，持续%s秒", skill_value = 0,
has_effect = true,start_effect1 = "fashijiaxue",
},
[40001001] = {name = "回血技能",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 1,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 5000, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chuansongbaohu",
},
[40001002] = {name = "回血技能buff",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 5000, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chuansongbaohu",
},
[40001003] = {name = "大型生命药剂buff效果",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chiyaogx",
},
[40001010] = {name = "无敌buff",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chuansongbaohu",
},
[40001011] = {name = "离线挂机保护buff",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001020] = {name = "恶灵附身0",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001021] = {name = "恶灵附身1",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001022] = {name = "恶灵附身2",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001023] = {name = "恶灵附身3",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001024] = {name = "恶灵附身4",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001025] = {name = "恶灵附身5",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40001030] = {name = "行凶状态",type = "Buff",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[41001001] = {name = "雪地迅影龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xuedixunyinglong_attack1",
},
[41001002] = {name = "冰霜食人魔普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "bingshuangshirenmo_attack1",
},
[41001003] = {name = "精灵龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "jinglinglong_attack1",
},
[41001004] = {name = "晶化卫士普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "jinghuaweishi_attack1",
},
[41001005] = {name = "蝠翼幼龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41001006] = {name = "狂怒树灵普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kuangnushuling_attack1",
},
[41001007] = {name = "魅惑魔女普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "meihuomonv_attack1",
},
[41001008] = {name = "哥布林普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gebulin_attack1",
},
[41001009] = {name = "紫兰魔鹰普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "zilanmoying_attack1",
},
[41001010] = {name = "林地妖精普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41001011] = {name = "深海恐鱼普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "shenhaikongyu_attack1",
},
[41001012] = {name = "晶蓝海马普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "jinglanhaima_attack1",
},
[41001013] = {name = "潮汐海魔普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chaoxihaimo_attack1",
},
[41001014] = {name = "裂齿海魔普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "liechihaimo_attack1",
},
[41001015] = {name = "娜迦海妖普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "najiahaiyao_attack1",
},
[41001016] = {name = "黑暗精灵普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "anyejingling_attack1",
},
[41001017] = {name = "魔晶怪普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "mojingguai_attack1",
},
[41001018] = {name = "梦魇马普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "mengyanma_attack1",
},
[41001019] = {name = "遗忘骑士普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "yiwangqishi_attack1",
},
[41001020] = {name = "撼地神牛普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "handishenniu_attack1",
},
[41001021] = {name = "黑岩红蝎普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "heiyanhongxie_attack1",
},
[41001022] = {name = "黄沙迅龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "huangshaxunlong_attack1",
},
[41001023] = {name = "赤红地蜥普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "chihongdixi_attack1",
},
[41001024] = {name = "沙尘魔像普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "shachenmoxiang_attack1",
},
[41001025] = {name = "巨岩魔像普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "juyanmoxiang_attack1",
},
[41001026] = {name = "娜迦战士普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41001027] = {name = "娜迦侍女普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "najiashinv_attack1",
},
[41001028] = {name = "深海守卫者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "shenhaishouweizhe_attack1",
},
[41001029] = {name = "鱼人战士普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "yurenzhanshi_attack1",
},
[41001030] = {name = "水晶巨鳄普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41001031] = {name = "骷髅战士普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kulouzhanshi_attack1",
},
[41001032] = {name = "火炎亡者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "huoyanwangzhe_attack1",
},
[41001033] = {name = "哀鸣游魂普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "aimingyouhun_attack1",
},
[41001034] = {name = "痛苦女妖普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "tongkunvyao_attack1",
},
[41001035] = {name = "屠杀者哈坎普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "tushazhehakan_attack1",
},
[41001036] = {name = "丛林碎地者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "conglingsuidizhe_attack1",
},
[41001037] = {name = "丛林掷矛者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "conglinzhimaozhe_attack1",
},
[41001038] = {name = "丛林巫师普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "conglinwushi_attack1",
},
[41001039] = {name = "巨刃螳螂普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "jurentanglang_attack1",
},
[41001040] = {name = "枯树魔普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kushumo_attack1",
},
[41001041] = {name = "毒刺蜥人普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "duchixiren_attack1",
},
[41001042] = {name = "裂爪巨鼠普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "liezhuajushu_attack1",
},
[41001043] = {name = "平原陆行鸟普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "pingyuanludiniao_attack1",
},
[41001044] = {name = "劈山兽普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "pishanshou_attack1",
},
[41001045] = {name = "狮虎兽普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "shihushou_attack1",
},
[41001046] = {name = "暗夜刺杀者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "anyecishazhe_attack1",
},
[41001047] = {name = "暗夜猎杀者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "anyelieshazhe_attack1",
},
[41001048] = {name = "大野猪普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "dayezhu_attack1",
},
[41001049] = {name = "恶魔清道夫普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "emoqingdaofu_attack1",
},
[41001050] = {name = "黑暗巫师普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "heipaoren_attack1",
},
[41001051] = {name = "黑袍人普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "heipaoren_attack1",
},
[41001052] = {name = "幻魔师普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "huanmoshi_attack1",
},
[41001053] = {name = "灵魂收割者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "linghunshougezhe_attack1",
},
[41001054] = {name = "吸魂魔蝠普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xihunmofu_attack1",
},
[41001055] = {name = "凶残劣魔普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xiongcanliemo_attack1",
},
[41001056] = {name = "虚空猎犬普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xukongliequan_attack1",
},
[41001057] = {name = "虚空魔眼普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xukongmoyan_attack1",
},
[41001058] = {name = "虚空魔影普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xukongmoying_attack1",
},
[41001059] = {name = "虚空行者普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xukongxingzhe_attack1",
},
[41001060] = {name = "地狱鬼牙兽普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "diyuguiyashou_attack1",
},
[41001061] = {name = "火流星普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "huoliuxing_attack1",
},
[41001062] = {name = "盗宝哥布林普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gebulin_attack1",
},
[41001063] = {name = "骷髅卫兵普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kulouzhanshi_attack1",
},
[41001064] = {name = "暗影魔龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41001065] = {name = "炽翼魔龙普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 2,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1200, skill_describe = "0", skill_value = 0,

},
[41031001] = {name = "骷髅王普攻1",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 2000, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kulouwang_attack1",
},
[41031002] = {name = "骷髅王普攻2",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 7,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 2000, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "kulouwang_attack2",
},
[41031003] = {name = "骷髅王灵魂收割",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 10000, skill_describe = "0", skill_value = 0,
warn_time = 3200,warn_ani = {type="circle",radius=5,center="source",timing="sing_ability",},has_effect = true,start_effect1 = "kulouwang_attack4",
},
[41031004] = {name = "骷髅王死亡飞镰",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 1000, skill_describe = "0", skill_value = 0,
warn_time = 4500,warn_ani = {type="deskcube",rectx=2.25,recty=5.5,center="source",timing="sing_ability",},has_effect = true,start_effect1 = "kulouwang_attack3",
},
[41031005] = {name = "骷髅王灵魂震爆召唤",type = "Skill",sub_type = "SummonSkill",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 40000, skill_describe = "0", skill_value = 0,

},
[41031006] = {name = "骷髅王灵魂震爆选中",type = "0",sub_type = "SummonSkill",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
warn_time = 3200,warn_ani = {type="circle",radius=3,center="target",timing="use_ability",},has_effect = true,start_effect1 = "kulouwang_yuanwang",
},
[41031007] = {name = "骷髅王灵魂爆炸结算",type = "Skill",sub_type = "SummonSkill",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 0, skill_describe = "0", skill_value = 0,

},
[41041001] = {name = "监工迪菲亚·普攻",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 3,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 2000, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "xukongxingzhe_attack1",
},
[41041002] = {name = "监工迪菲亚·黑暗冲击",type = "Normal",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 20000, skill_describe = "0", skill_value = 0,
warn_time = 3000,warn_ani = {type="sector",radius=4,center="source",timing="sing_ability",},has_effect = true,start_effect1 = "jiangongdifeiya1",
},
[41041003] = {name = "监工迪菲亚·暗影风暴",type = "Skill",sub_type = "None",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "单体伤害", cd = 10000, skill_describe = "0", skill_value = 0,
warn_time = 3000,warn_ani = {type="circle",radius=5,center="source",timing="sing_ability",},has_effect = true,start_effect1 = "jiangongdifeiya2",
},
[41041004] = {name = "监工迪菲亚·重伤BUFF",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40024001] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024002] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024003] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024004] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024005] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024006] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024007] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024008] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024009] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024010] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024011] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024012] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024013] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024014] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024015] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024016] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024017] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024018] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024019] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40024020] = {name = "毒箭天赋buff",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,
has_effect = true,start_effect1 = "gongshoudujian",
},
[40034001] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034002] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034003] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034004] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034005] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034006] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034007] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034008] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034009] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034010] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034011] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034012] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034013] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034014] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034015] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034016] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034017] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034018] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034019] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034020] = {name = "天赋静电场召唤技能",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034101] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034102] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034103] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034104] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034105] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034106] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034107] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034108] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034109] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034110] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034111] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034112] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034113] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034114] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034115] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034116] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034117] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034118] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034119] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
[40034120] = {name = "天赋静电场间隔次数伤害",type = "0",sub_type = "0",interrupt_auto_fight = 0,interrupt_auto_attack = 0,target_needless = 0,is_harmless = 0,distance = 0,energy = 0, icon = "0" , 
attack_mode = "0", cd = 0, skill_describe = "0", skill_value = 0,

},
}