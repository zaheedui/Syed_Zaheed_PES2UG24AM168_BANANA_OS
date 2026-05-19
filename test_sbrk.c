#include <unistd.h>
#include <stdio.h>
int main() { printf("%p\n", sbrk(0)); return 0; }
