from talon import Module, Context, canvas, ctrl, cron, ui, actions, app, imgui
from talon.types import Point2d


import time


mod = Module()





crosshairs_moving = False

crosshairs_tick_job = None

crosshairs_position = Point2d(ctrl.mouse_pos()[0], ctrl.mouse_pos()[1])

direction = 'east'

hissing = ""


crosshairs_canvas = None


ctx = Context()

ctx.matches = r"""
mode: command
"""


def crosshairs_tick_cb():
    global direction

    if crosshairs_moving:

        if direction == "north":
            ctrl.mouse_move(ctrl.mouse_pos()[0], ctrl.mouse_pos()[1] - 10)
        elif direction == "east":
            ctrl.mouse_move(ctrl.mouse_pos()[0] + 10, ctrl.mouse_pos()[1])
        elif direction == "south":
            ctrl.mouse_move(ctrl.mouse_pos()[0], ctrl.mouse_pos()[1] + 10)
        elif direction == "west":
            ctrl.mouse_move(ctrl.mouse_pos()[0] - 10, ctrl.mouse_pos()[1])



def crosshairs_canvas_draw(canvas):
    print(str(canvas))
    print(ctrl.mouse_pos())
    paint= canvas.paint
    paint.color = "00ff00ff"
    paint.stroke_width = 6
    canvas.draw_points(canvas.PointMode.LINES,
        [Point2d(ctrl.mouse_pos()[0], 0),
            Point2d(ctrl.mouse_pos()[0], ui.screens()[0].rect.height - 1)])
    
    canvas.draw_points(canvas.PointMode.LINES,
        [Point2d(0, ctrl.mouse_pos()[1]),
            Point2d(ui.screens()[0].rect.width - 1, ctrl.mouse_pos()[1])])


@imgui.open(y=600)
def gui(gui: imgui.GUI):
    global history
    gui.text(direction)
    gui.line()
    gui.text(hissing)

@mod.action_class
class HissSpiralActions:
    def spiral_start():
        """Starts the "spiral" mouse"""

        global crosshairs_canvas
        global crosshairs_position
        global crosshairs_tick_job

        if crosshairs_tick_job:
            cron.cancel(crosshairs_tick_job)
        crosshairs_tick_job = cron.interval("40ms", crosshairs_tick_cb)


        if crosshairs_canvas is None:
            crosshairs_canvas = canvas.Canvas(0, 0, ui.screens()[0].rect.width -1 , ui.screens()[0].rect.height -1)
            crosshairs_position = Point2d(ctrl.mouse_pos()[0], ctrl.mouse_pos()[1])
            crosshairs_canvas.register("draw", crosshairs_canvas_draw)


    def spiral_stop():
        """Stops the "spiral" mouse"""
        global crosshairs_canvas

        cron.cancel(crosshairs_tick_job)
        crosshairs_canvas.unregister("draw", crosshairs_canvas_draw)
        crosshairs_canvas.hide()
        crosshairs_canvas = None



    def crosshairs_move(): 
        """move the crosshairs in a 'fed-ex truck circling the block' clockwise fashioin"""
        global crosshairs_position
        global direction
        global crosshairs_moving 
        global hissing
        crosshairs_moving = True
        hissing = "hissing"


    def crosshairs_stop():
        """stop the crosshairs"""
        global direction
        global crosshairs_moving
        global hissing
        crosshairs_moving = False
        if direction == "north":
            direction = "east"
        elif direction == "east":
            direction = "south"
        elif direction == "south":
            direction = "west"
        elif direction == "west":
            direction = "north"
        hissing = ""


    def crosshairs_history_show():
        "displaying how long you've been hissing"
        gui.show()

    def crosshairs_history_hide():
        "hiding the history"
        gui.hide()


@ctx.action_class("user")
class WeirdActions:
    def noise_hiss_start():
        actions.user.crosshairs_move()
    def noise_hiss_stop():
        actions.user.crosshairs_stop()

    def noise_pop():
        actions.user.racer_gas_toggle()



