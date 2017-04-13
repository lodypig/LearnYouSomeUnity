tb.TalentTable = {

[40013003] = {name = "破甲",career = "soldier", needLevel = 30, count = 1, 
desc = "攻击时有$概率忽视目标$的防御力", next_desc = "攻击时有$概率忽视目标$的防御力", learn_desc = "攻击时有$概率忽视目标$的防御力", need_broadcast = 1, 
show_name = "破甲", float_text = "C", effect = " ", icon = "tb_zhanshi_3", mask_icon = "tb_zhanshi_3_b", type = "Attack", sub_type = "Normal"}, 

[40013004] = {name = "刚毅",career = "soldier", needLevel = 45, count = 1, 
desc = "受击时有$的概率，减少$的伤害", next_desc = "受击时有$的概率，减少$的伤害", learn_desc = "受击时有$的概率，减少$的伤害", need_broadcast = 1, 
show_name = "坚毅", float_text = "D", effect = " ", icon = "tb_zhanshi_4", mask_icon = "tb_zhanshi_4_b", type = "Defence", sub_type = "Normal"}, 

[40013001] = {name = "嗜血",career = "soldier", needLevel = 60, count = 1, 
desc = "攻击时有$概率额外造成$的伤害，并将本次伤害的$转化为生命值", next_desc = "攻击时有$概率额外造成$的伤害，并将本次伤害的$转化为生命值", learn_desc = "攻击时有$概率额外造成$的伤害，并将本次伤害的$转化为生命值", need_broadcast = 1, 
show_name = "吸血", float_text = "A", effect = " ", icon = "tb_zhanshi_1", mask_icon = "tb_zhanshi_1_b", type = "Attack", sub_type = "Normal"}, 

[40013002] = {name = "反震",career = "soldier", needLevel = 70, count = 1, 
desc = "受击时有$的概率将本次受到攻击的$反弹给攻击者", next_desc = "受击时有$的概率将本次受到攻击的$反弹给攻击者", learn_desc = "受击时有$的概率将本次受到攻击的$反弹给攻击者", need_broadcast = 1, 
show_name = "反震", float_text = "B", effect = " ", icon = "tb_zhanshi_2", mask_icon = "tb_zhanshi_2_b", type = "Defence", sub_type = "Normal"}, 

[40023001] = {name = "烈弓",career = "bowman", needLevel = 30, count = 1, 
desc = "攻击时有$的几率，将本次攻击的伤害提高$", next_desc = "攻击时有$的几率，将本次攻击的伤害提高$", learn_desc = "攻击时有$的几率，将本次攻击的伤害提高$", need_broadcast = 1, 
show_name = "烈弓", float_text = "E", effect = " ", icon = "tb_gongshou_1", mask_icon = "tb_gongshou_1_b", type = "Attack", sub_type = "Normal"}, 

[40023004] = {name = "灵动",career = "bowman", needLevel = 45, count = 1, 
desc = "受到攻击时，有$的几率完全躲避本次伤害", next_desc = "受到攻击时，有$的几率完全躲避本次伤害", learn_desc = "受到攻击时，有$的几率完全躲避本次伤害", need_broadcast = 1, 
show_name = "灵动", float_text = "H", effect = " ", icon = "tb_gongshou_4", mask_icon = "tb_gongshou_4_b", type = "Defence", sub_type = "Normal"}, 

[40023002] = {name = "狙心",career = "bowman", needLevel = 60, count = 1, 
desc = "攻击时对生命值低于$的目标造成额外$的伤害", next_desc = "攻击时对生命值低于$的目标造成额外$的伤害", learn_desc = "攻击时对生命值低于$的目标造成额外$的伤害", need_broadcast = 1, 
show_name = "狙心", float_text = "F", effect = " ", icon = "tb_gongshou_2", mask_icon = "tb_gongshou_2_b", type = "Attack", sub_type = "Negative"}, 

[40023003] = {name = "毒箭",career = "bowman", needLevel = 70, count = 1, 
desc = "攻击时有$概率使目标中毒，造成持续伤害，持续$秒", next_desc = "攻击时有$概率使目标中毒，造成持续伤害，持续$秒", learn_desc = "攻击时有$概率使目标中毒，造成持续伤害，持续$秒", need_broadcast = 1, 
show_name = "毒箭", float_text = "G", effect = " ", icon = "tb_gongshou_3", mask_icon = "tb_gongshou_3_b", type = "Attack", sub_type = "Normal"}, 

[40033001] = {name = "连雷",career = "magician", needLevel = 30, count = 1, 
desc = "攻击时有$几率触发雷电共鸣，对目标额外造成一次闪电箭$的伤害", next_desc = "攻击时有$几率触发雷电共鸣，对目标额外造成一次闪电箭$的伤害", learn_desc = "攻击时有$几率触发雷电共鸣，对目标额外造成一次闪电箭$的伤害", need_broadcast = 1, 
show_name = "连雷", float_text = "I", effect = "位置特效(name=fashilianlei;elapsedTime=5.0;target=受击者;offset=(0,0.1,0))", icon = "tb_fashi_1", mask_icon = "tb_fashi_1_b", type = "Attack", sub_type = "Normal"}, 

[40033003] = {name = "魔甲",career = "magician", needLevel = 45, count = 1, 
desc = "受击时有$的几率施放魔甲术吸收$的伤害", next_desc = "受击时有$的几率施放魔甲术吸收$的伤害", learn_desc = "受击时有$的几率施放魔甲术吸收$的伤害", need_broadcast = 1, 
show_name = "化伤", float_text = "K", effect = "绑定特效(name=huashangtianfu;elapsedTime=1.0)", icon = "tb_fashi_3", mask_icon = "tb_fashi_3_b", type = "Defence", sub_type = "Normal"}, 

[40033004] = {name = "静电",career = "magician", needLevel = 60, count = 1, 
desc = "攻击时有$的几率在当前目标所在位置留下静电力场，对处于其中的可攻击单位造成伤害，持续$秒", next_desc = "攻击时有$的几率在当前目标所在位置留下静电力场，对处于其中的可攻击单位造成伤害，持续$秒", learn_desc = "攻击时有$的几率在当前目标所在位置留下静电力场，对处于其中的可攻击单位造成伤害，持续$秒", need_broadcast = 1, 
show_name = "静电", float_text = "L", effect = "位置特效(name=jingdianlichang;elapsedTime=4.5;target=受击者;offset=(0,0.1,0))", icon = "tb_fashi_4", mask_icon = "tb_fashi_4_b", type = "Attack", sub_type = "Exclusive"}, 

[40033002] = {name = "充能",career = "magician", needLevel = 70, count = 1, 
desc = "所有技能伤害提高$", next_desc = "所有技能伤害提高$", learn_desc = "所有技能伤害提高$", need_broadcast = 1, 
show_name = "充能", float_text = "J", effect = " ", icon = "tb_fashi_2", mask_icon = "tb_fashi_2_b", type = "Attack", sub_type = "Negative"}, 

}