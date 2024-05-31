#!/bin/bash
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--lmsys--vicuna-13b-v1.5/snapshots/c8327bf999adbd2efe2e75f6509fa01436100dc2
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--lmsys--vicuna-7b-v1.5/snapshots/3321f76e3f527bd14065daf69dad9344000a201d
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--meta-llama--Llama-2-70b-chat-hf/snapshots/e9149a12809580e8602995856f8098ce973d1080
# model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--baichuan-inc--Baichuan2-7B-Chat/snapshots/ea66ced17780ca3db39bc9f8aa601d8463db3da5
model_path=/cpfs01/shared/public/public_hdd/llmeval/model_weights/hf_hub/models--baichuan-inc--Baichuan2-13B-Chat/snapshots/c8d877c7ca596d9aeff429d43bff06e288684f45
# Launch three processes in the background
# export CUDA_VISIBLE_DEVICES=0,1
python -m fastchat.serve.controller --host 0.0.0.0 &
pids+=($!)
python -m fastchat.serve.model_worker --model-path $model_path --host 0.0.0.0 --num-gpus 1 &
pids+=($!)

# Trap the TERM signal and kill the background processes
trap 'kill ${pids[@]}' TERM

# Wait for any child processes to complete
wait