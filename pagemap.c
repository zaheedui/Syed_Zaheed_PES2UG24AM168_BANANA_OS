#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>

static void query_pagemap(const char *label, void *vaddr) {
    uint64_t data;
    long page_size = sysconf(_SC_PAGESIZE);
    unsigned long vpn = (unsigned long)vaddr / page_size;

    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) { perror("open pagemap"); return; }

    // Each pagemap entry is 8 bytes; seek to the entry for this VPN
    if (lseek(fd, vpn * 8, SEEK_SET) == (off_t)-1) {
        perror("lseek"); close(fd); return;
    }
    if (read(fd, &data, 8) != 8) {
        perror("read"); close(fd); return;
    }
    close(fd);

    int present  = (data >> 63) & 1;   // bit 63: page in RAM?
    int swapped  = (data >> 62) & 1;   // bit 62: page on swap?
    uint64_t pfn = data & 0x7FFFFFFFFFFFFF;  // bits 0-54: frame number

    printf("  %-14s VA=%p  present=%d  swapped=%d", label, vaddr, present, swapped);
    if (present)
        printf("  PFN=0x%lx  →  PA=0x%lx",
               (unsigned long)pfn, (unsigned long)(pfn * page_size));
    else
        printf("  (no physical frame assigned)");
    printf("\n");
}

int main(void) {
    char *p = malloc(4096 * 4);  // allocate 4 pages

    printf("=== Before touching any page ===\n");
    query_pagemap("page[0]:", p);
    query_pagemap("page[1]:", p + 4096);
    query_pagemap("page[2]:", p + 8192);

    // Touch only pages 0 and 1
    p[0] = 'X';
    p[4096] = 'Y';

    printf("\n=== After touching pages 0 and 1 ===\n");
    query_pagemap("page[0]:", p);
    query_pagemap("page[1]:", p + 4096);
    query_pagemap("page[2]:", p + 8192);  // never touched

    free(p);
    return 0;
}