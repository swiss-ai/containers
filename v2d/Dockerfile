# Boilerplate Swiss AI stuff
# This image does NOT face SSL certificate issues when pip installing
FROM nvcr.io/nvidia/pytorch:24.05-py3

# Avoid interactive prompts
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
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# install decord
RUN git clone --recursive https://github.com/dmlc/decord
# Go to fixed commit (last commit we tested this on) and then build it.
RUN cd decord \
    && git checkout d2e56190286ae394032a8141885f76d5372bd44b \
    && mkdir build && cd build \
    # && cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release \
    # Use this if we don't want GPU acceleration
    && cmake .. -DUSE_CUDA=0 -DCMAKE_BUILD_TYPE=Release \ 
    && make

# setup python bindings for decord
RUN cd decord/python && python3 setup.py install
RUN python -m pip install --upgrade pip

# Install v2d library
# Better to COPY than git clone because git clone is unaware when the repo changes. We want a static/reproducible thing independent of upstream repo changes.
COPY video2dataset /workspace/video2dataset
RUN cd video2dataset && pip install -e .
RUN pip install opencv-python==4.8.0.74

# Activate the virtualenv when starting the container.
CMD ["/bin/bash", "-c", "source /opt/venv/bin/activate && exec /bin/bash"]

# Possible issue: torch.cuda.is_available() returns False. Do we need this to use cuda?

##############
# HOW TO USE #
##############
# 0. Allocate and enter a compute node
#   a. Run `salloc -t240` to allocate compute, and note the jobid for that allocation.
#   b. Run `srun --overlap --jobid <JOBID> --pty bash` (get the JOBID from previous step).

# TO BUILD THE IMAGE AND SQUASHFILE
# 1. Build the Docker image with `podman build -t v2d_image .`
#   a. Run `cd /store/swissai/a08/containers/v2d` to go to the dir containing the Dockerfile.
#   b. Run `podman build -t v2d_image .`
# 2. Compress the Docker image into a squash file with `enroot import -x mount -o v2d_image.sqsh podman://v2d_image`
# 3. Run `exit` to go back to login node

# TO RUN A CONTAINER WITH THIS IMAGE
# 4. From login node, create a container based on the Docker image we just created
#   a. For an interactive job: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/v2d/v2d.toml --container-workdir=$PWD --pty bash`
#       Note: we point to the .toml file, which itself sets the image to be hardcoded as 4m_image.sqsh.
#   b. For a one-time run: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/v2d/v2d.toml --container-workdir=$PWD <YOUR COMMAND HERE>`
#   c. For something with sbatch: TODO (but probably something like this https://github.com/swiss-ai/pretrain/blob/add-llama3-large-config/slurm/run_llama_large_baseline.sh)
#   d. To run the video2dataset command: