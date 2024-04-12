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

if __name__ == "__main__":
    log_and_run([
        "pip install --upgrade pip", 
        "zip -r cairo-lang-0.13.1.zip cairo-lang-0.13.1", 
        "pip install cairo-lang-0.13.1.zip",
        "pip install aiofiles"
    ], "Installing cairo-lang", cwd="cairo-lang")

    log_and_run([
        "cairo-compile --cairo_path=./src src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo --output simple_bootloader.json --proof_mode",
    ], "Compile simple_bootloader program", cwd="cairo-lang")

    log_and_run([
        "git clone https://github.com/lambdaclass/cairo-vm.git",
    ], "Clone cairo-vm", cwd=".")

    log_and_run([
        "make deps",
    ], "Prepare cairo-vm", cwd="cairo-vm/cairo1-run")