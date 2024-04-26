#pragma once
#include <d3d11.h> 
#include <wrl.h>
#include <DX3D/Prerequisites.h>


class DeviceContext
{
public:
	DeviceContext(ID3D11DeviceContext* device_context, RenderSystem * system);

	void clearRenderTargetColor(const SwapChainPtr& swap_chain,f32 red, f32 green, f32 blue, f32 alpha);
	void clearDepthStencil(const SwapChainPtr& swap_chain);

	
	void setVertexBuffer(const VertexBufferPtr& vertex_buffer);
	void setIndexBuffer(const IndexBufferPtr& index_buffer);


	void drawTriangleList(ui32 vertex_count, ui32 start_vertex_index);
	void drawIndexedTriangleList(ui32 index_count, ui32 start_vertex_index, ui32 start_index_location);
	void drawTriangleStrip(ui32 vertex_count, ui32 start_vertex_index);

	void setViewportSize(ui32 width, ui32 height);

	void setVertexShader(const VertexShaderPtr& vertex_shader);
	void setPixelShader(const PixelShaderPtr& pixel_shader);

	void setTexture(const Texture2DPtr* texture, ui32 num_textures);

	void setConstantBuffer(const ConstantBufferPtr& buffer);
private:
	Microsoft::WRL::ComPtr<ID3D11DeviceContext> m_device_context;
	RenderSystem * m_system = nullptr;
private:
	friend class ConstantBuffer;
};

