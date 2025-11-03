#!/bin/bash

# 函数：检查一个数是否为素数
is_prime() {
    local num=$1
    # 小于 2 的数不是素数
    if [ $num -lt 2 ]; then
        return 1 # 返回 1 表示不是素数
    fi
    # 检查从 2 到 sqrt(num) 的数
    for ((i=2; i*i<=num; i++)); do
        if ((num % i == 0)); then
            return 1 # 返回 1 表示不是素数
        fi
    done
    return 0 # 返回 0 表示是素数
}

# 主程序
read -p "请输入一个整数: " n
if is_prime "$n"; then
    echo "$n 是素数"
else
    echo "$n 不是素数"
fi