using UnityEngine;
using UnityEngine.UI;

public class NativeTest : MonoBehaviour {

    public Text lblText;
    public Text lblVolume;

	// Use this for initialization
	void Start () {
        NativeManager.GetInstance().BindSpeechResult(SpeechResult);
        NativeManager.GetInstance().BindSpeechVolumeChange(VolumeChanged);
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void StartSpeech() {
        NativeManager.Speech.StartSpeech();
    }

    public void StopSpeech() {
        NativeManager.Speech.StopSpeech();
    }

    void VolumeChanged(int volume)
    {
        if (lblVolume != null)
        {
            lblVolume.text = string.Format("音量：{0}", volume);
        }
    }

    void SpeechResult(string result, byte[] data, int length)
    {
        if (lblText != null)
            lblText.text = result;
        if(data != null)
           Util.PlayWav(data);
    }
}
