package ink.render;

import kha.graphics4.PipelineState;

class Material {

	public var state:PipelineState;

	public function new() {
		state = new PipelineState();
	}

	public function build() {
		state.compile();
	}

	public function apply(g:kha.graphics4.Graphics) {
		g.setPipeline(state);
	}
}