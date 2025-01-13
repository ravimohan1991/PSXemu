#include "renderer.h"
#include <stdafx.hpp>
#include <memory/bus.h>
#include <video/vram.h>

Renderer::Renderer(int width, int height, const std::string& title, Bus* _bus) :
    bus(_bus)
{
    window_width = width;
    window_height = height;

    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);

    
    vram.init();
}

Renderer::~Renderer()
{
   
}

void Renderer::draw_call(std::vector<Vertex>& data, Primitive p)
{
    draw_data.insert(draw_data.end(), data.begin(), data.end());
}

void Renderer::draw(std::vector<Vertex>& data)
{
    /* Get current display resolution. */
    int width = bus->gpu->width[bus->gpu->status.hres];
    int height = bus->gpu->height[bus->gpu->status.vres];

    /* Display area start. */
    auto& display_area = bus->gpu->display_area;

    /* Ignore scissor test. */
    auto& draw_top_left = bus->gpu->drawing_area_top_left;
    auto& draw_bottom_right = bus->gpu->drawing_area_bottom_right;
    auto size = draw_bottom_right - draw_top_left;

    shader->bind();
    vram.bind_vram_texture();
    int count = (int)data.size();
}

void Renderer::update()
{
    glfwPollEvents();
}

void Renderer::swap()
{

    draw_data.clear();
    primitive_count = 0;
}

bool Renderer::is_open()
{
    return !glfwWindowShouldClose(window);
}
