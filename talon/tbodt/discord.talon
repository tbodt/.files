app: /Discord/
-
fuzz$:
    key(cmd-k)
    sleep(100ms)
fuzz <user.phrase>:
    key(cmd-k)
    sleep(100ms)
    insert(phrase)
    sleep(100ms)
    key(enter)

server up: key(cmd-alt-up)
server down: key(cmd-alt-down)
