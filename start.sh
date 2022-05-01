#!/bin/sh

WORK_DIR="/opt/_ruantiblock_blacklist"

cd "$WORK_DIR"
./run_parser.sh ./ruantiblock_ip.conf ./blacklist/ip && ./run_parser.sh ./ruantiblock_fqdn.conf ./blacklist/fqdn && git add . && git commit -m "Updated: `date -u \"+%Y-%m-%d %H:%M %z\"`" && git push origin master
