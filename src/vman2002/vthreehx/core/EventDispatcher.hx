package vman2002.vthreehx.core;

typedef Listener = (Dynamic, Event)->Void;
typedef Event = Dynamic;

/**
 * This modules allows to dispatch event objects on custom JavaScript objects.
 */
class EventDispatcher {
    public var _listeners:Map<String, Array<Listener>> = null;

	public function new() {}

	/**
	 * Adds the given event listener to the given event type.
	 *
	 * @param type The type of event to listen to.
	 * @param listener The function that gets called when the event is fired.
	 */
	public function addEventListener( type:String, listener:Listener ) {
		if (this._listeners == null) this._listeners = new Map<String, Array<Listener>>();
		var listeners = this._listeners;

		if (!listeners.exists(type))
            listeners.set(type, []);
        
        if (!listeners.get(type).contains(listener))
            listeners.get(type).push(listener);
	}

	/**
	 * Returns `true` if the given event listener has been added to the given event type.
	 *
	 * @param type The type of event.
	 * @param listener The listener to check.
	 * @return Whether the given event listener has been added to the given event type.
	 */
	public function hasEventListener( type:String, listener:Listener ) {
		var listeners = this._listeners;
		if (listeners == null) return false;

		return listeners.exists(type) && listeners.get(type).contains(listener);
	}

	/**
	 * Removes the given event listener from the given event type.
	 *
	 * @param type The type of event.
	 * @param listener The listener to remove.
	 */
	public function removeEventListener( type:String, listener:Listener ) {
		var listeners = this._listeners;
		if (listeners == null) return;

		var listenerArray = listeners.get(type);
		if (listenerArray != null)
            listenerArray.remove(listener);
	}

	/**
	 * Dispatches an event object.
	 *
	 * @param event The event that gets fired.
	 */
	public function dispatchEvent( event:Event ) {
		var listeners = this._listeners;
		if (listeners == null) return;

		var listenerArray = listeners.get(event.type);
		if (listenerArray != null) {
			event.target = this;

			// Make a copy, in case listeners are removed while iterating.
			var array = listenerArray.copy();

			for (thing in array)
				thing( this, event );

			event.target = null;
		}
	}
}