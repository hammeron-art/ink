package ink.state;

import ink.core.Application;
import ink.core.AppSystem;
import ink.core.Log;

@:allow(ink.core.Application)
class StateManager extends AppSystem {
	var states:Array<State>;
	var operations:List<StateOperation>;

	var isStartState:Bool = true;
	var statesActive:Bool = false;
	var statesForegrounded:Bool = #if html5 true #else false #end;

	public function new() {
		super();

		states = new Array<State>();
		operations = new List<StateOperation>();
	}
	
	public inline function getCurrentState():State {
		return states[states.length - 1];
	}

	/**
	 * Add state to stack and make it the active state
	 * @param	newState
	 */
	public function push(newState:State) {
		operations.add( { action: StateAction.Push, state: newState } );
	}

	/**
	 * Remove active state and resume the next in the stack
	 */
	public function pop() {
		operations.add( { action: StateAction.Pop} );
	}

	/**
	 * Remove states from stack until the specified state is topmost
	 * @param	newState
	 */
	/*public function popToState(newState:State) {
		operations.add( { action: StateAction} );
	}*/

	/**
	 * Pop top state and push a new one
	 * @param	newState
	 */
	public function change(newState:State) {
		operations.add( { action: StateAction.Pop } );
		operations.add( { action: StateAction.Push, state: newState } );
	}

	/**
	 * Process operations and state update event
	 * @param	delta
	 */
	function updateStates(delta:Float) {
		updateOperations();
		
		var currentState = getCurrentState();

		if (currentState != null) {
			currentState.update(delta);
		}
	}

	function updateOperations()  {
		while (!operations.isEmpty()) {

			switch(operations.first().action) {

				case Push:

					var pushed = operations.first().state;
					var top = states[states.length-1];

					// pause top state
					if (!isStartState && top != null) {
						if (statesForegrounded)
							top.background();
						if (statesActive)
							top.suspend();
					}

					states.push(operations.first().state);
					pushed.init(app);

					isStartState = false;

				case Pop:

					if (states.length == 0) {
						return;
					}

					var popped = states[states.length-1];

					if (!isStartState) {
						if (statesForegrounded)
							popped.background();
						if (statesActive)
							popped.suspend();
					}

					popped.destroy();
					states.pop();

					isStartState = false;
					
					if (states.length > 0)
						states[states.length-1].resume();
						
				default:
			}

			operations.pop();
		}
	}

	function fixedUpdateStates(delta:Float) {
		var currentState = getCurrentState();

		if (currentState != null)
			currentState.fixedUpdate(delta);

	}

	function backgroundStates() {
		Log.assert(statesForegrounded == true, "Background states called when state are not foregrounded");

		if (states.length != 0) {
			states[states.length - 1].background();
		}

		statesForegrounded = false;
	}

	function foregroundStates() {
		Log.assert(statesForegrounded == false, "Foreground states called when state are not backgrounded");

		if (states.length != 0) {
			states[states.length - 1].foreground();
		}

		statesForegrounded = true;
	}
}

typedef StateOperation = {
	var action:StateAction;
	@:optional var state:State;
}

enum StateAction {
	Push;
	Pop;
	Clear;
}