package ink.render;

import kha.Color;
//import kha.graphics2.Style;

class RenderSystem extends ink.core.AppSystem {

	public var backColor:Color;
	public var renderEvent = new ink.core.Event<kha.Framebuffer->Void>();
	//var starTime:Float;
	//var video:kha.Video;

	public function new() {
		super();
		backColor = Color.Purple;

		//starTime = kha.System.time;
	}

	override public function onInit() {
		//kha.Assets.videos.gameVideo.play(true);

		//video = kha.Assets.videos.gameVideo;
		//trace(video.width(), video.height(), video.getLength());
		//video.play(true);
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

		var g = framebuffer.g2;
		g.begin();

		for (entity in scene.entityList) {
			var drawable = entity.getComponent(ink.render.SpriteComponent);

			if (drawable != null) {
				var matrix = entity.transform.getWorld();
				g.drawImage(drawable.texture.image, matrix.translation.x, matrix.translation.y);
			}
		}

		g.end();

		/*var date = Date.now();
		var hour = date.getHours();
		var minutes = date.getMinutes();
		var seconds = date.getSeconds();

		var width:Float = kha.System.windowWidth();
		var height:Float = kha.System.windowHeight();
		var centerX = width / 2;
		var centerY = height / 2;
		var radius = Math.min(width, height) / 2;
		var image = kha.Assets.images.sprite;

		var g = framebuffer.g2;
		
		g.style.font = kha.Assets.fonts.notoSansRegular;
		g.style.fontSize = 32;
		g.style.fillColor = kha.Color.Magenta;

		var style1 = new Style();
		style1.fill = false;
		style1.strokeColor = kha.Color.Cyan;
		style1.strokeWeight = 3;

		var style2 = new Style();
		style2.fillColor = kha.Color.White;
		style2.strokeColor = kha.Color.Orange;
		style2.strokeWeight = 1;

		var style3 = new Style();
		style3.strokeColor = kha.Color.Red;
		style3.strokeWeight = 2;

		g.begin(true);

		// Frame
		g.push();
		g.translate(centerX, centerY);

		// Images
		g.image(image, -128, 16);
		g.scaledImage(image, -256, 64, 64, 64);
		g.subImage(image, -256-64, 128, 120, 100, 120, 100);
		g.scaledSubImage(image, -256-128, -64, 120, 100, 120, 100, 128, 128);

		g.ellipse(0, 0, radius, radius, style1);
		var start = g.pop();

		// Pointers
		g.translate(centerX, centerY);
		g.ellipse(0, 0, 32, 32, style1);

		g.rotate(-Math.PI / 2);
		
		style2.fillColor = kha.Color.fromFloats(1.0, 1.0, 1.0, 0.5);
		g.push();
		g.rotate((hour / 12) * Math.PI * 2);
		g.triangle(32, -4, radius/2, 0, 32, 4, style2);
		g.pop();

		g.push();
		g.rotate((minutes / 60) * Math.PI * 2);
		g.rect(32, -4, radius-64, 8, style2);
		g.pop();

		g.push();
		g.rotate((seconds / 60) * Math.PI * 2);
		g.line(32, 0, radius-32, 0, style3);
		g.pop();

		for (i in 1...13) {
			g.rotate((Math.PI * 2) / 12);
			g.text('$i', radius - 16 - g.style.font.width(g.style.fontSize, '$i') / 2, -g.style.font.height(g.style.fontSize) / 2);
		}

		// Misc
		g.setTransform(start);

		var trans = kha.math.FastMatrix3.rotation((Math.PI * 2 / 12) * (seconds % 12));
		var p1 = new kha.math.FastVector2(radius-48, 0);

		g.beginShape(kha.graphics2.Primitive.Lines, style1);
		for (i in 0...12) {
			p1 = trans.multvec(p1);
			g.vertex(p1.x, p1.y);
		}
		g.endShape(true);


		g.video(video, 32, 32, 200, 200);

		g.end();*/

		renderEvent.dispatch(framebuffer);
	}

}