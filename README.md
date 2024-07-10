# Containers 
Since using the CSCS cluster often requires starting a compute node with a container as defined with an `--environment` flag in the `srun` call, in this repo we track the Dockerfiles and toml files used to define and link to the Docker images used for different use cases.

Hopefully, keeping a repository of the Dockerfiles/etc. for each image helps (a) keep provenance of the Dockerfiles, so that unexpected changes don't sneak up on us/we have reproducible results, and (b) we have one place in which we can reference and leverage the Dockerfiles/setups while building new ones.

## Cloning
Run `git clone --recurse-submodules -j8 git@github.com:swiss-ai/containers.git` (make sure you have the `--recurse-submodules` because some images may require copying over another git repo saved as a submodule in this one).


## The Basics
Each subdirectory contains at least (a) a `Dockerfile` and (b) a `.toml` file.
The Dockerfile is used to define the Docker image. The `.toml` file is used to point to the image which is used to create a newly constructed container for a new job on a compute node.

### How to build a Docker image?
0. (Preliminary) Allocate and enter a compute node.
    * Run `salloc -t240` to allocate compute, and note the jobid for that allocation.
    * Run `srun --overlap --jobid <JOBID> --pty bash` (get the JOBID from previous step) to enter the compute node.
1. Build the Docker image with `podman build -t <IMAGE_NAME> .`
    * Run `cd /store/swissai/a08/containers/<IMAGE_DIR>` to go to the dir containing the Dockerfile.
    * Run `podman build -t <IMAGE_NAME> .`
2. Compress the Docker image into a squash file with `enroot import -x mount -o <IMAGE_NAME>.sqsh podman://<IMAGE_NAME>`
3. Run `exit` to go back to login node

## How to run a container with this image?
4. From a login node, create a container based on the Docker image we just created.
    * For an interactive job: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/<IMAGE_DIR>/<IMAGE_DIR>.toml --container-workdir=$PWD --pty bash` (note: we point to the `.toml` file, which itself sets the image to be hardcoded as 4m_image.sqsh).
    * For a one-time run: run `srun --overlap --jobid <JOBID> --environment=/store/swissai/a08/containers/<IMAGE_DIR>/<IMAGE_DIR>.toml --container-workdir=$PWD <YOUR COMMAND HERE>`
    * For something with sbatch: TODO (but probably something like this https://github.com/swiss-ai/pretrain/blob/add-llama3-large-config/slurm/run_llama_large_baseline.sh)
