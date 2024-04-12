# cairo1-cairo0 Bootloader

This project implements a modified version of the cairo0 bootloader to facilitate the loading and execution of cairo1 compiled pie zip files. This allows for interoperability between cairo1 and cairo0, enabling cairo1 tasks to run within the cairo0 bootloader environment.

## Overview

The primary goal of this project is to extend the functionality of the existing cairo0 bootloader to support loading and running cairo1 compiled pie zip files. By doing so, it opens up opportunities for leveraging both cairo versions within the same environment, enhancing interoperability and compatibility.

## Getting Started

To set up the project environment and run the bootloader, follow these steps:

1. **Setup Python Environment**: Ensure you have a compatible Python environment set up.
   
2. **Installation**: Run `python setup.py` to install the necessary dependencies and set up the project.

3. **Run Bootloader**: Execute `python run.py` to start the bootloader and begin loading and executing cairo1 tasks within the cairo0 environment.