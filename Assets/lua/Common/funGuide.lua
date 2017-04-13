function ShowGuide(...)
    local guide = {};
    guide.fun = function (args)
        if GuideManager.pause then
            guide.status = "pause";
            return;
        end

        local text = args[1];
        local path = args[2];
        local style = args[3];
        local showBlack = args[4];
        local pos = string.find(path, "%.");
        if pos ~= nil then
            local uiName = string.sub(path, 1, pos - 1);
            local target = string.sub(path, pos + 1);
            local ui = UIManager.GetInstance():FindUI(uiName);

            if ui ~= nil then
                local lua = ui.gameObject:GetComponent("LuaBehaviour");
                if lua ~= nil and lua.LuaController ~= nil and lua.LuaController.isFirstUpdate then
                    if client.uiGuide ~= nil then
                        if uiName ~= "MainUI" or lua.LuaController.isShow then
                            local targetGO = lua:GO(target);
                            if targetGO ~= nil then
                                client.uiGuide.hideClickMask();
                                client.uiGuide.Show(targetGO, text, style, showBlack, path);
                                guide.status = "finished";
                                return;
                            end
                        end
                    end
                end
            end
            
            --如果执行时该UI或者按钮还没创建出来，则状态会设置为pause，等待重新执行
            if client.uiGuide ~= nil then
                client.uiGuide.showClickMask();
            end
            guide.status = "pause";
        else
          	--print("新手引导路径配置出错："..path)
        end
    end
    guide.args = {...};

    return guide;
end

function GuideDelay(...)
    local guide = {};
    guide.fun = function (args)
        if GuideManager.pause then
            guide.status = "pause";
            return;
        end

        local time = args[1];
        client.uiGuide.showClickMask();
        local timer = Timer.New(function ()
            client.uiGuide.hideClickMask();
            GuideManager.run();
        end, time)
        if timer ~= nil then
            timer:Start()
        end
    end
    guide.args = {...};

    return guide;
end