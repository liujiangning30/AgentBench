#!/bin/bash
export HOME=$HOME
DLC_PATH="/cpfs01/shared/public/dlc"
DLC_CONFIG_PATH="${HOME}/.dlc/config"
WORKSPACE_ID='ws18sdj44um64lxi'
NODE_NAMES=pjlab-lingjun-073

num_nodes=1
mysql_password=password
mysql_port=3306

task_kg="master0:5000/eflops/liujiangning:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,kg-dev 20 kg-std 20"
task_avalon="master0:5000/eflops/liujiangning:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,avalon-dev-naive 20 avalon-dev-single 20"
task_os="master0:5000/eflops/liujiangning:agentbench-alfworld,cd /root/workspace && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,os-dev 20 os-std 20"
task_webshop="master0:5000/eflops/liujiangning:agentbench-webshop-rc1,cd /root/workspace,webshop-dev 10 webshop-std 10"
task_alfworld="master0:5000/eflops/liujiangning:agentbench-alfworld,cd /root/workspace,alfworld-dev 20 alfworld-std 20"
task_m2w="master0:5000/eflops/liujiangning:agentbench-mind2web-rc1,cd /root/workspace,m2w-dev 20 m2w-std 20"
task_cg="master0:5000/eflops/liujiangning:agentbench-card-game,cd /root/workspace,cg-dev 20 cg-std 20"
task_ltp="master0:5000/eflops/liujiangning:agentbench-ltp,cd /root/workspace,ltp-dev 20 ltp-std 20"
task_db="docker.io/liujiangning30/agentbench-mysql:latest,cd /cpfs01/user/liujiangning/work/AgentBench && . /cpfs01/user/liujiangning/miniconda3/bin/activate && conda activate agent-bench,dbbench-dev 20 dbbench-std 20"

# export MYSQL_ROOT_PASSWORD=$mysql_password && export MYSQL_TCP_PORT=$mysql_port && 
tasks=$task_os
COMMAND="{work_env} && python -c 'import socket; print(socket.gethostbyname(socket.gethostname()))' && python -m src.start_task -a -s {start}"

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

for i in  "${tasks[@]}"
do
    # set -- $i
    IFS=',' read image work_env start <<< "${i}"
    JOB_NAME="agentbenchv2-server-$start"
    DLC_CMD=$(update_command "$COMMAND" work_env="$work_env" start="$start")

    ${DLC_PATH} --config ${DLC_CONFIG_PATH}  create job \
    --name $JOB_NAME \
    --kind TFJob \
    --worker_count $num_nodes \
    --worker_cpu 20 \
    --worker_memory 400 \
    --worker_image $image \
    --workspace_id ${WORKSPACE_ID} \
    --worker_shared_memory 400 \
    --node_names ${NODE_NAMES} \
    --command  "${DLC_CMD}"
done
