#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int global_init = 42;          // .data - initialized global
int global_uninit;             // .bss  - uninitialized global (zeroed)
const char *rodata = "hello";  // .rodata - read-only constant

int main(void) {
    int stack_var = 7;
    int *heap_var = malloc(64);

    printf("%-20s %p\n", "Text  (main):",    (void *)main);
    printf("%-20s %p\n", "Rodata:",          (void *)rodata);
    printf("%-20s %p\n", "Data  (init):",    (void *)&global_init);
    printf("%-20s %p\n", "BSS   (uninit):",  (void *)&global_uninit);
    printf("%-20s %p\n", "Heap  (malloc):",  (void *)heap_var);
    printf("%-20s %p\n", "Stack (local):",   (void *)&stack_var);

    // Print the gap between heap and stack
    printf("\nHeap-to-Stack gap: %lu MB\n",
           ((unsigned long)&stack_var - (unsigned long)heap_var) / (1024*1024));

    printf("\n--- /proc/self/maps (filtered) ---\n");
    char cmd[128];
    snprintf(cmd, sizeof(cmd),
        "cat /proc/%d/maps | grep -E 'heap|stack|layout'", getpid());
    system(cmd);

    free(heap_var);
    return 0;
}