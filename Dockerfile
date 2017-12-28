FROM nvcr.io/nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
ENV DEBIAN_FRONTEND "noninteractive"

RUN apt-get update -y
RUN apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" dist-upgrade


RUN apt-get install -y --no-install-recommends \
  dconf-tools \
  curl wget \
  tar zip unzip zlib1g-dev bzip2 libbz2-dev \
  openssl libssl-dev \
  zsh vim screen tree htop \
  net-tools lynx iftop traceroute \
  git apt-transport-https software-properties-common ppa-purge apt-utils ca-certificates \
  build-essential binutils cmake pkg-config libtool autoconf automake autogen \
  sudo

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
  gcc-6 g++-6 gcc-7 g++-7 gdb
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20

RUN apt-get install -y --no-install-recommends \
  libboost-all-dev \
  libtbb2 libtbb-dev \
  libatlas-base-dev libopenblas-base libopenblas-dev \
  libeigen3-dev liblapacke-dev \
  graphviz

RUN apt-get install -y python3-numpy python3-dev python3-pip python3-wheel python3-setuptools

WORKDIR /opt
RUN git clone https://github.com/tensorflow/tensorflow 
WORKDIR /opt/tensorflow
RUN git checkout r1.4
RUN apt-get install -y openjdk-8-jdk
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt-get update -y
RUN apt-get install -y bazel
RUN apt-get install -y libcupti-dev 
# https://github.com/tensorflow/tensorflow/issues/7843
# https://gist.github.com/PatWie/0c915d5be59a518f934392219ca65c3d
ENV TD_ROOT=/opt/tensorflow
ENV PYTHON_BIN_PATH=/usr/bin/python3
ENV PYTHON_LIB_PATH=/usr/local/lib/python3.5/dist-packages
ENV TF_NEED_JEMALLOC=1
ENV TF_ENABLE_XLA=1
ENV TF_NEED_GCP=0
ENV TF_NEED_S3=0
ENV TF_NEED_GDR=0
ENV TF_NEED_VERBS=0
ENV TF_NEED_HDFS=0
ENV TF_NEED_MPI=0
ENV TF_NEED_OPENCL=0
ENV TF_NEED_OPENCL_SYCL=0
ENV TF_NEED_COMPUTECPP=0
ENV TF_NEED_CUDA=1
ENV CUDA_TOOLKIT_PATH=/usr/local/cuda
ENV CUDNN_INSTALL_PATH=/usr/local/cuda
ENV TF_CUDA_VERSION=9.0
ENV TF_CUDNN_VERSION=7.0.5
ENV TF_CUDA_COMPUTE_CAPABILITIES=7.0
ENV TF_CUDA_CLANG=0
ENV TF_NEED_MKL=0
#ENV TF_DOWNLOAD_MKL=1
ENV GCC_HOST_COMPILER_PATH=/usr/bin/gcc
ENV CC_OPT_FLAGS=-march=native
RUN ./configure
RUN bazel build --config=opt --config=cuda --config=mkl --incompatible_load_argument_is_label=false //tensorflow/tools/pip_package:build_pip_package
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
RUN pip3 install /tmp/tensorflow_pkg/tensorflow-1.4.0-py2-none-any.whl

#RUN apt-get install -f
#RUN apt-get update -y
#RUN apt-get upgrade -y
#RUN apt-get dist-upgrade -y
#RUN apt-get clean
#RUN apt-get autoremove -y
#RUN apt-get update -y
#RUN apt-get upgrade -y
#RUN apt-get autoremove -y
#RUN apt-get autoclean -y
#RUN rm -rf /var/lib/apt/lists/*



