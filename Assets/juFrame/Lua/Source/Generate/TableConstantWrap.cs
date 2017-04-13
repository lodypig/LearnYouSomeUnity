﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class TableConstantWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(TableConstant), typeof(System.Object));
		L.RegFunction("New", _CreateTableConstant);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("ITEM_TYPE_DROP", get_ITEM_TYPE_DROP, set_ITEM_TYPE_DROP);
		L.RegVar("ITEM_TYPE_EQUIP", get_ITEM_TYPE_EQUIP, set_ITEM_TYPE_EQUIP);
		L.RegVar("EFFECT_ADD_HP", get_EFFECT_ADD_HP, set_EFFECT_ADD_HP);
		L.RegVar("EFFECT_ADD_MP", get_EFFECT_ADD_MP, set_EFFECT_ADD_MP);
		L.RegVar("PROFESSION_WARRIOR", get_PROFESSION_WARRIOR, set_PROFESSION_WARRIOR);
		L.RegVar("PROFESSION_ARCHER", get_PROFESSION_ARCHER, set_PROFESSION_ARCHER);
		L.RegVar("PROFESSION_MAGE", get_PROFESSION_MAGE, set_PROFESSION_MAGE);
		L.RegVar("EQUIP_TYPE_WEAPEN", get_EQUIP_TYPE_WEAPEN, set_EQUIP_TYPE_WEAPEN);
		L.RegVar("EQUIP_TYPE_SUB_WEAPEN", get_EQUIP_TYPE_SUB_WEAPEN, set_EQUIP_TYPE_SUB_WEAPEN);
		L.RegVar("EQUIP_TYPE_RING", get_EQUIP_TYPE_RING, set_EQUIP_TYPE_RING);
		L.RegVar("EQUIP_TYPE_NECKLACE", get_EQUIP_TYPE_NECKLACE, set_EQUIP_TYPE_NECKLACE);
		L.RegVar("EQUIP_TYPE_GLOVES", get_EQUIP_TYPE_GLOVES, set_EQUIP_TYPE_GLOVES);
		L.RegVar("EQUIP_TYPE_CLOTH", get_EQUIP_TYPE_CLOTH, set_EQUIP_TYPE_CLOTH);
		L.RegVar("EQUIP_TYPE_TROUSERS", get_EQUIP_TYPE_TROUSERS, set_EQUIP_TYPE_TROUSERS);
		L.RegVar("EQUIP_TYPE_HELMET", get_EQUIP_TYPE_HELMET, set_EQUIP_TYPE_HELMET);
		L.RegVar("EQUIP_TYPE_SHOES", get_EQUIP_TYPE_SHOES, set_EQUIP_TYPE_SHOES);
		L.RegVar("EQUIP_TYPE_SHOULDER", get_EQUIP_TYPE_SHOULDER, set_EQUIP_TYPE_SHOULDER);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateTableConstant(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				TableConstant obj = new TableConstant();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: TableConstant.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ITEM_TYPE_DROP(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.ITEM_TYPE_DROP);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ITEM_TYPE_EQUIP(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.ITEM_TYPE_EQUIP);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EFFECT_ADD_HP(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EFFECT_ADD_HP);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EFFECT_ADD_MP(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EFFECT_ADD_MP);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PROFESSION_WARRIOR(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.PROFESSION_WARRIOR);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PROFESSION_ARCHER(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.PROFESSION_ARCHER);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PROFESSION_MAGE(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.PROFESSION_MAGE);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_WEAPEN(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_WEAPEN);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_SUB_WEAPEN(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_SUB_WEAPEN);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_RING(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_RING);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_NECKLACE(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_NECKLACE);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_GLOVES(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_GLOVES);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_CLOTH(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_CLOTH);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_TROUSERS(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_TROUSERS);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_HELMET(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_HELMET);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_SHOES(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_SHOES);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EQUIP_TYPE_SHOULDER(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, TableConstant.EQUIP_TYPE_SHOULDER);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ITEM_TYPE_DROP(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.ITEM_TYPE_DROP = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ITEM_TYPE_EQUIP(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.ITEM_TYPE_EQUIP = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EFFECT_ADD_HP(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EFFECT_ADD_HP = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EFFECT_ADD_MP(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EFFECT_ADD_MP = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_PROFESSION_WARRIOR(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.PROFESSION_WARRIOR = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_PROFESSION_ARCHER(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.PROFESSION_ARCHER = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_PROFESSION_MAGE(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.PROFESSION_MAGE = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_WEAPEN(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_WEAPEN = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_SUB_WEAPEN(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_SUB_WEAPEN = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_RING(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_RING = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_NECKLACE(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_NECKLACE = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_GLOVES(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_GLOVES = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_CLOTH(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_CLOTH = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_TROUSERS(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_TROUSERS = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_HELMET(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_HELMET = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_SHOES(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_SHOES = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EQUIP_TYPE_SHOULDER(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			TableConstant.EQUIP_TYPE_SHOULDER = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
