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

#include "Common.hlsl"

Texture2D HeightMap: register(t0);
sampler HeightMapSampler: register(s0);

VPS_INOUT vsmain(VS_INPUT input)
{
	VPS_INOUT output = (VPS_INOUT)0;

	float2 texcoord = (input.texcoord * 1) + time * 0.009;
	float2 texcoord2 = (float2(-input.texcoord.x, input.texcoord.y) * 1) + time * 0.01;

	float height1 = HeightMap.SampleLevel(HeightMapSampler, texcoord, 0).r;
	float height2 = HeightMap.SampleLevel(HeightMapSampler, texcoord2, 0).r;

	float height = lerp(height1, height2, 0.5);

	output.position = mul(float4(
		input.position.x * water.size.x,
		height * water.size.y,
		input.position.z * water.size.z,
		1),
		world);
	output.worldPosition = output.position.xyz;

	output.position = mul(output.position, camera.view);
	output.position = mul(output.position, camera.proj);
	output.texcoord = input.texcoord;

	return output;
}



float4 psmain(VPS_INOUT input) : SV_TARGET
{
	float2 texcoord = (input.texcoord * 8) + time * 0.009;
	float2 texcoord2 = (float2(-input.texcoord.x,input.texcoord.y) * 8) + time * 0.01;



	float3 normal1 = ComputeNormalFromHeightMap(
		HeightMap,
		HeightMapSampler,
		water.heightMapSize,
		texcoord,
		water.size.y * 3);

	float3 normal2 = ComputeNormalFromHeightMap(
		HeightMap,
		HeightMapSampler,
		water.heightMapSize,
		texcoord2,
		water.size.y * 3);



	float3 normal = normalize(lerp(normal1, normal2, 0.5));
	normal = normalize(mul(normal, (float3x3)world));


	float4 waterColor = float4(0.24, 0.37, 0.49 ,1);//GroundMap.Sample(GroundMapSampler, input.texcoord * 100.0);
	float4 crestColor = float4(1, 1, 1, 1);//CliffMap.Sample(CliffMapSampler, input.texcoord * 60.0);

	float4 color = waterColor;
	float angle = abs(dot(normal, float3(0, 1, 0)));

	float minAngle = 0.5;
	float maxAngle = 1.0;

	if (angle >= minAngle && angle <= maxAngle)
		color = lerp(crestColor, color, (angle - minAngle) * (1.0 / (maxAngle - minAngle)));
	if (angle < minAngle)
		color = crestColor;

	float3 final_light = computePhongLighting(
		camera,
		light,
		input.worldPosition.xyz,
		normal.xyz,

		3,
		color.rgb * float3(0.09, 0.09, 0.09),

		0.7,
		color.rgb,

		1.0,
		float3(1, 1, 1),

		30.0);

	return  float4(final_light, 0.8);
}