package ink.render;

import kha.math.FastMatrix4;
import ink.math.Matrix4x4;

class CameraComponent extends ink.entity.Component {
	var projection:Matrix4x4;
	
	public function new(projection) {
		super();

		this.projection = projection;
	}

	public function getProjectView() {
		
	}
}