package ink.render;

import kha.Color;

class RenderSystem extends ink.core.AppSystem {

	public var backColor:Color;

	public function new() {
		super();
		backColor = Color.Purple;
	}

	public function render(framebuffer:kha.Framebuffer) {
		framebuffer.g4.clear(backColor);
	}

}