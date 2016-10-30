package ink.render;

class SpriteComponent extends MeshComponent {

	public var material:Material;
	public var texture:Texture;

	public function new(texture:Texture, material:Material = null) {
		this.texture = texture;
		this.material = material;

		super();

		mesh = {
			vertexCount: 4,
			positions: [
				[0.0, 0.0, 0.0],
				[texture.image.width, 0.0, 0.0],
				[0.0, texture.image.height, 0.0],
				[texture.image.width, texture.image.height, 0.0]
			],
			colors: [[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]],
			uvs: [[0.0, 1.0], [1.0, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: [0, 1, 2, 2, 1, 3],
		};
	}
}