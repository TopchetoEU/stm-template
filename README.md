# Setting up the CubeMX project

Here, you are given the skeleton of a project, with the exception of the CubeMX project. This is a short guide how to set it up.

For preexisting projects:
1. Go to `File > Load Project` and select your project file
2. Go to `File > Save Project As` and save to the `stfiles` folder in this project

For new projects:
1. Go to `File > New Project`
2. Select the correct board
2. Go to `File > Save Project As` and save to the `stfiles` folder in this project

Setting up the actual project:
1. Go to `Project manager` tab
2. In the `Project` side tab, set `Toolchain` to `Makefile`
3. In the `Code Generator` side tab:
	1. Click on `Add necessary files as reference in the toolchain project configuration file`
	2. Toggle `Generate peripheral initialization as a pair of '.c/.h' files per peripheral`
	3. Toggle `Keep user code when regenerating`
	4. Write `scripts/postgen.sh` in the `After code generation` field
5. Click "Generate code"
6. For some reason, CubeMX generates a linker script for an older toolchain. Go to the .ld file in `stfiles` and remove all occurences of `(READONLY)`
	TODO: Is this correct?
7. Go into stfiles/Makefile and comment out everything, except the lines between `C_SOURCES = ` and `PREFIX = `, between `CPU = ` and `C_INCLUDES = `, and the single lines `LDSCRIPT =` and `TARGET = `. In result, you should be left with a Makefile that declares these variables:
	- TARGET
	- C_SOURCES
	- ASM_SOURCES
	- ASMM_SOURCES
	- PREFIX
	- CPU
	- MCU
	- C_DEFS
	- AS_INCLUDES
	- C_INCLUDES
	- LDSCRIPT

# Setting up the main project

Go to the `conf.mk` file and set `TARGET` to your project name. This will dictate the output names in `bin`. All sources in the specified directories will be walked *recursively*.

# Adding a dependency

You can add a dependency to another project by adding its source dir and header dir like this:

```Makefile
SRC_DIRS += dep/my-dep/src
INC_DIRS += dep/my-dep/inc
```

Now, all .c and .h files from there will be included in the build process. By convention, dependencies are added to a `dep` folder, using git's submodules.

# Debugging in VSCode

1. Install the "Cortex Debug" extension
2. In your `launch.json` file, add a "Cortex Debug" preset
3. After the default preset has appeared, edit `executable` to point to the actual .elf file and set `servertype` to stlink

Pro tip: use the clangd extension, and generate a `compile_commands.json` file, using `bear -- make -B`. The experience is leaps and bounds better than microsoft's server.

# Integrating in an existing project

This is applicable only for existing CubeMX/CubeIDE projects with an established code base.

- Add this repo as an origin to your project (`git remote add template this-repo-url`)
- Merge whichever branch you prefer into your project (`git merge template/main --allow-unrelated-histories` or `git merge template/with-boson --allow-unrelated-histories`)
- Copy your .ioc file into `stfiles`
- Follow the above steps
- Move all user files from `Core/Src` into `src` and `Core/Inc` into `inc` (important: do not copy CubeMX-generated files)
- Copy all user code from `main.c` whereever it belongs (init code in main() goes in setup(), loop code goes in loop(), private and local variables go in the main.c file, above all functions). User code in `Error_Handler` should go in the `_error` function in `syscall.c` instead.

# Requirements

For now, this works only on linux, so if you're on windows, use WSL.

To see a list of required binaries to be installed into the PATH, run `make requirements`.
