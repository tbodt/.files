escape:
    key(escape)
    sleep(50ms)

vim save: user.vim_command('w')
vim close: user.vim_command('q')
vim fuzz: key(ctrl-p)
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
