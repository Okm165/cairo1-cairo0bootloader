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
        "pip install cairo-lang==0.13.1",
        "pip install aiofiles",
        "pip install cairo0-bootloader/"
    ], "Installing cairo-lang", cwd=".")

    log_and_run([
        "git clone https://github.com/starkware-libs/cairo.git",
        "cd cairo",
        "git checkout v2.6.3",
        "cd ..",
        "mv cairo/corelib/ .",
        "rm -rf cairo/",
    ], "Clone corelib", cwd=".")

    log_and_run([
        "cargo install --path .",
    ], "Install cairo-vm", cwd="cairo-vm/cairo1-run")
