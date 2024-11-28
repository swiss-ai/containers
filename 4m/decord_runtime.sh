#!/bin/bash
# Build decord at runtime
cd /workspace/decord/build
cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release
make
cd ../python
python3 setup.py install
