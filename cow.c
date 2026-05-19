#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define MB (1024 * 1024)
#define ALLOC_MB 128

static long get_minor_faults(void) {
    FILE *f = fopen("/proc/self/stat", "r");
    if (!f) return -1;
    char line[4096];
    if (!fgets(line, sizeof(line), f)) { fclose(f); return -1; }
    fclose(f);
    char *p = strrchr(line, ')');
    if (!p) return -1;
    p += 2;
    long minflt;
    if (sscanf(p, "%*s %*s %*s %*s %*s %*s %*s %ld", &minflt) != 1) return -1;
    return minflt;
}

int main(void) {
    char *region = malloc(ALLOC_MB * MB);
    memset(region, 'P', ALLOC_MB * MB);

    printf("Parent: allocated and touched %d MB (%d pages)\n",
           ALLOC_MB, ALLOC_MB * 256);

    pid_t pid = fork();

    if (pid == 0) {
        long faults_start = get_minor_faults();
        char sink = 0;
        for (int i = 0; i < ALLOC_MB * MB; i += 4096)
            sink += region[i];
        long faults_after_read = get_minor_faults();

        printf("\nChild READ-ONLY scan:\n");
        printf("  Page faults: %ld  (should be ~0, pages are shared)\n",
               faults_after_read - faults_start);

        long faults_before_write = get_minor_faults();
        memset(region, 'C', ALLOC_MB * MB);
        long faults_after_write = get_minor_faults();

        printf("\nChild WRITE pass:\n");
        printf("  Page faults: %ld\n",
               faults_after_write - faults_before_write);
        printf("  Expected:    %d  (one COW fault per page)\n",
               ALLOC_MB * 256);

        free(region);
        exit(0);
    }

    wait(NULL);
    free(region);
    return 0;
}