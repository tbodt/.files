from talon import Context

vocabulary = [
    'vim',
    'ninja',
    'meson',
    'git',
]
vocabulary = dict(zip(vocabulary, vocabulary))
vocabulary.update({
    'tea bot': 'tbodt',
    'timac': 'tmux',
})

ctx = Context()
ctx.lists['user.vocabulary'] = vocabulary

