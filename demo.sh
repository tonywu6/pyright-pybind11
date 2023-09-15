#!/usr/bin/env bash

set -x

git clean -fX .

conda env create --file environment.yml --prefix .venv

.venv/bin/cmake .

make

.venv/bin/stubgen --package calculator --output typings

conda env create --file example/environment.yml --prefix example/.venv

./example/.venv/bin/pip show -f calculator
./example/.venv/bin/python example/main.py

./example/.venv/bin/mypy example/main.py
./example/.venv/bin/pyright example/main.py
