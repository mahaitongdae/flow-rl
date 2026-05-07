# Specify which GPUs to use
GPUS=(0 1 2 3 4 5 6 7)  # Modify this array to specify which GPUs to use
SEEDS=(0 1 2 3)
NEGATIVE_SLOPES=(0.01 0.1)
NUM_EACH_GPU=2

PARALLEL=$((NUM_EACH_GPU * ${#GPUS[@]}))

TASKS=(
    # "Ant-v5"
    # "Walker2d-v5"
    "HalfCheetah-v5"
    # "Hopper-v5"
    # "Humanoid-v5"
    # "InvertedDoublePendulum-v5"
    # "InvertedPendulum-v5"
    # "Pusher-v5"
    # "Reacher-v5"
    "Swimmer-v5"
    # "HumanoidStandup-v5"
)

SHARED_ARGS=(
    "algo=dpmd_leakyrelu_reverse_linear"
    "log.tag=negative_slope"
    "log.entity=haitongma-harvard-university"
    "log.project=simpo-neurips"
)


run_task() {
    task=$1
    seed=$2
    slot=$3
    negative_slope=$4
    num_gpus=${#GPUS[@]}
    device_idx=$((slot % num_gpus))
    device=${GPUS[$device_idx]}
    echo "Running $task $seed negative_slope=$negative_slope on GPU $device"
    export CUDA_VISIBLE_DEVICES=$device
    export XLA_PYTHON_CLIENT_PREALLOCATE="false"
    command="python3 examples/online/main_mujoco_offpolicy.py task=$task seed=$seed algo.negative_slope=$negative_slope ${SHARED_ARGS[@]}"
    if [ -n "$DRY_RUN" ]; then
        echo $command
    else
        echo $command
        $command
    fi
}

. env_parallel.bash
if [ -n "$DRY_RUN" ]; then
    env_parallel -P${PARALLEL} run_task {1} {2} {%} {3} ::: ${TASKS[@]} ::: ${SEEDS[@]} ::: ${NEGATIVE_SLOPES[@]}
else
    env_parallel --bar --results log/parallel/$name -P${PARALLEL} run_task {1} {2} {%} {3} ::: ${TASKS[@]} ::: ${SEEDS[@]} ::: ${NEGATIVE_SLOPES[@]}
fi
