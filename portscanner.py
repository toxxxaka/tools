import socket
import termcolor

def scan(target, ports):
    for port in range(1,ports):
        scan_port(target, port)

def scan_port(ipaddress, port):
    try:
        sock = socket.socket()
        sock.connect((ipaddress, port))
        print(" [+] Port is open" + str(port))
        sock.close()
    except:
        print("Port is closed" + str(port))

targets = input("[*] Enter Targets To Scan(split multiple targets with ,): ")
ports = int(input("[*] Enter Port To Scan(split multiple ports with ,): "))
if ',' in targets:
    print("[+] Scanning Multiple Targets")
    for ip_addr in targets.split(","):
        scan(ip_addr.strip(' '), ports)
else:
    scan(targets, ports)

