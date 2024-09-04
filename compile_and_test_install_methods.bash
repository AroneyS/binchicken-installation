#!/bin/bash

set -e

export BINCHICKEN_VERSION=$1
echo "Testing Bin Chicken version $BINCHICKEN_VERSION"

# Test conda install
echo "Testing conda install .."
sed "s/BINCHICKEN_VERSION/$BINCHICKEN_VERSION/g" Dockerfile.conda.in > Dockerfile.conda
docker build --no-cache --progress=plain -f Dockerfile.conda . &> conda.build.log

# Test PyPI install
echo "Testing PyPI install .."
sed "s/BINCHICKEN_VERSION/$BINCHICKEN_VERSION/g" Dockerfile.pypi.in > Dockerfile.pypi
docker build --no-cache --progress=plain -f Dockerfile.pypi . &> pypi.build.log

# Test docker install. Easier here than within a Dockerfile
echo "Testing docker install .."
git clone https://github.com/AroneyS/binchicken bc && cd bc && git checkout vBINCHICKEN_VERSION && cd ..
chmod g+rw . # Docker needs this to write to the mounted volume - diamond uses it as a temp directory
rm -rf test_docker
bash -c "docker pull samuelaroney/binchicken:$BINCHICKEN_VERSION && docker run -v $(pwd):/data samuelaroney/binchicken:$BINCHICKEN_VERSION coassemble --forward bc/test/data/sample_1.1.fq bc/test/data/sample_2.1.fq bc/test/data/sample_3.1.fq --reverse bc/test/data/sample_1.2.fq bc/test/data/sample_2.2.fq bc/test/data/sample_3.2.fq --genomes bc/test/data/GB_GCA_013286235.1.fna --assemble-unmapped --unmapping-max-identity 99 --unmapping-max-alignment 90 --prodigal-meta --output /data/test_docker" &> docker.build.log

# Test apptainer install. Too annoying to run this within a Dockerfile and simple enough here.
echo "Testing apptainer install .."
rm -f binchicken_$BINCHICKEN_VERSION.sif
bash -c 'singularity pull docker://samuelaroney/binchicken:$BINCHICKEN_VERSION && singularity run --cleanenv -B $(pwd) binchicken_$BINCHICKEN_VERSION.sif coassemble --forward $(pwd)/bc/test/data/sample_1.1.fq $(pwd)/bc/test/data/sample_2.1.fq $(pwd)/bc/test/data/sample_3.1.fq --reverse $(pwd)/bc/test/data/sample_1.2.fq $(pwd)/bc/test/data/sample_2.2.fq $(pwd)/bc/test/data/sample_3.2.fq --genomes $(pwd)/bc/test/data/GB_GCA_013286235.1.fna --assemble-unmapped --unmapping-max-identity 99 --unmapping-max-alignment 90 --prodigal-meta --output $(pwd)/test_singularity' > singularity.build.stdout.log 2> singularity.build.stderr.log
