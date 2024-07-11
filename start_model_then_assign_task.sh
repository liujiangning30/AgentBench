#!/bin/bash

model_name=$1
model_path=$2
output_path=$3
force_finish=$4

# 定义timestamp变量
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# 启动第一个进程
{
  export HOME=/cpfs01/user/liujiangning
  . /cpfs01/user/liujiangning/miniconda3/bin/activate
  conda activate lmdeploy
  lmdeploy serve api_server --model-name $model_name --model-format hf --tp 1 $model_path
} &

# 保存第一个进程的PID
pid1=$!

# 等待模型启动完成后再启动第二个进程
sleep 60

# 启动第二个进程
{
  export HOME=/cpfs01/user/liujiangning
  cd /cpfs01/user/liujiangning/work/AgentBench
  . /cpfs01/user/liujiangning/miniconda3/bin/activate
  conda activate agent-bench
  python -m src.assigner --force_finish $force_finish --model_name $model_name --model_url http://127.0.0.1:23333 --output ${output_path}/${TIMESTAMP}
} &

# 保存第二个进程的PID
pid2=$!

# 捕获TERM信号并杀死所有后台进程
trap 'kill $pid1 $pid2' TERM

# 等待第二个进程结束
wait $pid2

# 一旦第二个进程结束，立即杀死第一个进程
kill $pid1

# 脚本结束
echo "Process 2 has finished and Process 1 has been terminated."