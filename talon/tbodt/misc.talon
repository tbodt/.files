history: user.history_toggle()
fox <user.running_applications>: user.switcher_focus(running_applications)
grep: "rg "
space left: key(ctrl-left)
space right: key(ctrl-right)
wheel: user.mouse_gaze_scroll()
face(stick_out_tongue): core.repeat_phrase()
^system sleep$: user.system_command('pmset sleepnow')

^mixed mode$:
    mode.disable("sleep")
    mode.enable("dictation")
    mode.enable("command")
