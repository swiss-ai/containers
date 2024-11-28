# Boilerplate Swiss AI stuff
FROM nvcr.io/nvidia/pytorch:24.01-py3
 
ENV DEBIAN_FRONTEND=noninteractive

# Install extra apt tools
RUN apt-get update && apt-get install -y software-properties-common

# Install decord specific packages
RUN apt-get install -y build-essential python3-dev python3-setuptools make cmake
RUN apt-get install -y ffmpeg libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev

# Install pip, virtualenv, and git
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    git

# Create and activate a virtual environment
# ENV VIRTUAL_ENV=/opt/venv
# RUN python3 -m venv $VIRTUAL_ENV
# ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /workspace
RUN git clone https://github.com/swiss-ai/ml-4m.git
WORKDIR /workspace/ml-4m

# Checkout a version of ml-4m which we know is stable for installing the library. REMOVE THIS if you want to install from the updated ml-4m repo.
# RUN git checkout b8d794cd132e942582b837ffd7ddc6bf204692a3
RUN pip install -e .

# install specific packages for yolo and fixing opencv
RUN pip install ultralytics peft opencv-python==4.8.0.74

# # install decord
WORKDIR /workspace
ENV NVIDIA_DRIVER_CAPABILITIES=all
# # RUN ln -s /usr/lib/x86_64-linux-gnu/libnvcuvid.so.1 /usr/local/cuda/lib64/libnvcuvid.so
RUN ln -s /usr/lib/aarch64-linux-gnu/libnvcuvid.so.1 /usr/local/cuda/lib64/libnvcuvid.so
RUN git clone --recursive https://github.com/dmlc/decord
# Go to fixed commit (last commit we tested this on) and then build it.
RUN cd decord \
    && git checkout d2e56190286ae394032a8141885f76d5372bd44b \
    && mkdir build
# Attempt to install decord from source (fails with "Cannot find libnvcuvid" error)
# RUN cd build && cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release \
#     # Use this if we don't want GPU acceleration
#     # && cmake .. -DUSE_CUDA=0 -DCMAKE_BUILD_TYPE=Release \ 
#     && make
# # setup python bindings for decord
# RUN cd decord/python && python3 setup.py install

# Copy script to install decord at container runtime.
COPY decord_runtime.sh /workspace/decord_runtime.sh
RUN chmod +x /workspace/decord_runtime.sh
# ENTRYPOINT ["source", "/workspace/decord_runtime.sh"]

# Activate the virtualenv when starting the container.
# CMD ["/bin/bash", "-c", "source /opt/venv/bin/activate && exec /bin/bash"]

### FIX of opencv issue where opencv version wasnt using ffmpeg -> couldn't open video
#RUN pip uninstall opencv -y
#RUN pip uninstall opencv-python -y
#RUN pip uninstall opencv-python-headless -y
#RUN pip install opencv-python --user
#RUN pip install opencv-python-headless --user

##############
# HOW TO USE #
##############
# 0. Allocate and enter a compute node
#   a. Run `salloc -t240` to allocate compute, and note the jobid for that allocation.
#   b. Run `srun --overlap --jobid <JOBID> --pty bash` (get the JOBID from previous step).

# TO BUILD THE IMAGE AND SQUASHFILE
# 1. Build the Docker image with `podman build -t 4m_image .`
#   a. Run `cd /store/swissai/a08/containers/4m` to go to the dir containing the Dockerfile.
#   b. Run `podman build -t 4m_image .`
# 2. Compress the Docker image into a squash file with `enroot import -x mount -o 4m_image.sqsh podman://4m_image`
# 3. Run `exit` to go back to login node

# TO RUN A CONTAINER WITH THIS IMAGE
# 4. From login node, create a container based on the Docker image we just created
#   a. For an interactive job: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/4m/4m.toml --container-workdir=$PWD --pty bash`
#       Note: we point to the .toml file, which itself sets the image to be hardcoded as 4m_image.sqsh.
#   b. For a one-time run: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/4m/4m.toml --container-workdir=$PWD <YOUR COMMAND HERE>`
#   c. For something with sbatch: TODO (but probably something like this https://github.com/swiss-ai/pretrain/blob/add-llama3-large-config/slurm/run_llama_large_baseline.sh)
# 5. Run `source /workspace/decord_runtime.sh` to install GPU-accelerated decord at runtime.