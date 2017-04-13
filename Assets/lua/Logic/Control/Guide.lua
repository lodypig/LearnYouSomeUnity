--[[
ShowGuide参数说明
1.显示文本 
2.按钮路径
3.引导样式(圆形:"circle", 方形:"rect")
4.遮罩显示(显示:"showMask", 隐藏:"hideMask")

GuideDelay参数说明
1.延迟时间

RegisterGuide参数说明
1.引导触发类型
2.触发条件
3.引导内容

--]]

function InitGuideStep(guideCtrl)
	local guide = {
		--ShowGuide("拖动<color=#66d52d>摇杆</color>进行移动", "MainUI.Joystick.Area");
		ShowGuide("点击即可<color=#66d52d>追踪任务</color>", "MainUITask.RightTask.taskPanel.taskList.Grid._Content.Task1.Panel");
	}
	guideCtrl.RegisterGuide("special", "first_game", guide);

	
	


	--装备强化引导，5级任务触发
	local guide = {
		ShowGuide("来试试<color=#66d52d>强化装备</color>吧！", "MainUI.menu", "circle", "showMask");
		GuideDelay(0.4);
		ShowGuide("点击进入<color=#66d52d>装备强化</color>界面", "MainUI.menuGroup.Grid1.Btn2", "circle", "showMask");
		ShowGuide("选择需要强化的装备", "UIWorkShopNew.content.LeftContent._EquipGrid.equip1", "rect", "hideMask");
		ShowGuide("每次强化增长一定的<color=#66d52d>熟练度</color>", "UIWorkShopNew.content.EnhancePanel.BtnEnhance", "circle", "hideMask");
		ShowGuide("<color=#66d52d>熟练度</color>满时强化成功", "UIWorkShopNew.content.EnhancePanel.BtnEnhance", "circle", "hideMask");
		ShowGuide("<color=#66d52d>全身强化</color>可直接培养全身装备至下一级", "UIWorkShopNew.content.EnhancePanel.BtnAll", "circle", "hideMask");

	};
	guideCtrl.RegisterGuide("task", 50000017, guide);

	--技能升级引导，任务触发
	local guide = {
		ShowGuide("来试试<color=#66d52d>升级技能</color>吧", "MainUI.menu", "circle", "showMask");
		GuideDelay(0.4);
		ShowGuide("点击进入<color=#66d52d>技能升级</color>界面", "MainUI.menuGroup.Grid1.Btn3", "circle", "showMask");
		ShowGuide("选择需要升级的技能", "UISkillNew.SkillPanel.BtnGroup.activeSkill.skillItem1", "rect", "hideMask");
		ShowGuide("升级技能需要消耗<color=#66d52d>技能点</color>", "UISkillNew.SkillPanel.Top.skillPoint", "rect", "hideMask");
		ShowGuide("点击<color=#66d52d>升级</color>技能", "UISkillNew.SkillPanel.Info.levelUpBtn", "circle", "hideMask");
	};
	guideCtrl.RegisterGuide("task", 50000022, guide);
	
	

	--地图传送引导，任务触发
	local guide = {
		ShowGuide("微风平原很远？通过<color=#66d52d>地图传送</color>可快速到达！", "MainUI.ditu.mask", "circle", "showMask");
		ShowGuide("打开<color=#66d52d>世界地图</color>", "UIAreaMap.CommonDlg.ButtonGroup.btn2", "circle", "showMask");
		ShowGuide("点击前往<color=#66d52d>微风平原</color>", "UIAreaMap._worldMap.bk.weifengpingyuan", "circle", "showMask");
	};
	guideCtrl.RegisterGuide("task", 50000024, guide);


	--坐骑系统，任务触发
	local guide = {
		ShowGuide("你获得了一匹新的<color=#66d52d>坐骑</color>，快去看看吧！", "MainUI.menu", "circle", "showMask");
		GuideDelay(0.4);
		ShowGuide("点击进入<color=#66d52d>角色界面</color>", "MainUI.menuGroup.Grid1.Btn1", "circle", "showMask");
		ShowGuide("点击进入<color=#66d52d>坐骑界面</color>", "NewUIRole.CommonDlg.ButtonGroup.btn2", "circle", "showMask");
		ShowGuide("坐骑加成属性，即使未激活也可生效哦！", "NewUIRole.HorsePanel.ndRight._ndTrain.ndAttrContent", "rect", "showMask");
		ShowGuide("此坐骑培养至2阶<color=#66d52d>可骑乘</color>！", "NewUIRole.HorsePanel.ndRight._ndTrain.ndTop", "rect", "showMask");
		ShowGuide("使用<color=#66d52d>饲料</color>对坐骑进行<color=#66d52d>培养</color>", "NewUIRole.HorsePanel.ndRight._ndTrain.ndCost._btnTrain", "circle", "hideMask");
		 	
	};
	guideCtrl.RegisterGuide("task", 50000039, guide);


	--装备洗炼第1次
	local guide = {
		ShowGuide("想要给装备增加或替换属性？来试试<color=#66d52d>装备洗炼</color>吧", "MainUI.Bag", "circle", "showMask");
		ShowGuide("选择用来<color=#66d52d>提取属性</color>的装备", "NewUIRole.BagPanel.bagCon.Container.Grid.Content.0", "circle", "hideMask");
		ShowGuide("点击进入<color=#66d52d>洗炼界面</color>", "EquipFloat.content.equip2.Button.Right.btn1", "circle", "hideMask");
		ShowGuide("此处为身上装备的<color=#66d52d>附加属性</color>，最多为6条", "xilian._content._leftEquip", "rect", "showMask");
		ShowGuide("选择一条空的<color=#66d52d>属性条目</color>", "xilian._content._leftEquip._addAttr._attr4", "rect", "showMask");
		ShowGuide("洗炼将会<color=#66d52d>随机</color>提取一条属性", "xilian._content._rightEquip", "rect", "showMask");
		ShowGuide("点击<color=#66d52d>洗炼</color>加入新属性", "xilian._content._btn", "circle", "hideMask");
		ShowGuide("运气真好！抽中了最好的<color=#66d52d>属性</color>", "xilianSuccess.Image._btnOK", "circle", "hideMask");
		ShowGuide("请继续出发寻找智慧之神吧！", "NewUIRole.CommonDlg.Close", "circle", "hideMask");
	};
	guideCtrl.RegisterGuide("task", 50000044, guide);

	--装备洗炼第2次
	local guide = {
		ShowGuide("又有新的装备可以<color=#66d52d>洗炼</color>了哦", "MainUI.Bag", "circle", "showMask");
		ShowGuide("选择用来<color=#66d52d>提取属性</color>的装备", "NewUIRole.BagPanel.bagCon.Container.Grid.Content.0", "circle", "hideMask");
		ShowGuide("点击进入<color=#66d52d>洗炼界面</color>", "EquipFloat.content.equip2.Button.Right.btn1", "circle", "hideMask");
		ShowGuide("点击<color=#66d52d>洗炼</color>加入新属性", "xilian._content._btn", "circle", "hideMask");
	};
	guideCtrl.RegisterGuide("task", 50000045, guide);
	


	--悬赏任务引导，任务触发
	local guide = {
		ShowGuide("没有任务可做了？来试试<color=#66d52d>悬赏任务</color>吧", "MainUI.btnGroup.BtnActivity", "circle", "showMask");
		ShowGuide("点击进入<color=#66d52d>悬赏任务界面</color>", "UIActivity.Panel.DailyPanel.Top.view.viewport.content.0.Item.btn.text", "circle", "hideMask");
		ShowGuide("此处包含悬赏任务的<color=#66d52d>品质</color>、<color=#66d52d>奖励</color>、<color=#66d52d>目标</color>等信息", "UIRewardTask.Panel.TaskInfo.1", "rect", "showMask");
		ShowGuide("使用<color=#66d52d>悬赏令</color>可以刷新任务，刷新不会使得任务品质变低", "UIRewardTask.Panel.Refresh", "circle", "hideMask");
		--GuideDelay(0.5);
		ShowGuide("点击<color=#66d52d>追踪</color>即可在主界面追踪该任务", "UIRewardTask.Panel.TaskInfo.2.Btn.Text", "circle", "hideMask");
	};
	guideCtrl.RegisterGuide("task", 50000069, guide);
	
	
	
	--掠夺引导
	local guide = {
		ShowGuide("切换至“屠杀”模式才能击杀其他玩家", "MainUI.player.pk_model", "circle", "showMask");
	};
	guideCtrl.RegisterGuide("scene", 20040004, guide);

	local guide = {
		ShowGuide("成功击杀目标，赶快拾取其掉落的遗物吧", "MainUI.OpenTreasure", "circle", "showMask");
		ShowGuide("拾取遗物将会增加恶名值", "UIGetYiWu.Panel._back._BtnConfirm", "circle", "showMask");
	}
	guideCtrl.RegisterGuide("special", "getYiWu", guide);

	--[[
	local guide = {
		ShowGuide("打开界面触发1", "UIRole.AttrPanel.CheckBox.ButtonGroup.btn2", "rect", "showMask");
		ShowGuide("打开界面触发2", "UIRole.CommonDlg.ButtonGroup.btn2", "rect", "showMask");
		ShowGuide("打开界面触发2", "UIRole.CommonDlg.Close", "rect", "hideMask");
	};
	guideCtrl.RegisterGuide("showui", "UIRole", guide);
	--用于测试引导第一次进入某界面触发
	--]]
	
end
