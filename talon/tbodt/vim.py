from talon import Module, actions

mod = Module()
@mod.action_class
class VimActions:
    def vim_command(command: str):
        """vim command"""
        actions.key('escape')
        actions.sleep('50ms')
        actions.insert(',' + command)
        actions.key('enter')

