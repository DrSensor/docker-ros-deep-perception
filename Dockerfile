FROM cimenx/docker-ros-deep-perception
MAINTAINER Fahmi Akbar Wildana <fahmi.akbar.w@mail.ugm.ac.id>

# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO indigo

RUN apt-get update \
&& apt-get install -y \
        software-properties-common build-essential \
        wget curl git pkg-config

RUN add-apt-repository ppa:v-launchpad-jochen-sprickerhof-de/pcl
RUN wget http://packages.ros.org/ros.key -O - | apt-key add -
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-get update && apt-get install -y \
    cmake \
    python3-pip python3-dev python3.4-venv \
&& pip3 install --upgrade pip

RUN pip3 install --no-cache-dir --upgrade wheel numpy cython

# Intall ROS INDIGO
RUN apt-get install -y \
        ros-$ROS_DISTRO-ros-base \
        ros-$ROS_DISTRO-image-pipeline \
        ros-$ROS_DISTRO-laser-pipeline
&& apt-get purge -y \
    ros-indigo-image-view \
    ros-indigo-cv-bridge \
    ros-indigo-vision-opencv \
    xbitmaps \
    xorg-sgml-doctools \
    xterm \
    xtrans-d \
    qt4-qmake qtchooser qtcore4-l10n \
    libopencv* \
    x11* \
    libqt* \
    libvtk* \
    libx11*


RUN pip3 install --no-cache-dir rosdep rosinstall vcstools
RUN rosdep init \
&& rosdep fix-permissions \
&& rosdep update \
&& echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
SHELL ["/bin/bash", "-c", "source /opt/ros/indigo/setup.bash"]

RUN rm /opt/ros/$(rosversion -d)/lib/python2.7/dist-packages/cv2.so

SHELL ["/bin/bash", "-c", "export PYTHONPATH=/opt/ros/$(rosversion -d)/lib/python2.7/dist-packages/:/usr/local/lib/python3.$(python3 -V|awk -F \. {'print $2'}))/dist-packages/"] 

# TODO : Opencv 3.2 lib atlas/openblas/mkl
RUN apt-get install -y \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev
RUN wget https://github.com/Itseez/opencv/archive/3.2.0.zip \
&& unzip 3.2.0.zip \
&& mkdir /opencv-3.2.0/cmake_binary \
&& cd /opencv-3.2.0/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
        -DBUILD_opencv_java=OFF \
        -DWITH_CUDA=OFF \
        -DENABLE_AVX=ON \
        -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON \
        -DWITH_IPP=ON \
        -DWITH_TBB=ON \
        -DWITH_EIGEN=ON \
        -DWITH_V4L=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
        -DPYTHON_EXECUTABLE=$(which python3) \
        -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /3.2.0.zip \
&& rm -r /opencv-3.2.0

RUN pip3 install --no-cache-dir \
    https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.0.1-cp34-cp34m-linux_x86_64.whl

RUN rm -rf /var/lib/apt/lists/*
