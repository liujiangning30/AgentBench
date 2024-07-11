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
WORKER_CPU=${WORKER_CPU:-20}
WORKER_MEMORY=${WORKER_MEMORY:-400Gi}
SHELL_ENV=${SHELL_ENV:-"zsh"}
WORKER_IMAGE=${WORKER_IMAGE:-"pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:cu121-ubuntu22-lkk-0513-rc6"}

NODE_NAMES=pjlab-lingjun-073
num_nodes=1
mysql_password=password
mysql_port=3306

task_kg="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,kg-dev 20 kg-std 20,1000"
task_avalon="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,avalon-dev-naive 20 avalon-dev-single 20,7000"
task_os="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,os-dev 20 os-std 20,7000"
task_webshop="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-webshop,cd /root/workspace,webshop-dev 10 webshop-std 10,3000"
task_alfworld="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-alfworld,cd /root/workspace,alfworld-dev_20_alfworld-std_20,4000"
task_m2w="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-mind2web,cd /root/workspace,m2w-dev 20 m2w-std 20,5000"
task_cg="pjlab-wulan-acr-registry-vpc.cn-wulanchabu.cr.aliyuncs.com/pjlab-eflops/liukuikun:agentbench-card-game,cd /root/workspace,cg-dev 20 cg-std 20,6000"
task_ltp="docker.io/longinyu/agentbench-ltp,cd /root/workspace,ltp-dev 20 ltp-std 20"
task_db="docker.io/liujiangning30/agentbench-mysql:latest,cd /cpfs01/user/liujiangning/work/AgentBench && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,dbbench-dev 20 dbbench-std 20"

# export MYSQL_ROOT_PASSWORD=$mysql_password && export MYSQL_TCP_PORT=$mysql_port && 
tasks=$task_webshop
COMMAND="{work_env} && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && python -m src.start_task -a -s {start} -p {port}"

update_command() {
    local cmd="$1"
    shift
    for arg; do
        key=$(echo "$arg" | cut -d= -f1)
        value=$(echo "$arg" | cut -d= -f2)
        cmd=${cmd//\{$key\}/$value}
    done
    echo "$cmd"
}

# --node_names ${NODE_NAMES} \
# --worker-gpu $WORKER_GPU \
# --conda-env ${CONDA_ENV}"

# set -- $i
IFS=',' read image work_env start port <<< "${tasks}"
JOB_NAME="agentbenchv2-server-$start"
start="${start//_/ }"
echo $start
TASK_CMD=$(update_command "$COMMAND" work_env="$work_env" start="$start" port="$port")

${DLC_PATH} submit pytorchjob --config ${DLC_CONFIG_PATH} \
--name $JOB_NAME \
--resource_id ${RESOURCE_ID} \
--data_sources ${DATA_SOURCES} \
--workspace_id $WORKERSPACE_ID \
--workers $WORKER_COUNT \
--worker_cpu $WORKER_CPU \
--worker_gpu ${WORKER_GPU} \
--worker_memory $WORKER_MEMORY \
--worker_image ${image} \
--worker_shared_memory 200Gi \
--priority ${PRIORITY} \
--command  "${TASK_CMD}"