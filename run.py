from setup import log_and_run

if __name__ == "__main__":
    log_and_run([
        "cairo-run \
        --program=simple_bootloader.json \
        --layout=recursive_with_poseidon \
        --program_input=simple_bootloader_input.json \
        --air_public_input=simple_bootloader_public_input.json \
        --air_private_input=simple_bootloader_private_input.json \
        --trace_file=simple_bootloader_trace.json \
        --memory_file=simple_bootloader_memory.json \
        --print_output \
        --proof_mode \
        --print_info"
    ], "Running cairo1 pie in cairo0 bootloader", cwd="cairo-lang")

    # log_and_run([
    #     "cargo run ../../cairo1.cairo \
    #     --layout recursive_large_output \
    #     --trace_file cairo1/program.trace \
    #     --memory_file cairo1/program.memory \
    #     --air_public_input cairo1/air_public_input.json \
    #     --air_private_input cairo1/air_private_input.json \
    #     --proof_mode"
    # ], "Running cairo1 vm", cwd="cairo-vm/cairo1-run")

    # log_and_run([
    #     "cargo run ../../cairo1.cairo \
    #     --layout recursive_large_output \
    #     --print_output"
    # ], "Running cairo1 vm", cwd="cairo-vm/cairo1-run")
