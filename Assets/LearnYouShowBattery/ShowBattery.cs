using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;

public class ShowBattery : MonoBehaviour {

    public UnityEngine.UI.Text tfTime;
    public UnityEngine.UI.Text tfBattery;

    string _time = string.Empty;
    string _battery = string.Empty;

    void Start()
    {
        StartCoroutine("UpdataTime");
        StartCoroutine("UpdataBattery");
    }

    void OnGUI()
    {
       
    }

    IEnumerator UpdataTime()
    {
        DateTime now = DateTime.Now;
        _time = string.Format("{0}:{1}", now.Hour, now.Minute);
        tfTime.text = _time;
        yield return new WaitForSeconds(60f - now.Second);
        while (true)
        {
            now = DateTime.Now;
            _time = string.Format("{0}:{1}", now.Hour, now.Minute);
            tfTime.text = _time;
            yield return new WaitForSeconds(60f);
        }
    }

    IEnumerator UpdataBattery()
    {
        while (true)
        {

			float temp = GetBatteryLevel ();
			_battery = temp.ToString();
			Debug.Log (temp);
            tfBattery.text = _battery;
            yield return new WaitForSeconds(300f);
        }
    }

//    int GetBatteryLevel()
//    {
//        try
//        {
//            string CapacityString = System.IO.File.ReadAllText("/sys/class/power_supply/battery/capacity");
//            return int.Parse(CapacityString);
//        }
//        catch (Exception e)
//        {
//            Debug.Log("Failed to read battery power; " + e.Message);
//        }
//        return -1;
//    }  

	[DllImport("__Internal")]
	private static extern float GetBatteryLevel ();
}
