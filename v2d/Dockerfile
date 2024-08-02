# Boilerplate Swiss AI stuff
# This image does NOT face SSL certificate issues when pip installing
FROM nvcr.io/nvidia/pytorch:24.01-py3

# Avoid interactive promptssx
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

RUN apt-get install -y libnvidia-decode-525-server

# # Create and activate a virtual environment
# ENV VIRTUAL_ENV=/opt/venv
# RUN python3 -m venv $VIRTUAL_ENV
# ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install torch and torchaudio - the builtin torch does not have torchaudio so we have to try to install versions which are compatible with each other.
# unfortunately this still fails with v2d - 
# RuntimeError: Failed to import transformers.models.blip_2.modeling_blip_2 because of the following error (look up to see its traceback):
# Failed to import transformers.generation.utils because of the following error (look up to see its traceback):
#    /usr/local/lib/python3.10/dist-packages/transformer_engine_extensions.cpython-310-aarch64-linux-gnu.so: undefined symbol: _ZN2at4_ops5zeros4callEN3c108ArrayRefINS2_6SymIntEEENS2_8optionalINS2_10ScalarTypeEEENS6_INS2_6LayoutEEENS6_INS2_6DeviceEEENS6_IbEE
RUN pip3 install --index-url https://download.pytorch.org/whl/nightly/cu124 torch torchaudio torchvision

# install decord
ENV NVIDIA_DRIVER_CAPABILITIES=all
# RUN ln -s /usr/lib/x86_64-linux-gnu/libnvcuvid.so.1 /usr/local/cuda/lib64/libnvcuvid.so
RUN ln -s /usr/lib/aarch64-linux-gnu/libnvcuvid.so.1 /usr/local/cuda/lib64/libnvcuvid.so
RUN git clone --recursive https://github.com/dmlc/decord
# Go to fixed commit (last commit we tested this on) and then build it.
RUN cd decord \
    && git checkout d2e56190286ae394032a8141885f76d5372bd44b \
    && mkdir build && cd build \
    && cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release \
    # Use this if we don't want GPU acceleration
    # && cmake .. -DUSE_CUDA=0 -DCMAKE_BUILD_TYPE=Release \ 
    && make

# setup python bindings for decord
RUN cd decord/python && python3 setup.py install
RUN python -m pip install --upgrade pip

# Install v2d library
# Better to COPY than git clone because git clone is unaware when the repo changes. We want a static/reproducible thing independent of upstream repo changes.
COPY video2dataset /workspace/video2dataset
RUN cd video2dataset && pip install --upgrade --upgrade-strategy only-if-needed -e .
RUN pip install opencv-python==4.8.0.74

RUN pip uninstall transformer-engine -y

# # Activate the virtualenv when starting the container.
# CMD ["/bin/bash", "-c", "source /opt/venv/bin/activate && exec /bin/bash"]

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
    # srun --overlap --jobid <JOBID> --reservation=todi --environment=/store/swissai/a08/containers/v2d/v2d.toml --container-workdir=$PWD --pty bash
    # video2dataset --url_list="/store/swissai/a08/data/OLD/raw/howto100m/v2d/howto100m_v2d_0_5000.csv" --config="/store/swissai/a08/containers/v2d/video2dataset/swiss_ai/configs/download_todi_cut.yaml" --output_folder="/store/swissai/a08/data/raw/howto100m/v2d_5000" --input_format="csv" --output_format="webdataset" --url_col="video_link" --encode_formats="{'video': 'mp4', 'audio':'m4a'}"
    # video2dataset --url_list="/store/swissai/a08/data/raw/howto100m/v2d_5000/0000000{000..229}.tar" --config="/store/swissai/a08/containers/v2d/video2dataset/swiss_ai/configs/whisperx.yaml" --output_folder="/store/swissai/a08/data/raw/howto100m/v2d_5000/whisperx" --input_format="webdataset" --output_format="webdataset" --encode_formats="{'video': 'mp4', 'audio':'m4a'}" --stage="whisper"