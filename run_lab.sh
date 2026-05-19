#!/bin/bash

# ============================================================================
# Memory Management Lab - Complete Command Script
# ============================================================================
# Run this script in: /home/munireddy/Desktop/Murali/OS-U3-BANANA-main
# Prerequisites: sudo apt update && sudo apt install -y gcc build-essential linux-tools-common linux-tools-$(uname -r) sysstat strace
# ============================================================================

echo "Starting Memory Management Lab..."
echo "========================================="

# ============================================================================
# SECTION 0: Get Your Bearings - Baseline Memory Info
# ============================================================================
echo ""
echo "SECTION 0: Baseline Memory"
echo "========================================="

# Display RAM and swap in MB
echo "Running: free -m"
free -m
echo ""

# Show system page size in bytes (typically 4096)
echo "Running: getconf PAGESIZE"
getconf PAGESIZE
echo ""

# Calculate number of physical page frames
echo "Running: awk '/MemTotal/ {print \$2 / 4}' /proc/meminfo"
awk '/MemTotal/ {print $2 / 4}' /proc/meminfo
echo ""

# ============================================================================
# SECTION 1: The Virtual Address Space
# ============================================================================
echo "SECTION 1: Virtual Address Space"
echo "========================================="

# Compile layout.c without PIE to get fixed memory addresses
echo "Running: gcc -o layout layout.c -no-pie"
gcc -o layout layout.c -no-pie

# Run layout - prints address locations of code, data, heap, stack
echo "Running: ./layout"
./layout
echo ""

# ============================================================================
# SECTION 2: Demand Paging
# ============================================================================
echo "SECTION 2: Demand Paging"
echo "========================================="

# Compile demand paging demo
echo "Running: gcc -O0 -o demand demand.c"
gcc -O0 -o demand demand.c

# Run demand - shows VmSize vs VmRSS before/after malloc and touching pages
echo "Running: ./demand"
./demand
echo ""

# ============================================================================
# SECTION 3: Page Tables & Pagemap
# ============================================================================
echo "SECTION 3: Page Tables"
echo "========================================="

# Compile pagemap program
echo "Running: gcc -O0 -o pagemap pagemap.c"
gcc -O0 -o pagemap pagemap.c

# Run pagemap with sudo (requires /proc/self/pagemap access)
echo "Running: sudo ./pagemap"
sudo ./pagemap
echo ""

# ============================================================================
# SECTION 4: Copy-on-Write (COW)
# ============================================================================
echo "SECTION 4: Copy-on-Write"
echo "========================================="

# Compile COW demo
echo "Running: gcc -O0 -o cow cow.c"
gcc -O0 -o cow cow.c

# Run COW - fork child, read-only scan (shared), then write (COW faults)
echo "Running: ./cow"
./cow
echo ""

# ============================================================================
# SECTION 5: Shared Libraries
# ============================================================================
echo "SECTION 5: Shared Libraries"
echo "========================================="

# Compile hello.c dynamically (links to shared libc)
echo "Running: gcc -o hello_dynamic hello.c"
gcc -o hello_dynamic hello.c

# Compile hello.c statically (includes libc in binary)
echo "Running: gcc -static -o hello_static hello.c"
gcc -static -o hello_static hello.c

# Compare sizes of dynamic vs static binaries
echo "Running: ls -lh hello_dynamic hello_static"
ls -lh hello_dynamic hello_static
echo ""

# Show dynamic library loading debug output
echo "Running: LD_DEBUG=libs ./hello_dynamic 2>&1 | head -30"
LD_DEBUG=libs ./hello_dynamic 2>&1 | head -30
echo ""

# List shared libraries for bash
echo "Running: ldd /bin/bash"
ldd /bin/bash
echo ""

# Count processes sharing libc
echo "Running: sudo grep 'libc' /proc/*/maps 2>/dev/null | awk -F/ '{print \$3}' | sort -un | wc -l"
sudo grep 'libc' /proc/*/maps 2>/dev/null | awk -F/ '{print $3}' | sort -un | wc -l
echo ""

# Show libc mappings with permissions in current process
echo "Running: cat /proc/self/maps | grep libc"
cat /proc/self/maps | grep libc
echo ""

# ============================================================================
# SECTION 6: Under the Hood - malloc Syscalls (brk vs mmap)
# ============================================================================
echo "SECTION 6: malloc Syscalls"
echo "========================================="

# Compile allocation trace
echo "Running: gcc -O0 -o alloc_trace alloc_trace.c"
gcc -O0 -o alloc_trace alloc_trace.c

# Run alloc_trace - shows break changes for small/large mallocs
echo "Running: ./alloc_trace"
./alloc_trace
echo ""

# Trace brk() and mmap() syscalls
echo "Running: strace -e brk,mmap ./alloc_trace 2>&1 | tail -20"
strace -e brk,mmap ./alloc_trace 2>&1 | tail -20
echo ""

# ============================================================================
# SECTION 7: Fragmentation
# ============================================================================
echo "SECTION 7: Fragmentation"
echo "========================================="

# Compile fragmentation demo
echo "Running: gcc -O0 -o fragment fragment.c"
gcc -O0 -o fragment fragment.c

# Run fragment - shows external and internal fragmentation
echo "Running: ./fragment"
./fragment
echo ""

# ============================================================================
# SECTION 8: Swapping
# ============================================================================
echo "SECTION 8: Swapping"
echo "========================================="

# Check swap configuration
echo "Running: swapon --show"
swapon --show
echo ""

# Compile swap pressure test
echo "Running: gcc -O0 -o swap_pressure swap_pressure.c"
gcc -O0 -o swap_pressure swap_pressure.c

# Run swap_pressure - allocates 80% RAM, touches pages, re-reads (shows VmRSS/VmSwap)
echo "Running: ./swap_pressure (this will take ~10 seconds)"
./swap_pressure
echo ""

# ============================================================================
# SECTION 9: Page Replacement & Working Set
# ============================================================================
echo "SECTION 9: Page Replacement"
echo "========================================="

# Compile working set demo
echo "Running: gcc -O0 -o working_set working_set.c"
gcc -O0 -o working_set working_set.c

# Test with small working set (64 MB) - should be fast
echo "Running: ./working_set 512 64 5"
./working_set 512 64 5
echo ""

# Test with large working set (512 MB) - should be slower
echo "Running: ./working_set 512 512 5"
./working_set 512 512 5
echo ""

# Show active/inactive page counts
echo "Running: grep -E 'Active|Inactive' /proc/meminfo"
grep -E 'Active|Inactive' /proc/meminfo
echo ""

# ============================================================================
# SECTION 10: Thrashing
# ============================================================================
echo "SECTION 10: Thrashing"
echo "========================================="

# Compile thrashing test
echo "Running: gcc -O0 -o thrash thrash.c"
gcc -O0 -o thrash thrash.c

# Run thrash - allocates increasing % of RAM with random access
# Shows throughput drop at thrashing point (WARNING: may slow system for 30-60s)
echo "Running: ./thrash (this will take ~20 seconds - system may slow down)"
./thrash
echo ""

# ============================================================================
# CLEANUP
# ============================================================================
echo "CLEANUP"
echo "========================================="

# Remove all binaries and source files
echo "Running: rm -f layout layout_pie demand pagemap cow hello_dynamic hello_static alloc_trace fragment swap_pressure working_set thrash *.c"
rm -f layout layout_pie demand pagemap cow hello_dynamic hello_static alloc_trace fragment swap_pressure working_set thrash *.c

echo ""
echo "========================================="
echo "Memory Management Lab Complete!"
echo "========================================="
