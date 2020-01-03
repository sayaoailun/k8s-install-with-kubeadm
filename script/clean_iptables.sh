#!/bin/sh
set -eux
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t raw -F
iptables -t raw -X
iptables -t mangle -F
iptables -t mangle -X