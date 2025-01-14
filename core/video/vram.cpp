#include <stdafx.hpp>
#include <glad/glad.h>
#include "opengl/stb_image.h"
#include "opengl/stb_image_write.h"
#include "vram.h"

void VRAM::init()
{
	image_buffer = new ubyte[3 * 1024 * 512];
}

void VRAM::upload_to_gpu()
{
}

void VRAM::bind_vram_texture()
{
}

void VRAM::write_to_image()
{
	stbi_write_jpg("vram_dump.jpg", 1024, 512, 3, image_buffer, 100);
}

ushort VRAM::read(uint x, uint y)
{
	int index = (y * 1024) + x;
	return ptr[index];
}

void VRAM::write(uint x, uint y, ushort data)
{
	int index = (y * 1024) + x;
	ptr[index] = data;

	image_buffer[index * 3 + 0] = (data << 3) & 0xf8;
	image_buffer[index * 3 + 0] = (data >> 2) & 0xf8;
	image_buffer[index * 3 + 0] = (data >> 7) & 0xf8;
}

VRAM vram;
