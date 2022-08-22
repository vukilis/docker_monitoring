#!/bin/bash

REQUIRED_PKG="swaks"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    sudo apt-get install $REQUIRED_PKG -y
fi

for report in {1..5}
do
    docker stats | while read line
    do
        cd "$(dirname "$0")";
        file_output=$(awk 'BEGIN {FS="="} NR==1 {print $2}' .env | sed 's/"//g')   # file name of stats output
        HOST_MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2/1024/1024}')
        oldifs=IFS
        IFS=;
        dStats=$(docker stats --no-stream --format "table {{.MemPerc}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Name}}\t{{.ID}}" | sed -n '1!p')

        SUM_RAM=`echo $dStats | tail -n +2 | sed "s/%//g" | awk '{s+=$1} END {print s}'`
        SUM_CPU=`echo $dStats | tail -n +2 | sed "s/%//g" | awk '{s+=$2} END {print s}'`
        SUM_RAM_QUANTITY=`LC_NUMERIC=C printf %.2f $(echo "$SUM_RAM*$HOST_MEM_TOTAL*0.01" | bc)`


        # Output the result
        echo "########################################### Start of Resources Output ##############################################" >> $file_output
        echo " " >> $file_output
        dat=$(date)
        echo "Present Date & Time is: $dat                                       Report: $report" >> $file_output
        echo " " >> $file_output

        echo "MEM %     CPU %     MEM USAGE / LIMIT     NAME                   CONTAINER ID" >> $file_output
        IFS=$'\r\n' GLOBIGNORE='*'
        for i in  $dStats
        do
            cpuPerc=$(echo $i | awk '{print $2}')
            memPerc=$(echo $i | awk '{print $1}')
            cpuPerc=${cpuPerc%"%"}
            cpuPerc=${cpuPerc/.*}
            memPerc=${memPerc%"%"}
            memPerc=${memPerc/.*}
            if [ $cpuPerc -ge 0 ] || [ $memPerc -ge 0  ]
            then
                echo $i >> $file_output
            else
                echo "System performance are good!" >> $file_output
            fi
        done
        
        SUM_RAM=$(free | awk '/^Mem/ { printf("%.2f\n", $3/$2 * 100.0) }')
        cpu_threshold='80'
        SUM_CPU=$(top -b -n 1 | grep Cpu | awk '{print $8}'|cut -f 1 -d ".")
        cpu_use=$(expr 100 - $SUM_CPU)
        user=$(whoami)
        SUM_RAM=${SUM_RAM%.*}
        if [ $SUM_RAM -ge 0 ] || [ $cpu_use -ge 0 ]
        then
            echo " " >> $file_output
            echo "MEM %     CPU %     MEM USAGE / LIMIT                            USER" >> $file_output
            # echo -e "${SUM_RAM}%\t\t  ${cpu_use}%\t\t${SUM_RAM_QUANTITY}GiB / ${HOST_MEM_TOTAL}GiB \t\t\t\t\t\t ${user}" >> $file_output
            echo -e "${SUM_RAM}%       ${cpu_use}%       ${SUM_RAM_QUANTITY}GiB / ${HOST_MEM_TOTAL}GiB                         ${user}" >> $file_output
            echo " ">> $file_output
        fi

        echo "########################################### End of Resources Output ################################################" >> $file_output
        echo " " >> $file_output

        # Email alert
        user=$(awk 'BEGIN {FS="="} NR==3 {print $2}' .env | sed 's/"//g')
        num=3
        if [ "$cpu_use" -ge 50 ]; 
        then
            SUBJECT="Report"
            MESSAGE=$(awk 'BEGIN {FS="="} NR==2 {print $2}' .env | sed 's/"//g')  # file name of mail attachemnt
            FROM=$(awk 'BEGIN {FS="="} NR==4 {print $2}' .env | sed 's/"//g')
            EMAILPSWD=$(awk 'BEGIN {FS="="} NR==5 {print $2}' .env | sed 's/"//g')
            TO=$(awk 'BEGIN {FS="="} NR==6 {print $2}' .env | sed 's/"//g')
            echo "ATTENTION: CPU load is high on ${user} at ${dat}" >> $MESSAGE
            echo "" >> $MESSAGE
            echo "Report $report" >> $MESSAGE
            echo "CPU current usage is: ${cpu_use}%" >> $MESSAGE
            echo "RAM current usage is: ${SUM_RAM}%" >> $MESSAGE
            echo "" >> $MESSAGE
            echo "+------------------------------------------------------------------+" >> $MESSAGE
            echo "Top 5 processes which consuming high CPU" >> $MESSAGE
            echo "+------------------------------------------------------------------+" >> $MESSAGE
            echo "$(top -b -n $num | sed -n '7,12p')" >> $MESSAGE
            echo "" >> $MESSAGE
            echo "+------------------------------------------------------------------+" >> $MESSAGE
            echo "Top 10 Processes which consuming high CPU using the ps command" >> $MESSAGE
            echo "+------------------------------------------------------------------+" >> $MESSAGE
            echo "$(ps -eo pcpu,pid,user,args | sort -k 1 -r | head -11)" >> $MESSAGE
            RMSG=$(cat $MESSAGE)
            swaks --from "$FROM" --to "$TO" -s smtp.gmail.com:587 -tls -au "$FROM" -ap "$EMAILPSWD" --header "Subject: $SUBJECT" --attach "$file_output" --body "$RMSG"
            rm $MESSAGE
            echo "ATTENTION ON REPORT $report!"
            break
        fi
        break
    done
done