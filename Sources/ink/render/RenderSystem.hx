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

		var g = framebuffer.g2;

		var g = framebuffer.g2;
		g.begin(false);
		g.color = Color.White;

		var entities = app.stateManager.getCurrentState().scene.entityList;

		for (entity in entities) {
			var transform = entity.transform.getWorld();
			g.fillRect(transform.m[12], transform.m[13], 64, 64);
		}

		g.end();
	}

}