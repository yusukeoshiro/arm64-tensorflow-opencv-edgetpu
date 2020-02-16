FROM ubuntu:18.04
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y
RUN apt install -y libffi-dev libbz2-dev liblzma-dev libsqlite3-dev libncurses5-dev libgdbm-dev zlib1g-dev libreadline-dev libssl-dev tk-dev build-essential libncursesw5-dev libc6-dev openssl git
RUN apt install -y wget

# install python
RUN wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz && tar -xf Python-3.7.0.tar.xz 
RUN cd Python-3.7.0 && ./configure && make && make altinstall
RUN alias python3=python3.7
RUN apt install -y curl
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.7  get-pip.py
RUN apt install -y python-h5py libhdf5-dev libc-ares-dev libeigen3-dev
RUN python3.7 -m pip install --upgrade cython
RUN python3.7 -m pip install h5py


# install tensorflow
RUN python3.7 -m pip install --upgrade setuptools
RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.0.0/tensorflow-2.0.0-cp37-none-linux_armv7l.whl
RUN python3.7 -m pip install --user tensorflow-2.0.0-cp37-none-linux_armv7l.whl
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

# install opencv
ENV OPENCV_DIR=/opt/opencv 
ENV LIBGPUARRAY_DIR=/opt/libgpuarray 
ENV NUM_CORES=8 
ENV NB_UID=1000 
ENV CLONE_TAG=1.0 
ENV OPENCV_VERSION=4.1.2 
ENV OPENCL_ENABLED=OFF 

# build and install opencv
RUN apt install -y --no-install-recommends build-essential ca-certificates wget libavcodec-dev libavformat-dev libavdevice-dev libv4l-dev libjpeg-dev  liblapack-dev protobuf-compiler cmake g++ unzip x265 libx265-dev libnuma-dev libx264-dev libvpx-dev libfdk-aac-dev libmp3lame-dev libopus-dev x264
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
    rm -rf /src/$OPENCV_VERSION-contrib.zip && \
    mkdir -p $OPENCV_DIR/opencv-$OPENCV_VERSION/build
RUN cd $OPENCV_DIR/opencv-$OPENCV_VERSION/build && \
    cmake \
    -D PYTHON_EXECUTABLE=$(which python3.7) \
    -D WITH_CUDA=OFF \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D PYTHON_DEFAULT_EXECUTABLE=$(which python3.7) \
    -D PYTHON_INCLUDE_DIR=${python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())"} \
    -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_DIR/opencv_contrib-$OPENCV_VERSION/modules \
    -D WITH_TBB=ON \
    -D WITH_PTHREADS_PF=ON \
    -D WITH_OPENNI=OFF \
    -D WITH_OPENNI2=ON \
    -D WITH_EIGEN=ON \
    -D BUILD_DOCS=ON \
    -D BUILD_TESTS=ON \
    -D BUILD_PERF_TESTS=ON \
    -D BUILD_EXAMPLES=ON \
    -D WITH_OPENCL=$OPENCL_ENABLED \
    -D USE_GStreamer=ON \
    -D WITH_GDAL=ON \
    -D WITH_CSTRIPES=ON \
    -D ENABLE_FAST_MATH=1 \
    -D WITH_OPENGL=ON \
    -D WITH_QT=OFF \
    -D WITH_IPP=ON \
    -D WITH_FFMPEG=ON \
    -D CMAKE_SHARED_LINKER_FLAGS=-Wl,-Bsymbolic \
    -D WITH_V4L=ON .. && \
    make -j $(nproc) && \
    make install && \
    ldconfig && \ 
    rm -rf $OPENCV_DIR;\
    apt-get autoclean -y ;\
    rm -rf /var/lib/apt/lists/*

