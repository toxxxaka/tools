import socket

ip = input("Введите IP-адрес для сканирования: ")
max_port = int(input("Введите максимальный номер порта для проверки: "))

open_ports = []

for port in range(1, max_port + 1):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(0.5)
    result = sock.connect_ex((ip, port))
    if result == 0:
        open_ports.append(port)
    sock.close()

print("Открытые порты:")
for port in open_ports:
    print(port)
