This repository serves as a fully worked (containerised) example for the installation of the [Bin Chicken software package](https://aroneys.github.io/binchicken/) on a Linux system.

If you are simply attempting to install Bin Chicken on your own system, you should follow the instructions on the [Bin Chicken website](https://aroneys.github.io/binchicken/). Instructions there include for installing Bin Chicken via dockerhub, which produces an optimised (and pre-built) image. Use that one if the intention is to use Bin Chicken on your data.

The repository here is simply intended to show installation in a containerised environment free from the Bin Chicken authors' specific computing environment.

To process the example installation, after entering the repository directory, run the following bash script replacing `RELEASE_VERSION` with the version of Bin Chicken you wish to install (e.g. 0.12.1):

This will build/download multiple containers and log the output to `*.build.log` files. The build process will take some time, as it involves downloading and compiling a number of dependencies. Sample data is run through each as well to ensure Bin Chicken not just installs, but also runs.

```bash
bash compile_and_test_install_methods.bash RELEASE_VERSION
```

The `*.build.log` files created using this process is available in this repository.
