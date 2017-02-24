using System;
using System.IO;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using System.Text;

public class ConsoleEditorWindow : EditorWindow
{
    static ConsoleEditorWindow window = null;

    string currentFilePath = string.Empty;
    string currentContent = string.Empty;
    string content = string.Empty;

    Vector2 scroll;

    int currentPage = 1;
    int maxPage = 1;

    int maxNum = 15000;

    void Init()
    {
        if (LogConsole.Instance.IsFileInUse(currentFilePath))
        {
            content = "<color=#" + LogConsole.ColorToHex(Color.red) + ">" + "文件正在被写入，读取失败" + "</color>";
        }
        else
        {
            content = System.IO.File.ReadAllText(currentFilePath, Encoding.UTF8);
        }
        
        maxPage = Mathf.FloorToInt(content.Length / maxNum);

        if (content.Length - maxPage * maxNum > 0)
        {
            maxPage++;
        }

        currentContent = RefreshPage();
    }

    #region Drawing Window
    public void OnGUI()
    {

        GUI.skin.GetStyle("TextArea").richText = true;
        EditorGUILayout.BeginVertical(GUILayout.Height(700));
        scroll = EditorGUILayout.BeginScrollView(scroll, false, false);
        EditorGUILayout.TextArea(currentContent, GUI.skin.GetStyle("TextArea"));
        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
        GUI.skin.GetStyle("TextArea").richText = false;
        //page button
        EditorGUILayout.BeginHorizontal();
        {
            int temp = currentPage;
            currentPage = EditorGUILayout.IntField(currentPage, GUILayout.Width(30));
            if (currentPage > maxPage)
            {
                currentPage = maxPage;
            }
            else if (currentPage < 1)
            {
                currentPage = 1;
            }

            if (temp != currentPage)
            {
                //refresh text
                currentContent = RefreshPage();
            }

            EditorGUILayout.LabelField("/" + maxPage);


            Rect rect = GUILayoutUtility.GetRect(new GUIContent("<-上一页"), EditorStyles.miniButton, GUILayout.Width(200), GUILayout.Height(25));
            if (GUI.Button(rect, "<-上一页", EditorStyles.miniButton))
            {
                temp = currentPage;
                currentPage--;
                if (currentPage > maxPage)
                {
                    currentPage = maxPage;
                }
                else if (currentPage < 1)
                {
                    currentPage = 1;
                }

                if (temp != currentPage)
                {
                    //refresh text
                    currentContent = RefreshPage();
                }
            }
            rect = GUILayoutUtility.GetRect(new GUIContent("下一页->"), EditorStyles.miniButton, GUILayout.Width(200), GUILayout.Height(25));
            if (GUI.Button(rect, "下一页->", EditorStyles.miniButton))
            {
                temp = currentPage;
                currentPage++;
                if (currentPage > maxPage)
                {
                    currentPage = maxPage;
                }
                else if (currentPage < 1)
                {
                    currentPage = 1;
                }

                if (temp != currentPage)
                {
                    //refresh text
                    currentContent = RefreshPage();
                }
            }
        }
        EditorGUILayout.EndHorizontal();

        // open new log
        {
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            GUILayout.FlexibleSpace();
            Rect rect = GUILayoutUtility.GetRect(new GUIContent("打开新日志"), EditorStyles.miniButton, GUILayout.ExpandWidth(true), GUILayout.Height(25));
            GUI.backgroundColor = Color.green;
            if (GUI.Button(rect, "打开新日志", EditorStyles.miniButton))
            {
                OpenFile();
            }
        }
    }

    string RefreshPage()
    {
        //from
        int from = FindColorLeftIndex((currentPage - 1) * maxNum);
        int to = FindColorRightIndex((currentPage) * maxNum);

        int length = 1;
        if (to <= content.Length)
        {
            length = to - from;
        }
        else
        {
            length = content.Length - from;
        }

        return content.Substring(from, length);
    }

    /// <summary>
    /// back to search the first <color></color> left index paired.
    /// FIX:no more left like: <color=#7F7F7F><i>
    /// </summary>
    int FindColorLeftIndex(int beginIndex)
    {
        //no more char in the left.
        if (beginIndex == 0)
        {
            return beginIndex;
        }

        while (beginIndex >= 0)
        {
            if (content[beginIndex] == '<' && beginIndex + 6 < content.Length)
            {
                if (content.Substring(beginIndex + 1, 6) == "color=")
                {
                    if (beginIndex - 1 >= 0 && content[beginIndex - 1] == '>' && beginIndex - 3 >= 0 && content.Substring(beginIndex - 3, 3) == "<i>")
                    {
                        //do nothing
                    }
                    else if (beginIndex - 1 >= 0 && content[beginIndex - 1] == '>' && beginIndex - 15 >= 0 && content.Substring(beginIndex - 15, 7) == "<color=")
                    {
                        //do nothing
                    }
                    else
                    {
                        return beginIndex;
                    }
                }
            }
            beginIndex--;
        }

        return beginIndex;
    }

    /// <summary>
    /// FIX:no more right end like </i></color>
    /// </summary>
    int FindColorRightIndex(int endIndex)
    {
        if (endIndex >= content.Length)
        {
            return content.Length;
        }

        while (endIndex <= content.Length)
        {
            if (content[endIndex - 1] == '>' && endIndex - 8 >= 0)
            {
                if (content.Substring(endIndex - 8, 8) == "</color>")
                {
                    ///</color>|</i></color>
                    ///
                    if (content[endIndex] == '<' && endIndex + 3 < content.Length && content.Substring(endIndex, 4) == "</i>")
                    {
                        //do nothing.
                    }
                    else if (content[endIndex] == '<' && endIndex + 7 < content.Length && content.Substring(endIndex, 8) == "</color>")
                    {
                        //do nothing
                    }
                    else
                    {
                        return endIndex;
                    }
                }
            }
            endIndex++;
        }
        return endIndex;
    }

#endregion

    #region Editor Control

    [MenuItem("日志/清空日志 %#L")]
    static void OpenConsole()
    {
        string[] str = new string[1];
        LogConsole.Instance.ClearAllLogFiles(str);
    }

    [MenuItem("日志/打开日志 %l")]
    static void OpenFile()
    {
        string logFolder = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1) + "Log";

        if (!Directory.Exists(logFolder))
        {
            TTLoger.LogError("当前没有任何日志!");
            return;
        }

        var path = EditorUtility.OpenFilePanel(
        "选择一个日志",
        logFolder,
        "log");
        if (!string.IsNullOrEmpty(path))
        {
            OpenWindow(path);
        }
    }

    static void OpenWindow(string filePath)
    {
        if (window != null) window.Close();
        window = (ConsoleEditorWindow)GetWindow(
            typeof(ConsoleEditorWindow),
            true,
            "P27日志-" + filePath,
            true
        );
        window.minSize = new Vector2(1024, 768);
        window.maxSize = new Vector2(1024, 768);
        window.currentFilePath = filePath;
        window.Init();
        window.Show();
    }

    #endregion
}
