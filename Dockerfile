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
