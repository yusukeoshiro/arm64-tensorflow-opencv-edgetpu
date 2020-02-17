FROM ubuntu:18.04
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y
RUN apt install -y libffi-dev libbz2-dev liblzma-dev libsqlite3-dev libncurses5-dev libgdbm-dev zlib1g-dev libreadline-dev libssl-dev tk-dev build-essential libncursesw5-dev libc6-dev openssl git
RUN apt install -y wget curl

# install python
RUN apt install -y python3.7 python3.7-dev python3.7-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.7 get-pip.py
RUN apt install -y libhdf5-dev libc-ares-dev libeigen3-dev
RUN python3.7 -m pip install --upgrade cython
RUN python3.7 -m pip install h5py

# build and install opencv
ENV OPENCV_DIR=/opt/opencv
ENV LIBGPUARRAY_DIR=/opt/libgpuarray
ENV NUM_CORES=8
ENV NB_UID=1000
ENV CLONE_TAG=1.0
ENV OPENCV_VERSION=4.1.2
ENV OPENCL_ENABLED=OFF

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates wget \
    libavcodec-dev libavformat-dev libavdevice-dev libv4l-dev libjpeg-dev  liblapack-dev \
    protobuf-compiler cmake g++ unzip \
    x265 libx265-dev libnuma-dev libx264-dev libvpx-dev libfdk-aac-dev libmp3lame-dev libopus-dev \
    x264 libgtk2.0-dev pkg-config

RUN mkdir -p /src && \
    cd /src && \
    mkdir -p $OPENCV_DIR && \
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip && \
    unzip $OPENCV_VERSION.zip && \
    mv /src/opencv-$OPENCV_VERSION/ $OPENCV_DIR/ && \
    rm -rf /src/$OPENCV_VERSION.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip -O $OPENCV_VERSION-contrib.zip && \
    unzip $OPENCV_VERSION-contrib.zip && \
    mv /src/opencv_contrib-$OPENCV_VERSION $OPENCV_DIR/ && \
    rm -rf /src/$OPENCV_VERSION-contrib.zip
RUN mkdir -p $OPENCV_DIR/opencv-$OPENCV_VERSION/build && \
    cd $OPENCV_DIR/opencv-$OPENCV_VERSION/build && \
    cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_DIR/opencv_contrib-$OPENCV_VERSION/modules \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_DOCS=ON \
    -D BUILD_EXAMPLES=ON \
    -D ENABLE_PRECOMPILED_HEADERS=OFF \
    -D WITH_TBB=ON \
    -D WITH_OPENMP=ON \
    -D ENABLE_NEON=ON \
    -D OPENCV_EXTRA_EXE_LINKER_FLAGS=-latomic \
    -D PYTHON3_EXECUTABLE=$(which python3.7) \
    .. && \
    make -j $(nproc) && \
    make install && \
    ldconfig && \
    rm -rf $OPENCV_DIR;\
    apt-get autoclean -y ;\
    rm -rf /var/lib/apt/lists/*

# install tensorflow
RUN python3.7 -m pip install --upgrade setuptools
RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.0.0/tensorflow-2.0.0-cp37-none-linux_aarch64.whl
RUN python3.7 -m pip install --user tensorflow-2.0.0-cp37-none-linux_aarch64.whl
RUN apt update && apt upgrade -y
RUN apt install -y liblapack-dev gfortran

# installing scipy latest
RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install --upgrade setuptools
RUN apt-get install -y libblas-dev libopenblas-base libopenblas-dev python-dev gcc gfortran libatlas-base-dev
RUN python3.7 -m pip install numpy==1.16.4
RUN python3.7 -m pip install setuptools==45.1.0
RUN python3.7 -m pip install pybind11==2.4.3
RUN wget https://github.com/scipy/scipy/releases/download/v1.4.1/scipy-1.4.1.tar.gz
RUN tar -xzvf scipy-1.4.1.tar.gz
RUN cd scipy-1.4.1 && python3.7 setup.py install --user
RUN python3.7 -m pip install keras==2.2.5

# install edge tpu
RUN apt-get update -y
RUN apt-get install -y curl gnupg
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y libedgetpu1-std
RUN apt-get install -y python3-edgetpu

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -y \
    install sudo xvfb \
    git wget virtualenv python3-numpy python3-scipy netpbm \
    ghostscript libffi-dev libjpeg-turbo-progs \
    cmake  \
    libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev \
    python3-tk \
    libharfbuzz-dev libfribidi-dev && apt-get clean
RUN apt-get install -yq  libssl-dev openssl build-essential gcc
RUN python3.7 -m pip install --upgrade cython
RUN python3.7 -m pip install --upgrade wheel
RUN python3.7 -m pip install --upgrade Pillow
RUN python3.7 -m pip install --upgrade numpy
RUN apt-get install -yq wget libssl-dev openssl build-essential gcc zlib1g-dev
RUN apt-get install -y usbutils curl
RUN python3.7 -m pip install https://dl.google.com/coral/python/tflite_runtime-2.1.0.post1-cp37-cp37m-linux_aarch64.whl

