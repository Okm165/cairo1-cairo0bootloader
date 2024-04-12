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