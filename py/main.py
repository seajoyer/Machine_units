#!/usr/bin/env python3

import warnings
import numpy as np

warnings.filterwarnings("ignore", category=RuntimeWarning)

def mcheps(T, init):
    eps = init

    while T(1.0) + eps / T(2.0) > T(1.0):
        eps /= T(2.0)
    return eps

def mchdwarf(T, init):
    dwarf = init

    while dwarf / T(2.0) != T(0.0):
        dwarf /= T(2.0)
    return dwarf

def mchgiant(T, init):
    giant = init

    while not np.isinf(giant * T(2.0)):
        giant *= T(2.0)
    return giant

print("-" * 25)
for T in [np.float16, np.float32, np.float64]:
    print(f"Data type: {np.dtype(T).name}")
    print(f"  Epsilon: {mcheps(T, T(1.0))}")
    print(f"  Dwarf:   {mchdwarf(T, T(1.0))}")
    print(f"  Giant:   {mchgiant(T, T(1.0))}\n")
