package ink.render;

import kha.graphics4.PipelineState;

class Material {

	public var pipeline:PipelineState;
	public var vertexFormat:VertexFormat;
	public var textures:haxe.ds.Vector<Texture>;

	var textureIds:haxe.ds.Vector<kha.graphics4.TextureUnit>;
	static var maxTextureNumber = 8;

	public function new() {
		pipeline = new PipelineState();
		textures = new haxe.ds.Vector(maxTextureNumber);
		textureIds = new haxe.ds.Vector(maxTextureNumber);
	}

	public function build() {
		pipeline.inputLayout = [vertexFormat.convertToVertexStructure()];
		pipeline.compile();

		for (i in 0...maxTextureNumber) {
			#if flash
			try {
				textureIds[i] = pipeline.getTextureUnit('tex$i');
			} catch (e:Dynamic) {
				textureIds[i] = null;
			}
			#else
			textureIds[i] = pipeline.getTextureUnit('tex$i');
			#end

			trace(textureIds[i]);
		}
	}

	public function apply(g:kha.graphics4.Graphics) {
		g.setPipeline(pipeline);
		
		for (i in 0...maxTextureNumber) {
			if (textures[i] != null && textureIds[i] != null)
				g.setTexture(textureIds[i], textures[i].image);
		}
	}
}