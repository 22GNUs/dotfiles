#!/bin/sh
nmap -p 1082 30.5.160.0/24 | grep -B 4 open | awk '/Nmap scan report for/{print $NF}' | tr -d '()'
