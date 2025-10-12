#!/bin/bash
#Вывод заголовка
echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"
#Запись всех PID (имена папок) из папки /proc
pid_array=$(find /proc -maxdepth 1 -type d | grep -oE '[0-9]+$')
for i in ${pid_array[@]}
do
    tty='?'
    if [ -h /proc/$i/fd/0 ]; then
        #Получение tty
        if [ -c $(readlink /proc/$i/fd/0) ]; then
            if [ $(readlink /proc/$i/fd/0) != '/dev/null' ]; then
                tty=$(readlink /proc/$i/fd/0 | cut -c6-10)
            fi
        fi
    fi
    if [ -f /proc/$i/stat ]; then
        #Статус процесса
        stat=$(cat /proc/$i/stat | awk '{print $3}')
        #Суммарное вермя использования CPU
        varHertz=$(getconf CLK_TCK)
        utime=$(awk '{print $14}' /proc/$i/stat)
        stime=$(awk '{print $15}' /proc/$i/stat)
        let result=(utime+stime)/varHertz
        time=$(date -u -d "@$result" +"%M:%S")
    fi
    #Вывод COMMAND
    if [ -d /proc/$i ]; then
        command=$(cat /proc/$i/cmdline | tr '\0' ' ')
        if [ -z "$command" ]; then
            command="[$(cat /proc/$i/comm)]"
        fi
    fi
    echo -e "$i\t$tty\t$stat\t$time\t$command"
done
