using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class CombineMesh : MonoBehaviour
{

    void Start()
    {
        MeshFilter[] meshfilters = GetComponentsInChildren<MeshFilter>();
        Material[] mats = new Material[meshfilters.Length];
        CombineInstance[] combine = new CombineInstance[meshfilters.Length];
        Matrix4x4 matrix = this.transform.worldToLocalMatrix;
        for (int i = 0; i < meshfilters.Length; ++i) {
            MeshFilter mf = meshfilters[i];
            MeshRenderer mr = mf.GetComponent<MeshRenderer>();
            if (mr == null) {
                continue;
            }
            combine[i].mesh = mf.sharedMesh;
            combine[i].transform = mf.transform.localToWorldMatrix * matrix;
            mr.enabled = false;
            mats[i] = mr.sharedMaterial;
        }
        MeshFilter thisMF = GetComponent<MeshFilter>();
        Mesh mesh = new Mesh();
        mesh.name = "CombineMesh";
        mesh.CombineMeshes(combine, false);

        MeshRenderer thisMR = GetComponent<MeshRenderer>();
        thisMR.sharedMaterials = mats;
        thisMR.enabled = true;

        MeshCollider mc = GetComponent<MeshCollider>();
        if (mc != null) {
            mc.sharedMesh = mesh;
        }
    }
}


//MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
//CombineInstance[] combine = new CombineInstance[meshFilters.Length];
//Material[] mats = new Material[meshFilters.Length];
//Matrix4x4 matrix = transform.worldToLocalMatrix;
//for (int i = 0; i < meshFilters.Length; i++)
//{
//    MeshFilter mf = meshFilters[i];
//    MeshRenderer mr = meshFilters[i].GetComponent<MeshRenderer>();
//    if (mr == null)
//    {
//        continue;
//    }
//    combine[i].mesh = mf.sharedMesh;
//    combine[i].transform = mf.transform.localToWorldMatrix * matrix;
//    mr.enabled = false;
//    mats[i] = mr.sharedMaterial;
//}
//MeshFilter thisMeshFilter = GetComponent<MeshFilter>();
//Mesh mesh = new Mesh();
//mesh.name = "Combined";
//thisMeshFilter.mesh = mesh;
//mesh.CombineMeshes(combine, false);
//MeshRenderer thisMeshRenderer = GetComponent<MeshRenderer>();
//thisMeshRenderer.sharedMaterials = mats;
//thisMeshRenderer.enabled = true;

//MeshCollider thisMeshCollider = GetComponent<MeshCollider>();
//if (thisMeshCollider != null)
//{
//    thisMeshCollider.sharedMesh = mesh;
//}
