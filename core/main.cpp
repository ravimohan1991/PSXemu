#include <stdafx.hpp>
#include <video/renderer.h>
#include <memory/bus.h>

int main()
{
    Karma::Log::Init();
    
	auto emulator = std::make_unique<Bus>("./bios/SCPH1001.BIN");

    std::string game_file = "./roms/RIDGERACERUSA.CUE";
	emulator->cddrive->insert_disk(game_file);

    while (/*emulator->renderer->is_open()*/true)
    {
		emulator->tick();
	}
}
