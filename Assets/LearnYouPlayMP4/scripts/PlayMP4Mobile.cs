using UnityEngine;
using System.Collections;

public class PlayMP4Mobile : MonoBehaviour {
    void OnGUI()
    {
        if (GUI.Button(new Rect(20, 10, 200, 50), "PLAY ControlMode.CancelOnTouch"))
        {
            Handheld.PlayFullScreenMovie("Movie/logo.mp4", Color.black, FullScreenMovieControlMode.CancelOnInput);
        }

        if (GUI.Button(new Rect(20, 90, 200, 25), "PLAY ControlMode.Full"))
        {
            Handheld.PlayFullScreenMovie("Movie/logo.mp4", Color.black, FullScreenMovieControlMode.Full);
        }

        if (GUI.Button(new Rect(20, 170, 200, 25), "PLAY ControlMode.Hidden"))
        {
            Handheld.PlayFullScreenMovie("Movie/logo.mp4", Color.black, FullScreenMovieControlMode.Hidden);
        }

        if (GUI.Button(new Rect(20, 250, 200, 25), "PLAY ControlMode.Minimal"))
        {
            Handheld.PlayFullScreenMovie("Movie/logo.mp4", Color.black, FullScreenMovieControlMode.Minimal);
        }

    }
}
