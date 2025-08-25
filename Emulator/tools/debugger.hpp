#pragma once
#include <vector>
#include "cpu_widget.hpp"
#include "mem_widget.hpp"

class Bus;
class DEBugger {
public:
	friend class CPUWidget;
	friend class MemWidget;
	friend class GPUWidget;

public:
    DEBugger(Bus* _bus);
	~DEBugger();

	void init_theme();
	void display();

	template <typename T>
	void push_widget();

private:
	Bus* bus;
	std::vector<Widget*> widget_stack;
};

template<typename T>
inline void DEBugger::push_widget()
{
	widget_stack.push_back(new T(this));
}
