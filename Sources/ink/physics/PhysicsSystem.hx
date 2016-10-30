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
	}

	override public function onUpdate(delta:Float) {
		space.step(delta);
	}

}