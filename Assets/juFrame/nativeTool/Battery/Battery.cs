using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;


public enum AndoirdStatus {
    BATTERY_STATUS_UNKNOWN,
    BATTERY_STATUS_CHARGING,
    BATTERY_STATUS_DISCHARGING,
    BATTERY_STATUS_NOT_CHARGING,
    BATTERY_STATUS_FULL
}

public enum iOSStatus { 
    
}

public class Battery { 
    
    public static float GetBattery() {
#if UNITY_EDITOR
        return 1;
#elif UNITY_ANDROID
        return GetBatteryLevelAndroid();
#elif UNITY_IOS
        return GetBatteryLeveliOS();
#else 
        return GetBatteryLevelStandalone();
#endif
    }

    public static int GetBatteryCharging()
    {
#if UNITY_EDITOR
        return 0;
#elif UNITY_ANDROID
        return IsChargingAndoird();
#elif UNITY_IOS
        return IsChargingiOS();
#else 
        return 0;
#endif
    }

#if UNITY_ANDROID
    static float GetBatteryLevelAndroid() {
        try
        {
            string capacityString = System.IO.File.ReadAllText("/sys/class/power_supply/battery/capacity");
            return (float.Parse(capacityString))/100;
        }
        catch (Exception e) {
            TTLoger.LogWarning("Failed to read battery power : " + e.Message);
        }
        return -1f;
    }

    static int IsChargingAndoird() {
        return NativeAndroid.Call<int>("IsCharging");
    }
#endif    

#if UNITY_IOS
    [DllImport("__Internal")]
    private static extern float GetBatteryLeveliOS();

    [DllImport("__Internal")]
    private static extern int IsChargingiOS();
        
#endif

#if UNITY_STANDALONE
    static float GetBatteryLevelStandalone() {
        return -1;
    }

    static int GetBatteryStandalone() {
        return 0;
    }
#endif
}
