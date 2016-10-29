package ink.render;

class DrawableComponent extends ink.entity.Component {

	/**
	 * When the component is attached to an entity.
	 */
	override public function onAddedToEntity() {
	}

	/**
	 * When the component is attached to and entity
	 * and that entity is on a scene.
	 */
	override public function onAddedToScene() { }

	/**
	 * When the application is resumed while the component's
	 * owning entity is in a scene. This will also be called
	 * when the owning entity is added to the scane if the
	 * application is currently active or when the component
	 * is added to the entity if the entity is already in the
	 * scene.
	 */
	override public function onResume() { }

	/**
	 * When the application is foregrounded while
	 * the entity is in the scene. This will also be
	 * caleed when the entity is added to the scene if
	 * the application is currently foregrounded or when
	 * the component is added to the entity if the entity
	 * is alread in the scene.
	 */
	override public function onForeground() { }

	/**
	 * When the application is foregrounded while the entity
	 * is in the scene. This will also be called when the entity
	 * is added to the scene if the application is currently
	 * foregrounded or when the component is added to the entity
	 * if the entity is already in the scene
	 *
	 * @param	delta
	 */
	override public function onUpdate(delta:Float) { }

	/**
	 * At fixed time periods
	 * @param	delta
	 */
	override public function onFixedUpdate(delta:Float) { }

	/**
	 * When the application is backgrounded while the owning
	 * entity is removed from the scene if the applicaiton is
	 * currently foregrounded or when the component is removed
	 * while the entity is in the scene
	 */
	override public function onBackground() { }

	/**
	 * When the application is backgrounded while the owning
	 * entity is in the scene. This will also be called when
	 * the owning entity is removed from the scene if the
	 * application is currently active or when the component
	 * is removed while the entity is in the scene.
	 */
	override public function onSuspend() { }

	/**
	 * When the component is removed from an entity or then the
	 * entity is removed from the scene.
	 */
	override public function onRemovedFromScene() { }

	/**
	 * When the component is removed from an entity.
	 */
	override public function onRemovedFromEntity() { }

}