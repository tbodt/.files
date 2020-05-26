from talon import Context

vocabulary = [
    'vim',
    'ninja',
    'meson',
]
vocabulary = dict(zip(vocabulary, vocabulary))
vocabulary.update({
    'tea bot': 'tbodt',
})

ctx = Context()
ctx.lists['user.vocabulary'] = vocabulary

