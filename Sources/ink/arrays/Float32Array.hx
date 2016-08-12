package ink.arrays;

abstract Float32Array(kha.arrays.Float32Array) {
	inline public function new(elements: Int) {
    	this = new kha.arrays.Float32Array(elements);
	}

	@:arrayAccess
	public inline function get(index:Int) {
		return this.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index:Int, value:Float) {
		this.set(index, value);
		return value;
	}
}