using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.XCodeEditor;
#endif
using System.IO;

public static class XCodePostProcess
{

#if UNITY_EDITOR
	[PostProcessBuild(999)]
	public static void OnPostProcessBuild( BuildTarget target, string pathToBuiltProject )
	{
//		if (target != BuildTarget.iOS) {
//			Debug.LogWarning("Target is not iPhone. XCodePostProcess will not run");
//			return;
//		}
//
//		// Create a new project object from build target
//		XCProject project = new XCProject( pathToBuiltProject );
//
//        //得到xcode工程的路径
//        string path = Path.GetFullPath (pathToBuiltProject);
//
//		// Find and run through all projmods files to patch the project.
//		// Please pay attention that ALL projmods files in your project folder will be excuted!
//		string[] files = Directory.GetFiles( Application.dataPath, "*.projmods", SearchOption.AllDirectories );
//		foreach( string file in files ) {
//			string name = Path.GetFileNameWithoutExtension(file);
//            if (name.ToLower().Contains("iflytek"))
//				project.ApplyMod( file );
//		}
//
//		//TODO implement generic settings as a module option
//		project.overwriteBuildSetting("ENABLE_BITCODE", "NO" , "all");
//		project.overwriteBuildSetting("CODE_SIGN_IDENTITY", "iPhone Developer", "all");
//		
//		// Finally save the xcode project
//		project.Save();
//
//        File.Copy(Path.Combine(Application.dataPath ,"../Ios/UnityAppController.mm"), path + "/Classes/UnityAppController.mm", true);
	}
#endif

    public static void Log(string message)
	{
		Debug.Log("PostProcess: "+message);
	}
}
