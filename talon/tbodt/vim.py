from talon import Context, Module, actions

mod = Module()
@mod.action_class
class VimActions:
    def vim_command(command: str):
        """vim command"""
        actions.key('escape')
        actions.sleep('50ms')
        actions.insert(',' + command)
        actions.key('enter')


mod.tag('vim', 'tag to load vim and/or related plugins!')

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
    def undo():
        actions.user.vim_command('undo')
    def redo():
        actions.user.vim_command('redo')
