package ink.input;

import ink.core.Application;
import ink.core.AppSystem;
import ink.core.Event;
import ink.core.Log;
import ink.input.Input;
import kha.Key;
import kha.Scheduler;
import kha.input.Gamepad;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Sensor;
import kha.input.Surface;

#if !macro
/**
 * Handle all player input
 * Keyboard, mouse, touch and gamepad
 */
@:allow(ink.core.Application)
class InputSystem extends ink.core.AppSystem {
	
	public var onKeyEvent = new Event<KeyEvent->Void>();
	public var onPointerEvent = new Event<PointerEvent->Void>();
	
	var keyStates:Map<KeyCode, Int>;
	var padStates:Map<PadKey, Int>;
	var padAxisStates:Map<PadAxis, Float>;
	var pointerStates:Map<Int, Map<PointerKey, Pointer>>;
	
	var keyBindings:Map<String, Array<KeyCode>>;
    var padKeyBindings:Map<String, Array<PadKey>>;
	var pointerBindings:Map<String, Array<PointerKey>>;
	
    var inputReleased:Map<String, Bool>;
    var inputPressed:Map<String, Bool>;
    var inputDown:Map<String, Bool>;
	
	var ignoreLastKey:Bool;
	var frameCount:Int;
	
	override public function onInit():Void {
		keyStates = new Map();
		padStates = new Map();
		padAxisStates = new Map();
		pointerStates = new Map();
		
		keyBindings = new Map();
        padKeyBindings = new Map();
		pointerBindings = new Map();
		
        inputDown = new Map();
        inputPressed = new Map();
        inputReleased = new Map();
		
		ignoreLastKey = false;
		frameCount = 0;

		Keyboard.get().notify(onKeyDown, onKeyUp);
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		
		#if android
		Surface.get().notify(onTouchDown, null, null);
		#end
	}
	
	function onTouchDown(index, x, y) {
		pointerEvent(index, 0, x, y, 0, 0, MDown);
		/*pointerEvent({
			kind: MDown,
			x: x,
			y: y,
			dx: 0,
			dy: 0,
			id: index,
			pressure: 1,
			button: 0,
		});*/
		
		//trace('Touch');
	}
	
	function onMouseDown(button:Int, x:Int, y:Int) {
		pointerEvent(0, button, x, y, 0, 0, MDown);
		/*pointerEvent({
			kind: MDown,
			x: x,
			y: y,
			dx: 0,
			dy: 0,
			id: 0,
			pressure: 1,
			button: button,
		});*/
	}
	
	function onMouseUp(button:Int, x:Int, y:Int) {
		pointerEvent(0, button, x, y, 0, 0, MUp);
		/*pointerEvent({
			kind: MUp,
			x: x,
			y: y,
			dx: 0,
			dy: 0,
			id: 0,
			pressure: 1,
			button: button,
		});*/
	}
	
	function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int) {
		pointerEvent(0, 0, x, y, movementX, movementY, MMove);
		/*pointerEvent({
			kind: MMove,
			x: x,
			y: y,
			dx: movementX,
			dy: movementY,
			id: 0,
			pressure: 1,
			button: 0,
		});*/
	}

	function pointerEvent(index, button:Int, x, y, movementX, movementY, kind) { //event:PointerEvent) {
		var pointer = getPointerState(button, index);
		
		if (onPointerEvent.__listeners.length > 0) {
			onPointerEvent.dispatch({
				kind: kind,
				x: x,
				y: y,
				dx: movementX,
				dy: movementY,
				id: index,
				pressure: 1,
				button: button,
			});
		}	
		
		switch( kind ) {
		case MDown:
			if (pointer.frame <= 0)
				pointer.frame = getFrame();
		case MUp:
			pointer.frame = -getFrame();
			pointer.x = x;
			pointer.y = y;
		case MMove:
			pointer.x = x;
			pointer.y = y;
		case MMoveRelative:
			pointer.dx = movementX;
			pointer.dy = movementY;
		case MUnknown:
			Log.info('Unknown mouse event');
		}
	}
	
	public function isDown(name:String) {
		var result = false;
		
		if (keyBindings.exists(name)) {
			for (key in keyBindings[name]) {
				result = isKeyDown(key);
				if (result) break;
			}
		}
		
		if (padKeyBindings.exists(name)) {
			for (key in padKeyBindings[name]) {
				result = result || isPadDown(key);
				if (result) break;
			}
		}
		
		if (pointerBindings.exists(name)) {
			for (key in pointerBindings[name]) {
				result = result || isPointerDown(key);
				if (result) break;
			}
		}
		
		return result;
	}
	
	public function isPressed(name:String) {
		if (!keyBindings.exists(name))
			return false;
		
		for (key in keyBindings[name]) {
			return isKeyPressed(key);
		}
		
		return false;
	}
	
	public function isReleased(name:String) {
		if (!keyBindings.exists(name))
			return false;
		
		for (key in keyBindings[name]) {
			return isKeyReleased(key);
		}
		
		return false;
	}
	
	inline public function isKeyDown(key:KeyCode) {
		return keyStates[key] > 0;
	}
	
	inline public function isKeyPressed(key:KeyCode) {
		return keyStates[key] == getFrame();
	}
	
	inline public function isKeyReleased(key:KeyCode) {
		return keyStates[key] == -getFrame();
	}
	
	inline public function isPointerDown(key:PointerKey) {
		return getPointerState(key).frame > 0;
	}
	
	inline public function isPointerPressed(key:PointerKey) {
		return getPointerState(key).frame == getFrame();
	}
	
	inline public function isPointerReleased(key:PointerKey) {
		return getPointerState(key).frame == -getFrame();
	}
	
	inline public function isPadDown(key:PadKey) {
		return padStates[key] > 0;
	}
	
	inline public function isPadPressed(key:PadKey) {
		return padStates[key] == getFrame();
	}
	
	inline public function isPadReleased(key:PadKey) {
		return padStates[key] == -getFrame();
	}
	
	public function getAxisValue(axis:PadAxis) {
		return padAxisStates.exists(axis) ? padAxisStates[axis] : 0;
	}
	
	public function getKeyState(key:KeyCode) {
		if (!keyStates.exists(key)) {
			keyStates.set(key, 0);
		}
		
		// For some reason keyState map don't work for neko
		// and we have to manually loop through the map
		
		#if !neko
		return keyStates[key];
		#else
		for (k in keyStates)
			if (k == key)
				return k;
		
		return null;
		#end
	}
	
	public function getPadState(key:PadKey) {
		if (!padStates.exists(key)) {
			padStates.set(key, 0);
		}
		
		return padStates[key];
	}
	
	public function getPointerState(key:PointerKey, id = 0) {
		if (!pointerStates.exists(id)) {
			pointerStates.set(id, new Map());
		}
		
		if (!pointerStates[id].exists(key)) {
			pointerStates[id].set(key, {
				button: key,
				id: 0,
				x: 0,
				y: 0,
				dx: 0,
				dy: 0,
				pressure: 0,
				frame: 0,
			});
		}
		
		return pointerStates[id].get(key);
	}
	
	public function bindKey(name:String, key:KeyCode) {
		if (!keyBindings.exists(name)) {
			keyBindings.set(name, []);
		}
		
		keyBindings[name].push(key);
	}
	
	public function bindPadKey(name:String, key:PadKey) {
		if (!padKeyBindings.exists(name)) {
			padKeyBindings.set(name, []);
		}
		
		padKeyBindings[name].push(key);
	}
	
	public function bindPointer(name:String, key:PointerKey) {
		if (!pointerBindings.exists(name)) {
			pointerBindings.set(name, []);
		}
		
		pointerBindings[name].push(key);
	}
	
	#if (!flash && lime)
	function padConnected(pad:lime.ui.Gamepad) {
		Log.info('Gamepad ${pad.name} detected');
		Log.info([pad.guid, pad.name]);
		
		pad.onDisconnect.add(function() {
			padDisconnected(pad);
		});
		
		pad.onButtonDown.add(function(key) {
			var event:PadEvent = {
				key: key,
				kind: PKeyDown
			}
			
			padEvent(event);
		});
		
		pad.onButtonUp.add(function(key) {
			var event:PadEvent = {
				key: key,
				kind: PKeyUp
			}
			
			padEvent(event);
		});
		
		pad.onAxisMove.add(function(axis, value) {
			var event:PadEvent = {
				axis: axis,
				value: value,
				kind: PAxis
			}
			
			padEvent(event);
		});
	}
	
	function padDisconnected(pad:lime.ui.Gamepad) {
		Log.info('Gamepad ${pad.name} disconnected');
	}
	#end
	
	inline function getFrame() {
		return frameCount + 1;
	}
	
	override public function onUpdate(delta:Float):Void {
		++frameCount;
	}
	/**
	 * Transform axis move in key event
	 * @param	axis
	 * @param	value value must be between 0 and 1
	 */ 
	function axisEvent(event:PadEvent) {
		
		var threshold = 0.2;
		
		// Test and send axis as key event
		function stick(key:PadKey, v:Float) {
		
			var kind = PUnknown;
			
			if (!isPadDown(key) && v > 0.5 + threshold)
				kind = PKeyDown;
			if (isPadDown(key) && v < 0.5 + threshold)
				kind = PKeyUp;
			
			if (kind == PUnknown)
				return PUnknown;
			
			var event:PadEvent = {
				key: key,
				kind: kind
			}
			
			padEvent(event);
			
			return kind;
		}
		
		function dir(dir1, dir2, value, sValue) {
			if (value < 0.0) {
				stick(dir1, sValue);
				var event:PadEvent = {
					key: dir2,
					kind: PKeyUp
				}
				
				padEvent(event);
			} else {
				stick(dir2, sValue);
				var event:PadEvent = {
					key: dir1,
					kind: PKeyUp
				}
				
				padEvent(event);
			}
		}
		
		var sValue = Math.abs(event.value) * 0.5 + 0.5;
		
		switch (event.axis) {
			case PadAxis.LEFT_X:
				dir(PadKey.LSTICK_LEFT, PadKey.LSTICK_RIGHT, event.value, sValue);
				
			case PadAxis.LEFT_Y:
				dir(PadKey.LSTICK_UP, PadKey.LSTICK_DOWN, event.value, sValue);
				
			case PadAxis.RIGHT_X:
				dir(PadKey.RSTICK_LEFT, PadKey.RSTICK_RIGHT, event.value, sValue);
				
			case PadAxis.RIGHT_Y:
				dir(PadKey.RSTICK_UP, PadKey.RSTICK_DOWN, event.value, sValue);
			
			case PadAxis.TRIGGER_LEFT:
				var kind = PUnknown;
							
				if (!isPadDown(PadKey.LEFT_TRIGGER) && event.value >= 0.5)
					kind = PKeyDown;
				if (isPadDown(PadKey.LEFT_TRIGGER) && event.value < 0.5)
					kind = PKeyUp;
				
				if (kind == PUnknown)
					return;
				
				var event:PadEvent = {
					key: PadKey.LEFT_TRIGGER,
					kind: kind
				}
				
				padEvent(event);
			
			case PadAxis.TRIGGER_RIGHT:
				var kind = PUnknown;
							
				if (!isPadDown(PadKey.RIGHT_TRIGGER) && event.value >= 0.5)
					kind = PKeyDown;
				if (isPadDown(PadKey.RIGHT_TRIGGER) && event.value < 0.5)
					kind = PKeyUp;
				
				if (kind == PUnknown)
					return;
				
				var event:PadEvent = {
					key: PadKey.RIGHT_TRIGGER,
					kind: kind
				}
				
				padEvent(event);
				
			
			default:
				Log.info("Unknown gamepad event");
		}
	}
	
	function padEvent(event:PadEvent) {
		switch (event.kind) {
		case PKeyDown:
			if (getPadState(event.key) <= 0)
				padStates[event.key] = getFrame();
		case PKeyUp:
			padStates[event.key] = -getFrame();
		case PAxis:
			axisEvent(event);
			padAxisStates[event.axis] = event.value;
		case PUnknown:
			Log.warn('Unknown gamepad event $event');
		}
	}
	
	function onKeyDown(key:Key, char:String) {
		
		var keyCode = khaKeyToKeyCode(key, char);
		keyEvent(keyCode, char.charCodeAt(0), KDown);
		
	}
	
	function onKeyUp(key:Key, char:String) {
		
		var keyCode = khaKeyToKeyCode(key, char);
		keyEvent(keyCode, char.charCodeAt(0), KUp);
	}
	
	function khaKeyToKeyCode(key:Key, char:String) {
		return switch (key) {
			case BACKSPACE:
				KeyCode.BACKSPACE;
			case TAB:
				KeyCode.TAB;
			case ENTER:
				KeyCode.RETURN;
			case SHIFT:
				KeyCode.LEFT_SHIFT;
			case CTRL:
				KeyCode.LEFT_CTRL;
			case ALT:
				KeyCode.LEFT_ALT;
			case CHAR:
				char.charCodeAt(0);
			case ESC:
				KeyCode.ESCAPE;
			case DEL:
				KeyCode.DELETE;
			case UP:
				KeyCode.UP;
			case DOWN:
				KeyCode.DOWN;
			case LEFT:
				KeyCode.LEFT;
			case RIGHT:
				KeyCode.RIGHT;
			case BACK:
				KeyCode.BACKSPACE;
		}
	}
	
	function keyEvent(keyCode:KeyCode, charCode:Int, kind:KeyEventKind) {

		if (onKeyEvent.__listeners.length > 0) {
			var event:KeyEvent = {
				keyCode: keyCode,
				charCode: charCode,
				modifier: KeyModifier.NONE,
				kind: kind,
				frame: 0,
				propagate: true
			}
			onKeyEvent.dispatch(event);

			if (!event.propagate)
				return;
		}
		
		switch( kind ) {
		case KDown:
			if (getKeyState(keyCode) <= 0) {
				keyStates[keyCode] = getFrame();
			}
		case KUp:
			keyStates[keyCode] = -getFrame();
		default:
		}
	}
	
}

typedef KeyEvent = {
	var keyCode:KeyCode;
	var charCode:Int;
	var modifier:KeyModifier;
	var kind:KeyEventKind;
	var frame:Int;
	var propagate:Bool;
}

typedef Pointer = {
	var button:Int;
	var id:Int;
	var dx:Float;
	var dy:Float;
	var pressure:Float;
	var x:Float;
	var y:Float;
	@:optional var frame:Int;
}

typedef PointerEvent = {
	> Pointer,
	var kind:PointerEventKind;
}

typedef PadEvent = {
	var kind:PadEventKind;
	@:optional var key:PadKey;
	@:optional var axis:PadAxis;
	@:optional var value:Float;
}

enum KeyEventKind {
	KDown;
	KUp;
	KUnknown;
	KWheel;
}

enum PadEventKind {
	PKeyDown;
	PKeyUp;
	PAxis;
	PUnknown;
}

enum PointerEventKind {
	MDown;
	MMoveRelative;
	MUp;
	MMove;
	MUnknown;
}

typedef AxisState = {
	var frame:Int;
	var value:Float;
}
#end