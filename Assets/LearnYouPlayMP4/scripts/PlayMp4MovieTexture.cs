using UnityEngine;
using System.Collections;

public class PlayMp4MovieTexture : MonoBehaviour {

    public MovieTexture movieTexture;
	void Start () {
        this.GetComponent<Renderer>().material.mainTexture = movieTexture;
        movieTexture.loop = true;
	}

    void OnGUI()
    {
        if (GUILayout.Button("播放/继续"))
        {
            //播放/继续播放视频
            if (!movieTexture.isPlaying)
            {
                movieTexture.Play();
            }

        }

        if (GUILayout.Button("暂停播放"))
        {
            //暂停播放
            movieTexture.Pause();
        }

        if (GUILayout.Button("停止播放"))
        {
            //停止播放
            movieTexture.Stop();
        }
    }
	
}
