﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class MonoLoaderWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(MonoLoader), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("OnDestroy", OnDestroy);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("AssetLoader", get_AssetLoader, set_AssetLoader);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnDestroy(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			MonoLoader obj = (MonoLoader)ToLua.CheckObject(L, 1, typeof(MonoLoader));
			obj.OnDestroy();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_AssetLoader(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			MonoLoader obj = (MonoLoader)o;
			AssetLoader ret = obj.AssetLoader;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index AssetLoader on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_AssetLoader(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			MonoLoader obj = (MonoLoader)o;
			AssetLoader arg0 = (AssetLoader)ToLua.CheckObject(L, 2, typeof(AssetLoader));
			obj.AssetLoader = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index AssetLoader on a nil value" : e.Message);
		}
	}
}

