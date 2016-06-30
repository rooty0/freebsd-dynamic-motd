#!/usr/bin/env sh

# Example of style of a motd
# http://www.mewbies.com/how_to_customize_your_console_login_message_tutorial.htm

# Settings
#DOTS_AFTER_LONGEST_WORD=3 # not implemented
#CENTRALIZED_OUTPUT='yes' # not implemented
ACTIVE_PLUGINS="DISK LASTLOG" # not implemented

# Reuse output
uptime_command=$(uptime)

#
pl () {
  # input integer, single word,
  [ $1 -eq 1 ] && echo $3 || echo $2
}

#
# DISK
# "Disk Usage....: You're using 2M in /home/mewbie"
#
disk_usage=$(df -h / | awk 'END{print "You are using " $3 "/" $2 "(" $5 ") in " $6}')
OUTPUT_DISK=$disk_usage
HEADLINE_DISK="Disk Usage"
#
# LASTLOGIN
# "Last Login....: Mon Jun 14 02:59:55 from 123.456.789.0"
#
lastlog=$(lastlogin $(whoami) | awk -F '[[:space:]][[:space:]]+' '{print $4 " from " $3}')
HEADLINE_LASTLOG=""
OUTPUT_LASTLOG=$lastlog
#
# LOAD
# ] 0,34 (1 minute) 0,35 (5 minutes) 0,34 (15 minutes) / 8 cores
#
load=$(echo ${uptime_command} $(sysctl -n hw.ncpu)| awk -F 'load averages: ' '{print $2}' | awk '{print $1 " (1 minute) " $2 " (5 minutes) " $3 " (15 minutes) / " $4 " cores"}')
HEADLINE_LOAD=""
OUTPUT_LOAD=$load
#
# LOGINS
# ] There are currently 4 users users logged in and 1 users using ssh
#
term_users=$(echo ${uptime_command} | cut -d',' -f3 | cut -c 2-)
ssh_users=$(ps ax | grep -Ec 'sshd: .*@.* \(sshd\)')
HEADLINE_LOGINS=""
OUTPUT_LOGINS="There are currently ${term_users} logged in and ${ssh_users} user$(pl $ssh_users s) using ssh"
#
# MEMORY
# ] Total: 8171MB [100%]  Used: 3158MB [38%]  Free: 5012MB [61%]  Swap In Use: 859M(10%)/7.2G
memory_total=$(sysctl -n hw.physmem)
memory_pagesize=$(sysctl -n hw.pagesize)
memory_inactive=$(( $(sysctl -n vm.stats.vm.v_inactive_count) * ${memory_pagesize} ))
memory_cache=$(( $(sysctl -n vm.stats.vm.v_cache_count) * ${memory_pagesize} ))
memory_free=$(( $(sysctl -n vm.stats.vm.v_free_count) * ${memory_pagesize} ))
memory_aval=$(( ${memory_inactive} + ${memory_cache} + ${memory_free} ))
memory_used=$(( ${memory_total} - ${memory_aval} ))
# in mb
mem_total_mb=$(( ${memory_total} / (1024*1024) ))
mem_used_mb=$(( ${memory_used} / (1024*1024) ))
mem_used_pr=$(( ${memory_used} * 100 / ${memory_total} ))
mem_aval_mb=$(( ${memory_aval} / (1024*1024) ))
mem_aval_pr=$(( ${memory_aval} * 100 / ${memory_total} ))
mem_swap=$(swapinfo -h | awk 'END{print $3"("$5")/"$4}')
#
HEADLINE_MEMORY="Memory"
OUTPUT_MEMORY="Total: ${mem_total_mb}MB [100%]  Used: ${mem_used_mb}MB [${mem_used_pr}%]  Free: ${mem_aval_mb}MB [${mem_aval_pr}%]  Swap In Use: ${mem_swap}"
#
# PROCESSES
# ] 36 running of which 1 is yours
#
running_proc=$(ps xo state | sed 1d | grep -cv 'I')
running_proc_users=$(ps xo state -U stan | sed 1d | grep -cv 'I')
HEADLINE_PROCESSES=""
OUTPUT_PROCESSES="${running_proc} running of which ${running_proc_users} $(pl $running_proc_users are is) yours"
#
# UPTIME
# ] 17 days 20 hours 10 minutes
#
uptime=$(echo ${uptime_command} | cut -d',' -f1 -f2 | sed -r 's/^([0-9]+:[0-9]+)[ ]+up[ ]+([0-9]+)[ ]+days,[ ]+([0-9]+):([0-9]+).*$/\2 days \3 hours \4 minutes/g')
HEADLINE_UPTIME=""
OUTPUT_UPTIME=$uptime
#
# WEATHER
# ] 58°C (99°F), Cloudy
HEADLINE_WEATHER="Weather"
OUTPUT_WEATHER=""
#
# TEMPERATURE
# ] Core0: 91.4°F  M/B: 98.6°F  CPU: 89.6°F  Disk: 98°F
temp_core=$(sysctl -n dev.cpu.0.temperature)
temp_hdd=$(smartctl -A /dev/ada0|grep -i Temperature_Celsius | awk -F '[[:space:]][[:space:]]+' '{print $9}')
HEADLINE_TEMPERATURE="Temperature"
OUTPUT_TEMPERATURE="Core0: ${temp_core}  Disk [ada0]: ${temp_hdd} [ada1]: ____"

#
# TEMPLATE
#
echo "Last Login....: ${OUTPUT_LASTLOG}"
echo "Uptime........: ${OUTPUT_UPTIME}"
echo "Load..........: ${OUTPUT_LOAD}"
echo "Memory........: ${OUTPUT_MEMORY}"
echo "Temperature...: ${OUTPUT_TEMPERATURE}"
echo "Disk Usage....: ${OUTPUT_DISK}"
echo "Logins........: ${OUTPUT_LOGINS}"
echo "Processes.....: ${OUTPUT_PROCESSES}"
echo "Weather.......: ${OUTPUT_WEATHER}"

