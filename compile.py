from setup import log_and_run

if __name__ == "__main__":
    log_and_run([
        "cairo-compile --cairo_path=./src src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo --output simple_bootloader.json --proof_mode",
    ], "Compile simple_bootloader program", cwd="cairo-lang")

    log_and_run([
        "cargo run ../../cairo1.cairo --layout all_cairo --cairo_pie_output ../../cairo1_pie.zip --append_return_values"
    ], "Compiling cairo1 pie", cwd="cairo-vm/cairo1-run")
