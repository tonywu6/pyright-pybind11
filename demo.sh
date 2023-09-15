#!/usr/bin/env bash

set -x

git clean -fX .

conda env create --file environment.yml --prefix .venv

.venv/bin/cmake .

make

.venv/bin/stubgen --package calculator --output typings

.venv/bin/hatch build --target sdist

conda env create --file examples/environment.yml --prefix examples/.venv

./examples/.venv/bin/pip show -f calculator
./examples/.venv/bin/python examples/main.py

./examples/.venv/bin/mypy examples/main.py
./examples/.venv/bin/pyright examples/main.py
