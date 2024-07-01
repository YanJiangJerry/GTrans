#!/bin/bash

# 初始化一个用于保存结果的数组
declare -A acc0
declare -A acc1

# 遍历所有种子、模型和数据集
for s in {0..9}
do
    for m in GCN SAGE GAT GPR
    do
        for dataset in ogb-arxiv twitch-e cora amazon-photo fb100 elliptic
        do
            # 确保数据集的文件夹存在
            mkdir -p results/structure/$dataset

            # 定义CSV文件的头部
            if [ ! -f results/structure/$dataset/acc0.csv ]; then
                echo "model,0,1,2,3,4,5,6,7,8,9" > results/structure/$dataset/acc0.csv
            fi
            if [ ! -f results/structure/$dataset/acc1.csv ]; then
                echo "model,0,1,2,3,4,5,6,7,8,9" > results/structure/$dataset/acc1.csv
            fi

            # 运行Python脚本并保存输出到临时文件
            output=$(python train_both_all.py --seed=$s --gpu_id=0 --model=$m --tune=0 --dataset=$dataset --debug=1 --s=1)

            # 提取最后两行
            last_two_lines=$(echo "$output" | tail -n 2)

            # 提取最后两行的具体值
            acc0_value=$(echo "$last_two_lines" | sed -n '1p')
            acc1_value=$(echo "$last_two_lines" | sed -n '2p')

            # 保存结果到数组中
            acc0[$dataset,$m,$s]=$acc0_value
            acc1[$dataset,$m,$s]=$acc1_value
        done
    done
done

# 将结果写入CSV文件
for dataset in ogb-arxiv twitch-e cora amazon-photo fb100 elliptic
do
    for m in GCN SAGE GAT GPR
    do
        # 初始化每行的内容，以模型名开头
        acc0_line="$m"
        acc1_line="$m"
        for s in {0..9}
        do
            # 将对应的结果添加到行内容中
            acc0_line="$acc0_line,${acc0[$dataset,$m,$s]}"
            acc1_line="$acc1_line,${acc1[$dataset,$m,$s]}"
        done
        # 将行内容写入CSV文件
        echo "$acc0_line" >> results/structure/$dataset/acc0.csv
        echo "$acc1_line" >> results/structure/$dataset/acc1.csv
    done
done
