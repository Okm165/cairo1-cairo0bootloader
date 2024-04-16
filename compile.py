import os
from install import log_and_run

if __name__ == "__main__":
    current_dir = os.getcwd()

    log_and_run([
        f"cairo-compile --cairo_path=. bootloader/recursive_with_poseidon/simple_bootloader.cairo --output {current_dir}/bootloader.json --proof_mode",
    ], "Compile bootloader program", cwd="cairo")

    log_and_run([
        f"cargo run {current_dir}/cairo1.cairo --layout all_cairo --cairo_pie_output {current_dir}/cairo1_pie.zip --append_return_values"
    ], "Compiling cairo1 pie", cwd="cairo-vm/cairo1-run")
