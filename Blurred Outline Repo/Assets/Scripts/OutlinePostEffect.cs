using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class OutlinePostEffect : MonoBehaviour
{
    [Header("Outline Stats")]
    [Range(0, 50)]
    [SerializeField] private int outlineSize = 21;
    [SerializeField] private Color outlineColor;
    [SerializeField] private bool showOutlineInFront = false;
    [SerializeField] private bool showOutlineBehind = false;
    [Header("Shader References")]
    [SerializeField] private Shader outline;
    [SerializeField] private Shader drawSolidColor;
    private Camera tempCam;
    private Material outlineMat;
    private float[] kernel;

    private static readonly int SceneTex = Shader.PropertyToID("_SceneTex");
    private static readonly int Kernel = Shader.PropertyToID("kernel");
    private static readonly int KernelWidth = Shader.PropertyToID("_kernelWidth");
    private static readonly int OutlineColorProperty = Shader.PropertyToID("_OutlineColor");
    private static readonly int inFront = Shader.PropertyToID("_OnlyShowInFrontObject");
    private static readonly int behind = Shader.PropertyToID("_OnlyShowBehindObject");

    private void Start()
    {
        tempCam = new GameObject().AddComponent<Camera>();
        outlineMat = new Material(outline);

        kernel = GaussianKernel.Calculate(5, outlineSize);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //set up a temporary camera
        tempCam.CopyFrom(Camera.current);
        tempCam.clearFlags = CameraClearFlags.Color;
        tempCam.backgroundColor = Color.black;

        //cull any layer that isn't the outline
        tempCam.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        //make the temporary renderTexture
        RenderTexture rt = RenderTexture.GetTemporary(src.width, src.height, 0, RenderTextureFormat.R8);

        //set the camera's target texture when rendering
        tempCam.targetTexture = rt;

        //render all objects this camera can render, but with our own custom shader
        tempCam.RenderWithShader(drawSolidColor, "");

        //settings all material properties
        outlineMat.SetColor(OutlineColorProperty, outlineColor);
        outlineMat.SetFloatArray(Kernel, kernel);
        outlineMat.SetInt(KernelWidth, kernel.Length);
        outlineMat.SetTexture(SceneTex, src);

        outlineMat.SetFloat(inFront, showOutlineInFront ? 1 : 0);
        outlineMat.SetFloat(behind, showOutlineBehind ? 1 : 0);

        //no need for more then 1 sample. which also makes the mask a little bigger then it should be
        rt.filterMode = FilterMode.Point;

        //copy the temporary RT to the final image
        Graphics.Blit(rt, dest, outlineMat);
        
        tempCam.targetTexture = src;

        //free the video memory
        RenderTexture.ReleaseTemporary(rt);
    }
}
