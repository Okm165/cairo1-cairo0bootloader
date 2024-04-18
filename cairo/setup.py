import setuptools

setuptools.setup(
    name="bootloader",
    version="0.3",
    description="This is bootloader program modification for cairo1<>cairo0 interop of original implementation done by STARKWARE link: https://github.com/starkware-libs/cairo-lang.git",
    url="#",
    author="Okm165",
    packages=setuptools.find_packages(),
    zip_safe=False,
    package_data={
        "bootloader.recursive_with_poseidon": ["*.cairo", "*/*.cairo"],
        "bootloader.recursive": ["*.cairo", "*/*.cairo"],
        "bootloader.starknet_with_keccak": ["*.cairo", "*/*.cairo"],
        "bootloader.starknet": ["*.cairo", "*/*.cairo"],
        "bootloader": ["*.cairo", "*/*.cairo"],
        "builtin_selection": ["*.cairo", "*/*.cairo"],
        "common.builtin_poseidon": ["*.cairo", "*/*.cairo"],
        "common": ["*.cairo", "*/*.cairo"],
        "lang.compiler": ["cairo.ebnf", "lib/*.cairo"],
    }
)
