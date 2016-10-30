package ink.render;

import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;

class Mesh {

	var indexBuffer:IndexBuffer;
	var vertexBuffer:VertexBuffer;
	var structure:VertexFormat;
	var meshData:MeshData;

	public function new(meshData:MeshData, ?structure:VertexFormat) {
		this.structure = structure;
		this.meshData = meshData;

		ink.core.Log.assert(meshData != null, 'MeshData can\'t be null');
		ink.core.Log.assert(meshData.indices != null, 'MeshData indices can\'t be null');

		if (structure == null)
			structure = meshData.structure;
		ink.core.Log.assert(structure != null, 'Vertex structure can\'t be null');

		indexBuffer = new IndexBuffer(meshData.indices.length, kha.graphics4.Usage.StaticUsage);
		vertexBuffer = new VertexBuffer(meshData.vertexCount, structure.convertToVertexStructure(), kha.graphics4.Usage.StaticUsage);
	}

	public function build() {
		var vertices = MeshTools.buildVertexData(meshData, structure);

		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, vertices[i]);
		}
		vertexBuffer.unlock();

		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = meshData.indices[i];
		}
		indexBuffer.unlock();
	}

	public function apply(g:kha.graphics4.Graphics) {
		g.setVertexBuffer(vertexBuffer);
    	g.setIndexBuffer(indexBuffer);
	}

}