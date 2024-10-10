#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"

DATA_SOURCES="d-t6eho1vza1mhowio6z,d-art86a2ch022326902,d-ink8qcii9xtjb8nnhv,d-werawxl4rqlqxjzy1c,d-y44jni7lmuiup5bfs7,d-lx4svuc2asrio1608t"

DLC_CONFIG_PATH=${DLC_CONFIG_PATH:-"${HOME}/.dlc/config"}
WORKERSPACE_ID=${WORKERSPACE_ID:-5366}
RESOURCE_ID=${RESOURCE_ID:-"quota12hhgcm8cia"}
PRIORITY=${PRIORITY:-1}
WORKER_COUNT=${WORKER_COUNT:-1}
WORKER_GPU=${WORKER_GPU:-1}
WORKER_CPU=${WORKER_CPU:-24}
WORKER_MEMORY=${WORKER_MEMORY:-400Gi}
SHELL_ENV=${SHELL_ENV:-"zsh"}
WORKER_IMAGE=${WORKER_IMAGE:-"pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:cu121-ubuntu22-lkk-0513-rc6"}

# /cpfs01/user/liujiangning/work/AgentBench
# ** NOET ** 
# model_name=internlm2-chat-7b
# model_url=http://22.8.40.48:23333
# output_path=outputs/aliyun_Ampere_7B_FT_agentflan-v2_d0424rc15/all/{TIMESTAMP}
force_finish=False
# ** NOET ** 
# TASK_CMD="cd /cpfs01/user/liujiangning/work/AgentBench && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench && python -m src.assigner --force_finish $force_finish --model_name internlm2-chat-7b --model_path /cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2_5_boost1_7B_FT_merge_fuck_bbh_v2 --output outputs/internlm2_5_boost1_7B_FT_merge_fuck_bbh_v2/all/{TIMESTAMP}"

# TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
TIMESTAMP=2024-09-20-13-50-10
model_name=internlm2-chat-7b
model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--internlm--internlm2_5-7b-chat/snapshots/9b8d9553846ecf6393f3408fa9d3ec9928fdab4d
output_path=outputs/internlm2_5-7b-chat/all/${TIMESTAMP}

TIMESTAMP=2024-09-20-13-57-19
model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--internlm--internlm2-chat-7b/snapshots/70e6cdc9643ce7e3d9a369fb984dc5f1a1b2cec6
output_path=outputs/internlm2-chat-7b/all/${TIMESTAMP}

# TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
TIMESTAMP=2024-09-25-10-12-49
model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2_5_boost1_7B_FT_merge_boost_bbh_v2
output_path=outputs/internlm2_5_boost1_7B_FT_merge_boost_bbh_v2/all/${TIMESTAMP}
TASK_CMD="cd /cpfs01/user/liujiangning/work/AgentBench && chmod +x start_model_then_assign_task.sh && ./start_model_then_assign_task.sh ${model_name} ${model_path} ${output_path} false"

task_name=all
JOB_NAME="agentbenchv2-$model_name-$task_name"

${DLC_PATH} submit pytorchjob --config ${DLC_CONFIG_PATH} \
--name $JOB_NAME \
--resource_id ${RESOURCE_ID} \
--data_sources ${DATA_SOURCES} \
--workspace_id $WORKERSPACE_ID \
--workers $WORKER_COUNT \
--worker_cpu $WORKER_CPU \
--worker_gpu ${WORKER_GPU} \
--worker_memory $WORKER_MEMORY \
--worker_image ${WORKER_IMAGE} \
--worker_shared_memory 200Gi \
--priority ${PRIORITY} \
--command  "${TASK_CMD}"
