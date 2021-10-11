using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraDepth : MonoBehaviour
{
    void Start()
    {
        var cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.None;
    }
}
