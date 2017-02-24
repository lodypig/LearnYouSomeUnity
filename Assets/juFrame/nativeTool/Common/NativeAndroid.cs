using UnityEngine;
public class NativeAndroid  {
    private static AndroidJavaObject androidJavaObject;
    public static AndroidJavaObject AndroidJaveObject
    {
        get
        {
            if (androidJavaObject == null)
            {
                AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
                AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
                androidJavaObject = jo;
            }
            return androidJavaObject;
        }
    }

    public static void Call(string func, params object[] args)
    {
        Debug.Log("NativeAndroid:" + func);
        AndroidJaveObject.Call(func, args);
    }

    public static AndroidReturnType Call<AndroidReturnType>(string func, params object[] args) {
        return AndroidJaveObject.Call<AndroidReturnType>(func, args);
    }
}
