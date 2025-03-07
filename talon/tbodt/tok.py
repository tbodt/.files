from talon import Module, Context, grammar

mod = Module()
mod.mode('tok')
mod.list("nimi")

ctx_ale = Context()
ctx_ale.matches = '''
mode: all
'''

ww = {}
for w in '''a akesi ala alasa ale anpa ante anu awen e en esun ijo ike ilo insa jaki jan jelo jo kala kalama kama kasi ken kepeken kili kiwen ko kon kule kulupu kute la lape laso lawa len lete li lili linja lipu loje lon luka lukin lupa ma mama mani meli mi mije moku moli monsi mu mun musi mute nanpa nasa nasin nena ni nimi noka o olin ona open pakala pali palisa pan pana pi pilin pimeja pini pipi poka poki pona pu sama seli selo seme sewi sijelo sike sin sina sinpin sitelen sona soweli suli suno supa suwi tan taso tawa telo tenpo toki tomo tu unpa uta utala walo wan waso wawa weka wile namako kin oko kipisi leko monsuta tonsi jasima kijetesantakalu soko meso epiku kokosila lanpan n misikeke ku pake apeja majuna powe'''.split():
    ww[w.replace('j','y')] = w
ctx_ale.lists['user.nimi'] = ww
#ctx_ale.lists['user.vocabulary'] = dict(talon_vocabulary, **ww)

ctx = Context()
ctx.matches = '''
mode: user.tok
'''

@ctx.capture('user.talon_phrase', rule='{user.nimi}+')
def phrase(m):
    phrase = grammar.Phrase(' '.join(m.nimi_list))
    phrase._words = m.nimi_list
    return phrase

@ctx.capture('user.talon_word', rule='{user.nimi}')
def word(m):
    phrase = grammar.Phrase(' '.join(m.nimi_list))
    phrase._words = [m.nimi]
    return phrase
