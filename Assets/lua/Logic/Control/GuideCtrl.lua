function CreateGuideCtrl()
	local guideCtrl = {};

	guideCtrl.guideList = {};	--引导列表
	guideCtrl.guideCount = 0; 	--引导数量

	guideCtrl.curGuide = nil;	--当前引导
	guideCtrl.curStep = 0;
	guideCtrl.pause = false;

	guideCtrl.chapterGuideIdStart = 1000;

	function guideCtrl.RegisterGuide(type, condition, guide)
		guide.index = guideCtrl.guideCount + 1;
		guideCtrl.guideCount = guide.index;

		if guideCtrl.guideList[type] == nil then
			guideCtrl.guideList[type] = {};
		end

		guideCtrl.guideList[type][condition] = guide;
	end

	function guideCtrl.run()
		if AppConst.bDisableGuide then
			guideCtrl.stop();
			return;
		end

		guideCtrl.curStep = guideCtrl.curStep + 1;
		local guide = guideCtrl.curGuide;
		local step = guideCtrl.curStep;
		if guide ~= nil and step <= #guide then
			local fun = guide[step].fun;
			if fun ~= nil then
				fun(guide[step].args);
			end
		end 
	end

	function guideCtrl.stop()
		guideCtrl.curGuide = nil;
		guideCtrl.curStep = 0;
	end

	function guideCtrl.update()
		if guideCtrl.curGuide ~= nil then
			local guideStep = guideCtrl.curGuide[guideCtrl.curStep];
			if guideStep ~= nil and guideStep.status == "pause" then	
				local fun = guideStep.fun;
				if fun ~= nil then
					fun(guideStep.args);
				end
			end
		end 
	end

	function guideCtrl.startGuide(guide)
		local index = guide.index;

        ui.ShowMainUI();
        EventManager.onEvent(Event.ON_MAIN_MENU_HIDE);
		guideCtrl.curGuide = guide;
		guideCtrl.curStep = 0;
		guideCtrl.run();

		--向服务发送完成引导
		guideCtrl.completeGuide(index)
	end

	--判断是否完成该引导
	function guideCtrl.isCompleteGuide( guide )
		local index = guide.index;
		if DataCache.guideList == nil or DataCache.guideList:Contains(index) then
			return true;
		end

		return false;
	end

	function guideCtrl.firstGuide()
		if guideCtrl.guideList["special"] ~= nil then
			local guide = guideCtrl.guideList["special"]["first_game"];
			if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
				guideCtrl.startGuide(guide);
			end
		end
	end

	function guideCtrl.yiwuGuide()
		if guideCtrl.guideList["special"] ~= nil then
            local guide = guideCtrl.guideList["special"]["getYiWu"];
            if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
                guideCtrl.startGuide(guide);
            end
        end
	end

	function guideCtrl.handleLevelUp()
		local level = DataCache.myInfo.level;

		if guideCtrl.guideList["level"] ~= nil then
			local guide = guideCtrl.guideList["level"][level];
			if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
				guideCtrl.startGuide(guide);
			end
		end
	end

	function guideCtrl.handleShowUI(uiName)

		if guideCtrl.guideList["showui"] ~= nil then
			local guide = guideCtrl.guideList["showui"][uiName];
			if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
				guideCtrl.startGuide(guide);
			end
		end
	end

	function guideCtrl.handleCompleteTask(taskId)
		if guideCtrl.guideList["task"] ~= nil then
			local guide = guideCtrl.guideList["task"][taskId];
			if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
				guideCtrl.startGuide(guide);
			end
		end
	end

	function guideCtrl.handleChangeScene(sceneId)
		if guideCtrl.guideList["scene"] ~= nil then
			local guide = guideCtrl.guideList["scene"][sceneId];
			if guide ~= nil and not guideCtrl.isCompleteGuide(guide) then
				--切换到引导掠夺场景时默认切换到和平模型）
				if DataCache.scene_sid == 20040004 and AvatarCache.me.pk_mode == "quanti" then
					local msg = { cmd = "pk_mode_change",  pk_mode = "heping" };
		            Send(msg,  MainUI.onKillCallback);
		        end
				guideCtrl.startGuide(guide);
			end
		end

		--章节引导
		guideCtrl.checkChapterGuide(sceneId);
		
	end

	function guideCtrl.checkChapterGuide(sceneId )
		local chapter = guideCtrl.getChapter(sceneId);
		if chapter ~= nil then
			local guideIndex = chapter.chapterId + guideCtrl.chapterGuideIdStart;
			if not guideCtrl.isCompleteGuide({index = guideIndex}) and guideCtrl.isTaskProgress(chapter.taskId) then
				--显示章节压幕
	        	PanelManager:CreateFullScreenPanel('UIChapterCurtain',function() end, chapter);
	 
				guideCtrl.completeGuide(guideIndex)
			end
		end
	end

	--判断关联的任务是否正在进行
	function guideCtrl.isTaskProgress(taskId)		
		local taskList = client.task.getTaskList();
		for i=1,#taskList do
            if taskList[i].sid == taskId then
               	return true;
            end
    	end

    	return false;
	end
	
	--获得与场景关联的章节数据
	function guideCtrl.getChapter(sceneId)
		for i=1, #tb.chapterTable do
			if tb.chapterTable[i].sceneId == sceneId then
				return tb.chapterTable[i];
			end
		end

		return nil;
	end

	function guideCtrl.completeGuide(index)
		DataCache.guideList:Add(index);
		local msg = {cmd = "complete_guide", index = index};
		Send(msg);
	end

	EventManager.register(Event.ON_LEVEL_UP, guideCtrl.handleLevelUp);
	EventManager.register(Event.ON_GUIDE_SHOW_UI, guideCtrl.handleShowUI);
	EventManager.register(Event.ON_GUIDE_COMPLETE_TASK, guideCtrl.handleCompleteTask);
	EventManager.register(Event.ON_GUIDE_CHANGE_SCENE, guideCtrl.handleChangeScene);

	InitGuideStep(guideCtrl);

	return guideCtrl;
end

GuideManager = CreateGuideCtrl();