#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"

DATA_SOURCES="d-t6eho1vza1mhowio6z"

DLC_CONFIG_PATH=${DLC_CONFIG_PATH:-"${HOME}/.dlc/config"}
WORKERSPACE_ID=${WORKERSPACE_ID:-5366}
RESOURCE_ID=${RESOURCE_ID:-"quota12hhgcm8cia"}
PRIORITY=${PRIORITY:-9}
WORKER_COUNT=${WORKER_COUNT:-1}
WORKER_GPU=${WORKER_GPU:-0}
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
TASK_CMD="cd /cpfs01/user/liujiangning/work/AgentBench && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench && python -m src.assigner --force_finish $force_finish"

task_name=all
# aliyun_Ampere_7B_FT_agentflan-v2_d0424rc1
# aliyun_Ampere_7B_FT_agentflan-v2_d0424rc14
# aliyun_Ampere_7B_FT_agentflan-v2_d0424rc15
# vicuna-13b, Baichuan2-7B-Chat, Llama-2-70b-chat, Qwen1.5-7B-Chat
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_rc47
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_rc47_s2
# P-official_volc_Ampere_7B_v1_1_enhance_FT_v1_0_0_s1_rc47_s2_rl
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_0523rc1
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_0523rc1_s2
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_0523rc2
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_0523rc2_s2
# aliyun_Ampere_7B_v1_1_enchance_FT_v1_0_0_s1_0523rc2_s2_0524
# P-volc_Ampere_7B_v1.1_enchance_FT_v1.0.0_s1_0523rc2_s2_0524_rl
# aliyun_Ampere_7B_v1_1_enchance_FT_20240530rc1
model_name=agentbenchv2-assigner-aliyun_Ampere_7B_v1_1_enchance_FT_20240530rc5
JOB_NAME="$model_name-$task_name"

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
