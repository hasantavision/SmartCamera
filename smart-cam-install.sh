#!/bin/bash

set -e

echo "** Install requirements"

folder=${HOME}/src
mkdir -p $folder

sudo apt-get update

sudo apt-get install -y build-essential make cmake cmake-curses-gui git g++ pkg-config curl libfreetype6-dev
sudo apt-get install -y libcanberra-gtk-module libcanberra-gtk3-module protobuf-compiler libprotoc-dev python3-dev python3-pip
sudo apt-get install -y autoconf libtool
sudo pip3 install -U pip cython testresources setuptools==49.6.0 wheel
sudo pip3 install numpy==1.19.4 matplotlib==3.2.2

pushd $folder

if [ ! -f protobuf-python-${version}.zip ]; then
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${version}/protobuf-python-${version}.zip
fi
if [ ! -f protoc-${version}-linux-aarch_64.zip ]; then
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${version}/protoc-${version}-linux-aarch_64.zip
fi

unzip protobuf-python-${version}.zip
unzip protoc-${version}-linux-aarch_64.zip -d protoc-${version}
sudo cp protoc-${version}/bin/protoc /usr/local/bin/protoc

cd protobuf-${version}/
./autogen.sh
./configure --prefix=/usr/local
make -j$(nproc)

sudo make install
sudo ldconfig

sudo pip3 uninstall -y protobuf
cd python/
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
python3 setup.py bdist_wheel --cpp_implementation

sudo pip3 install dist/*.whl

popd

sudo apt-get update
sudo apt-get install libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
sudo pip3 install -U --no-deps numpy==1.19.4 future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 pybind11 pkgconfig packaging keras==2.7.0
sudo env H5PY_SETUP_REQUIRES=0 pip3 install -U h5py==3.1.0
sudo pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v461 tensorflow

sudo apt-get install python3-pyqt5
sudo pip3 install onnx==1.11.0
wget onnxruntime
sudo pip3 install onnxruntime
sudo pip3 install tf2onnx

pushd ${HOME}/Documents
git clone github_smartcam
pushd SmartCam
python3 main.py
