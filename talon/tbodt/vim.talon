tag: terminal
and win.title: /vim/
-

tag(): user.vim

escape:
    key(escape)
    sleep(50ms)

vim close:
    user.vim_command("quit")

fuzz: key(ctrl-p)
vim left:
    key(ctrl-w)
    key(h)
vim right:
    key(ctrl-w)
    key(l)
vim up:
    key(ctrl-w)
    key(k)
vim down:
    key(ctrl-w)
    key(j)
