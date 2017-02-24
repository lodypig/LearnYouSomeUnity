using UnityEngine;
using System.Collections;

/*
 * 自动销毁加载器
 * 访问AssetLoader时创建并缓存加载器
 * Destroy时自动释放
 */
public class MonoLoader : MonoBehaviour
{
    protected AssetLoader _assetLoader;


    // 获取
    public AssetLoader AssetLoader
    {
        get
        {
            if (_assetLoader == null)
            {
                _assetLoader = AssetBundleManager.GetLoader(this.gameObject);                
            }
            return _assetLoader;
        }
        set
        {
            if (value == null)
            {
                return;
            }

            if (_assetLoader == value) {
                return;
            }

            _assetLoader = value;
            AssetBundleManager.CacheLoader(this.gameObject, _assetLoader);  
        }
    }

    // 销毁
    public virtual void OnDestroy()
    {
        if (_assetLoader != null)
        {
            _assetLoader.Release();
            AssetBundleManager.RemoveLoader(this.gameObject);
        }

    }
}
