#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"

DATA_SOURCES="d-t6eho1vza1mhowio6z,d-art86a2ch022326902,d-ink8qcii9xtjb8nnhv,d-werawxl4rqlqxjzy1c,d-y44jni7lmuiup5bfs7,d-lx4svuc2asrio1608t"

DLC_CONFIG_PATH=${DLC_CONFIG_PATH:-"${HOME}/.dlc/config"}
WORKERSPACE_ID=${WORKERSPACE_ID:-5366}
RESOURCE_ID=${RESOURCE_ID:-"quota12hhgcm8cia"}
PRIORITY=${PRIORITY:-9}
WORKER_COUNT=${WORKER_COUNT:-1}
WORKER_GPU=${WORKER_GPU:-1}
WORKER_CPU=${WORKER_CPU:-24}
WORKER_MEMORY=${WORKER_MEMORY:-150Gi}
SHELL_ENV=${SHELL_ENV:-"zsh"}
WORKER_IMAGE=${WORKER_IMAGE:-"pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:cu121-ubuntu22-lkk-0513-rc6"}

num_nodes=1
num_gpus=1
# internlm, lmdeploy
conda_env=lmdeploy

# model_path=/cpfs01/shared/public/public_hdd/zhangwenwei/ckpt/exps/20240401/aliyun_Ampere_7B_v1.1_FT_v1.0.0_s1_rc42/1980_hf
# model_path=/cpfs01/shared/public/public_hdd/zhangwenwei/ckpt/exps/20240418/aliyun_Darwin_100B_B330k_E29k_FT_v1_0_s1_rc47_g512_set256_495_hf
# model_path=/cpfs02/llm/shared/public/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_internlm2.5_rc5_tool_agentflan-v2_d0424rc37/350_hf
# model_path=/cpfs02/llm/shared/public/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0424rc56/350_hf
# model_path=/cpfs02/llm/shared/public/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0617rc1/50_hf
# model_path=/cpfs02/llm/shared/public/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0617rc2/50_hf
# model_path=/cpfs02/llm/shared/public/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0617rc3/140_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240621/aliyun_internlm2_5_7B_enhance2_0_exp5_FT_s1_20240621rc6_s2_20240612rc10_388step_388_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2_5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc13_379_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2_5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc13_379_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2_5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc11_388_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2_5_boost1_256k_rope50m_7B_FT_s1_20240621rc10_s2_20240612rc13_379_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc14/hf_256k
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2_5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc13_rl_20240622rc1_360_hf
# model_path=/cpfs02/llm/shared/public/zhangwenwei/ckpt/exps/20240623/aliyun_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15/hf_256k

# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc1/280_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc1/360_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc2/280_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc2/360_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_7B_FT_s1_20240621rc11_s2_20240612rc16_rl_20240622rc1/320_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc1/280_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc2/360_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc3/280_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc3/320_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc3/360_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc4/320_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc15_rl_20240622rc4/360_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2.5_boost1_256k_rope50m_7B_FT_s1_20240621rc11_s2_20240612rc16_rl_20240622rc3/320_hf
# model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2_5_boost1_7B_FT_merge_all_ppo_ckpts
model_path=/cpfs02/llm/shared/public/zhaoqian/ckpt/7B/240623/P-volc_internlm2_5_boost1_7B_FT_merge_fuck_bbh_v2
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--Qwen--Qwen1.5-7B-Chat/snapshots/294483ad23713036574b30587b186713373f4271
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--Qwen--Qwen1.5-14B-Chat/snapshots/79e31c0b5875db412a7db189514b523ec8440928
# Llama-2-70b-chat, internlm2-chat-7b, Baichuan2-13B-Chat, qwen1.5-7b
model_name=internlm2-chat-7b
server_tag=P-volc_internlm2_5_boost1_7B_FT_merge_fuck_bbh_v2
TASK_CMD="export HOME=/cpfs01/user/liujiangning && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate $conda_env && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && lmdeploy serve api_server --model-name $model_name --model-format hf --tp 1 $model_path"
# DLC_CMD="export HOME=/cpfs01/user/liujiangning && source ~/.bashrc && source activate agent-bench && export LD_LIBRARY_PATH=/cpfs01/shared/public/zhaoqian/cuda-compat-12-2 && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && cd /cpfs01/user/liujiangning/work/AgentBench && bash start_fschat_servce.sh"
JOB_NAME="internlm2-chat-server-$server_tag"

# --priority ${PRIORITY} \
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
