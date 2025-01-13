#pragma once
#include "widget.hpp"

class Debugger;
class MemWidget : public Widget {
public:
    MemWidget(class DEBugger* _debugger) : 
		Widget("Memory Editor"), debugger(_debugger) {}
	~MemWidget() = default;

	void execute() override;

private:
	class DEBugger* debugger;
};
