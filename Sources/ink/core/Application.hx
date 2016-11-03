package ink.core;

import kha.Framebuffer;

typedef AppOptions = {
	> kha.System.SystemOptions,
	var backColor:kha.Color;
	var loadEverything:Bool;
}

class Application {

	public var renderSystem(default, null):ink.render.RenderSystem;
	public var input:ink.input.InputSystem;
	public var stateManager:ink.state.StateManager;

	var options:AppOptions;
	var systems:Array<AppSystem>;

	// If systems can be created
	var canAddSystens:Bool;

	public function new() {
		systems = [];
		
		// Default options
		options = {title: "Ink Application", width: 800, height: 600, backColor: kha.Color.fromValue(0x2a3133), loadEverything: true};
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
			@:privateAccess
			appSystem.app = this;
			appSystem.onInit();
		}

		onInit();
		initialState();
		Log.assert(stateManager.operations.length > 0 && stateManager.operations.first().action == ink.state.StateManager.StateAction.Push, 'Can\'t start without a state');
		stateManager.updateOperations();
	}

	/**
	 * Create core app systems
	 */
	function createDefaultSystems():Void {
		input = createSystem(new ink.input.InputSystem());
		//resourceManager = createSystem(new ResourceManager());
		stateManager = createSystem(new ink.state.StateManager());
		renderSystem = createSystem(new ink.render.RenderSystem());
		renderSystem.backColor = options.backColor;

		/*#if packer
		packer = createSystem(new TexturePacker());
		#end*/
	}

	function update(): Void {
		var delta = 1.0 / 60.0;
		//updateIntervalRemainder = Math.min(updateIntervalRemainder + delta, 0.33);
		
		onUpdate(delta);

		for (appSystem in systems) {
			appSystem.onUpdate(delta);
		}

		stateManager.updateStates(delta);
	}
	
	function render(framebuffer: Framebuffer): Void {
		if (renderSystem != null)
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