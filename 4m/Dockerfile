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
RUN git checkout b8d794cd132e942582b837ffd7ddc6bf204692a3
RUN pip install -e .

# install specific packages for yolo and fixing opencv
RUN pip install ultralytics peft opencv-python==4.8.0.74

# Activate the virtualenv when starting the container.
# CMD ["/bin/bash", "-c", "source /opt/venv/bin/activate && exec /bin/bash"]

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