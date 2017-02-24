using UnityEngine;
using System.Collections;
using System.Diagnostics;
using System.IO;

public class CMDProcesser : MonoBehaviour {
    public static void processCommand(string command, string argument)
    {
        ProcessStartInfo start = new ProcessStartInfo(command);
        start.Arguments = argument;
        start.CreateNoWindow = true;
        start.ErrorDialog = true;
        start.UseShellExecute = false;

        if (start.UseShellExecute)
        {
            start.RedirectStandardOutput = false;
            start.RedirectStandardError = false;
            start.RedirectStandardInput = false;
        }
        else
        {
            start.RedirectStandardOutput = true;
            start.RedirectStandardError = true;
            start.RedirectStandardInput = true;
            start.StandardOutputEncoding = System.Text.UTF8Encoding.UTF8;
            start.StandardErrorEncoding = System.Text.UTF8Encoding.UTF8;
        }

        Process p = Process.Start(start);

        if (!start.UseShellExecute)
        {
            Log(p.StandardOutput);
            LogError(p.StandardError);
        }

        p.WaitForExit();
        p.Close();
    }

    static void Log(StreamReader streamReader) 
    {
        string s = streamReader.ReadToEnd();
        if (string.IsNullOrEmpty(s)) {
            return;
        }
        TTLoger.Log(s);
    }

    static void LogError(StreamReader streamReader)
    {
        string s = streamReader.ReadToEnd();
        if (string.IsNullOrEmpty(s))
        {
            return;
        }
        TTLoger.LogError(s);
    }

}
