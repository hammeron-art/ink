package ink.render;

import kha.Color;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.Shaders;
import ink.render.VertexData;

class RenderSystem extends ink.core.AppSystem {

	public var backColor:Color;
	public var renderEvent = new ink.core.Event<kha.Framebuffer->Void>();

	var material:Material;
	var textureID:kha.graphics4.TextureUnit;
	var mvpID:kha.graphics4.ConstantLocation;
	var vertexStructure:VertexFormat;

	public function new() {
		super();
		backColor = Color.Purple;
		material = new Material();

		vertexStructure = new VertexFormat();
		vertexStructure.elements.push(new VertexElement(TFloat(3), SPosition));
		vertexStructure.elements.push(new VertexElement(TFloat(2), STexcoord));
		vertexStructure.elements.push(new VertexElement(TFloat(4), SColor));

		material.pipeline.fragmentShader = kha.Shaders.simple_frag;
		material.pipeline.vertexShader = kha.Shaders.simple_vert;
		material.pipeline.blendSource = kha.graphics4.BlendingFactor.BlendOne;
		material.pipeline.blendDestination = kha.graphics4.BlendingFactor.InverseSourceAlpha;
		material.pipeline.alphaBlendSource = kha.graphics4.BlendingFactor.SourceAlpha;
		material.pipeline.alphaBlendDestination = kha.graphics4.BlendingFactor.InverseSourceAlpha;
		material.vertexFormat = vertexStructure;
		material.build();

		textureID = material.pipeline.getTextureUnit('tex');
		mvpID = material.pipeline.getConstantLocation('modelViewProjection');
	}

	override public function onInit() {
	}

	public function render(framebuffer:kha.Framebuffer) {
		//framebuffer.g4.clear(backColor);

		#if (!webgl && html5)
		@:privateAccess {
			var g:kha.js.CanvasGraphics = cast framebuffer.g2;
			g.width = 960;
			g.height = 540;
			g.canvas.width = 960;
			g.canvas.height = 540;
			g.canvas.save();
		}
		#end

		var scene = app.stateManager.getCurrentState().scene;

		// Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
		var projection = FastMatrix4.perspectiveProjection(45.0, 960/540, 0.1, 1000.0);
		var fov = ink.math.MathUtil.degToRad(45);
		var distance = (0.5 * 540) / Math.tan(fov * 0.5);

		//projection = FastMatrix4.orthogonalProjection(0, 0, 540, 960, 0.1, 10000);
		// Camera matrix
		var view = FastMatrix4.lookAt(new FastVector3(0, 0, distance), // Position in World Space
					new FastVector3(0, 0, 0), // and looks at the origin
					new FastVector3(0, 1, 0) // Head is up
		);

		// Model matrix: an identity matrix (model will be at the origin)
		var model = FastMatrix4.identity();

		var g = framebuffer.g4;

		g.begin();
		g.clear(backColor);

		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		var mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		//mvp = mvp.multmat(model);

		for (entity in scene.entityList) {
			var drawable = entity.getComponent(ink.render.SpriteComponent);

			if (drawable != null) {
				var mesh = new Mesh(drawable.mesh, vertexStructure);
				mesh.build();
				mesh.apply(g);

				material.textures[0] = drawable.texture;
				material.apply(g);
			
				g.setMatrix(mvpID, mvp.multmat(entity.transform.getWorld()));
				g.drawIndexedVertices();
			}
		}

		g.end();

		renderEvent.dispatch(framebuffer);
	}

}