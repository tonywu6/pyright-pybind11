#include <pybind11/pybind11.h>

namespace py = pybind11;

int add(int i, int j) { return i + j; }

int sub(int i, int j) { return i - j; }

PYBIND11_MODULE(calculator, m) {
  m.doc() = "Calculator";

  m.def("add", &add, "A function that adds two numbers");

  py::module submodule = m.def_submodule("subtract");

  submodule.def("sub", &sub, "A function that subtracts two numbers");
}
