from talon import Context, Module, actions

mod = Module()
@mod.action_class
class VimActions:
    def vim_to_normal():
        """vim enter normal mode"""
        actions.key('escape')
        #actions.sleep('50ms')

    def vim_command(command: str):
        """vim command"""
        actions.user.vim_to_normal()
        actions.insert(',' + command)
        actions.key('enter')

    def vim_normal(keys: str):
        """vim normal mode keys"""
        actions.user.vim_to_normal()
        for key in keys.split():
            actions.key(key)


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

    def file_start():
        actions.user.vim_command('0')
    def file_end():
        actions.user.vim_command('$')
