#!/bin/bash

# CPU Stress Workload Script for Jetson Nano
# This script creates CPU-intensive workloads to push CPU utilization to maximum

# Global variables
DURATION=3600
THREADS=$(nproc)
PIDS=()

# Function to display header information
display_header() {
    echo "=========================================="
    echo "CPU Stress Workload"
    echo "=========================================="
    echo "Duration: ${DURATION} seconds"
    echo "Threads: ${THREADS}"
    echo "=========================================="
    echo ""
}

# Function to perform CPU-intensive computation
# Uses pure bash arithmetic for maximum CPU utilization
cpu_burn() {
    local thread_id=$1
    local end_time=$(($(date +%s) + $DURATION))
    
    echo "Starting CPU thread ${thread_id}..."
    
    while [ $(date +%s) -lt $end_time ]; do
        # Perform intensive integer and floating point calculations
        # Multiple nested loops to keep CPU busy
        local result=0
        local temp=0
        
        # Integer arithmetic loop
        for ((i=1; i<=100000; i++)); do
            result=$((result + i * i))
            result=$((result % 2147483647))  # Prevent overflow
        done
        
        # Additional computation
        for ((j=1; j<=50000; j++)); do
            temp=$((temp ^ result))
            result=$((result + temp))
        done
        
        # Bitwise operations
        for ((k=1; k<=10000; k++)); do
            result=$((result << 1))
            result=$((result | (result >> 16)))
            result=$((result & 0x7FFFFFFF))
        done
    done
    
    echo "CPU thread ${thread_id} completed."
}

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Stopping CPU stress..."
    kill "${PIDS[@]}" 2>/dev/null
    exit 0
}

# Function to start CPU stress workload
start_cpu_stress() {
    echo "Starting CPU stress workload..."
    echo "Press Ctrl+C to stop early"
    echo ""
    
    # Start background processes for each thread
    for ((i=1; i<=$THREADS; i++)); do
        cpu_burn $i &
        PIDS+=($!)
    done
    
    # Set up signal handlers
    trap cleanup INT TERM
    
    # Wait for all processes
    wait "${PIDS[@]}"
    
    echo ""
    echo "CPU stress workload completed."
}

# Main function
main() {
    # Parse command line arguments
    DURATION=${1:-3600}  # Default: 1 hour (3600 seconds)
    THREADS=${2:-$(nproc)}  # Default: Use all available CPU cores
    
    # Display header
    display_header
    
    # Start CPU stress workload
    start_cpu_stress
}

# Execute main function
main "$@"

