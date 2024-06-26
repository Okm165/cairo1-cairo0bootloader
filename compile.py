import os
from install import log_and_run

if __name__ == "__main__":
    current_dir = os.getcwd()

    log_and_run(
        [
            f"cairo-compile --cairo_path=. bootloader/contract/contract_bootloader.cairo --output {current_dir}/bootloader.json --proof_mode",
        ],
        "Compile bootloader program",
        cwd="cairo0-bootloader",
    )
