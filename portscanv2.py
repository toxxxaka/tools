# Программа для сканирования портов указанного IP-адреса
# Запрашивает у пользователя IP и максимальный порт

import socket

ip = input("Введите IP-адрес для сканирования: ")
max_port = int(input("Введите максимальный номер порта для проверки: "))

# Список для хранения открытых портов
open_ports = []

# Сканируем порты от 1 до max_port
for port in range(1, max_port + 1):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(0.5)  # Таймаут 0.5 секунды
    result = sock.connect_ex((ip, port))
    if result == 0:
        open_ports.append(port)
    sock.close()

# Выводим открытые порты
print("Открытые порты:")
for port in open_ports:
    print(port)
