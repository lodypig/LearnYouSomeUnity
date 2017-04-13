
ClassRegistry = {};

function getClass(class_name)
    return ClassRegistry[class_name];
end

function createObj(class_name, params)
    local cls = getClass(class_name);
    local obj = cls:new(params);
    return obj;
end

-- 创建类函数, 支持多重继承，可以通过表构造类
function jzClass(name, super_name)
    local cls = {};
    cls._name = name;
    cls._is_class = true;
    if super_name ~= nil then
        local super = ClassRegistry[super_name];
        if super ~= nil then
            cls._base = super;
            cls.__index = function (table, key)
                return super[key];
            end;
        end
    end
    setmetatable(cls, cls);
    function cls:new(t)
        local obj = {};
        if t ~= nil then
            for k, v in pairs(t) do
                obj[k] = v;
            end
        end
        obj._is_class = false;
        obj._base = self;
        obj.__index = self;
        setmetatable(obj, obj);
        return obj;
    end
    ClassRegistry[name] = cls;
    return cls;
end


function RegisterCMoveData()
    
end

function RegisterCSkillData()

end

function RegisterCFootstepData()
    local cls = jzClass("CFootstepData");
    cls.footstep = 0;
    cls.index = 0;

end


function RegisterCHandlerSet()
    local cls = jzClass("CHandlerSet");
    cls.handlers = {};
    cls.DoHandler = function (key, handler)
        cls.handlers[key] = handler;
    end;
    cls.CallHandler = function (key, obj, ds)
        local handler = cls.handlers[key];
        if handler ~= nil then
            handler(obj, ds);
        end
    end;
    return cls;
end

function RegisterCAvatarState()
    local cls = jzClass("CAvatarState");
    return cls;
end

function RegisterCAvatar()
    local cls = jzClass("CAvatar");
    return cls;
end


function RegisterClasses()
    RegisterCHandlerSet();
    RegisterCMoveData();
    RegisterCAvatarState();
    RegisterCAvatar();
end


--RegisterClasses();

-- 测试类
function TestClass()
   

  	--print("CAvatar class");

    local CAvatar = jzClass("CAvatar");
    CAvatar.name = "我是战士";
    CAvatar.career = "solider";
    CAvatar.control_logic = "WildHeping";
    function CAvatar:get_type()
      	--print(self);
      	--print("Avatar");
    end;

  	--print("CModel class");

    local CModel = jzClass("CModel", "CAvatar");
    CModel.role_name = "warrior_male_1";
    function CModel:get_type()
      	--print(self);
      	--print("Model");
        self._base:get_type();
    end;

  	--print("CWarrior class");
    
    local CWarrior = jzClass("CWarrior", "CModel");
    CWarrior.fight = 1000;

  	--print("CWarrior obj")

    local obj = CWarrior:new();
  	--print(obj.role_name);
  	--print("----------------")
    obj:get_type();
  	--print("==================")

  	--print("TestClass end");
end