#include <stdafx.hpp>
#include "shader.h"

Shader::~Shader()
{
   
}

void Shader::bind()
{
}

void Shader::unbind()
{
    
}

void Shader::set_int(const char* str, int val)
{
    
}

void Shader::set_vec2(const char* str, const glm::vec2& val)
{
}

void Shader::load(const std::string& filepath, ShaderType type)
{
    std::string shader_code;
    std::ifstream shader_file;

    shader_file.exceptions(std::ifstream::failbit | 
                           std::ifstream::badbit);
    try {
        shader_file.open(filepath);
        
        std::stringstream ss;
        ss << shader_file.rdbuf();
       
        shader_file.close();
        shader_code = ss.str();        
    }
    catch (std::ifstream::failure e) {
        printf("Could not read shader file!\n");
    }
    
    const char* shader_str = shader_code.c_str();

}

void Shader::build()
{

}

uint Shader::raw()
{
    return shader_id;
}

void Shader::check_errors(uint shader, ShaderType type)
{
}
