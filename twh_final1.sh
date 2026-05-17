#!/bin/sh

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

hr() {
    if [ "$#" -eq 0 ]; then
        printf '\n%80s\n' ' ' | tr ' ' '-'
    else
        m="$*"
        len="${#m}"
        fill="$(printf '%'"$((76-len))"'s' '' | tr ' ' '-')"
        printf '\n-- %s %s\n\n' "$*" "$fill"
    fi
}

check_server_resources() {
    hr 'Конфигурация сервера'
    lsblk 2>/dev/null || printf 'lsblk: недоступен\n'
    printf '\n'
    if is_installed free; then
        free -h | head -n 2
    else
        printf 'free: не найден\n'
    fi
    printf '\nCPU:\n'
    if is_installed nproc; then
        nproc
    else
        grep -c '^processor' /proc/cpuinfo 2>/dev/null || printf 'nproc: недоступен\n'
    fi
    hr
}

check_sshd_config() {
    hr 'Конфигурация SSH (sshd -T)'
    if ! is_installed sshd; then
        printf 'sshd не найден в PATH.\n'
        hr
        return
    fi
#    if [ "$(id -u)" -ne 0 ]; then
#        printf '\033[33mНе root: sshd -T может выдать ошибку или неполный список.\033[0m\n'
#        printf 'Для полного режима запустите скрипт с sudo.\n\n'
#    fi
 #   if ! out=$(sshd -T 2>/dev/null); then
 #       printf '\033[31msshd -T завершился с ошибкой (часто нужен root).\033[0m\n'
 #       hr
 #       return
 #   fi
    printf '%s\n' "$out" | grep -E \
        'passwordauthentication|kbdinteractiveauthentication|challengeresponseauthentication|^port|permitrootlogin|pubkeyauthentication' \
        || printf 'Нет строк, совпадающих с фильтром.\n'
    hr
}

#harakiri() {
#    printf '\033[31mCommiting *roskomnadzor*...\033[0m\n'
#    rm -- "$0"
#    exit
#}

trap '' INT

os_full="$(lsb_release -d 2>/dev/null | awk -F: '{os=$2;gsub("^[[:space:]]*", "", os);print os}')"
if [ -z "$os_full" ]; then
    if [ -f /etc/os-release ] ||
       [ -f /usr/lib/os-release ] ||
       [ -f /etc/lsb-release ]; then
        for file in /etc/os-release /usr/lib/os-release /etc/lsb-release; do
            . "$file" && break
        done
        os_full="${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}"
    fi
fi
os_name="${os_full%% *}"
[ -d /opt/webdir/bin/ ] && os_name=BitrixVM
kernel=$(printf '%s %s\n' "$(uname -s)" "$(uname -r)")
load="$(awk -v nproc="$(nproc)" '{printf "%s, %s, %s of %s CPU\n", $1, $2, $3, nproc}' /proc/loadavg)"
ram="$(free -m | awk 'NR==2 {printf "%s Mb of %s Mb\n", $3, $2}')"
swap="$(awk 'NR==2 {printf "%s (%s), %s Mb of %s Mb\n", $1, $2, int($4/1024), int($3/1024)}' /proc/swaps)"

clear
printf 'tw-helper *x2 improved\n'

case "$os_name" in
Alma*)
printf "
\033[38;5;196m   =@= \033[38;5;208m=@=    %s\033[0m - %s
\033[38;5;196m   \\.  \033[38;5;208m|_ \033[38;5;148m,.  \033[0m\033[97;1mLoad:\033[0m %s
\033[38;5;27m @=__\033[38;5;196m\` \033[38;5;148m,_-=@  \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;45m     ,.|      \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;45m     =@=        \033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
Astra)
printf "\033[38;5;32m
\033[38;5;32m     A       %s\033[0m - %s
\033[38;5;32m____/ \\____  \033[0m\033[97;1mLoad:\033[0m %s
\033[38;5;32m \`._ \\.\\\\.\`   \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;32m  /.\\' \\\\\\    \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;32m /'     '\\    \033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
Arch)
printf "\033[38;5;38m     .
\033[38;5;38m    /'\\       %s\033[0m - %s
\033[38;5;38m   /\\  \\      \033[0m\033[97;1mLoad:\033[0m %s
\033[38;5;38m  /  _  \\     \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;38m / _| |_-\\    \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;38m//\`      \\\\\\ \033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
BitrixVM)
printf "\033[38;5;124m
\033[38;5;124m  .\033[0m-=\033[38;5;124m''=-.    %s\033[0m - %s
\033[38;5;124m /\033[0m ||\033[38;5;124m     \\   \033[0m\033[97;1mLoad:\033[0m %s
\033[38;5;124m| \033[0m || ===\033[38;5;124m  |  \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;124m \\ \033[0m\\\\\\__//\033[38;5;124m /   \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;124m  '-=__=-' \033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
CentOS)
printf "
\033[38;5;148m  ,__\033[38;5;208m^\033[35m__,     \033[38;5;148m%s\033[0m - %s
\033[38;5;148m  |\\ \033[38;5;208m|\033[35m /|     \033[0m\033[97;1mLoad:\033[0m  %s
\033[35m <--- \033[34m--->    \033[0m\033[97;1mRAM:\033[0m  %s
\033[34m  |/_\033[38;5;148m|\033[38;5;208m_\\|     \033[0m\033[97;1mSwap:\033[0m %s
\033[34m  \` \033[38;5;148m v\033[38;5;208m  \` \033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
Debian)
printf "\033[38;5;197m   _____
\033[38;5;197m  /  __ \\     %s\033[0m - %s
\033[38;5;197m |  /    |    \033[0m\033[97;1mLoad:\033[0m %s
\033[38;5;197m |  \\___-     \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;197m -_           \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;197m   --_\033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
Ubuntu)
printf "\033[38;5;202m         _
\033[38;5;202m     ---(_)   %s\033[0m - %s
\033[38;5;202m _/  ---  \\   \033[0m\033[97;1mLoad:\033[0m  %s
\033[38;5;202m(_) |   |     \033[0m\033[97;1mRAM:\033[0m  %s
\033[38;5;202m  \\  --- _/   \033[0m\033[97;1mSwap:\033[0m %s
\033[38;5;202m     ---(_)\033[0m
" "$os_full" "$kernel" "$load" "$ram" "${swap:-none}"
;;
esac

echo

[ -d /opt/webdir/bin/ ] && cp=BitrixVM
[ -d /usr/local/vesta/ ] && cp=Vesta
[ -d /usr/local/hestia/ ] && cp=Hestia
[ -d /usr/local/mgr5/ ] && cp=ISPmanager
[ -d /usr/local/fastpanel2 ] && cp=FASTPANEL
printf '\033[1mPanel:\033[0m %s\n' "${cp:-not installed}"

if is_installed mysql; then
    mysql_ver="$(mysql --version | awk '{for(i=3;i<=NF;i++){printf "%s ", $i}}')"
fi
printf '\033[1mMySQL:\033[0m %s\n' "${mysql_ver:-not installed}"

while true; do
printf '
    1. Top CPU / RAM
    2. OOMs
    3. Disk usage
    4. Firewall
    5. Fail2ban
    6. Listen ports + Web servers (ports 80 / 443)
    7. Nginx
    8. Apache
    9. Fix archlinux-keyring (useful?)
   10. Network interfaces, routes, IPv4 / IPv6, Connectivity check
   11. DNS
   12. Kernels
   13. vmstat / iostat (useful?)
   14. atop
   15. Server configuration
   16. SSH configuration
    0. Exit + roskomnadzor

Select: '
read -r action
case "$action" in

    0)
        exit 0
        ;;
    1)
        hr Top CPU usage
        ps axk-%cpu opid,user,%cpu,%mem,command | head
        hr Top RAM usage
        ps axk-%mem opid,user,%cpu,%mem,command | head
        hr
        ;;

    2)
        hr OOMs
        grep -Ei 'killed process|oom.killer|out of memory' \
            /var/log/messages /var/log/syslog /var/log/kern.log 2>/dev/null \
            | tail -20
        hr
        ;;

    3)
        hr Disk Usage
        df -h | head -n 1
        df -h | grep -E '/dev/(vd|sd)'
        hr Inodes
        df -hi | head -n 1
        df -hi | grep -E '/dev/(vd|sd)'
        hr
        ;;

    4)
        hr Firewall

        printf '\033[1m= ufw =\033[0m\n\n'
        if is_installed ufw; then
            ufw status verbose
        else
            printf 'ufw: не установлен\n'
        fi

        printf '\n\033[1m= iptables =\033[0m\n\n'
        if is_installed iptables; then
            printf '%s\n\n' '--- iptables -S ---'
            iptables -S
            printf '\n--- iptables -L -v -n --line-numbers ---\n\n'
            iptables -L -v -n --line-numbers
        else
            printf 'iptables: не установлен\n'
        fi

        printf '\n\033[1m= firewall-cmd (firewalld) =\033[0m\n\n'
        if is_installed firewall-cmd; then
            printf 'State: %s\n\n' "$(firewall-cmd --state 2>/dev/null)"
            for zone in $(firewall-cmd --get-active-zones 2>/dev/null | grep -v ':'); do
                firewall-cmd --list-all --zone="$zone" 2>/dev/null
            done
        else
            printf 'firewall-cmd: не установлен\n'
        fi

        hr
        ;;

    5)
        hr fail2ban

        if is_installed fail2ban-client; then
            printf '\033[1m= Статус =\033[0m\n\n'
            fail2ban-client status 2>/dev/null

            printf '\n\033[1m= Jails =\033[0m\n\n'
            jails=$(fail2ban-client status 2>/dev/null \
                | grep 'Jail list' \
                | sed 's/.*Jail list:[[:space:]]*//' \
                | tr ',\t' '  ')
            if [ -z "$jails" ]; then
                printf 'Активных jail не найдено\n'
            else
                for jail in $jails; do
                    jail=$(printf '%s' "$jail" | tr -d ' ')
                    [ -z "$jail" ] && continue
                    printf '\n\033[1m-- jail: %s --\033[0m\n\n' "$jail"
                    fail2ban-client status "$jail" 2>/dev/null
                done
            fi
        else
            printf 'fail2ban: не установлен\n'
        fi

        hr
        ;;

    6)
        hr Listen ports

        if is_installed netstat; then
            netstat -tulpn 2>/dev/null
        else
            ss -tulpn
        fi

        hr "Web servers (ports 80 / 443)"

        if is_installed netstat; then
            netstat -tulpn 2>/dev/null | grep -E ':80[[:space:]]|:443[[:space:]]' \
                || printf 'Ничего не слушает на 80/443\n'
        else
            ss -tulpn | grep -E ':80[[:space:]]|:443[[:space:]]' \
                || printf 'Ничего не слушает на 80/443\n'
        fi

        hr
        ;;

    7)
        hr Nginx

        if is_installed nginx; then
            printf '\033[1m= Конфиги и server_name =\033[0m\n\n'
            nginx -T 2>/dev/null | grep -E "configuration file|server_name"

            printf '\nПоиск по домену (Enter — пропустить): '
            read -r ng_domain
            if [ -n "$ng_domain" ]; then
                hr "Nginx — поиск: $ng_domain"
                grep -Rn "$ng_domain" /etc/nginx 2>/dev/null \
                    || printf 'Не найдено\n'
            fi
        else
            printf 'nginx: не установлен\n'
        fi

        hr
        ;;

    8)
        hr Apache

        apache_bin=""
        apache_conf_dir=""
        is_installed apache2ctl && apache_bin=apache2ctl
        is_installed apachectl  && apache_bin="${apache_bin:-apachectl}"
        is_installed httpd      && apache_bin="${apache_bin:-httpd}"
        [ -d /etc/apache2 ] && apache_conf_dir=/etc/apache2
        [ -d /etc/httpd   ] && apache_conf_dir="${apache_conf_dir:-/etc/httpd}"

        if [ -n "$apache_bin" ]; then
            printf '\033[1m= Virtual hosts (-S) =\033[0m\n\n'
            "$apache_bin" -S 2>/dev/null

            if [ -n "$apache_conf_dir" ]; then
                printf '\nПоиск по домену (Enter — пропустить): '
                read -r ap_domain
                if [ -n "$ap_domain" ]; then
                    hr "Apache — поиск: $ap_domain"
                    grep -Rn "$ap_domain" "$apache_conf_dir" 2>/dev/null \
                        || printf 'Не найдено\n'
                fi
            fi
        else
            printf 'Apache не установлен\n'
        fi

        hr
        ;;

    9)
        hr Fix archlinux-keyring
        if [ "$os_name" = Arch ]; then
            rm -vr /etc/pacman.d/gnupg
            pacman-key --verbose --init
            pacman-key --verbose --populate
        else
            echo Your OS is not Arch Linux
        fi
        hr
        ;;

    10)
        hr "Network interfaces (без docker/veth/bridge)"

        printf '\033[1m= IPv4 =\033[0m\n\n'
        for iface in $(ip -o link show 2>/dev/null \
                       | awk -F': ' '{print $2}' \
                       | cut -d@ -f1 \
                       | grep -vE '^(veth|br-[0-9a-f]|docker|virbr|vmbr)'); do
            ip -4 addr show "$iface" 2>/dev/null
        done

        printf '\n\033[1m= IPv6 =\033[0m\n\n'
        for iface in $(ip -o link show 2>/dev/null \
                       | awk -F': ' '{print $2}' \
                       | cut -d@ -f1 \
                       | grep -vE '^(veth|br-[0-9a-f]|docker|virbr|vmbr)'); do
            result=$(ip -6 addr show "$iface" 2>/dev/null)
            [ -n "$result" ] && printf '%s\n' "$result"
        done

        hr IPv4 routes
        ip -4 route show 2>/dev/null

        hr IPv6 routes
        ip -6 route show 2>/dev/null

        hr Connectivity check

        printf 'Ping 8.8.8.8 (IPv4):               '
        if ping -c3 -W5 8.8.8.8 >/dev/null 2>&1; then
            printf '\033[32mOK\033[0m\n'
        else
            printf '\033[31mFAIL\033[0m\n'
        fi

        printf 'Ping 2001:4860:4860::8888 (IPv6):  '
        if ping6 -c3 -W5 2001:4860:4860::8888 >/dev/null 2>&1; then
            printf '\033[32mOK\033[0m\n'
        else
            printf '\033[33mFAIL (или IPv6 не настроен)\033[0m\n'
        fi

        printf 'TCP google.com:443:                '
        if is_installed nc; then
            if nc -z -w5 google.com 443 2>/dev/null; then
                printf '\033[32mOK\033[0m\n'
            else
                printf '\033[31mFAIL\033[0m\n'
            fi
        elif is_installed curl; then
            if curl -sS -o /dev/null --connect-timeout 6 --max-time 8 \
                https://google.com/ 2>/dev/null; then
                printf '\033[32mOK\033[0m\n'
            else
                printf '\033[31mFAIL\033[0m\n'
            fi
        else
            printf '\033[33mSKIP (нужен nc или curl)\033[0m\n'
        fi

        printf 'HTTP http://google.com:           '
        if is_installed curl; then
            if curl -sS -o /dev/null --max-time 12 --connect-timeout 8 \
                http://google.com/ 2>/dev/null; then
                printf '\033[32mOK\033[0m\n'
            else
                printf '\033[31mFAIL\033[0m\n'
            fi
        else
            printf '\033[33mSKIP (curl не установлен)\033[0m\n'
        fi

        hr
        ;;

    11)
        hr DNS resolver

        printf '\033[1m= Управление DNS =\033[0m\n\n'
        if [ -L /etc/resolv.conf ]; then
            real_target=$(readlink -f /etc/resolv.conf 2>/dev/null)
            printf '/etc/resolv.conf -> %s  (symlink)\n' "$real_target"
            case "$real_target" in
                */systemd*) printf 'Управляется: \033[33msystemd-resolved\033[0m\n' ;;
                *)          printf 'Управляется: неизвестно (symlink)\n' ;;
            esac
        else
            printf '/etc/resolv.conf: обычный файл\n'
        fi

        if is_installed resolvectl; then
            printf '\n\033[1m= resolvectl status =\033[0m\n\n'
            resolvectl status 2>/dev/null
        elif is_installed systemd-resolve; then
            printf '\n\033[1m= systemd-resolve --status =\033[0m\n\n'
            systemd-resolve --status 2>/dev/null
        fi

        if is_installed nmcli; then
            printf '\n\033[1m= NetworkManager (nmcli) =\033[0m\n\n'
            printf 'State: %s\n\n' "$(nmcli -t -f STATE general 2>/dev/null)"
            nmcli dev show 2>/dev/null | grep -E 'IP4\.DNS|IP6\.DNS' || true
        fi

        printf '\n\033[1m= /etc/resolv.conf =\033[0m\n\n'
        cat /etc/resolv.conf 2>/dev/null

        if [ -f /etc/nsswitch.conf ]; then
            printf '\n\033[1m= /etc/nsswitch.conf (hosts) =\033[0m\n\n'
            grep '^hosts' /etc/nsswitch.conf
        fi

        printf '\n\033[1m= Тест резолвинга =\033[0m\n\n'
        for host in google.com ya.ru; do
            printf 'Resolving %-15s ' "$host:"
            result=""
            if is_installed dig; then
                result=$(dig +short +time=3 +tries=1 "$host" A 2>/dev/null | head -1)
            elif is_installed nslookup; then
                result=$(nslookup "$host" 2>/dev/null \
                    | awk '/^Address:/{print $2}' | grep -v '#' | head -1)
            elif is_installed getent; then
                result=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -1)
            fi
            if [ -n "$result" ]; then
                printf '\033[32m%s\033[0m\n' "$result"
            else
                printf '\033[31mFAIL\033[0m\n'
            fi
        done

        hr
        ;;

    12)
        hr Available kernels

        case "$os_name" in
        Ubuntu|Debian|Astra)
            if is_installed dpkg; then
                printf '\033[1m= Установленные пакеты ядра =\033[0m\n\n'
                dpkg -l 'linux-image-*' 2>/dev/null | awk '/^ii/{print $2, $3}'
            fi
            ;;
        CentOS|Alma*|Rocky*)
            if is_installed rpm; then
                printf '\033[1m= Установленные ядра =\033[0m\n\n'
                rpm -q kernel 2>/dev/null
            fi
            ;;
        Arch)
            if is_installed pacman; then
                printf '\033[1m= Установленные ядра =\033[0m\n\n'
                pacman -Q 2>/dev/null | grep '^linux'
            fi
            ;;
        esac

        printf '\n\033[1m= /boot/vmlinuz* =\033[0m\n\n'
        ls -lh /boot/vmlinuz* 2>/dev/null || printf 'Файлы vmlinuz не найдены в /boot\n'

        printf '\n\033[1m= Текущее ядро =\033[0m\n\n'
        uname -r

        hr
        ;;

    13)
        hr "vmstat — 5 снимков, интервал 1с"
        vmstat 1 5

        hr iostat
        if is_installed iostat; then
            iostat -xz 1 3
        else
            printf 'iostat не найден. Установите пакет sysstat:\n\n'
            case "$os_name" in
            Ubuntu|Debian|Astra) printf '  apt install sysstat\n' ;;
            CentOS|Alma*|Rocky*) printf '  yum install sysstat  /  dnf install sysstat\n' ;;
            Arch)                printf '  pacman -S sysstat\n' ;;
            *)                   printf '  установите пакет sysstat\n' ;;
            esac
        fi

        hr
        ;;

    14)
        hr atop

        if ! is_installed atop; then
            printf '\033[33matop не установлен.\033[0m\n\n'
            printf 'Команда для установки:\n\n'
            case "$os_name" in
            Ubuntu|Debian|Astra)
                printf '  apt install atop -y\n\n'
                ;;
            CentOS|Alma*|Rocky*)
                printf '  dnf install atop -y\n'
                printf '  # или: yum install atop -y\n\n'
                ;;
            Arch)
                printf '  pacman -S atop --noconfirm\n\n'
                ;;
            *)
                printf '  установите пакет atop\n\n'
                ;;
            esac

            printf 'Добавьте atop в автозагрузку после установки:\n\n'
            printf '  systemctl enable atop\n\n'
            printf 'Установить сейчас? [y/N]: '
            read -r do_install

            case "$do_install" in
            y|Y)
                case "$os_name" in
                Ubuntu|Debian|Astra)
                    apt install atop -y
                    ;;
                CentOS|Alma*|Rocky*)
                    if is_installed dnf; then
                        dnf install atop -y
                    else
                        yum install atop -y
                    fi
                    ;;
                Arch)
                    pacman -S atop --noconfirm
                    ;;
                *)
                    printf 'Автоматическая установка не поддерживается для этого дистрибутива.\n'
                    hr; continue
                    ;;
                esac

                if is_installed atop; then
                    systemctl enable atop 2>/dev/null
                    systemctl start atop 2>/dev/null
                    printf '\n\033[32matop установлен и добавлен в автозагрузку.\033[0m\n\n'
                else
                    printf '\n\033[31mУстановка не удалась. Проверьте вывод выше.\033[0m\n'
                    hr; continue
                fi
                ;;
            *)
                hr; continue
                ;;
            esac
        fi

        atop_log_dir="/var/log/atop"

        printf '  1. Лог за сегодня  (atop -r)\n'
        printf '  2. Список доступных логов\n'
        printf '  3. Открыть лог за конкретный день\n'
        printf '  4. Конфигурация atop\n'
        printf '  Enter — назад\n\n'
        printf 'Выбор: '
        read -r atop_action

        case "$atop_action" in
        1)
            printf '\nНажмите q для выхода из atop.\n\n'
            atop -r 2>/dev/null \
                || printf 'Лог за сегодня не найден. Проверьте: systemctl status atop\n'
            ;;
        2)
            printf '\n\033[1m= Логи в %s =\033[0m\n\n' "$atop_log_dir"
            if [ -d "$atop_log_dir" ]; then
                ls -lh "$atop_log_dir"
                printf '\nФормат имён файлов: atop_YYYYMMDD\n'
                printf 'Пример: atop -r %s/atop_%s\n' \
                    "$atop_log_dir" "$(date +%Y%m%d 2>/dev/null)"
            else
                printf 'Директория %s не найдена.\n' "$atop_log_dir"
                printf 'Сервис atop, возможно, не запущен: systemctl start atop\n'
            fi
            ;;
        3)
            if [ -d "$atop_log_dir" ]; then
                printf 'Доступные файлы:\n\n'
                ls "$atop_log_dir"
                printf '\nВведите имя файла (например atop_%s): ' \
                    "$(date +%Y%m%d 2>/dev/null)"
                read -r atop_file
                atop_path="$atop_log_dir/$atop_file"
                if [ -f "$atop_path" ]; then
                    printf '\nНажмите q для выхода из atop.\n\n'
                    atop -r "$atop_path" 2>/dev/null
                else
                    printf 'Файл не найден: %s\n' "$atop_path"
                fi
            else
                printf 'Директория %s не найдена.\n' "$atop_log_dir"
            fi
            ;;
        4)
            printf '\n\033[1m= Конфигурация atop =\033[0m\n\n'
            atop_conf=""
            [ -f /etc/default/atop ]   && atop_conf=/etc/default/atop
            [ -f /etc/sysconfig/atop ] && atop_conf=/etc/sysconfig/atop

            if [ -n "$atop_conf" ]; then
                printf 'Файл: \033[1m%s\033[0m\n\n' "$atop_conf"
                cat "$atop_conf"
            else
                printf 'Конфигурационный файл не найден.\n'
                printf 'Ожидаемые пути:\n'
                printf '  /etc/default/atop    (Debian / Ubuntu)\n'
                printf '  /etc/sysconfig/atop  (CentOS / Alma)\n'
            fi

            printf '\n\033[1mКлючевые параметры:\033[0m\n\n'
            printf '  LOGINTERVAL / INTERVAL — интервал снимка в секундах\n'
            printf '    (в Ubuntu /etc/default/atop обычно LOGINTERVAL=600)\n'
            printf '  LOGPATH=...    — директория с логами\n'
            printf '  OUTFILE=...    — имя файла лога (если есть в вашей сборке)\n\n'

            if [ -n "$atop_conf" ] && [ -w "$atop_conf" ]; then
                printf 'Задать новый интервал снимка, сек (10–86400)? Пустой ввод — без изменений.\n'
                printf 'Пишется в LOGINTERVAL и/или INTERVAL при наличии строк. Пример: 60. Значение: '
                read -r new_interval
                new_interval=$(printf '%s' "$new_interval" | tr -d '[:space:]')
                if [ -n "$new_interval" ]; then
                    case "$new_interval" in
                    ''|*[!0-9]*)
                        printf '\033[31mНужно целое число секунд.\033[0m\n'
                        ;;
                    *)
                        if [ "$new_interval" -lt 10 ] || [ "$new_interval" -gt 86400 ]; then
                            printf '\033[31mДопустимо 10–86400 секунд.\033[0m\n'
                        else
                            if grep -qE '^(export[[:space:]]+)?(INTERVAL|LOGINTERVAL)=' "$atop_conf"; then
                                sed -i "s/^INTERVAL=.*/INTERVAL=$new_interval/" "$atop_conf"
                                sed -i "s/^LOGINTERVAL=.*/LOGINTERVAL=$new_interval/" "$atop_conf"
                                sed -i "s/^export[[:space:]]\{1,\}INTERVAL=.*/export INTERVAL=$new_interval/" "$atop_conf"
                                sed -i "s/^export[[:space:]]\{1,\}LOGINTERVAL=.*/export LOGINTERVAL=$new_interval/" "$atop_conf"
                                printf '\n\033[32mИнтервал %s записан в %s (INTERVAL и/или LOGINTERVAL)\033[0m\n' \
                                    "$new_interval" "$atop_conf"
                                if is_installed systemctl; then
                                    if systemctl restart atop.service 2>/dev/null \
                                        || systemctl restart atop 2>/dev/null; then
                                        printf '\033[32matop перезапущен (systemctl restart).\033[0m\n'
                                    else
                                        printf '\033[33mНе удалось перезапустить atop через systemctl — сделайте вручную.\033[0m\n'
                                    fi
                                else
                                    printf '\033[33msystemctl не найден — перезапустите atop вручную.\033[0m\n'
                                fi
                            else
                                printf '\033[31mВ %s нет строк INTERVAL= / LOGINTERVAL= — правка вручную.\033[0m\n' "$atop_conf"
                            fi
                        fi
                        ;;
                    esac
                fi
            elif [ -n "$atop_conf" ]; then
                printf '\n\033[33mНет прав на запись в %s — задайте интервал от root.\033[0m\n' "$atop_conf"
                printf 'После правок: systemctl restart atop.service\n'
            else
                printf 'После ручного редактирования: systemctl restart atop.service\n'
            fi
            ;;
        *)
            ;;
        esac

        hr
        ;;

    15)
        check_server_resources
        ;;

    16)
        check_sshd_config
        ;;

    *)
        :
esac
done
