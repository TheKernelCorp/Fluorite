![Fluorite Logo][logo_url]

A highly experimental OS written in [Crystal][crystal_home].   
Chat with us on [Discord][discord]!

## Contributing

If you want to help, talk to us on our [Discord][discord] server.  
We'll be happy to work with you.

## Building on Linux/WSL

- Get an [i686-elf gcc cross-compiler][cross_cc] going
- Install the [latest Crystal compiler][crystal_compiler]
- Install the [latest version of SCons][scons]
- Run `scons` to build
- Run `scons test` to run Runtime tests.
- Run `scons --qemu-curses` to build and run qemu

## Building via Docker

- Build the Docker image: `docker build -t fluorite-builder .`
- Use the image to compile the code: `docker run --rm -v $(pwd):/build -t fluorite-builder`
- Any arguments to `scons` can be passed in like this:
  `docker run --rm -v $(pwd):/build -t fluorite-builder -- test` <- runs `scons test` within the container.

- all build artifacts will be placed in the `./build` directory

## Troubleshooting

**`xorriso : FAILURE : Cannot find path '/efi.img' in loaded ISO image`** `or`   
**`grub-mkrescue: error: ``mformat`` invocation failed`**:

- On Arch: `sudo pacman -Sy mtools`
- On Debian/Ubuntu/WSL: `sudo apt-get install mtools`
- On Fedora/RedHat/CentOS: `sudo yum install mtools`

[logo_url]: logo.png
[cross_cc]: http://wiki.osdev.org/GCC_Cross-Compiler
[crystal_home]: https://crystal-lang.org
[crystal_compiler]: https://crystal-lang.org/docs/installation/index.html
[discord]: https://discord.gg/nmESdX8
[scons]: http://scons.org/
