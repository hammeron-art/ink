package ink.render;

import kha.Color;
import kha.graphics2.Style;

class RenderSystem extends ink.core.AppSystem {

	public var backColor:Color;

	public function new() {
		super();
		backColor = Color.Purple;
	}

	public function render(framebuffer:kha.Framebuffer) {
		//framebuffer.g4.clear(backColor);

		/*#if (!webgl)
		@:privateAccess {
			var g:kha.js.CanvasGraphics = cast framebuffer.g2;
			g.width = 960;
			g.height = 540;
			g.canvas.width = 960;
			g.canvas.height = 540;
			g.canvas.save();
		}
		#end*/

		var style1 = new Style();
		var style2 = new Style();
		var style3 = new Style();

		style1.fillColor = Color.Red;
		style2.fill = false;
		style2.strokeColor = Color.Green;
		style2.strokeWeight = 5;

		style3.strokeColor = Color.Cyan;
		style3.strokeWeight = 3;
		//style3.fill = false;

		var g = framebuffer.g2;
		g.begin(true/*, Color.fromFloats(0.05, 0.2, 0.02, 1.0)*/);
		
		g.rect(0, 0, 32, 32, style1);
		g.translate(32, 32);
		g.rect(0, 0, 32, 32, style2);
		g.scale(3.0, 3.0);
		g.translate(32, 0);
		g.rect(0, 0, 32, 32, style3);
		g.translate(64, 64);
		g.rotate(kha.System.time);
		g.quad(-16, -32, 16, -24, 40, 12, -20, 35);
		g.rect(-16, -16, 32, 32, style2);

		/*g.color = Color.White;
		var entities = app.stateManager.getCurrentState().scene.entityList;
		//g.fill(Color.fromFloats(1.0, 0.5, 0.5, 0.5));

		g.rect(8, 8, 64, 64, style1);
		g.triangle(64, 64-64, 64-32, 64, 64+32, 64, style1);
		g.quad(256, 256, 256+128+78, 256, 256+128+15, 256+128+23, 256+12, 256+128+6);

		for (entity in entities) {
			var transform = entity.transform;
			//g.stroke(Color.fromFloats(0.0, 0.0, 1.0, 1.0));
			//g.strokeWeight(6);
			g.translate(transform.x, transform.y);
			g.rect(-32, -32, 32, 32, style2);
			//g.stroke(Color.fromFloats(0.5, 0.5, 0.5, 1.0));
			//g.strokeWeight(2);
			g.line(0, 0, 128, 0);
		}*/

		g.end();
	}

}