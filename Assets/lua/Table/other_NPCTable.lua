if tb.NPCTable == nil then
    tb.NPCTable = {}
end

tb.NPCTable[10010051] = {description = "传送水晶",name = "传送水晶",showname = 0,canclick = false,type = 101,
mask = 4,style = "Portal4",style_scale = 1.3,script = "PortalCrystal",attr_level = 20,static= "true",chose_area = "4,4,4", show_type = 1,
}
tb.NPCTable[10010052] = {description = "普通秘境入口",name = "普通秘境入口",canclick = false,type = 101,
mask = 4,style = "NMiJing",style_scale = 1,script = "cbtMJCtrl",attr_level = 20,static= "true",chose_area = "3,4,3", show_type = 1,
}
tb.NPCTable[10010053] = {description = "高级秘境入口",name = "高级秘境入口",canclick = false,type = 101,
mask = 4,style = "SMiJing",style_scale = 1,script = "cbtMJCtrl",attr_level = 20,static= "true",chose_area = "3,4,3", show_type = 1,
}
tb.NPCTable[10010054] = {description = "过图点1",name = "3",showname = 0,canclick = false,type = 101,
mask = 4,style = "Portal1",style_scale = 0.5,script = "TransmitPoint",attr_level = 20,static= "true",chose_area = "4,4,4", show_type = 1,
}
tb.NPCTable[10010055] = {description = "过图点2",name = "3",showname = 0,canclick = false,type = 101,
mask = 4,style = "Portal1",style_scale = 0.5,script = "TransmitPoint",attr_level = 20,static= "true",chose_area = "4,4,4", show_type = 1,
}
tb.NPCTable[10010056] = {description = "过图点3",name = "3",showname = 0,canclick = false,type = 101,
mask = 4,style = "Portal1",style_scale = 0.5,script = "TransmitPoint",attr_level = 20,static= "true",chose_area = "4,4,4", show_type = 1,
}
tb.NPCTable[10010057] = {description = "过图点4",name = "3",showname = 0,canclick = false,type = 101,
mask = 4,style = "Portal1",style_scale = 0.5,script = "TransmitPoint",attr_level = 20,static= "true",chose_area = "4,4,4", show_type = 1,
}
tb.NPCTable[10010100] = {description = "村长",name = "村长",canclick = true,type = 100,
mask = 4,style = "najiashinv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[10010101] = {description = "陆仁甲",name = "陆仁甲",canclick = true,type = 100,
mask = 4,style = "conglinwushi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[10010102] = {description = "肖炳义",name = "肖炳义",canclick = true,type = 100,
mask = 4,style = "tushazhehakan",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[10010103] = {description = "隋忠定",name = "隋忠定",canclick = true,type = 100,
mask = 4,style = "yurenzhanshi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[80010001] = {description = "魔晶矿石",name = "魔晶矿石",canclick = false,type = 102,
mask = 4,style = "weifengyihuizhang",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 1,collect_scope = 5,respond_time = 500,collect_time = 5000,collect_msg = "采集魔晶矿石",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[80010002] = {description = "魔晶矿石2",name = "魔晶矿石2",canclick = false,type = 102,
mask = 4,style = "weifengyihuizhang",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 500,collect_time = 5000,collect_msg = "采集魔晶矿石",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[80010003] = {description = "魔晶矿石3",name = "魔晶矿石3",canclick = false,type = 102,
mask = 4,style = "weifengyihuizhang",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 3,collect_character = 3,collect_scope = 5,respond_time = 500,collect_time = 5000,collect_msg = "采集魔晶矿石",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[80010004] = {description = "藏宝箱",name = "藏宝箱",canclick = false,type = 100,
mask = 4,style = "baoxiang",style_scale = 1,ai = 1308,attr_level = 1,static= "true", effect = "body", show_type = 1,
}
tb.NPCTable[80010005] = {description = "金币堆",name = "金币堆",canclick = false,type = 102,
mask = 4,style = "jinbi1",style_scale = 2,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 3,respond_time = 700,collect_time = 3000,collect_msg = "收集金币", show_type = 1,
}
tb.NPCTable[80010006] = {description = "钻石堆",name = "钻石堆",canclick = false,type = 102,
mask = 4,style = "zuanshi1",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 3,respond_time = 700,collect_time = 3000,collect_msg = "收集钻石", show_type = 1,
}
tb.NPCTable[80010007] = {description = "龙蛋",name = "龙蛋",canclick = false,type = 102,
mask = 4,style = "longdan1",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 3,respond_time = 700,collect_time = 3000,collect_msg = "破坏龙蛋", show_type = 1,
}
tb.NPCTable[80010008] = {description = "能量石",name = "能量石",canclick = false,type = 102,
mask = 4,style = "nengliangshi",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 1,collect_character = 1,collect_scope = 3,respond_time = 700,collect_time = 2000,collect_msg = "采集能量石", show_type = 1,
}
tb.NPCTable[80010009] = {description = "祭坛",name = "祭坛",canclick = false,type = 100,
mask = 4,style = "jitan",style_scale = 1,attr_level = 1,static= "true", show_type = 1,
}
tb.NPCTable[90010001] = {description = "大祭司",name = "大祭司",canclick = true,type = 100,
mask = 4,style = "dajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010002] = {description = "黑魔师梅林",name = "黑魔师梅林",canclick = true,type = 100,
mask = 4,style = "heimoshimeilin",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010003] = {description = "精灵公主",name = "精灵公主",canclick = true,type = 100,
mask = 4,style = "jinglinggonzhu",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010004] = {description = "军团使者",name = "军团使者",canclick = true,type = 100,
mask = 4,style = "juntuanshizhe",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010005] = {description = "军团执政官",name = "军团执政官",canclick = true,type = 100,
mask = 4,style = "juntuanzhizhengguang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010006] = {description = "老年人",name = "老年人",canclick = true,type = 100,
mask = 4,style = "laonianren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010007] = {description = "雷狼副卫",name = "雷狼副卫",canclick = true,type = 100,
mask = 4,style = "leilangfuwei",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010008] = {description = "雷霆将军",name = "雷霆将军",canclick = true,type = 100,
mask = 4,style = "leitingjiangjun",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010009] = {description = "密教大祭司",name = "密教大祭司",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010010] = {description = "年轻人",name = "年轻人",canclick = true,type = 100,
mask = 4,style = "nianqingren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010011] = {description = "农夫",name = "农夫",canclick = true,type = 100,
mask = 4,style = "nongfu",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010012] = {description = "热情的中年人",name = "热情的中年人",canclick = true,type = 100,
mask = 4,style = "reqingdezhongnianren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010013] = {description = "少女",name = "少女",canclick = true,type = 100,
mask = 4,style = "shaonv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010014] = {description = "微风议会长",name = "微风议会长",canclick = true,type = 100,
mask = 4,style = "weifengyihuizhang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010015] = {description = "小男孩",name = "小男孩",canclick = true,type = 100,
mask = 4,style = "xiaonanhai",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010016] = {description = "小女孩",name = "小女孩",canclick = true,type = 100,
mask = 4,style = "xiaonvhai",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010017] = {description = "行商",name = "行商",canclick = true,type = 100,
mask = 4,style = "xingshang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010018] = {description = "中年妇女",name = "中年妇女",canclick = true,type = 100,
mask = 4,style = "zhongnianfunv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000001] = {description = "神秘少女",name = "神秘少女",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 2, task_sid = 50000001,
}
tb.NPCTable[30000002] = {description = "菲恩",name = "菲恩",canclick = true,type = 100,
mask = 4,style = "juntuanshizhe",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000003] = {description = "拉尔",name = "拉尔",canclick = true,type = 100,
mask = 4,style = "nianqingren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000004] = {description = "迪恩长老",name = "迪恩长老",canclick = true,type = 100,
mask = 4,style = "dienlaoshi_sm",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000005] = {description = "薇娜",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000006] = {description = "安妮",name = "安妮",canclick = true,type = 100,
mask = 4,style = "shaonv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000007] = {description = "墨菲斯特",name = "墨菲斯特",canclick = true,type = 100,
mask = 4,style = "reqingdezhongnianren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000008] = {description = "薇娜",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000009] = {description = "墨菲斯特",name = "墨菲斯特",canclick = true,type = 100,
mask = 4,style = "reqingdezhongnianren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000010] = {description = "惊慌的村民",name = "惊慌的村民",canclick = true,type = 100,
mask = 4,style = "laonianren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000011] = {description = "永恒使徒",name = "永恒使徒",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000012] = {description = "影子普拉尔",name = "影子普拉尔",canclick = true,type = 100,
mask = 4,style = "heipaoren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000013] = {description = "迪恩长老",name = "迪恩长老",canclick = true,type = 100,
mask = 4,style = "dienlaoshi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000014] = {description = "大长老巴伦",name = "大长老巴伦",canclick = true,type = 100,
mask = 4,style = "weifengyihuizhang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000015] = {description = "净化者骑士",name = "净化者骑士",canclick = true,type = 100,
mask = 4,style = "jinghuazheqishi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000016] = {description = "潮汐狂徒",name = "潮汐狂徒",canclick = true,type = 100,
mask = 4,style = "yanrichaoxidangtu_attack",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000017] = {description = "薇娜（光咏城1）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000018] = {description = "圣咏者",name = "圣咏者",canclick = true,type = 100,
mask = 4,style = "mijiaochengyuan",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000019] = {description = "永恒使徒（光咏城）",name = "永恒使徒",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000020] = {description = "智慧使徒（光咏城）",name = "智慧使徒",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000021] = {description = "审判使徒（光咏城）",name = "审判使徒",canclick = true,type = 100,
mask = 4,style = "leitingjiangjun",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000022] = {description = "莱温特（光咏城）",name = "赏金会长莱温特",canclick = true,type = 100,
mask = 4,style = "laiwente",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000023] = {description = "德卡（光咏城）",name = "德卡",canclick = true,type = 100,
mask = 4,style = "nianqingren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000024] = {description = "域外者（光咏城）",name = "域外者",canclick = true,type = 100,
mask = 4,style = "kuanggong",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000025] = {description = "薇娜（光咏城2）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000026] = {description = "汤姆（微风平原）",name = "汤姆",canclick = true,type = 100,
mask = 4,style = "kuanggong",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000027] = {description = "杰瑞（微风平原）",name = "杰瑞",canclick = true,type = 100,
mask = 4,style = "nianqingren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000028] = {description = "德卡（微风平原）",name = "德卡",canclick = true,type = 100,
mask = 4,style = "xingshang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000029] = {description = "薇娜（微风平原）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000030] = {description = "域外商人（微风平原）",name = "域外商人",canclick = true,type = 100,
mask = 4,style = "kuanggong",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000031] = {description = "迪恩长老（微风平原）",name = "迪恩长老",canclick = true,type = 100,
mask = 4,style = "dienlaoshi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000032] = {description = "德卡（安息任务）",name = "德卡",canclick = true,type = 100,
mask = 4,style = "xingshang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000033] = {description = "夏莉（光咏城）",name = "夏莉",canclick = true,type = 100,
mask = 4,style = "shaonv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000034] = {description = "智慧使徒（寂静之海）",name = "智慧使徒",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000035] = {description = "莱温特（寂静之海）",name = "赏金会长莱温特",canclick = true,type = 100,
mask = 4,style = "laiwente",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000036] = {description = "娜迦统领（寂静之海）",name = "娜迦统领加西",canclick = true,type = 100,
mask = 4,style = "najiazhanshi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000037] = {description = "娜迦护卫（寂静之海对话）",name = "娜迦护卫",canclick = true,type = 100,
mask = 4,style = "najiahaiyao",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000038] = {description = "夏莉（寂静之海）",name = "夏莉",canclick = true,type = 100,
mask = 4,style = "shaonv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000039] = {description = "湮日使者（寂静之海）",name = "湮日使者",canclick = true,type = 100,
mask = 4,style = "anyejingling",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000040] = {description = "薇娜（寂静之海）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000041] = {description = "娜迦护卫（寂静之海）",name = "娜迦护卫",canclick = true,type = 100,
mask = 4,style = "najiahaiyao",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000042] = {description = "智慧使徒（夏莉之战）",name = "智慧使徒",canclick = true,type = 100,
mask = 4,style = "mijiaodajisi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000043] = {description = "莱温特（夏莉之战）",name = "赏金会长莱温特",canclick = true,type = 100,
mask = 4,style = "laiwente",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000044] = {description = "薇娜（夏莉之战）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000045] = {description = "大药剂师（微风平原）",name = "大药剂师",canclick = true,type = 100,
mask = 4,style = "kuanggong",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000046] = {description = "农场主（微风平原）",name = "农场主",canclick = true,type = 100,
mask = 4,style = "nongfu",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000047] = {description = "农奴（微风平原）",name = "农奴",canclick = true,type = 100,
mask = 4,style = "kuanggong",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000048] = {description = "德卡（微风平原2）",name = "德卡",canclick = true,type = 100,
mask = 4,style = "xingshang",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000049] = {description = "薇娜（微风平原2）",name = "薇娜",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000050] = {description = "杰瑞（微风平原2）",name = "杰瑞",canclick = true,type = 100,
mask = 4,style = "nianqingren",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000051] = {description = "夏莉（光咏城2）",name = "夏莉",canclick = true,type = 100,
mask = 4,style = "shaonv",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000052] = {description = "净化者骑士（坠月谷）",name = "净化者骑士",canclick = true,type = 100,
mask = 4,style = "jinghuazheqishi_attack",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000053] = {description = "邪恶强盗",name = "邪恶强盗",canclick = true,type = 100,
mask = 4,style = "heianwushi",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[30000054] = {description = "神秘少女",name = "神秘少女",canclick = true,type = 100,
mask = 4,style = "weina",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 3, task_sid = 50000002,
}
tb.NPCTable[30010001] = {description = "拉尔的馈赠",name = "拉尔的馈赠",canclick = false,type = 102,
mask = 4,style = "baoxiang",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "打开箱子",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[30010002] = {description = "魔能水晶",name = "魔能水晶",canclick = false,type = 102,
mask = 4,style = "chuangsongmen",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "激活魔能",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[30010003] = {description = "树灵种子",name = "树灵种子",canclick = false,type = 102,
mask = 4,style = "baoxiang",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "采集影纹草",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[30010004] = {description = "结界水晶",name = "结界水晶",canclick = false,type = 102,
mask = 4,style = "chuangsongmen",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "激活魔能",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[30010005] = {description = "结界水晶",name = "结界水晶",canclick = false,type = 102,
mask = 4,style = "chuangsongmen",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "激活魔能",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[30010006] = {description = "结界水晶",name = "结界水晶",canclick = false,type = 102,
mask = 4,style = "chuangsongmen",style_scale = 1,ai = 1302,attr_level = 1,static= "true",visible_character = 2,collect_character = 2,collect_scope = 5,respond_time = 200,collect_time = 5000,collect_msg = "激活魔能",chose_area = "0.5,0.5,0.5", effect = "body", show_type = 1,
}
tb.NPCTable[90010019] = {description = "魔龙岛商人",name = "魔龙岛商人",canclick = true,type = 101,
mask = 4,style = "xingshang",style_scale = 1,script = "MolongManCtrl",attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010020] = {description = "能量车领取处",name = "能量车领取处",canclick = true,type = 100,
mask = 4,style = "leitingjiangjun",style_scale = 1,attr_level = 20,static= "true",appellation = "帝国学者",visible_character = 1,collect_character = 1,collect_scope = 3,respond_time = 100,chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010021] = {description = "能量车",name = "能量车",canclick = false,type = 100,
mask = 4,style = "nengliangche",style_scale = 1,fightSpeed = 0.006,ai = 1310,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}
tb.NPCTable[90010030] = {description = "宝藏遗物",name = "宝藏遗物",canclick = true,type = 101,
mask = 4,style = "lueduoyiwu",style_scale = 1,script = "TreasureCtrl",fightSpeed = 0.006,ai = 1312,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "1.0,1.0,1.0", show_type = 1,
}
tb.NPCTable[90010031] = {description = "跟随能量车",name = "跟随能量车",canclick = false,type = 100,
mask = 4,style = "nengliangche",style_scale = 1,fightSpeed = 0.006,ai = 1311,attr_level = 20,static= "true",appellation = "帝国学者",chose_area = "0.5,0.5,0.5", show_type = 1,
}