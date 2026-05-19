#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define POOL_SIZE (4 * 1024 * 1024)  // 4 MB pool
#define BLOCK_SIZE 4096              // 4 KB blocks
#define NUM_BLOCKS (POOL_SIZE / BLOCK_SIZE)  // 1024 blocks

int main(void) {
    char *pool = malloc(POOL_SIZE);
    if (!pool) { perror("malloc"); return 1; }

    // Track which blocks are "allocated"
    int allocated[NUM_BLOCKS];
    memset(allocated, 1, sizeof(allocated));  // all blocks "in use"

    printf("Pool: %d blocks of %d bytes = %d KB total\n",
           NUM_BLOCKS, BLOCK_SIZE, POOL_SIZE / 1024);

    // Free every OTHER block → creates a checkerboard: free-used-free-used-...
    int freed = 0;
    for (int i = 0; i < NUM_BLOCKS; i += 2) {
        allocated[i] = 0;
        freed++;
    }
    printf("Freed every other block: %d free blocks (%d KB free)\n",
           freed, freed * BLOCK_SIZE / 1024);

    // Now try to find a contiguous run of 128 blocks (512 KB)
    int need = 128;
    int found = 0;
    int run = 0;
    for (int i = 0; i < NUM_BLOCKS; i++) {
        if (!allocated[i]) {
            run++;
            if (run >= need) { found = 1; break; }
        } else {
            run = 0;
        }
    }

    printf("\nLooking for %d contiguous free blocks (%d KB)...\n",
           need, need * BLOCK_SIZE / 1024);
    if (found)
        printf("SUCCESS - found contiguous run\n");
    else
        printf("FAILED - %d KB free total, but largest contiguous run < %d KB\n",
               freed * BLOCK_SIZE / 1024, need * BLOCK_SIZE / 1024);
    printf("This is EXTERNAL FRAGMENTATION.\n");

    // Now show internal fragmentation
    printf("\n--- Internal Fragmentation ---\n");
    // malloc(1) actually reserves way more than 1 byte
    char *tiny = malloc(1);
    char *tiny2 = malloc(1);
    printf("malloc(1) at %p, malloc(1) at %p\n", tiny, tiny2);
    printf("Distance between them: %ld bytes (wasted: %ld bytes per alloc)\n",
           (long)(tiny2 - tiny), (long)(tiny2 - tiny) - 1);

    free(tiny);
    free(tiny2);
    free(pool);
    return 0;
}