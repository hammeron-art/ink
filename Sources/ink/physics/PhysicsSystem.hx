package ink.physics;

import nape.space.Space;
import nape.geom.Vec2;
import nape.shape.ShapeType;

class PhysicsSystem extends ink.core.AppSystem {
	
	public var space:Space;

	public function new(?gravity:Vec2) {
		super();
		space = new Space(gravity == null ? new Vec2(0, 600) : gravity);
	}

	override public function onInit() {
		app.renderSystem.renderEvent.add(debugDraw);
	}

	override public function onUpdate(delta:Float) {
		space.step(delta);
	}

	function debugDraw(framebuffer:kha.Framebuffer) {
		var g = framebuffer.g2;

		g.begin(false);

		for (body in space.bodies) {
			
			for (shape in body.shapes) {
				if (shape.isCircle()) {
					//g.ellipse(body.position.x, body.position.y, 64, 32);
					//g.rect(body.position.x, body.position.y, 64, 64);
				}
			}

		}

		g.end();
	}

}