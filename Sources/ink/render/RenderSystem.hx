package ink.render;

import kha.Color;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.graphics4.*;
import kha.Shaders;

class RenderSystem extends ink.core.AppSystem {

	public var backColor:Color;
	public var renderEvent = new ink.core.Event<kha.Framebuffer->Void>();

	var vertexStructure:VertexFormat;
	var material:Material;
	var textureID:kha.graphics4.TextureUnit;
	var mvpID:kha.graphics4.ConstantLocation;

	// An array of 3 vectors representing 3 vertices to form a triangle
    var vertices:Array<Float>;
    // Indices for our triangle, these will point to vertices above
    var indices:Array<Int>;

    var vertexBuffer:VertexBuffer;
    var indexBuffer:IndexBuffer;
    var pipeline:PipelineState;

	public function new() {
		super();
		backColor = Color.Purple;
		material = new Material();

		material.state.fragmentShader = kha.Shaders.default_frag;
		material.state.vertexShader = kha.Shaders.default_vert;

		var structure = new kha.graphics4.VertexStructure();
		structure.add("position", kha.graphics4.VertexData.Float3);
		structure.add("texcoord", kha.graphics4.VertexData.Float2);
		structure.add("color", kha.graphics4.VertexData.Float4);
		material.state.inputLayout = [structure];

		material.build();

		var image = kha.Assets.images.sprite;

		// An array of 3 vectors representing 3 vertices to form a triangle
		vertices = [
			-image.width/2, -image.height/2, 0.0, 0, 1, // Bottom-left
			image.width/2, -image.height/2, 0.0, 1, 1, // Bottom-right
			0,  image.height/2, 0.0, 0.5, 0 // Top
		];
		// Indices for our triangle, these will point to vertices above
		indices = [
			0, // Bottom-left
			1, // Bottom-right
			2  // Top
		];

		/*vertexStructure = new VertexFormat();
		vertexStructure.elements.push(new VertexElement(TFloat(3), SPosition));
		vertexStructure.elements.push(new VertexElement(TFloat(2), STexcoord));
		vertexStructure.elements.push(new VertexElement(TFloat(4), SColor));*/


		// Define vertex structure
		var structure = new VertexStructure();
		structure.add("pos", kha.graphics4.VertexData.Float3);
		structure.add("texcoord", kha.graphics4.VertexData.Float2);

		// Save length - we only store position in vertices for now
		// Eventually there will be texture coords, normals,...
		var structureLength = 5;

		// Compile pipeline state
		// Shaders are located in 'Sources/Shaders' directory
		// and Kha includes them automatically
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.compile();

		textureID = pipeline.getTextureUnit('tex');
		mvpID = pipeline.getConstantLocation('modelViewProjection');

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
		Std.int(vertices.length / 3), // Vertex count - 3 floats per vertex
		structure, // Vertex structure
		Usage.StaticUsage // Vertex data will stay the same
		);

		// Copy vertices to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
		vbData.set(i, vertices[i]);
		}
		vertexBuffer.unlock();

		// Create index buffer
		indexBuffer = new IndexBuffer(
		indices.length, // 3 indices for our triangle
		Usage.StaticUsage // Index data will stay the same
		);

		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
		iData[i] = indices[i];
		}
		indexBuffer.unlock();
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

		// Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
		var projection = FastMatrix4.perspectiveProjection(45.0, 960/540, 0.1, 1000.0);
		var fov = ink.math.MathUtil.degToRad(45);
		var distance = (0.5 * 540) / Math.tan(fov * 0.5);
		trace(distance);
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

		// Bind state we want to draw with
		g.setPipeline(pipeline);

		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		var mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		g.setMatrix(mvpID, mvp);
		g.setTexture(textureID, kha.Assets.images.sprite);
		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Draw!
		g.drawIndexedVertices();

		g.end();

		/*var scene = app.stateManager.getCurrentState().scene;

		//g.begin();
		//g.clear(backColor);

		var mesh:Mesh = null;

		// Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);

		// Camera matrix
		var view = FastMatrix4.lookAt(new FastVector3(4, 3, 3), // Position in World Space
					new FastVector3(0, 0, 0), // and looks at the origin
					new FastVector3(0, 1, 0) // Head is up
		);

		// Model matrix: an identity matrix (model will be at the origin)
		var model = FastMatrix4.identity();

		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		var mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		material.apply(g);
		g.setMatrix(mvpID, mvp);

		for (entity in scene.entityList) {
			var drawable = entity.getComponent(ink.render.SpriteComponent);

			if (drawable != null) {
				mesh = new Mesh(drawable.mesh, vertexStructure);
				mesh.build();

				mesh.apply(g);
				g.setTexture(textureID, drawable.texture.image);
			
				g.drawIndexedVertices();
			}
		}*/

		renderEvent.dispatch(framebuffer);
	}

}