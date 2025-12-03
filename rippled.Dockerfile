FROM ubuntu:18.04

RUN export LANGUAGE=C.UTF-8; export LANG=C.UTF-8; export LC_ALL=C.UTF-8; export DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install git pkg-config protobuf-compiler libprotobuf-dev libssl-dev wget build-essential && \
	apt-get update && \
	apt-get -y install g++-8 gcc-8 && \
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7 && \
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8
	
COPY cmake-3.25.1 /cmake-3.25.1
COPY boost_1_75_0 /boost_1_75_0

RUN cd cmake-3.25.1 && \
	./bootstrap && \
	make -j 8 && \
	make install && \
	cd .. && \
	cd boost_1_75_0 && \
	./bootstrap.sh && \
	./b2 -j 8 && \
	export BOOST_ROOT=/boost_1_75_0

COPY rippled /rippled

RUN export BOOST_ROOT=/boost_1_75_0 && \
	cd rippled && \
	sed -i '319,321d' src/ripple/overlay/impl/Handshake.cpp && \
	mkdir my_build && \
	cd my_build && \
	cmake .. && \
	cmake --build . -- -j 8

FROM ubuntu:18.04
COPY --from=0 /rippled/my_build/rippled /rippled/my_build/rippled

ENTRYPOINT [ "/rippled/my_build/rippled" ]
