using UnityEngine;
using UnityEngine.UI;
using LuaInterface;
using System;
using System.Collections;

public class NativeManager : MonoBehaviour {

    private static SpeechBase speech;
    private static EditBoxBase editBox;

    private static SpeechFactory speechFactory;
    private static EditBoxFactory editBoxFactory;

    private Action<int> onVolumeChanged;
    private Action<string, byte[], int> onSpeechResult;
    private Action onSpeechBegin;
    private Action onSpeechEnd;
    private Action<string> onSpeechError;
    private Action<string> onEditBoxResult;
    private Action<string> onEditBoxCancel;  
    private Action<double> onEditBoxHeightChange;
    private Action<string, int> onEditBoxTextChange;

    private static NativeManager instance;

    public bool editBoxForbideTouch;
    public bool isKeyboardOpened;
    public bool isStartSpeech;

    void Awake()
    {
        instance = this;
#if UNITY_IPHONE
		UnityEngine.iOS.NotificationServices.RegisterForNotifications (
        UnityEngine.iOS.NotificationType.Alert |
        UnityEngine.iOS.NotificationType.Badge |
        UnityEngine.iOS.NotificationType.Sound);
#endif
        CancelAllNotifications();
    }

    void OnApplicationPause(bool paused)
    {
        if (paused)
        {
            //Util.CallMethod("OnGamePaused");
        }
        else
        {
            //程序从后台进入前台时
            CancelAllNotifications();
        }
    }
    public static NativeManager GetInstance()
    {
        return instance;
    }
    public static SpeechBase Speech {
        get {

            if (speechFactory == null) {
                speechFactory = new SpeechFactory();
            }

            if (speech == null) {
                speech = speechFactory.CreateSpeech();
            }
            return speech;
        }
    }

    public static EditBoxBase EditBox {
        get {
            if (editBoxFactory == null) {
                editBoxFactory = new EditBoxFactory();
            }

            if (editBox == null) {
                editBox = editBoxFactory.Create();
            }
            return editBox;
        }
    }

    public bool shouldForbideTouch() {
        return isKeyboardOpened && editBoxForbideTouch;
    }

    public void BindSpeechResult(Action<string, byte[], int> onSpeechResultAction)
    {
        this.onSpeechResult = onSpeechResultAction;
    }

    public void BindSpeechBegin(Action onSpeechBeginAction)
    {
        this.onSpeechBegin = onSpeechBeginAction;
    }

    public void BindSpeechEnd(Action onSpeechEndAction)
    {
        this.onSpeechEnd = onSpeechEndAction;
    }

    public void BindSpeechError(Action<string> onSpeechErrorAction)
    {
        this.onSpeechError = onSpeechErrorAction;
    }

    public void BindSpeechVolumeChange(Action<int> onVolumeChangedAction)
    {
        this.onVolumeChanged = onVolumeChangedAction;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape) || Input.GetKeyDown(KeyCode.Home))
        {
            Application.Quit();
        }
#if UNITY_IPHONE
        //确保这手清除操作在设置消息数量的下一帧执行
        if (Notificator.IOSClearFlag != 0) 
        {
            if (Notificator.IOSClearFlag == 5)
                Notificator.CleanIOSNotificationStep();
            else
                Notificator.IOSClearFlag++;       
        }
#endif
    }

    public void StartSpeech()
    {
        Speech.StartSpeech();
        AudioManager.PauseMusic();
        isStartSpeech = true;
    }

    public void StopSpeech()
    {
        Speech.StopSpeech();
        AudioManager.ContinueMusic();
        isStartSpeech = false;
    }

    public void CancelSpeech()
    {
        Speech.CancelSpeech();
        AudioManager.ContinueMusic();
        isStartSpeech = false;
    }

    public string GetAudioPath()
    {
        return Speech.GetAudioPath();
    }


    public void ShowEditBox(EditBoxMessage ebm, Action<string> onEditBoxResult, Action<string> OnEditCancel, Action<double> onEditBoxHeightChange, Action<string, int> onEditBoxTextChange)
    {
        this.onEditBoxResult = onEditBoxResult;
        this.onEditBoxCancel = OnEditCancel;
        this.onEditBoxHeightChange = onEditBoxHeightChange;
        this.onEditBoxTextChange = onEditBoxTextChange;
        EditBox.ShowEditBox(ebm);
        isKeyboardOpened = true;
    }

    public void SetEditBoxString(string text) {
        EditBox.SetEditBoxString(text);
    }

    public void CloseEditBox() {
        EditBox.CloseEditBox();
    }

    public void OnVolumeChanged(string volume)
    {
        int vol = System.Convert.ToInt32(volume);
        if (onVolumeChanged != null) {
            onVolumeChanged(vol);
        }
    }

    public void OnSpeechResult(string result)
    {

        // TODO move to lua
        if(string.IsNullOrEmpty(result))
        {
            SysInfoLayer.Instance.ShowMsg("没有语音信息，请重新输入！");
            return;
        }

        byte[] buffer = speech.GetAudioData();
        byte[] encode = Util.EncodeWav(buffer);
        int audioLength = Mathf.RoundToInt((float)buffer.Length / (speech.GetSampleRate() * 2));//语音时长

        if (onSpeechResult != null)
        {
            onSpeechResult(result, encode, audioLength);
        }
    }

    public void OnSpeechBegin()
    {
        if (onSpeechBegin != null)
            onSpeechBegin();
    }

    public void OnSpeechEnd()
    {
        if (onSpeechEnd != null)
            onSpeechEnd();
    }

    void OnSpeechError(string error)
    {
        string[] param = error.Split(';');
        string errorCode =  "";
        if (param != null && param.Length > 1)
            errorCode = param[1];

        switch (errorCode)
        {
            case "10118":
                SysInfoLayer.Instance.ShowMsg("没有语音信息，请重新输入！");
                break;
            default:
                SysInfoLayer.Instance.ShowMsg(error);
                break;
        }
    }

    void OnEditBoxHeightChange(string height)
    {
        Double h = Double.Parse(height);
        if (onEditBoxHeightChange != null)
        {
            onEditBoxHeightChange(h);
        }
    }

    void OnEditBoxResult(string pResult)
    {
        if (onEditBoxResult != null)
        {
            onEditBoxResult(pResult);
        }
    }
    void OnEditBoxCancel(string pResult)
    {
        if (onEditBoxCancel != null)
        {
            onEditBoxCancel(pResult);
        }
    }

    void OnEditBoxTextChange(string posAndText) {
        if (onEditBoxTextChange != null) { 
            int index = posAndText.IndexOf('.');
            if (index > 0) {
                int pos = int.Parse(posAndText.Substring(0, index));
                onEditBoxTextChange(posAndText.Substring(index + 1, posAndText.Length - index -1), pos);
            }
            else {
                onEditBoxTextChange(posAndText, -1);
            }
        }
    }

    void OnKeyboardClose(string _param)
    {
        isKeyboardOpened = false;
    }

    public  float GetBattery() {
        return Battery.GetBattery();
    }

    public int GetBatteryCharging() { 
        return Battery.GetBatteryCharging();
    }

    public  NetworkReachability GetNetState() {
        return Application.internetReachability;
    }


    public void ShowNotification(int id, long delay, string title, string message,long repeatInterval)
    {
        Notificator.SendNotification(id, delay, title, message, repeatInterval);
    }
    public void CancelNotification(int id)
    {
        Notificator.CancelNotification(id);
    }
    public void CancelAllNotifications()
    {
        Notificator.CancelAllNotifications();
    }

    public string GetRegistrationID() 
    {
        string registrationID = string.Empty;
#if UNITY_EDITOR
        registrationID = string.Empty;
#elif UNITY_ANDROID
        registrationID = NativeAndroid.Call<string>("getRegistrationID");
        Debug.Log("Android registrationID:" + registrationID);      
#elif UNITY_IPHONE
        registrationID = Notificator._registrationID();
        Debug.Log("IOS registrationID:" + registrationID);   
#endif
        return registrationID;
    }
}
