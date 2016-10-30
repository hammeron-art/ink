package ink.core;

import kha.System;
import kha.Scheduler;
import kha.Assets;

@:access(ink.core.Application)
class Core {

	public function new() {
	}

	public function init(createApplication:Void->ink.core.Application) {
		var app = createApplication();
		var options = app.initOptions(app.options);
		app.options = options;

		System.init(options, function() {
			function start() {
				app.init();
				System.notifyOnRender(app.render);
				Scheduler.addTimeTask(app.update, 0, 1 / 60);
			}

			if (options.loadEverything) {
				Assets.loadEverything(start);
			} else {
				start();
			}
		});
	}
}