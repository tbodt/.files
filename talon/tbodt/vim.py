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


ctx = Context()
ctx.matches = """
tag: user.vim
"""


@ctx.action_class("edit")
class VimEditActions:
    def save():
        actions.user.vim_command('write')
    def save_all():
        actions.user.vim_command('wall')
