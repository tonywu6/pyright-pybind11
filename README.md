# Pyright & pybind11

Run `./demo.sh` to see everything described below.

---

Trying to figure out how to package type information together with [pybind11]
modules.

[pybind11]: http://pybind11.readthedocs.io

This example builds and packages a `calculator` module using pybind. The package
has the following structure:

- _module_ `calculator`
  - `add(a: int, b: int) -> int`
  - _submodule_ `subtract`
    - `sub(a: int, b: int) -> int`

## Prerequisites

- Conda, to manage Python environments and dependencies. Tested using Conda
  23.5.2
- Your system should also meet the minimum requirements for building C++
  (`make`; `gcc` or `clang`, etc.)

All commands below are run from the root of this repository.

## Building the bindings

Create a new conda environment in `.venv` and activate it.

```bash
conda env create --file environment.yml --prefix .venv \
  && conda activate $(realpath .venv)
```

The environment uses Python 3.8.17, and installs the following packages:

- pybind11
- [CMake], for generating the build system
- [MyPy], for generating type stubs
- [Hatch], for packaging Python distributions

[CMake]: https://pypi.org/project/cmake/
[MyPy]: http://mypy.readthedocs.io
[Hatch]: http://hatch.pypa.io

Conda also installs the necessary Python/pybind11 headers as well as pybind's
CMake input files, which CMake will need.

Generate the build system. CMake will use [`CMakelists.txt`](./CMakeLists.txt).

```bash
cmake .
```

Your command output should look similar to the following (paths and compiler
versions may vary):

> ```
> -- The CXX compiler identification is AppleClang 14.0.3.14030022
> -- Detecting CXX compiler ABI info
> -- Detecting CXX compiler ABI info - done
> -- Check for working CXX compiler: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++ - skipped
> -- Detecting CXX compile features
> -- Detecting CXX compile features - done
> -- Found PythonInterp: ... (found suitable version "3.8.17", minimum required is "3.6")
> -- Found PythonLibs: .../.venv/lib/libpython3.8.dylib
> -- Found pybind11: .../.venv/lib/python3.8/site-packages/pybind11/include (found version "2.11.1")
> -- Configuring done (0.5s)
> -- Generating done (0.0s)
> -- Build files have been written to: ...
> ```

Build the bindings. This creates a dynamic library `calculator.*.so` in the
current directory.

```bash
make
```

Your command output should look similar to the following:

> ```
> [ 50%] Building CXX object CMakeFiles/calculator.dir/calculator.cpp.o
> [100%] Linking CXX shared module calculator.cpython-38-darwin.so
> [100%] Built target calculator
> ```

It is now possible to import the module from Python:

```py
>>> import calculator
>>> calculator.add(1, 2)
... 3
```

## Generate type stubs

We will use MyPy's [stubgen] command.

[stubgen]: https://mypy.readthedocs.io/en/stable/stubgen.html

```bash
stubgen --package calculator --output typings
```

The stubs will be written to `typings/calculator`.

> ```
> Processed 2 modules
> Generated files under typings/calculator/
> ```

## Package

We will use [hatch] to create an installable Python distribution.

```bash
hatch build --target sdist
```

Hatch reads package metadata from `pyproject.toml` and creates a [source
distribution][sdist] `calculator-0.0.0.tar.gz` in the `dist` directory. This
`.tar.gz` file will be installable with `pip`.

[sdist]:
  https://packaging.python.org/en/latest/glossary/#term-Source-Distribution-or-sdist

## Install & test

We will create a new conda environment in `examples/.venv` and activate it.

```bash
conda env create --file examples/environment.yml --prefix examples/.venv \
  && conda activate $(realpath examples/.venv)
```

This time, the environment installs [MyPy], [Pyright], and the `calculator`
package we just built.

[Pyright]: https://microsoft.github.io/pyright/

We can see what files from our package were installed:

```
pip show -f calculator
```

> ```
> Name: calculator
> ...
> Files:
>   ...
>   calculator.*.so
>   calculator/__init__.pyi
>   calculator/py.typed
>   calculator/subtract.pyi
> ```

Run the example script.

```bash
python examples/test.py
```

> ```
> 41 + 1 = 42
> 43 - 1 = 42
> ```

## Comparing MyPy and Pyright

The example script deliberately contains a typing error:

```py
# def add(a: int, b: int) -> int:
add(41, "1")
```

Type-check with MyPy:

```bash
mypy examples/main.py
```

> ```
> examples/main.py:10: error: Argument 2 to "sub" has incompatible type "str"; expected "int"  [arg-type]
> Found 1 error in 1 file (checked 1 source file)
> ```

Type-check with Pyright:

```bash
pyright examples/main.py
```

> ```
> .../examples/main.py
>   .../examples/main.py:3:6 - warning: Import "calculator.subtract" could not be resolved from source (reportMissingModuleSource)
>   .../examples/main.py:10:37 - error: Argument of type "Literal['1']" cannot be assigned to parameter "arg1" of type "int" in function "sub"
>     "Literal['1']" is incompatible with "int" (reportGeneralTypeIssues)
> 1 error, 1 warning, 0 informations
> ```

`calculator.subtract` is a submodule generated by pybind11 which has no
corresponding source on the filesystem (the entire `calculator` package is in a
single `.so` file).

Here Pyright warns about not being able to resolve it from source, but MyPy does
not. Notice also that Pyright still reports the type error correctly thanks to
our type stubs.
