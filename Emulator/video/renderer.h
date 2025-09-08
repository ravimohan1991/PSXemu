#pragma once
#include <memory>
#include "opengl/shader.h"
#include <video/gpu_core.h>

#ifdef KR_MAC_PLATFORM
#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#endif
#include <GLFW/glfw3.h>
#ifdef KR_MAC_PLATFORM
#include <GLFW/glfw3native.h>
#endif

constexpr int MAX_VERTICES = 1024 * 512;

/**
 * @brief The drawing primitives supported by PS1
 */
enum class Primitive
{
	Polygon = 0,
	Rectangle = 1,
	Line = 2
};

class GPU;
class Bus;

class Renderer
{
public:
	/**
	 * @brief The constructor for initializing window width and height and
	 * initialize vram
	 *
	 * @note vram is a global variable defined in vram.cpp
	 */
	Renderer(int width, int height, const std::string& title, Bus* _bus);
	
	/**
	 * @brief Destructor
	 *
	 * @note Nothing here atm
	 */
	~Renderer();

	/**
	 * @brief A draw call in rendering is a command from the CPU to the GPU to render a specific set
	 * of geometry with certain materials or states. Each draw call represents the act of submitting mesh
	 * and material data to the GPU, instructing it on what and how to render on the screen.
	 *
	 * Called in GPU::gp0_render_polygon()
	 * @note Batch vertex data.
	 *
	 * @param data								Vertex buffer?
	 * @param primitive							Polygon, rectangle, or line
	 */
	void draw_call(std::vector<Vertex>& data, Primitive primitive);
	
	/**
	 * @brief Force draw vertex data.
	 *
	 * @brief data								Vertex buffer
	 *
	 * @note Called in GPU::gp0_fill_rect()
	 */
	void draw(std::vector<Vertex>& data);

	/**
	 * @brief Atm does the glfw polling
	 */
	void update();
	
	/**
	 * @brief Swap back and front buffers
	 */
	void swap();
	
	/**
	 * @brief Return true if glfw window is open
	 */
	bool is_open();

public:
	int32_t window_width, window_height;
	uint framebuffer;
	uint framebuffer_texture;
	uint framebuffer_rbo;

	uint draw_vbo, draw_vao;
	uint primitive_count = 0;
	std::vector<Vertex> draw_data;

	std::unique_ptr<Shader> shader;
	GLFWwindow* window;
	Bus* bus;
};
