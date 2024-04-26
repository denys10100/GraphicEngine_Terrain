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

Texture2D GroundMap: register(t1);
sampler GroundMapSampler: register(s1);

Texture2D CliffMap: register(t2);
sampler CliffMapSampler: register(s2);


VPS_INOUT vsmain(VS_INPUT input)
{
	VPS_INOUT output = (VPS_INOUT)0;

	float height = HeightMap.SampleLevel(HeightMapSampler, input.texcoord, 0).r;
	output.position = mul(float4(
		input.position.x * terrain.size.x, 
		height * terrain.size.y, 
		input.position.z * terrain.size.z, 
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



	float3 normal = ComputeNormalFromHeightMap(
		HeightMap,
		HeightMapSampler,
		terrain.heightMapSize,
		input.texcoord,
		terrain.size.y);

	normal = normalize(mul(normal, (float3x3)world));

	float height = HeightMap.SampleLevel(HeightMapSampler, input.texcoord, 0).r;
	float4 ground = GroundMap.Sample(GroundMapSampler, input.texcoord * 100.0);
	float4 cliff = CliffMap.Sample(CliffMapSampler, input.texcoord * 60.0);

	float4 color = ground;
	float angle = abs(dot(normal, float3(0, 1, 0)));

	float minAngle = 0.5;
	float maxAngle = 1.0;

	if (angle >= minAngle && angle <= maxAngle)
		color = lerp(cliff, color, (angle - minAngle) * (1.0 / (maxAngle - minAngle)));
	if (angle < minAngle)
		color = cliff;


	float alpha = 0.0;

	if (height < 0.01)
		alpha = 0;
	else
		alpha = 1;


	float3 final_light = computePhongLighting(
		camera,
		light,
		input.worldPosition.xyz,
		normal.xyz,

		4,
		color.rgb * float3(0.09, 0.09, 0.09),

		0.7,
		color.rgb,

		0.0,
		float3(1, 1, 1),

		10.0);

	return float4(final_light, alpha);
}