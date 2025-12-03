#!/bin/bash

set -e

# 如果不存在cmake-3.25.1
if [ ! -d "cmake-3.25.1" ]; then
	wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1.tar.gz
	tar xvzf cmake-3.25.1.tar.gz
fi

# 如果不存在rippled
if [ ! -d "rippled" ]; then
	git clone https://github.com/xrplf/rippled.git
	cd rippled
	git checkout tags/1.7.2
	cd ..
fi

# 如果不存在boost_1_75_0
if [ ! -d "boost_1_75_0" ]; then
	wget https://sourceforge.net/projects/boost/files/boost/1.75.0/boost_1_75_0.tar.gz/download -O boost_1_75_0.tar.gz
	tar xvzf boost_1_75_0.tar.gz
fi

docker build -t ripple -f rippled.Dockerfile .
DOCKER_BUILDKIT=1 docker build -t byzzfuzz .


docker rm -f tmp
# 1) 先从镜像创建一个临时容器
docker create --name tmp byzzfuzz
# 2) 从临时容器里拷贝 toxiproxy-server 到当前目录
docker cp tmp:/home/toxiproxy-server ./toxiproxy-server       
# 3) 删除临时容器
docker rm -f tmp

chmod +x ./toxiproxy-server

cargo build -p rust-ripple-p2p
# cargo run -p rust-ripple-p2p -- --toxiproxy-path ./toxiproxy-server