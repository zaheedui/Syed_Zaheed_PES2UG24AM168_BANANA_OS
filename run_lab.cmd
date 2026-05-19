@echo off
REM ============================================================================
REM Memory Management Lab - Complete Command Script (Windows)
REM ============================================================================
REM NOTE: This script is for reference. The actual lab runs on Linux/Ubuntu.
REM If using WSL (Windows Subsystem for Linux), use run_lab.sh instead.
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo Starting Memory Management Lab...
echo =========================================

REM ============================================================================
REM SECTION 0: Get Your Bearings
REM ============================================================================
echo.
echo SECTION 0: Baseline Memory
echo =========================================

echo Running: free -m
wsl free -m
echo.

echo Running: getconf PAGESIZE
wsl getconf PAGESIZE
echo.

echo Running: awk '/MemTotal/ {print $2 / 4}' /proc/meminfo
wsl awk "/MemTotal/ {print $2 / 4}" /proc/meminfo
echo.

REM ============================================================================
REM SECTION 1: Virtual Address Space
REM ============================================================================
echo.
echo SECTION 1: Virtual Address Space
echo =========================================

echo Running: gcc -o layout layout.c -no-pie
wsl gcc -o layout layout.c -no-pie

echo Running: ./layout
wsl ./layout
echo.

REM ============================================================================
REM SECTION 2: Demand Paging
REM ============================================================================
echo.
echo SECTION 2: Demand Paging
echo =========================================

echo Running: gcc -O0 -o demand demand.c
wsl gcc -O0 -o demand demand.c

echo Running: ./demand
wsl ./demand
echo.

REM ============================================================================
REM SECTION 3: Page Tables
REM ============================================================================
echo.
echo SECTION 3: Page Tables
echo =========================================

echo Running: gcc -O0 -o pagemap pagemap.c
wsl gcc -O0 -o pagemap pagemap.c

echo Running: sudo ./pagemap
wsl sudo ./pagemap
echo.

REM ============================================================================
REM SECTION 4: Copy-on-Write
REM ============================================================================
echo.
echo SECTION 4: Copy-on-Write
echo =========================================

echo Running: gcc -O0 -o cow cow.c
wsl gcc -O0 -o cow cow.c

echo Running: ./cow
wsl ./cow
echo.

REM ============================================================================
REM SECTION 5: Shared Libraries
REM ============================================================================
echo.
echo SECTION 5: Shared Libraries
echo =========================================

echo Running: gcc -o hello_dynamic hello.c
wsl gcc -o hello_dynamic hello.c

echo Running: gcc -static -o hello_static hello.c
wsl gcc -static -o hello_static hello.c

echo Running: ls -lh hello_dynamic hello_static
wsl ls -lh hello_dynamic hello_static
echo.

echo Running: LD_DEBUG=libs ./hello_dynamic 2^&1 ^| head -30
wsl LD_DEBUG=libs ./hello_dynamic 2>&1 ^| head -30
echo.

echo Running: ldd /bin/bash
wsl ldd /bin/bash
echo.

echo Running: sudo grep 'libc' /proc/*/maps 2^>/dev/null ^| awk -F/ '{print $3}' ^| sort -un ^| wc -l
wsl sudo grep 'libc' /proc/*/maps 2>/dev/null ^| awk -F/ '{print $3}' ^| sort -un ^| wc -l
echo.

REM ============================================================================
REM SECTION 6: malloc Syscalls
REM ============================================================================
echo.
echo SECTION 6: malloc Syscalls
echo =========================================

echo Running: gcc -O0 -o alloc_trace alloc_trace.c
wsl gcc -O0 -o alloc_trace alloc_trace.c

echo Running: ./alloc_trace
wsl ./alloc_trace
echo.

echo Running: strace -e brk,mmap ./alloc_trace 2^&1 ^| tail -20
wsl strace -e brk,mmap ./alloc_trace 2>&1 ^| tail -20
echo.

REM ============================================================================
REM SECTION 7: Fragmentation
REM ============================================================================
echo.
echo SECTION 7: Fragmentation
echo =========================================

echo Running: gcc -O0 -o fragment fragment.c
wsl gcc -O0 -o fragment fragment.c

echo Running: ./fragment
wsl ./fragment
echo.

REM ============================================================================
REM SECTION 8: Swapping
REM ============================================================================
echo.
echo SECTION 8: Swapping
echo =========================================

echo Running: swapon --show
wsl swapon --show
echo.

echo Running: gcc -O0 -o swap_pressure swap_pressure.c
wsl gcc -O0 -o swap_pressure swap_pressure.c

echo Running: ./swap_pressure (this will take ~10 seconds)
wsl ./swap_pressure
echo.

REM ============================================================================
REM SECTION 9: Page Replacement
REM ============================================================================
echo.
echo SECTION 9: Page Replacement
echo =========================================

echo Running: gcc -O0 -o working_set working_set.c
wsl gcc -O0 -o working_set working_set.c

echo Running: ./working_set 512 64 5
wsl ./working_set 512 64 5
echo.

echo Running: ./working_set 512 512 5
wsl ./working_set 512 512 5
echo.

echo Running: grep -E 'Active^|Inactive' /proc/meminfo
wsl grep -E "Active|Inactive" /proc/meminfo
echo.

REM ============================================================================
REM SECTION 10: Thrashing
REM ============================================================================
echo.
echo SECTION 10: Thrashing
echo =========================================

echo Running: gcc -O0 -o thrash thrash.c
wsl gcc -O0 -o thrash thrash.c

echo Running: ./thrash (this will take ~20 seconds)
wsl ./thrash
echo.

REM ============================================================================
REM CLEANUP
REM ============================================================================
echo.
echo CLEANUP
echo =========================================

echo Running: rm -f layout demand pagemap cow hello_dynamic hello_static alloc_trace fragment swap_pressure working_set thrash *.c
wsl rm -f layout demand pagemap cow hello_dynamic hello_static alloc_trace fragment swap_pressure working_set thrash *.c

echo.
echo =========================================
echo Memory Management Lab Complete!
echo =========================================
