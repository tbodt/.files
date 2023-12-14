tag: terminal
and win.title: /vim/
-

tag(): user.vim

(escape | normal): user.vim_to_normal()

vim close:
    user.vim_command("quit")

fuzz: user.vim_normal("ctrl-p")
vim left: user.vim_normal("ctrl-w h")
vim right: user.vim_normal("ctrl-w l")
vim up: user.vim_normal("ctrl-w k")
vim down: user.vim_normal("ctrl-w j")

go back: user.vim_normal("ctrl-o")
go forward: user.vim_normal("ctrl-i")
