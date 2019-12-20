# -*- coding: utf-8 -*-

import logging
import subprocess
from pathlib import Path
from threading import Thread
from typing import Sequence


class PluginRunner(Thread):
    """Thread that 'manages' a Plugin process.

    A runner will take care of creating and starting a process that will run the
    plugin entry point.

    """

    def __init__(
        self,
        unique_name: str,
        process_args: Sequence[str],
        process_cwd: Path,
        process_env: dict,
    ):
        self.logger = logging.getLogger(__name__)
        self.unique_name = unique_name

        self.process_args = process_args
        self.process_cwd = process_cwd
        self.process_env = process_env
        self.process = None

        Thread.__init__(self, name=self.unique_name)

    def kill(self):
        """Kills the plugin by killing the underlying process."""
        if self.process and self.process.poll() is None:
            self.logger.warning(f"About to kill plugin {self.unique_name}")
            self.process.kill()

    def run(self):
        """Runs the plugin

        Run the plugin using the entry point specified with the generated environment in
        its own subprocess. Pipes STDOUT and STDERR such that when the plugin stops
        executing (or IO is flushed) it will log it.
        """
        self.logger.info(f"Starting plugin {self.unique_name}: {self.process_args}")

        try:
            self.process = subprocess.run(
                args=self.process_args,
                env=self.process_env,
                cwd=str(self.process_cwd.resolve()),
                start_new_session=True,
                close_fds=True,
                universal_newlines=True,
                bufsize=1,
            )

            self.logger.info(f"Plugin {self.unique_name} is officially stopped")

        except Exception as ex:
            self.logger.exception(f"Plugin {self.unique_name} died: {ex}")
