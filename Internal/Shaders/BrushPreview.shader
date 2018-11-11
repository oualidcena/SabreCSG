﻿// Based on "Legacy Shaders/Transparent/Diffuse"
Shader "SabreCSG/BrushPreview"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_GridAlpha("Grid Alpha", Range(0,1)) = 0.3
		[HideInInspector] _GridSize("Grid Size", float) = 1.0
		[HideInInspector] _GridToggle("Grid Toggle", float) = 1.0
		[HideInInspector] _FaceToggle("Face Toggle", float) = 1.0
	}

	SubShader
	{
		Fog { Mode Off }
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200

		CGPROGRAM
			#pragma surface surf Lambert alpha:blend nofog

			fixed4 _Color;
			float _GridAlpha;
			float _GridSize;
			half _GridToggle;
			half _FaceToggle;

			struct Input
			{
				float3 worldPos;
				float3 worldNormal;
			};

			float mod(float val, float mod) {

				while (val < 0) {
					val += mod*100;
				}

				return fmod(val, mod);
			}

			void surf (Input IN, inout SurfaceOutput o)
			{
				float dist = distance(_WorldSpaceCameraPos, IN.worldPos);
				float gridThickness = max(0.08, smoothstep(0.0, 1.0, dist / 80.0));

				// counteract subpixel grid lines on small grid sizes.
				gridThickness += lerp(log2(1/_GridSize)*0.25, 0.0, min(1.0, _GridSize));

				fixed4 c = _Color;
				c.a *= _FaceToggle;

				float3 worldNormal = abs(IN.worldNormal);
			
				worldNormal.x = (worldNormal.x > worldNormal.y && worldNormal.x > worldNormal.z)?1:0;
				worldNormal.y = (worldNormal.y > worldNormal.x && worldNormal.y > worldNormal.z)?1:0;
				worldNormal.z = (worldNormal.z > worldNormal.y && worldNormal.z > worldNormal.x)?1:0;

				float3 worldspace = IN.worldPos;
				worldspace -= (gridThickness * _GridSize) / 6.28;

				float2 grid = float2(
					(worldspace.z * worldNormal.x) + (worldspace.x * worldNormal.z) + (worldspace.x * worldNormal.y),
					(worldspace.y * worldNormal.x) + (worldspace.y * worldNormal.z) + (worldspace.z * worldNormal.y)
				);

				_GridSize = max(0.01, _GridSize);

				grid.x = mod(grid.x,_GridSize);
				grid.y = mod(grid.y,_GridSize);

				grid.x = saturate(1.0 - sin(grid.x * ((3.14/_GridSize)+gridThickness/_GridSize)) * 30);
				grid.y = saturate(1.0 - sin(grid.y * ((3.14/_GridSize)+gridThickness/_GridSize)) * 30);

				float g = saturate(grid.x + grid.y);

				o.Emission = c.rgb + (g * _GridAlpha * _GridToggle);
				o.Alpha = c.a + (g * _GridAlpha * _GridToggle);
			}
		ENDCG
	}

	Fallback "Legacy Shaders/Transparent/VertexLit"
}