#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main()
{
    int num1, num2;
    char op[6];

    // loop to get <op> <num1> <num2>
    while (scanf("%5s %d %d", op, &num1, &num2) == 3)
    {
        char libname[32];
        void *handle;

        // build the lib<op>.so string
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // load the library into memory
        handle = dlopen(libname, RTLD_LAZY);

        if (!handle)
        {
            // failed to load, just skip it
            continue;
        }

        // define the function pointer shape
        typedef int (*op_func_t)(int, int);

        // reset error state then look for the symbol
        dlerror();
        op_func_t op_function = (op_func_t)dlsym(handle, op);

        // if we found the function, run it
        if (op_function)
        {
            int result = op_function(num1, num2);
            printf("%d\n", result);
        }

        dlclose(handle);
    }

    return 0;
}