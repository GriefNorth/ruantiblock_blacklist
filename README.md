# Создание конфигов ipset и dnsmasq со списком блокировок для [ruantiblock_openwrt](https://github.com/gSpotx2f/ruantiblock_openwrt).

## Установка зависимостей

Для работы с GitHub нужен git. Для lua-модуля (ruab_parser.lua) необходимы следующие зависимости: lua, luasocket, luasec, luabitop, [ruab_sum_ip.lua](https://raw.githubusercontent.com/gSpotx2f/ruantiblock_openwrt/master/ruantiblock-mod-lua/files/usr/lib/lua/ruab_sum_ip.lua), [iptool.lua](https://raw.githubusercontent.com/gSpotx2f/iptool-lua/master/5.1/iptool.lua) и опционально (для конвертирования кириллических доменов в punycode): iconv, [idn.lua](https://raw.githubusercontent.com/haste/lua-idn/master/idn.lua) или idn.
В разных Linux-дистрибутивах названия пакетов могут отличаться. На примере OpenWrt установка зависимостей выглядит так:

    opkg install git openssh-client-utils lua luasocket luasec luabitop iconv idn
    wget --no-check-certificate -O /usr/lib/lua/ruab_sum_ip.lua https://raw.githubusercontent.com/gSpotx2f/ruantiblock_openwrt/master/ruantiblock-mod-lua/files/usr/lib/lua/ruab_sum_ip.lua
    wget --no-check-certificate -O /usr/lib/lua/iptool.lua https://raw.githubusercontent.com/gSpotx2f/iptool-lua/master/5.1/iptool.lua
    wget --no-check-certificate -O /usr/lib/lua/idn.lua https://raw.githubusercontent.com/haste/lua-idn/master/idn.lua

## Установка скриптов для запуска модуля-парсера

1. Сделайте форк этого репозитория.

2. Затем создайте локальную копию вашего форка в `/opt/_ruantiblock_blacklist` (на той машине, где будет выполняться создание конфигов):

        git clone git@github.com:<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist /opt/_ruantiblock_blacklist

## Запуск

Создание конфигов ipset, dnsmasq и коммит на GitHub (эту команду можно добавить в cron для регулярного обновления списка блокировок):

    /opt/_ruantiblock_blacklist/start.sh

## Настройка [ruantiblock_openwrt](https://github.com/gSpotx2f/ruantiblock_openwrt) на роутере для получения созданных конфигов

В конфигурационном файле `/etc/ruantiblock/ruantiblock.conf` измените в следующих переменных имя аккаунта GitHub:

    RA_IP_IPSET_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/ip/ruantiblock.ip"
    RA_IP_DMASK_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/ip/ruantiblock.dnsmasq"
    RA_IP_STAT_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/ip/update_status"
    RA_FQDN_IPSET_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/fqdn/ruantiblock.ip"
    RA_FQDN_DMASK_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/fqdn/ruantiblock.dnsmasq"
    RA_FQDN_STAT_URL="https://raw.githubusercontent.com/<ИМЯ ВАШЕГО АККАУНТА GITHUB>/ruantiblock_blacklist/master/blacklist/fqdn/update_status"

Включение режима обновления блэклиста `ruantiblock-fqdn`:

    uci set ruantiblock.config.bllist_preset="ruantiblock-fqdn"
    uci commit ruantiblock

Обновление блэклиста:

    /usr/bin/ruantiblock update
