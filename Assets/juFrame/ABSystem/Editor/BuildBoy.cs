using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using System.Collections.Generic;
using System.Collections;
using System.IO;

namespace ABSystem {
    public class BuildBoy
    {

        // 将lua临时转成.txt文件、清理临时文件方法
        #region lua
        // 清理掉这个 目录下的 * .txt 文件，避免搜索时干扰
        public static void ClearLua()
        {
            string tmpPath;  //lua文件夹系统路径
            tmpPath = PathUtil.GetFullPath(PathConfig.tempLua); ;
            string[] files = Directory.GetFiles(tmpPath, "*.lua.txt", SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++)
            {
                FileUtil.DeleteFileOrDirectory(files[i]);
            }
        }

        // 拷贝lua
        public static void CopyLua()
        {
            string[] files;
            string tmpPath = PathUtil.GetFullPath(PathConfig.tempLua);
            if (!Directory.Exists(tmpPath))
            {
                Directory.CreateDirectory(tmpPath);
            }
            else
            {
                ClearLua();
            }
            files = Directory.GetFiles(PathUtil.GetFullPath(PathConfig.lua), "*.lua", SearchOption.AllDirectories);
            List<string> fileList = new List<string>();
            for (int i = 0; i < files.Length; i++)
            {
                string fname = Path.GetFileName(files[i]);
                fname = fname.Replace("\\", "/");
                string fullName = tmpPath + "/" + fname + ".txt";
                int index = fullName.IndexOf("Assets");
                fileList.Add(fullName.Substring(index));
                FileUtil.CopyFileOrDirectory(files[i], fullName);
            }
        }
        #endregion

        // 生成sprite清单
        #region atlas
        // ------------------------ 生成 atlas sprite 清单 -------------------------------
        static void GenAtlasSpriteRes() {
            // 获取atlasTargetPath里所有atlas文件夹
            string atlasSys = PathUtil.GetFullPath(PathConfig.atlasTargetPath);
            string[] dirs = Directory.GetDirectories(atlasSys);


            string atlasDir;      // atlas下每个图集文件夹路径
            string dirName;       // 图集文件夹名字
            string atlasPath;     // 图集的路径


            for (int i = 0; i < dirs.Length; ++i)
            {
                atlasDir = dirs[i].ReplaceESC();
                dirName = PathUtil.GetDirName(atlasDir);
                atlasPath = PathConfig.atlasTargetPath.Combine(dirName + "/" + dirName + ".png");
                UpdateAtlas(atlasPath, dirName, "atlas/" + dirName.ToLower());
            }
        }

        static void UpdateAtlas(string atlasPath, string dirName, string abName)
        {
            UnityEngine.Object[] assets = AssetDatabase.LoadAllAssetsAtPath(atlasPath);
            for (int i = 0; i < assets.Length; ++i)
            {
                if (assets[i] is Sprite)
                {
                    GameResourceData data = new GameResourceData();
                    data.type = GameResType.Sprite;
                    data.name = PathUtil.LastTrim(assets[i].name, '-');
                    data.id = int.Parse(GameResType.Sprite.ToString("d")) * 10000;
                    data.assetbundleName = abName;
                    UpdateGameResWorker(data);
                }
            }
        }

        // ------------------------ 生成 editor sprite 清单 -------------------------------
        static void GenEditorSpriteRes()
        {
            // 获取atlasTargetPath里所有atlas文件夹
            string spriteSys = PathUtil.GetFullPath(PathConfig.spritePath);
            string[] dirs = Directory.GetDirectories(spriteSys);


            string spriteDir;      // atlas下每个图集文件夹路径
            for (int i = 0; i < dirs.Length; ++i)
            {
                spriteDir = dirs[i].ReplaceESC();
                UpdateSprite(spriteDir);
            }
        }

        static void UpdateSprite(string dir) {
            string[] files = Directory.GetFiles(dir, "*.png", SearchOption.AllDirectories);

            string spritePath;
            string spriteName;

            for (int i = 0; i < files.Length; ++i) {
                spritePath = PathUtil.GetAssetPath(files[i].ReplaceESC());
                spriteName = PathUtil.GetFileNameWithoutExtension(spritePath);
                GameResourceData data = new GameResourceData();
                data.resPath = spritePath;
                data.type = GameResType.Sprite;
                data.name = spriteName;
                data.id = int.Parse(GameResType.Sprite.ToString("d")) * 10000;
                UpdateGameResWorker(data);
            }
        }

        // ------------------------ 生成所有 sprite 清单 -------------------------------
        public static void GenSpriteRes()
        {
            ClearGameRes(GameResType.Sprite);   // 先清除sprite类的资源清单
            GenAtlasSpriteRes();
            GenEditorSpriteRes();
        }

        
        #endregion

        // 资源清单处理方法
        #region GameRes
        public static void ClearGameRes(AssetBundleBuildConfig config)
        {
            for (int i = 0; i < config.filters.Count; ++i)
            {
                AssetBundleFilterMain filter = config.filters[i];
                if (filter.valid)
                {
                    ClearGameRes(filter.resType);
                    if (filter.HasSub())
                    {
                        for (int j = 0; j < filter.subFilterList.Count; ++j)
                        {
                            ClearGameRes(filter.subFilterList[j].resType);
                        }
                    }
                }
            }
        }

        public static void ClearGameRes(GameResType type)
        {
            SortedDictionary<string, GameResourceData> dict;
            if (GameResGenerator.GameResourceDict.TryGetValue(type, out dict))
            {
                dict.Clear();
            }
        }
       

        public static void UpdateGameRes(GameResType type, string name, string abName, string resPath = "")
        {
            GameResourceData data = new GameResourceData();
            data.type = type;
            data.name = name;
            data.id = int.Parse(type.ToString("d")) * 10000;
            data.resPath = resPath;
            data.assetbundleName = abName;
            UpdateGameResWorker(data);
        }

        public static void UpdateGameResWorker(GameResourceData data)
        {
            SortedDictionary<string, GameResourceData> dict;
            if (!GameResGenerator.GameResourceDict.TryGetValue(data.type, out dict))
            {
                dict = new SortedDictionary<string, GameResourceData>();
                GameResGenerator.GameResourceDict[data.type] = dict;
            }
            GameResourceData oldData;
            if (dict.TryGetValue(data.name, out oldData)){
                oldData.Update(data);
            }
            else { 
                dict.Add(data.name, data);
            }
        }


        #endregion

        public static void ChangeUIToSprite() {
            SpriteChecker.ChangeUIToSprite();
        }

        public static void ChangeUIToAtlas()
        {
            SpriteChecker.ChangeUIToAtlas();
        }
    }
}

