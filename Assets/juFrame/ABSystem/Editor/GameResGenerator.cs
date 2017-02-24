using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Linq;


namespace ABSystem 
{
    /// <summary>
    /// 游戏Resource资源数据
    /// </summary>
    public class GameResourceData
    {
        public int id = 0;
        public GameResType type = GameResType.Cloth;
        public string name = string.Empty;
        public string resPath = string.Empty;
        public string assetbundleName = string.Empty;

        public GameResourceData() { }
        public GameResourceData(GameBundleInfo bundleInfo, GameResInfo resInfo) {
            this.id = bundleInfo.id;
            this.type = bundleInfo.type;
            this.name = bundleInfo.name;
            this.assetbundleName = bundleInfo.assetbundle;
            this.resPath = resInfo.resPath;
        }

        public void Update(GameResourceData newData) {
            if (!string.IsNullOrEmpty(newData.resPath)) {
                this.resPath = newData.resPath;
            }

            if (!string.IsNullOrEmpty(newData.assetbundleName)) {
                this.assetbundleName = newData.assetbundleName;
            }
        }

        public string ToString(string path)
        {
            return id + "\t\t|" + type.ToString() + "\t\t|" + name + "\t\t|" + path;
        }

        public string ToGameData() {
            return id + "\t\t|" + type.ToString() + "\t\t|" + name + "\t\t|" + resPath + "\t\t|" + assetbundleName.ToLower();
        }

        public string ToResPath()
        {
            return ToString(resPath);
        }

        public string ToAssetbundlePath()
        {
            return ToString(assetbundleName.ToLower());
        }
    }


    public class GameResGenerator
    {
        public static SortedDictionary<GameResType, SortedDictionary<string, GameResourceData>> GameResourceDict = new SortedDictionary<GameResType, SortedDictionary<string, GameResourceData>>();

        public static void WriteGameRes()
        {
            string resEditorPath = PathUtil.GetFullPath(PathConfig.resEditor);
            string resBundlePath = PathUtil.GetFullPath(PathConfig.resBundle);

            var fileResEditor = new System.IO.StreamWriter(resEditorPath, false, Encoding.UTF8);
            var fileResBundle = new System.IO.StreamWriter(resBundlePath, false, Encoding.UTF8);
            //生成文件
            foreach (KeyValuePair<GameResType, SortedDictionary<string, GameResourceData>> pair in GameResourceDict)
            {
                SortedDictionary<string, GameResourceData> dict = pair.Value;
                List<GameResourceData> list = new List<GameResourceData>();
                foreach (KeyValuePair<string, GameResourceData> kv in dict)
                {
                    list.Add(kv.Value);
                }

                //list.Sort();
                IEnumerable<GameResourceData> query = from items in list orderby items.id select items;
                int i = 1;
                foreach (GameResourceData grd in query)
                {
                    grd.id = int.Parse(grd.type.ToString("d")) * 10000 + i++;
                    fileResEditor.WriteLine(grd.ToResPath());// 
                    fileResBundle.WriteLine(grd.ToAssetbundlePath());
                }
                fileResEditor.WriteLine("            ");
                fileResBundle.WriteLine("            ");
            }

            fileResEditor.Close();
            fileResBundle.Close();
        }

        public static void ReadGameRes()
        {
            TextAsset resEditor = AssetDatabase.LoadAssetAtPath<TextAsset>(PathConfig.resEditor);
            TextAsset resBundle = AssetDatabase.LoadAssetAtPath<TextAsset>(PathConfig.resBundle);
            if (resEditor == null || resBundle == null)
            {
                return;
            }
            List<GameResInfo> editorItems = TableUtil.ReadContent<GameResInfo>(resEditor.text);
            List<GameBundleInfo> bundleItems = TableUtil.ReadContent<GameBundleInfo>(resBundle.text);
            SortedDictionary<string, GameResourceData> dict = null;


            for (int i = 0; i < bundleItems.Count; ++i)
            {
                GameResourceData item = new GameResourceData(bundleItems[i], editorItems[i]);
                if (GameResourceDict.ContainsKey(item.type))
                {
                    dict = GameResourceDict[item.type];
                }
                else
                {
                    dict = new SortedDictionary<string, GameResourceData>();
                    GameResourceDict[item.type] = dict;
                }

                if (dict.ContainsKey(item.name))
                {
                    continue;
                }
                dict[item.name] = item;
            }
        }
    }
}