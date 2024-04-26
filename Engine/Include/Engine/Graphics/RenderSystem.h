#pragma once
#include <DX3D/Prerequisites.h>
#include <DX3D/Graphics/Texture2D.h>
#include <d3d11.h> 
#include <wrl.h>


class RenderSystem
{
public:

	RenderSystem();

	~RenderSystem();
public:
	SwapChainPtr createSwapChain(HWND hwnd, ui32 width, ui32 height);
	DeviceContextPtr getImmediateDeviceContext();
	VertexBufferPtr createVertexBuffer(void* list_vertices, ui32 size_vertex, ui32 size_list);
	IndexBufferPtr createIndexBuffer(void* list_indices, ui32 size_list);
	ConstantBufferPtr createConstantBuffer(void* buffer, ui32 size_buffer);
	VertexShaderPtr createVertexShader(const wchar_t* full_path, const char* entryPoint);
	PixelShaderPtr createPixelShader(const wchar_t* full_path, const char* entryPoint);
	Texture2DPtr createTexture(const wchar_t* full_path);
	Texture2DPtr createTexture(const Rect& size, Texture2D::Type type);


public:
	//bool compileVertexShader(const wchar_t* file_name, const char* entry_point_name, void** shader_byte_code, size_t* byte_code_size);
	//bool compilePixelShader(const wchar_t* file_name, const char* entry_point_name, void** shader_byte_code, size_t* byte_code_size);
	//void releaseCompiledShader();
	void setCullMode(const CullMode& mode);
private:
	void compilePrivateShaders();
	void initRasterizerStates();
private:
	DeviceContextPtr m_imm_device_context;
private:
	Microsoft::WRL::ComPtr<ID3D11Device> m_d3d_device;
	Microsoft::WRL::ComPtr<IDXGIDevice>  m_dxgi_device;
	Microsoft::WRL::ComPtr<IDXGIAdapter>  m_dxgi_adapter;
	Microsoft::WRL::ComPtr<IDXGIFactory>  m_dxgi_factory;
	Microsoft::WRL::ComPtr<ID3D11DeviceContext> m_imm_context;

	Microsoft::WRL::ComPtr<ID3DBlob>  m_blob = nullptr;

	Microsoft::WRL::ComPtr<ID3D11RasterizerState> m_cull_front_state = nullptr;
	Microsoft::WRL::ComPtr<ID3D11RasterizerState> m_cull_back_state = nullptr;
	Microsoft::WRL::ComPtr<ID3D11RasterizerState> m_cull_none_state = nullptr;
	Microsoft::WRL::ComPtr<ID3D11BlendState> m_alphaBlendState = nullptr;


	Microsoft::WRL::ComPtr<ID3DBlob>  m_vsblob = nullptr;
	Microsoft::WRL::ComPtr<ID3DBlob>  m_psblob = nullptr;
	Microsoft::WRL::ComPtr<ID3D11VertexShader> m_vs = nullptr;
	Microsoft::WRL::ComPtr<ID3D11PixelShader> m_ps = nullptr;


	unsigned char m_meshLayoutByteCode[1024];
	size_t m_meshLayoutSize = 0;

private:
	friend class SwapChain;
	friend class VertexBuffer;
	friend class IndexBuffer;
	friend class ConstantBuffer;
	friend class VertexShader;
	friend class PixelShader;
	friend class Texture2D;
	friend class FrameBuffer;
};