from talon import Module, actions
from talon_plugins import eye_zoom_mouse

mod = Module()

@mod.action_class
class Actions:
    def mouse_action():
        """"""
        if actions.tracking.control_zoom_enabled():
            actions.tracking.zoom()
        actions.user.noise_trigger_pop()


eye_zoom_mouse.config.live = True
