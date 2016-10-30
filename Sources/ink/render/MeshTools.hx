package ink.render;

import ink.core.Log;

class MeshTools {

	public static function createQuad():MeshData {
		return {
			vertexCount: 4,
			positions: [[-0.5, 0.5, 0.0], [0.5, 0.5, 0.0], [-0.5, -0.5, 0.0], [0.5, -0.5, 0.0]],
			colors: [[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]],
			uvs: [[0.0, 1.0], [1.0, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: [0, 1, 2, 2, 1, 3],
		}
	}

	/**
	 * Merge attribute data and return as a array ready to be used as VBO
	 * @param	mesh
	 * @param	customFormat use other format instead of the actual mesh format
	 * @return
	 */
	public static function buildVertexData(mesh:MeshData, format:VertexFormat) {
		Log.assert(format != null, "Can't build vertex data without a vertex format");

		var vertexData:Array<Float> = [];
		
		// Validate mesh data
		var count:Int = 0;
		
		for (element in format.elements) {
			
			inline function check(array:Array<Dynamic>) {
				Log.assert(array != null || array.length != 0 || array.length % element.numData() == 0);
			}

			switch (element.semantic) {
				case SPosition:
					check(mesh.positions);
					count = Std.int(mesh.positions.length);
				case STexcoord:
					check(mesh.uvs);
				case SNormal:
					check(mesh.normals);
				case SColor:
					check(mesh.colors);
				case SJointIndex | SWeight:
					Log.api("Not implemented!");
			}
		}
		
		// Build vertex data
		for (i in 0...count) {
			for (element in format.elements) {
				var n = element.numData();
				
				inline function addData(array:Array<Float>) {
					for (ii in 0...n) {
						vertexData.push(array[ii]);
					}
				}

				switch (element.semantic) {
					case SPosition:
						addData(mesh.positions[i]);
					case STexcoord:
						addData(mesh.uvs[i]);
					case SNormal:
						Log.api("Not implemented!");
					case SColor:
						addData(mesh.colors[i]);
					case SJointIndex | SWeight:
						Log.api("Not implemented!");
				}
			}
		}
		
		return vertexData;
	}

}