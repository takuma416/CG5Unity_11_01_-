Shader "PostEffect/ToneCorrection"
{
    Properties
    {
        // インスペクターで調整できるようにする項目
        saturation("彩度", range(0,1)) = 1
        contrast("コントラスト", range(0,2)) = 1
    }

    SubShader
    {
        Tags{ "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma editor_sync_compilation

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

                // C#側（インスペクター）から送られてくる変数
                half saturation;
                half contrast;

                half4 Frag(Varyings input) : SV_Target
                {
                    // 1. 元の画面の色を取得
                    half4 output = SAMPLE_TEXTURE2D(
                        _BlitTexture, 
                        sampler_LinearRepeat, 
                        input.texcoord);

                    // 2. 輝度（グレースケール）を計算
                    half grayscale = 
                        0.2126 * output.r + 
                        0.7152 * output.g + 
                        0.0722 * output.b;

                    half4 monochromeColor = 
                        half4(grayscale, grayscale, grayscale, 1);

                    // 3. 彩度の適用（モノクロと元の色を補間）
                    half4 outputColor = 
                        lerp(monochromeColor, output, saturation);

                    // 4. コントラストの適用（ここが追加分！）
                    // 0.5を基準に色を広げることでコントラストを調整します
                    outputColor.rgb = (outputColor.rgb - 0.5) * contrast + 0.5;

                    return outputColor;
                }
            ENDHLSL
        }
    }
}