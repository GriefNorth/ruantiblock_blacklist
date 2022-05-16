#!/bin/sh

############################## Usage ##################################
#
# run_parser.sh [<config> [<output directory>]]

#################### Platform-specific settings ########################

export SCRIPT_NAME="ruantiblock_blacklist"
export NAME="ruantiblock"
export LANG="en_US.UTF-8"
export LANGUAGE="en"

CONFIG_DIR="."
CONFIG_FILE="${CONFIG_DIR}/${NAME}.conf"
export DATA_DIR="."
export MODULES_DIR="."

########################## Default Settings ############################

### Запись событий в syslog (0 - off, 1 - on)
export ENABLE_LOGGING=1
### Кол-во попыток обновления блэклиста (в случае неудачи)
export MODULE_RUN_ATTEMPTS=3
### Таймаут между попытками обновления
export MODULE_RUN_TIMEOUT=60
### Модули для получения и обработки блэклиста
BLLIST_MODULE="${MODULES_DIR}/ruab_parser.lua"
#BLLIST_MODULE="${MODULES_DIR}/ruab_parser.py"

############################## Parsers #################################

### Режим обхода блокировок: zapret-info-fqdn, zapret-info-ip, rublacklist-fqdn, rublacklist-ip, antifilter-ip, ruantiblock-fqdn, ruantiblock-ip
export BLLIST_PRESET="zapret-info-fqdn"
### В случае если из источника получено менее указанного кол-ва записей, то обновления списков не происходит
export BLLIST_MIN_ENTRIES=30000
### Лимит IP адресов. При достижении, в конфиг ipset будет добавлена вся подсеть /24 вместо множества IP адресов пренадлежащих этой сети (0 - off)
export BLLIST_IP_LIMIT=0
### Подсети класса C (/24). IP адреса из этих подсетей не группируются при оптимизации (записи д.б. в виде: 68.183.221. 149.154.162. и пр.). Прим.: "68.183.221. 149.154.162."
export BLLIST_GR_EXCLUDED_NETS=""
### Группировать идущие подряд IP адреса в подсетях /24 в диапазоны CIDR
export BLLIST_SUMMARIZE_IP=0
### Группировать идущие подряд подсети /24 в диапазоны CIDR
export BLLIST_SUMMARIZE_CIDR=0
### Фильтрация записей блэклиста по шаблонам из файла BLLIST_IP_FILTER_FILE. Записи (IP, CIDR) попадающие под шаблоны исключаются из кофига ipset (0 - off, 1 - on)
export BLLIST_IP_FILTER=0
### Файл с шаблонами IP для опции BLLIST_IP_FILTER (каждый шаблон в отдельной строке. # в первом символе строки - комментирует строку)
export BLLIST_IP_FILTER_FILE="${CONFIG_DIR}/ip_filter"
### Лимит субдоменов для группировки. При достижении, в конфиг dnsmasq будет добавлен весь домен 2-го ур-ня вместо множества субдоменов (0 - off)
export BLLIST_SD_LIMIT=16
### SLD не подлежащие группировке при оптимизации (через пробел)
export BLLIST_GR_EXCLUDED_SLD="livejournal.com facebook.com vk.com blog.jp msk.ru net.ru org.ru net.ua com.ua org.ua co.uk amazonaws.com"
### Не группировать SLD попадающие под выражения (через пробел) ("[.][a-z]{2,3}[.][a-z]{2}$")
export BLLIST_GR_EXCLUDED_MASKS=""
### Фильтрация записей блэклиста по шаблонам из файла ENTRIES_FILTER_FILE. Записи (FQDN) попадающие под шаблоны исключаются из кофига dnsmasq (0 - off, 1 - on)
export BLLIST_FQDN_FILTER=0
### Файл с шаблонами FQDN для опции BLLIST_FQDN_FILTER (каждый шаблон в отдельной строке. # в первом символе строки - комментирует строку)
export BLLIST_FQDN_FILTER_FILE="${CONFIG_DIR}/fqdn_filter"
### Обрезка www[0-9]. в FQDN (0 - off, 1 - on)
export BLLIST_STRIP_WWW=1
### Преобразование кириллических доменов в punycode (0 - off, 1 - on)
export BLLIST_ENABLE_IDN=0
### Перенаправлять DNS-запросы на альтернативный DNS-сервер для заблокированных FQDN (0 - off, 1 - on)
export BLLIST_ALT_NSLOOKUP=0
### Альтернативный DNS-сервер
export BLLIST_ALT_DNS_ADDR="8.8.8.8"

### Источники блэклиста
export RBL_ALL_URL="https://reestr.rublacklist.net/api/v2/current/csv/"
export RBL_IP_URL="https://reestr.rublacklist.net/api/v2/ips/csv/"
export ZI_ALL_URL="https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv"
export AF_IP_URL="https://antifilter.download/list/allyouneed.lst"
export AF_FQDN_URL="https://antifilter.download/list/domains.lst"
# export RA_IP_IPSET_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/ip/ruantiblock.ip"
# export RA_IP_DMASK_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/ip/ruantiblock.dnsmasq"
# export RA_IP_STAT_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/ip/update_status"
# export RA_FQDN_IPSET_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/fqdn/ruantiblock.ip"
# export RA_FQDN_DMASK_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/fqdn/ruantiblock.dnsmasq"
# export RA_FQDN_STAT_URL="https://raw.githubusercontent.com/gSpotx2f/ruantiblock_blacklist/master/blacklist/fqdn/update_status"
export RBL_ENCODING=""
export ZI_ENCODING="CP1251"
export AF_ENCODING=""
# export RA_ENCODING=""

############################ Configuration #############################

### External config
if [ -n "$1" ]; then
    CONFIG_FILE="$1"
fi
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

### Blacklist source and mode
case "$BLLIST_PRESET" in
    zapret-info-ip)
        ### Источник для обновления списка блокировок (zapret-info, rublacklist, antifilter, ruantiblock)
        export BLLIST_SOURCE="zapret-info"
        ### Режим обхода блокировок: ip, fqdn
        export BLLIST_MODE="ip"
    ;;
    rublacklist-ip)
        export BLLIST_SOURCE="rublacklist"
        export BLLIST_MODE="ip"
    ;;
    rublacklist-fqdn)
        export BLLIST_SOURCE="rublacklist"
        export BLLIST_MODE="fqdn"
    ;;
    antifilter-ip)
        export BLLIST_SOURCE="antifilter"
        export BLLIST_MODE="ip"
    ;;
#     ruantiblock-ip)
#         export BLLIST_SOURCE="ruantiblock"
#         export BLLIST_MODE="ip"
#     ;;
#     ruantiblock-fqdn)
#         export BLLIST_SOURCE="ruantiblock"
#         export BLLIST_MODE="fqdn"
#     ;;
    *)
        export BLLIST_SOURCE="zapret-info"
        export BLLIST_MODE="fqdn"
    ;;
esac

AWK_CMD="awk"
LOGGER_CMD=`which logger`
if [ $ENABLE_LOGGING = "1" -a $? -ne 0 ]; then
    echo " Logger doesn't exists" >&2
    ENABLE_LOGGING=0
fi
LOGGER_PARAMS="-t ${SCRIPT_NAME}"

### Output directory
if [ -n "$2" ]; then
    export DATA_DIR="$2"
fi

export DNSMASQ_DATA_FILE="${DATA_DIR}/${NAME}.dnsmasq"
export IP_DATA_FILE="${DATA_DIR}/${NAME}.ip"
export IPSET_ONION="r_onion"
export IPSET_CIDR="rc"
export IPSET_CIDR_TMP="${IPSET_CIDR}t"
export IPSET_IP="ri"
export IPSET_IP_TMP="${IPSET_IP}t"
export IPSET_DNSMASQ="rd"
export UPDATE_STATUS_FILE="${DATA_DIR}/update_status"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"

MakeLogRecord() {
    if [ $ENABLE_LOGGING = "1" ]; then
        $LOGGER_CMD $LOGGER_PARAMS -p "user.${1}" "$2"
    fi
}

GetDataFiles() {
    local _return_code=1 _attempt=1 _update_string
    if [ -n "$BLLIST_MODULE" ]; then
        while :
        do
            nice -n 19 $BLLIST_MODULE
            _return_code=$?
            [ $_return_code -eq 0 ] && break
            ### STDOUT
            echo " Module run attempt ${_attempt}: failed [${BLLIST_MODULE}]"
            MakeLogRecord "err" "Module run attempt ${_attempt}: failed [${BLLIST_MODULE}]"
            _attempt=`expr $_attempt + 1`
            [ $_attempt -gt $MODULE_RUN_ATTEMPTS ] && break
            sleep $MODULE_RUN_TIMEOUT
        done

        if [ $_return_code -eq 0 ]; then
            _update_string=`$AWK_CMD '{
                printf "Received entries: %s\n", (NF < 3) ? "No data" : "CIDR: "$1", IP: "$2", FQDN: "$3;
                exit;
            }' "$UPDATE_STATUS_FILE"`
            ### STDOUT
            echo " ${_update_string}"
            MakeLogRecord "notice" "${_update_string}"
        fi
    else
        _return_code=0
    fi
    return $_return_code
}

Update() {
    local _return_code=0

    echo " ${SCRIPT_NAME} update (${1})..."
    MakeLogRecord "notice" "update (${1})..."
    GetDataFiles
    case $? in
        0)
            echo " Blacklist updated"
            MakeLogRecord "notice" "Blacklist updated"
        ;;
        2)
            echo " Error! Blacklist update error" >&2
            MakeLogRecord "err" "Error! Blacklist update error"
            _return_code=1
        ;;
        *)
            echo " Module error! [${BLLIST_MODULE}]" >&2
            MakeLogRecord "err" "Module error! [${BLLIST_MODULE}]"
            _return_code=1
        ;;
    esac
    return $_return_code
}

Update $1
exit $?
