--管理组队活动相关
function CreateTeamActivityCtrl()
	local teamAct = {}

	--当前选中的活动ID
	teamAct.curChooseActID = 0
	teamAct.ActivityList = {}

	teamAct.ActType = {
		shilianmijing = 1,
	}

	--TempCfg
	teamAct.GenerateActCfg = function()
		--试炼秘境
		teamAct.ActivityList = {
			[1] = {
				name = "试炼秘境",
				type = teamAct.ActType.shilianmijing,
				choose = 0,
				isFinish = false,
				isActive = true,
				subActList = {
					-- [2] = {name = "试炼秘境二层", fubenSid = 20002, isMatching = false, isFinish = false, isActive = true},
					-- [3] = {name = "试炼秘境三层", fubenSid = 20003, isMatching = false, isFinish = false, isActive = true},
					-- [1] = {name = "试炼秘境一层", fubenSid = 20001, isMatching = false, isFinish = false, isActive = true},
					-- [4] = {name = "试炼秘境四层", fubenSid = 20004, isMatching = false, isFinish = false, isActive = true},
					-- [5] = {name = "试炼秘境五层", fubenSid = 20005, isMatching = false, isFinish = false, isActive = true},
					-- [6] = {name = "试炼秘境六层", fubenSid = 20006, isMatching = false, isFinish = false, isActive = true},
				},
			},
		}
	end

	teamAct.RefreshFubenInfo = function()
		--todo teamAct.RefreshFubenInfo
	end

	--过滤组队活动列表
	--打开组队活动界面再做处理
	teamAct.filterActCfg = function(level)
		for i=1,#teamAct.ActivityList do
			local ActInfo = teamAct.ActivityList[i]
			for j=1,#ActInfo.subActList do
				local SubActInfo = ActInfo.subActList[j]
				local fubenSid = SubActInfo.fubenSid
				--设置limit level
				local pro = tb.fuben[fubenSid]
				if pro ~= nil then
					SubActInfo.limitlevel = pro.level
					SubActInfo.isActive = (SubActInfo.limitlevel <= level)
				end
			end
		end
	end

	teamAct.GetActInfo = function(MainActIndex, SubActIndex)
		if teamAct.ActivityList == nil or teamAct.ActivityList[MainActIndex] == nil then
			return nil
		end	
		local MainActInfo = teamAct.ActivityList[MainActIndex]
		if MainActInfo.subActList == nil or MainActInfo.subActList[SubActIndex] == nil then
			return nil
		end
		return MainActInfo, MainActInfo.subActList[SubActIndex]
	end

	teamAct.MatchAct = function(MainActIndex, SubActIndex, callback)
		local MainActInfo, SubActInfo = teamAct.GetActInfo(MainActIndex, SubActIndex)
		if MainActInfo == nil or SubActInfo == nil then
			ui.showMsg("请先选择想要匹配的活动")
			return
		end

		--Send Match Msg
		local Ret = false
		if tb.fuben[SubActInfo.fubenSid] ~= nil then
			Ret = client.fuben.challenge_fuben(tb.fuben[SubActInfo.fubenSid])
		end
		-- print(Ret)
		if Ret then
			callback(SubActInfo.Btn)
		end
	end

	teamAct.CancelMatchAct = function(MainActIndex, SubActIndex, callback)
		local MainActInfo, SubActInfo = teamAct.GetActInfo(MainActIndex, SubActIndex)
		if MainActInfo == nil or SubActInfo == nil then
			return
		end
		--Send Cancel Match Msg
		local Ret = client.fuben.cancel_challenge(SubActInfo.fubenSid, function() end)
		if Ret then
			callback(SubActInfo.Btn)
		end
	end

	--SetPort("", teamAct.listen_)

	teamAct.GenerateActCfg()
	return teamAct
end

client.teamAct = CreateTeamActivityCtrl();