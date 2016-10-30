package ink.render;

/**
 * Vertex attribute format to be send to the shader
 */
class VertexFormat {

	public var elements(default, null):Array<VertexElement>;
	// Total size of bytes
	public var totalSize(default, null):Int = 0;
	// Total number of values (eg. float2 + int3 = 5 values);
	public var totalNumValues(default, null):Int = 0;

	public function new() {
		this.elements = [];
	}

	public function push(vertex:VertexElement) {
		totalSize += vertex.size();
		totalNumValues += vertex.numData();
		elements.push(vertex);
	}
	
	public function hasSemantic(type:VertexSemantic) {
		for (element in elements)
			if (element.semantic == type)
				return true;
		
		return false;
	}
	
	public function getOffsetTo(semantic:VertexSemantic) {
		
		var offset = 0;
		
		for (element in elements) {
			if (element.semantic == semantic)
				break;
			offset += element.size();
		}
		
		return offset;
	}

	public function convertToVertexStructure() {
		var structure = new kha.graphics4.VertexStructure();

		for (element in elements) {
			switch (element.semantic) {
				case SPosition:
					structure.add("position", kha.graphics4.VertexData.Float3);
				case STexcoord:
					structure.add("texcoord", kha.graphics4.VertexData.Float2);
				case SColor:
					structure.add("color", kha.graphics4.VertexData.Float4);
				default:
					ink.core.Log.error('Not implemented');
			}
		}

		return structure;
	}
}

/*enum VertexType {
	TInt(size:Int);
	TFloat(size:Int);
	TByte(size:Int);
}

enum VertexSemantic {
	SPosition;
	STexcoord;
	SColor;
	SNormal;
	SWeight;
	SJointIndex;
}*/

/*class VertexStructure {
	public var elements: Array<VertexElement>;
	
	public function new() {
		elements = new Array<VertexElement>();
	}
	
	public function add(name: String, data: VertexData) {
		elements.push(new VertexElement(name, data));
	}
	
	public function size(): Int {
		return elements.length;
	}
	
	public function byteSize(): Int {
		var byteSize = 0;
		
		for (i in 0...elements.length) {
			byteSize += dataByteSize(elements[i].data);
		}
		
		return byteSize;
	}
	
	private function dataByteSize(data: VertexData) : Int {
		switch(data) {
			case Float1:
				return 1;
			case Float2:
				return 2;
			case Float3:
				return 3;
			case Float4:
				return 4;
			case Float4x4:
				return 16;
		}
		return 0;
	}
	
	public function get(index: Int): VertexElement {
		return elements[index];
	}
}*/