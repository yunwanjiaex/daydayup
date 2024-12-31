# 修改命令行参数
1. 修改以下代码的命令行参数,使通过 `ps` 看到的和程序实际接收的不一样
    ```c
    #include <stdio.h>

    int main(int argc, char **argv) {
        printf("argc=%d\n", argc);
        for (int i = 0; i < argc; i++)
            printf("argv[%d]=%s\n", i, argv[i]);
        getchar();
        return 0;
    }
    ```
2. 在不修改程序文件的前提下,通过劫持 `__libc_start_main` ,给 `main` 函数传递新的参数地址,编译 `gcc -fPIC -shared -ldl -o libinject.so inject.c`
    ```c
    #include <dlfcn.h>
    #include <stdlib.h>
    #include <string.h>
    int (*main_ori)(int, char **, char **);

    static int main_new(int argc, char **argv, char **env) {
        char **argv_bak = (char **)calloc(argc, sizeof(char *));
        for (int i = 0; i < argc; i++) {
            argv_bak[i] = (char *)calloc(strlen(argv[i]) + 1, sizeof(char));
            strcpy(argv_bak[i], argv[i]); // 将 argv 保存起来然后修改
            if (i == 0) // 设置命令名为 6666
                strncpy(argv[i], "6666", strlen(argv[i]));
            else // 清空所有命令行参数
                strncpy(argv[i], "", strlen(argv[i]));
            argv[i] = argv_bak[i];
        }
        return main_ori(argc, argv, env);
    }

    int __libc_start_main(int (*main)(int, char **, char **), int argc, char **argv,
                          void (*init)(void), void (*fini)(void),
                          void (*_fini)(void), void(*stack_end)) {
        int (*__start_ori)(int (*main)(int, char **, char **), int argc,
                           char **argv, void (*init)(void), void (*fini)(void),
                           void (*_fini)(void), void(*stack_end)) =
            dlsym(RTLD_NEXT, "__libc_start_main"); // 寻找真正的 __libc_start_main 函数
        main_ori = main; // 保存 main 的地址以供 main_new 调用
        return __start_ori(main_new, argc, argv, init, fini, _fini, stack_end);
    }
    ```
3. 运行`LD_PRELOAD=./libinject.so ./test 11 22 33 44`