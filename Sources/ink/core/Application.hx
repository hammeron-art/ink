package ink.core;

import kha.Framebuffer;

typedef AppOptions = {
	> kha.System.SystemOptions,
	var backColor:kha.Color;
}

class Application {

	var options:AppOptions;
	var systems:Array<AppSystem>;

	// If systems can be created
	var canAddSystens:Bool;
	var renderSystem:ink.render.RenderSystem;
	var input:ink.input.InputSystem;

	public function new() {
		systems = [];
		
		// Default options
		options = {title: "Ink Application", width: 960, height: 540, backColor: kha.Color.fromValue(0x2a3133)};
	}

	public function initOptions(options) {
		return options;
	}

	/**
	 * User defined
	 * Create app systems
	 */
	public function createSystems():Void { }

	/**
	 * User defined
	 * Called after all systems have been set up
	 */
	public function onInit():Void { }
	
	/**
	 * User defined
	 * Push first stage
	 */
	public function initialState():Void { }
	
	/**
	 * User defined
	 * Fixed update method called before any other system or state fixed update
	 * @param	delta
	 */
	public function onFixedUpdate(delta:Float):Void { }
	
	/**
	 * User defined
	 * Update method called before any other system or state update
	 * @param	delta
	 */
	public function onUpdate(delta:Float):Void { }

	/**
	 * User defined
	 * Called when an window event occurs
	 * @param	event
	 */
	//public function onWindowEvent(event:WindowEvent):Void {}
	
	/**
	 * AppSystems are created with this method
	 */
	public function createSystem<T>(appSystem:T):T {
		Log.assert(canAddSystens == true, "Can't create app systems");

		systems.push(cast appSystem);
		return appSystem;
	}

	/**
	 * Get a AppSystem by type
	 */
	@:generic public function getSystem<T:(AppSystem)>(c:Class<T>):T {
		for (system in systems) {
			if (Std.is(system, c)) {
				return cast system;
			}
		}
		return null;
	}

	/**
	 * Inicialize application
	 *
	 * @param	bakenekoCore
	 */
	function init():Void {
		canAddSystens = true;
		createDefaultSystems();
		createSystems();
		canAddSystens = false;
		
		for (appSystem in systems) {
			appSystem.onInit();
		}

		onInit();
		initialState();
	}

	/**
	 * Create core app systems
	 */
	function createDefaultSystems():Void {
		input = createSystem(new ink.input.InputSystem());
		//resourceManager = createSystem(new ResourceManager());
		//stateManager = createSystem(new StateManager());
		renderSystem = createSystem(new ink.render.RenderSystem());
		renderSystem.backColor = options.backColor;
		/*#if packer
		packer = createSystem(new TexturePacker());
		#end*/
	}

	function update(): Void {
		var delta = 1 / 60;
		//updateIntervalRemainder = Math.min(updateIntervalRemainder + delta, 0.33);
		
		onUpdate(delta);

		for (appSystem in systems) {
			appSystem.onUpdate(delta);
		}

		//stateManager.updateStates(delta);
	}
	
	function render(framebuffer: Framebuffer): Void {
		renderSystem.render(framebuffer);
	}

	/*function background():Void {
		stateManager.backgroundStates();

		for (appSystem in systems) {
			appSystem.onBackground();
		}
	}

	function foreground():Void {
		for (appSystem in systems) {
			appSystem.onForeground();
		}

		stateManager.foregroundStates();
	}*/

}