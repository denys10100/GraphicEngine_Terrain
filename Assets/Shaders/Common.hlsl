/*MIT License

C++ 3D Game Tutorial Series (https://github.com/PardCode/CPP-3D-Game-Tutorial-Series)

Copyright (c) 2019-2022, PardCode

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

struct VS_INPUT
{
	float4 position: POSITION0;
	float2 texcoord: TEXCOORD0;
	float3 normal: NORMAL0;
	float3 tangent: TANGENT0;
	float3 binormal: BINORMAL0;
};

struct VPS_INOUT
{
	float4 position: SV_POSITION;
	float2 texcoord: TEXCOORD0;
	float3 normal: NORMAL0;
	float3 worldPosition: TEXCOORD1;
};

struct CameraData
{
	row_major float4x4 view;
	row_major float4x4 proj;
	float4 position;
};

struct LightData
{
	float4 color;
	float4 direction;
};

struct TerrainData
{
	float4 size;
	float heightMapSize;
};

struct WaterData
{
	float4 size;
	float heightMapSize;
};

cbuffer constant: register(b0)
{
	row_major float4x4 world;
	float time;
	CameraData  camera;
	LightData light;
	TerrainData terrain;
	WaterData water;
};



float3 computePhongLighting(
	CameraData camera,
	LightData light,
	float3 worldPosition,
	float3 normal,

	float ka,
	float3 ia,

	float kd,
	float3 id,

	float ks,
	float3 is,

	float shininess
)
{
	float3 light_direction = -normalize(light.direction.xyz);
	float3 directionToCamera = normalize(worldPosition - camera.position.xyz);

	//AMBIENT LIGHT
	float3 ambient_light = ka * ia;

	//DIFFUSE LIGHT
	float amount_diffuse_light = max(dot(light_direction.xyz, normal), 0.0);
	float3 diffuse_light = kd * (light.color.rgb * id) * amount_diffuse_light;

	//SPECULAR LIGHT
	float3 reflected_light = reflect(light_direction.xyz, normal);
	float amount_specular_light = pow(max(0.0, dot(reflected_light, directionToCamera)), shininess);

	float3 specular_light = ks * amount_specular_light * is;

	float3 final_light = ambient_light + diffuse_light + specular_light;

	return final_light;
}



float3 ComputeNormalFromHeightMap(
	Texture2D heightMap,
	sampler heightMapSampler,
	float heightMapSize,
	float2 texcoord,
	float normalFactor
)
{
	float texelSize = 1.0 / heightMapSize;

	float t = heightMap.SampleLevel(heightMapSampler, float2(texcoord.x, texcoord.y - texelSize), 0).r;
	float b = heightMap.SampleLevel(heightMapSampler, float2(texcoord.x, texcoord.y + texelSize), 0).r;
	float l = heightMap.SampleLevel(heightMapSampler, float2(texcoord.x - texelSize, texcoord.y), 0).r;
	float r = heightMap.SampleLevel(heightMapSampler, float2(texcoord.x + texelSize, texcoord.y), 0).r;


	t *= normalFactor;
	b *= normalFactor;
	l *= normalFactor;
	r *= normalFactor;

	float3 normal = float3(-(r - l) * 0.5, 1, -(b - t) * 0.5);

	return normalize(normal);
}