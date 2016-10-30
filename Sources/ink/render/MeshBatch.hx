package ink.render;

import kha.graphics4.VertexStructure;
import ink.entity.Transform;
import ink.core.Pair;

/**
 * Batch groups of meshes in a single buffer to optimize performance
 */
class MeshBatch extends Mesh {
	var meshes:Array<Mesh>;

	// Array of the mesh to be included in the batcher
	var meshCache:Array<Pair<Mesh, Transform>>;

	public var meshCount(get, never):Int;

	public function new(?structure:VertexStructure, ?data:MeshData)  {
		super(data, structure);
		meshCache = [];
	}

	public function addMesh(mesh:Mesh, transform:Transform) {
		meshCache.push(new Pair(mesh, transform));
	}

	public function flush() {
		meshCache.splice(0, meshCache.length);
	}

	public function get_meshCount() {
		return meshCache.length;
	}
}