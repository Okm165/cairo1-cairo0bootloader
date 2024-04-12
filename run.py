import subprocess
from colorama import Fore, Style

def log_and_run(commands, description, cwd=None):
    full_command = " && ".join(commands)
    try:
        print(f"{Fore.YELLOW}Starting: {description}...{Style.RESET_ALL}")
        print(f"{Fore.CYAN}Command: {full_command}{Style.RESET_ALL}")
        result = subprocess.run(full_command, shell=True, check=True, cwd=cwd, text=True)
        print(f"{Fore.GREEN}Success: {description} completed!\n{Style.RESET_ALL}")
    except subprocess.CalledProcessError as e:
        print(f"{Fore.RED}Error running command '{full_command}': {e}\n{Style.RESET_ALL}")

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
], "Running recursion step", cwd="cairo-lang")