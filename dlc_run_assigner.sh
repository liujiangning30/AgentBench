#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"
DLC_CONFIG_PATH="${HOME}/.dlc/config"
IMAGE='master0:5000/eflops/liujiangning:agentbench-webshop-rc1'
WORKSPACE_ID='ws18sdj44um64lxi'

num_nodes=1

# /cpfs01/user/liujiangning/work/AgentBench
# ** NOET ** 
force_finish=false
# ** NOET ** 
DLC_CMD="cd /cpfs01/user/liujiangning/work/AgentBench && source /cpfs01/user/liujiangning/miniconda3/bin/activate agent-bench && python -m src.assigner --force_finish $force_finish"

task_name=all
# aliyun_Ampere_7B_FT_agentflan-v2_d0424rc1
# vicuna-13b, Baichuan2-7B-Chat, Llama-2-70b-chat, Qwen1.5-7B-Chat
model_name=agentbenchv2-assigner-Qwen1.5-7B-Chat
JOB_NAME="$model_name-$task_name"

${DLC_PATH} --config ${DLC_CONFIG_PATH}  create job \
--name $JOB_NAME \
--kind TFJob \
--worker_count $num_nodes \
--worker_cpu 20 \
--worker_memory 100 \
--worker_image ${IMAGE} \
--workspace_id ${WORKSPACE_ID} \
--worker_shared_memory 400 \
--command  "${DLC_CMD}"
