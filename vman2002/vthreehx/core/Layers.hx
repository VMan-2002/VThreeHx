package vman2002.vthreehx.core;

/**
 * A layers object assigns an 3D object to 1 or more of 32
 * layers numbered `0` to `31` - internally the layers are stored as a
 * bit mask], and by default all 3D objects are a member of layer `0`.
 *
 * This can be used to control visibility - an object must share a layer with
 * a camera to be visible when that camera's view is
 * rendered.
 *
 * All classes that inherit from {@link Object3D} have an `layers` property which
 * is an instance of this class.
 */
class Layers {
    /**
        * A bit mask storing which of the 32 layers this layers object is currently
        * a member of.
        *
        * @type {number}
        */
    public var mask = 1 | 0;

	/**
	 * Constructs a new layers instance, with membership
	 * initially set to layer `0`.
	 */
	public function new() {
	}

	/**
	 * Sets membership to the given layer, and remove membership all other layers.
	 *
	 * @param {number} layer - The layer to set.
	 */
	public function set( layer ) {
		this.mask = ( 1 << layer | 0 ) >>> 0;
	}

	/**
	 * Adds membership of the given layer.
	 *
	 * @param {number} layer - The layer to enable.
	 */
	public function enable( layer ) {
		this.mask |= 1 << layer | 0;
	}

	/**
	 * Adds membership to all layers.
	 */
	public function enableAll() {
		this.mask = 0xffffffff | 0;
	}

	/**
	 * Toggles the membership of the given layer.
	 *
	 * @param {number} layer - The layer to toggle.
	 */
	public function toggle( layer ) {
		this.mask ^= 1 << layer | 0;
	}

	/**
	 * Removes membership of the given layer.
	 *
	 * @param {number} layer - The layer to enable.
	 */
	public function disable( layer ) {
		this.mask &= ~ ( 1 << layer | 0 );
	}

	/**
	 * Removes the membership from all layers.
	 */
	public function disableAll() {
		this.mask = 0;
	}

	/**
	 * Returns `true` if this and the given layers object have at least one
	 * layer in common.
	 *
	 * @param {Layers} layers - The layers to test.
	 * @return {boolean } Whether this and the given layers object have at least one layer in common or not.
	 */
	public function test( layers ) {
		return ( this.mask & layers.mask ) != 0;
	}

	/**
	 * Returns `true` if the given layer is enabled.
	 *
	 * @param {number} layer - The layer to test.
	 * @return {boolean } Whether the given layer is enabled or not.
	 */
	public function isEnabled( layer ) {
		return ( this.mask & ( 1 << layer | 0 ) ) != 0;
	}

}