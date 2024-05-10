#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"
DLC_CONFIG_PATH="${HOME}/.dlc/config"
IMAGE='master0:5000/eflops/admin:u152-1696-20240318202159'
WORKSPACE_ID='ws18sdj44um64lxi'
# pjlab-lingjun-076, pjlab-lingjun-067
NODE_NAMES=pjlab-lingjun-073

num_nodes=1
num_gpus=1
# internlm
conda_env=lmdeploy

# model_path=/cpfs01/shared/public/public_hdd/zhangwenwei/ckpt/exps/20240401/aliyun_Ampere_7B_v1.1_FT_v1.0.0_s1_rc42/1980_hf
# model_path=/cpfs01/shared/public/public_hdd/zhangwenwei/ckpt/exps/20240418/aliyun_Darwin_100B_B330k_E29k_FT_v1_0_s1_rc47_g512_set256_495_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc7/40_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc1/30_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc2/40_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc3/40_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc4/40_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc5/40_hf
# /cpfs01/user/liujiangning/ckpt/exps/cot_refinement/aliyun_Ampere_7B_FT_cot_refinement_d0324rc6/40_hf
# model_path=/cpfs01/user/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0424rc2/480_hf
# model_path=/cpfs01/user/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0424rc1/290_hf
# model_path=/cpfs01/user/liujiangning/ckpt/exps/agentflan-v2/aliyun_Ampere_7B_FT_agentflan-v2_d0424rc9/500_hf
model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--Qwen--Qwen1.5-7B-Chat/snapshots/294483ad23713036574b30587b186713373f4271
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--Qwen--Qwen1.5-14B-Chat/snapshots/79e31c0b5875db412a7db189514b523ec8440928
# Llama-2-70b-chat, internlm2-chat-7b, Baichuan2-13B-Chat
model_name=qwen1.5-7b
DLC_CMD="export HOME=/cpfs01/user/liujiangning && source ~/.bashrc && source activate $conda_env && export LD_LIBRARY_PATH=/cpfs01/shared/public/zhaoqian/cuda-compat-12-2 && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && lmdeploy serve api_server --model-name $model_name --model-format hf --tp 1 $model_path"
# DLC_CMD="export HOME=/cpfs01/user/liujiangning && source ~/.bashrc && source activate agent-bench && export LD_LIBRARY_PATH=/cpfs01/shared/public/zhaoqian/cuda-compat-12-2 && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && cd /cpfs01/user/liujiangning/work/AgentBench && bash start_fschat_servce.sh"
JOB_NAME="internlm2-chat-server-$model_name"

${DLC_PATH} --config ${DLC_CONFIG_PATH}  create job \
--name $JOB_NAME \
--kind TFJob \
--worker_count $num_nodes \
--worker_cpu 20 \
--worker_gpu $num_gpus \
--worker_memory 400 \
--worker_image ${IMAGE} \
--workspace_id ${WORKSPACE_ID} \
--worker_shared_memory 400 \
--node_names ${NODE_NAMES} \
--command  "${DLC_CMD}"
