using System.IO;
using UnityEditor;
using UnityEngine;

namespace ABSystem
{
    public class AssetBundleBuildPanel : EditorWindow
    {

        bool isFocus;
        AssetBundleBuildConfig config;
        Vector2 scrollPos = Vector2.zero;


        [MenuItem("ABSystem/Builder Panel")]
        static void Open()
        {
            AssetBundleBuildPanel panel = GetWindow<AssetBundleBuildPanel>("ABSystem", true);
        }


		static public AssetBundleBuildConfig LoadConfig()
		{
            return AssetLoaderEditor.LoadAssetAtPath(PathConfig.buildConfig) as AssetBundleBuildConfig;
		}

        class Styles
        {
            public static GUIStyle box;
            public static GUIStyle toolbar;
            public static GUIStyle toolbarButton;
            public static GUIStyle tooltip;
            public static GUIStyle textfiled;
        }
        AssetBundleBuildPanel()
        {
            config = LoadConfig();
        }

        private bool drag;

        void UpdateEvent() {
            UnityEngine.Event e = UnityEngine.Event.current;
            switch (e.type)
            {
                case EventType.DragExited:
                    if (isFocus) {
                        if (config.NotHasFilter(Selection.activeObject))
                        { 
                         //   config.filters.Add(new AssetBundleFilterMain(Selection.activeObject));
                            Save();
                        }
                    }
                    break;
            }
        }   

        void UpdateStyles()
        {
            Styles.box = new GUIStyle(GUI.skin.box);
            Styles.box.margin = new RectOffset();
            Styles.box.padding = new RectOffset();
            

            Styles.toolbar = new GUIStyle(EditorStyles.toolbar);
            Styles.toolbar.margin = new RectOffset();
            Styles.toolbar.padding = new RectOffset();
            Styles.toolbarButton = EditorStyles.toolbarButton;


            Styles.tooltip = GUI.skin.GetStyle("AssetLabel");

            Styles.textfiled = new GUIStyle(EditorStyles.textField);
            Styles.textfiled.border = new RectOffset(2, 2, 2, 2);
        }


        void DrawContent(AssetBundleFilter filter) {
            if (!filter.isAppend || filter.independent) { 
                filter.assetbundleName = GUILayout.TextField(filter.assetbundleName, GUILayout.MinWidth(120), GUILayout.MaxWidth(240));
            }
            filter.pattern = GUILayout.TextField(filter.pattern, GUILayout.MinWidth(120), GUILayout.MaxWidth(320));
            filter.resType = (GameResType)EditorGUILayout.EnumPopup(filter.resType, GUILayout.MinWidth(80), GUILayout.MaxWidth(120), GUILayout.ExpandWidth(false));
            if (!filter.isAppend || filter.independent) { 
                filter.option = (BuildOption)EditorGUILayout.EnumPopup(filter.option, GUILayout.MinWidth(80), GUILayout.MaxWidth(120), GUILayout.ExpandWidth(false));
            }
        }

        int DrawMainFilter(AssetBundleFilterMain filter)
        {
            GUILayout.BeginHorizontal();
            {

                //--------------------  展开/折叠 --------------------------------
                if (filter.HasSub()) {
                    if (filter.showSub)
                    {
                        if (GUILayout.Button("◢", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                        {
                            filter.showSub = !filter.showSub;
                        }
                    }
                    else {
                        if (GUILayout.Button("▶", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                        {
                            filter.showSub = !filter.showSub;
                        }
                    }
                } else {
                    GUILayout.Space(27);
                }

                // 勾选框
                filter.valid = GUILayout.Toggle(filter.valid, "", GUILayout.ExpandWidth(false));

                // 文件夹/文件
                filter.target = EditorGUILayout.ObjectField(filter.target, filter.target.GetType(), GUILayout.MinWidth(150));

                // 通用内容
                DrawContent(filter);
              
               // filter.searchOption = (SearchOption)EditorGUILayout.EnumPopup(filter.searchOption, GUILayout.MinWidth(120), GUILayout.ExpandWidth(false));

                // 添加子筛选器
                if (GUILayout.Button("+", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                {
                    filter.AddSubFilter(new AssetBundleFilter());
                }

                // 删除
                if (GUILayout.Button("X", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                {
                    config.filters.Remove(filter);
                    return 1;
                }
            }
            GUILayout.EndHorizontal();

            // 显示子筛选器
            if (filter.IsShowSub()) {
                for (int i = 0; i < filter.subFilterList.Count; ++i)
                {
                    i -= DrawFilter(filter, filter.subFilterList[i]);
                }
            }
            
            return 0;
        }

        int DrawFilter(AssetBundleFilterMain mainFilter, AssetBundleFilter filter)
        {
            GUILayout.BeginHorizontal();
            {
                GUILayout.Space(50);

           

                
                //filter.independent = GUILayout.Toggle(filter.independent, "", GUILayout.ExpandWidth(false));

                if (filter.isAppend)
                {
                    if (filter.independent)
                    {
                        if (GUILayout.Button("I", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                        {
                            filter.independent = false;
                        }
                    }
                    else
                    {
                        if (GUILayout.Button("A", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                        {
                            filter.independent = true;
                        }
                    }
                    // 如果是添加类型子删选器，显示路径
                    filter.path = GUILayout.TextField(filter.path, GUILayout.MinWidth(150));
                }
                else {
                    // 否则，显示文件/文件夹
                    filter.target = EditorGUILayout.ObjectField(filter.target, filter.target.GetType(), GUILayout.MinWidth(150));
                }

                // 显示通用内容
                DrawContent(filter);

                // 转换类型按钮
                if (GUILayout.Button("┥", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                {
                    filter.isAppend = !filter.isAppend;
                }

                // 删除
                if (GUILayout.Button("X", GUILayout.ExpandWidth(false), GUILayout.Width(20), GUILayout.Height(15)))
                {
                    mainFilter.subFilterList.Remove(filter);
                    return 1;
                }
            }
            GUILayout.EndHorizontal();
            return 0;
        }

        void OnGUI()
        {
            bool hasNotValid = false;
            bool hasValid = false;
            if (config == null)
            {
                config = LoadConfig();
                if (config == null)
                {
                    config = new AssetBundleBuildConfig();
                } 
            }

            UpdateStyles();
            
             GUILayout.BeginHorizontal(Styles.toolbar);
             {
                 for (int i = 0; i < config.filters.Count; ++i) {
                     if (!config.filters[i].valid) {
                         hasNotValid = true;
                     } else {
                         hasValid = true;
                     }
                 }

                if (GUILayout.Button(hasNotValid ? "SelectAll" : "UnselectAll", Styles.toolbarButton))
                {
                    for (int i = 0; i < config.filters.Count; ++i)
                    {
                        config.filters[i].valid = hasNotValid;
                    }
                }

                if (GUILayout.Button("Add", Styles.toolbarButton)) {
                    config.filters.Add(new AssetBundleFilterMain());
                }

                if (GUILayout.Button("Gen", Styles.toolbarButton)) {
                    AssetBundleBuilder.Build(config, true);
                }

                if (GUILayout.Button("Clear", Styles.toolbarButton)) {
                    EditorApplication.delayCall += () =>
                    {
                        PathUtil.DeleteFileOrFolder(Application.streamingAssetsPath);
                        AssetDatabase.Refresh();
                        TTLoger.Log("清理完成！");
                    };
                }

                GUILayout.FlexibleSpace();
             }
            GUILayout.EndHorizontal();

            UnityEngine.Event e = UnityEngine.Event.current;
            if (e.type == EventType.scrollWheel)
            {
                scrollPos = new Vector2(0f, scrollPos.y + (-10) * e.delta.y);
            }
            scrollPos = GUILayout.BeginScrollView(scrollPos, false, false);

            GUILayout.BeginVertical();
            for (int i = 0; i < config.filters.Count; i++)
            {
                AssetBundleFilterMain filter = config.filters[i];
                i -= DrawMainFilter(filter);               
            }

            if (!hasValid) {
                GUI.enabled = false;
            }

            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Build")) {
                EditorApplication.delayCall += Build;
            }
            if (!hasValid)
            {
                GUI.enabled = true;
            }
            GUILayout.EndVertical();
            GUILayout.EndScrollView();

            //set dirty
            if (GUI.changed)
                Save();
            
            UpdateEvent();
            Repaint();
        }
   

        void OnFocus()
        {
            isFocus = true;            
        }

        void OnLostFocus() {
            isFocus = false;
        }

        private void Build()
        {
            Save();
            AssetBundleBuilder.Build(config);
        }

        void Save()
        {
            if (LoadConfig() == null)
            {
                AssetDatabase.CreateAsset(config, PathConfig.buildConfig);
            }
            else
            {
                EditorUtility.SetDirty(config);
            }
        }
    }
}