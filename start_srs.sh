#!/bin/bash
cd /root/shell
nohup ./srs.sh > /root/logs/srs_log/srs_$(date "+%Y-%m-%d-%H-%M-%S").log 2&>1 &
nohup ./mse.sh > /root/logs/mse_log/mse_$(date "+%Y-%m-%d-%H-%M-%S").log 2&>1 &
while true;
do sleep 1;
done;
