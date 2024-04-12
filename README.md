# cairo1-cairo0bootloader

This project implements a modified version of the Cairo0 bootloader to facilitate the loading and execution of Cairo1 compiled PIE zip files. This enables interoperability between Cairo1 and Cairo0, allowing Cairo1 tasks to run within the Cairo0 bootloader environment.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

1. **Setup Python Environment**: Ensure you have a compatible Python environment set up.

2. **Installation**: Run `python setup.py` to install the necessary dependencies and set up the project.

3. **Compile Cairo1**: Compile Cairo1 files into the Cairo PIE format by running `python compile.py`.

4. **Run Bootloader**: Start the bootloader by running `python run.py`, which will initiate the loading and execution of Cairo1 tasks within the Cairo0 environment.

## Work in Progress

Currently, only output building is supported. More features will be added soon!
