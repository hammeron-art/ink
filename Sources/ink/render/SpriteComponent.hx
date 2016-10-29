package ink.render;

class SpriteComponent extends DrawableComponent {

	public var material:Material;
	public var texture:Texture;

	public function new(texture:Texture, material:Material = null) {
		this.texture = texture;
		this.material = material;

		super();
	}
}