#include <cmath>
#include <iostream>
#include <Eigen/Core>

using namespace std;

template<typename T>
T mcheps(T init) {
    T eps = init;

    while (T(1.0) + eps / T(2.0) > T(1.0))
        eps /= T(2.0);
    return eps;
}

template<typename T>
T mchdwarf(T init) {
    T dwarf = init;

    while (dwarf / T(2.0) != T(0.0))
        dwarf /= T(2.0);
    return dwarf;
}

template<typename T>
T mchgiant(T init) {
    T giant = init;

    while (giant * T(2.0) < T(INFINITY))
        giant *= T(2.0);
    return giant;
}

template <typename T>
void printMachineParams(T init) {
    cout << endl;
    if (!strcmp("f", typeid(T).name()))
        cout << "Single-precision (float):" << endl;
    else if (!strcmp("d", typeid(T).name()))
        cout << "Double-precision (double):" << endl;
    else if (!strcmp("N5Eigen4halfE", typeid(T).name()))
        cout << "Half-precision (Eigen::half):" << endl;
    else
        cout << "UNKNOWN DATA TYPE" << endl;
    cout << "  Epsilon:  " << mcheps<T>(T(init))   << endl;
    cout << "  Dwarf:    " << mchdwarf<T>(T(init)) << endl;
    cout << "  Giant:    " << mchgiant<T>(T(init)) << endl;
}

int main() {
    printMachineParams<Eigen::half>(Eigen::half(1.0f));
    printMachineParams<float>(1.0f);
    printMachineParams<double>(1.0);
}
