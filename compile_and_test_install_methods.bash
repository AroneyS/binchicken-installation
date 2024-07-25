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
chmod g+rw . # Docker needs this to write to the mounted volume - diamond uses it as a temp directory
bash -c "docker pull samuelaroney/binchicken:$BINCHICKEN_VERSION && docker run -v `pwd`:/data samuelaroney/binchicken:$BINCHICKEN_VERSION coassemble --forward bc/test/data/sample_1.1.fq bc/test/data/sample_2.1.fq bc/test/data/sample_3.1.fq --reverse bc/test/data/sample_1.2.fq bc/test/data/sample_2.2.fq bc/test/data/sample_3.2.fq --genomes bc/test/data/GB_GCA_013286235.1.fna --singlem-metapackage bc/test/data/singlem_metapackage.smpkg --assemble-unmapped --unmapping-max-identity 99 --unmapping-max-alignment 90 --prodigal-meta --output test_docker" &> docker.build.log

# Test apptainer install. Too annoying to run this within a Dockerfile and simple enough here.
echo "Testing apptainer install .."
rm -f binchicken_$BINCHICKEN_VERSION.sif
bash -c 'apptainer pull docker://samuelaroney/binchicken:$BINCHICKEN_VERSION && apptainer run --cleanenv -B `pwd`:`pwd` binchicken_$BINCHICKEN_VERSION.sif coassemble --forward bc/test/data/sample_1.1.fq bc/test/data/sample_2.1.fq bc/test/data/sample_3.1.fq --reverse bc/test/data/sample_1.2.fq bc/test/data/sample_2.2.fq bc/test/data/sample_3.2.fq --genomes bc/test/data/GB_GCA_013286235.1.fna --singlem-metapackage bc/test/data/singlem_metapackage.smpkg --assemble-unmapped --unmapping-max-identity 99 --unmapping-max-alignment 90 --prodigal-meta --output test_apptainer' > apptainer.build.stdout.log 2> apptainer.build.stderr.log
