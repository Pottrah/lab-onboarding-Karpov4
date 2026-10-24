1. Цепочки Def-Use

Переменная: log_entry
Def: строка 2 — log_entry = "Start processing".
Def: строка 13 — log_entry = "Transaction finished with status: " + status.
Use: строка 14 — file.write(log_entry) использует второе значение переменной.

Переменная: status
Def: строка 4 — status = "approved" при условии amount > 0.
Use: строка 13 — переменная используется при формировании сообщения.
Use: строка 16 — переменная возвращается через return status.

Переменная: balance
Def: строка 5 — balance = get_balance(user_id) при условии amount > 0.
Use: строка 6 — значение используется при вычислении new_balance.

Переменная: new_balance
Def: строка 6 — new_balance = balance - amount.
Use: строка 7 — значение передаётся в update_balance(user_id, new_balance).

Переменная: file
Def: строка 12 — file = open("audit_log.txt", "w").
Use: строка 13 — вызов file.write(log_entry).


2. Выявленные дефекты

Дефект 1. Неинициализированная переменная status.
Если amount <= 0, то status = "approved" не выполняется, но переменная используется далее. Возникает ошибка.

Дефект 2. Мёртвое присваивание log_entry.
Начальное значение "Start processing" перезаписывается до чтения, поэтому первое присваивание не используется.

Дефект 3. Утечка ресурса.
Файл audit_log.txt открывается через open(), но не закрывается с помощью close().
