using UnityEngine;
using System.Collections;

public abstract class PlatformFactory<T> {

    public abstract T CreateAndroid();

	public abstract T CreateIOS();

    public abstract T CreateStandalone();

    public T Create() {
#if UNITY_ANDROID && !UNITY_EDITOR
        return this.CreateAndroid();
#elif UNITY_IPHONE && !UNITY_EDITOR
        return this.CreateIOS();
#else
       return this.CreateStandalone();
#endif
    }
}


