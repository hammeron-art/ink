package ink.core;

import kha.System;
import kha.Scheduler;

@:access(ink.core.Application)
class Core {

	public function new() {
	}

	public function init(createApplication:Void->ink.core.Application) {
		var app = createApplication();
		var options = app.initOptions(app.options);

		System.init(options, function() {
			app.init();
			System.notifyOnRender(app.render);
			Scheduler.addTimeTask(app.update, 0, 1 / 60);
		});
	}
}