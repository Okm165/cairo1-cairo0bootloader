import subprocess


def log_and_run(commands, description, cwd=None):
    from colorama import Fore, Style

    full_command = " && ".join(commands)
    try:
        print(f"{Fore.YELLOW}Starting: {description}...{Style.RESET_ALL}")
        print(f"{Fore.CYAN}Command: {full_command}{Style.RESET_ALL}")
        result = subprocess.run(
            full_command, shell=True, check=True, cwd=cwd, text=True
        )
        print(f"{Fore.GREEN}Success: {description} completed!\n{Style.RESET_ALL}")
    except subprocess.CalledProcessError as e:
        print(
            f"{Fore.RED}Error running command '{full_command}': {e}\n{Style.RESET_ALL}"
        )


if __name__ == "__main__":
    subprocess.run("pip install colorama", shell=True, check=True, text=True)

    log_and_run(
        [
            "pip install cairo-lang==0.13.1",
            "pip install aiofiles",
            "pip install cairo0-bootloader/",
        ],
        "Installing cairo-lang",
        cwd=".",
    )
