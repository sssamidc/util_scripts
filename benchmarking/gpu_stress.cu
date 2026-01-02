/*
 * GPU Stress Workload for Jetson Nano
 * CUDA program to push GPU utilization to maximum
 * 
 * Compile with: nvcc -o gpu_stress gpu_stress.cu -arch=sm_53
 * Run with: ./gpu_stress [duration_seconds] [grid_size]
 */

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>

// Global flag for graceful shutdown
volatile sig_atomic_t keep_running = 1;

void signal_handler(int sig) {
    keep_running = 0;
}

// GPU kernel: Matrix multiplication with intensive computation
__global__ void gpu_stress_kernel(float *A, float *B, float *C, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (idx < N * N) {
        int row = idx / N;
        int col = idx % N;
        
        float sum = 0.0f;
        // Perform matrix multiplication with additional computations
        for (int k = 0; k < N; k++) {
            sum += A[row * N + k] * B[k * N + col];
        }
        
        // Additional intensive computation: multiple iterations
        for (int iter = 0; iter < 10; iter++) {
            sum = sqrtf(sum * sum + 1.0f);
            sum = sinf(sum) + cosf(sum);
        }
        
        C[row * N + col] = sum;
    }
}

// GPU kernel: Vector operations with transcendental functions
__global__ void gpu_compute_intensive(float *data, int N, int iterations) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (idx < N) {
        float value = data[idx];
        // Perform many transcendental operations
        for (int i = 0; i < iterations; i++) {
            value = sinf(value) + cosf(value);
            value = expf(value * 0.1f);
            value = logf(fabsf(value) + 1.0f);
            value = sqrtf(value * value + 1.0f);
        }
        data[idx] = value;
    }
}

int main(int argc, char *argv[]) {
    // Parse arguments
    int duration = 3600;  // Default: 1 hour
    int grid_size = 512;  // Default matrix size
    
    if (argc > 1) {
        duration = atoi(argv[1]);
    }
    if (argc > 2) {
        grid_size = atoi(argv[2]);
    }
    
    printf("==========================================\n");
    printf("GPU Stress Workload\n");
    printf("==========================================\n");
    printf("Duration: %d seconds\n", duration);
    printf("Grid Size: %d x %d\n", grid_size, grid_size);
    printf("==========================================\n\n");
    
    // Set up signal handler for graceful shutdown
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // Get GPU device properties
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    
    if (deviceCount == 0) {
        fprintf(stderr, "Error: No CUDA devices found\n");
        return 1;
    }
    
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    printf("GPU: %s\n", prop.name);
    printf("Compute Capability: %d.%d\n", prop.major, prop.minor);
    printf("Total Global Memory: %.2f GB\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));
    printf("Multiprocessors: %d\n", prop.multiProcessorCount);
    printf("\n");
    
    // Allocate host memory
    size_t size = grid_size * grid_size * sizeof(float);
    float *h_A = (float*)malloc(size);
    float *h_B = (float*)malloc(size);
    float *h_C = (float*)malloc(size);
    float *h_data = (float*)malloc(grid_size * grid_size * sizeof(float));
    
    if (!h_A || !h_B || !h_C || !h_data) {
        fprintf(stderr, "Error: Failed to allocate host memory\n");
        return 1;
    }
    
    // Initialize host data
    for (int i = 0; i < grid_size * grid_size; i++) {
        h_A[i] = (float)rand() / RAND_MAX;
        h_B[i] = (float)rand() / RAND_MAX;
        h_data[i] = (float)rand() / RAND_MAX;
    }
    
    // Allocate device memory
    float *d_A, *d_B, *d_C, *d_data;
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);
    cudaMalloc((void**)&d_data, grid_size * grid_size * sizeof(float));
    
    if (cudaGetLastError() != cudaSuccess) {
        fprintf(stderr, "Error: Failed to allocate device memory\n");
        return 1;
    }
    
    // Copy data to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_data, h_data, grid_size * grid_size * sizeof(float), cudaMemcpyHostToDevice);
    
    // Configure kernel launch parameters
    int threadsPerBlock = 256;
    int blocksPerGrid = (grid_size * grid_size + threadsPerBlock - 1) / threadsPerBlock;
    int blocksPerGridVector = (grid_size * grid_size + threadsPerBlock - 1) / threadsPerBlock;
    
    printf("Starting GPU stress workload...\n");
    printf("Press Ctrl+C to stop early\n\n");
    
    time_t start_time = time(NULL);
    time_t end_time = start_time + duration;
    int iteration = 0;
    
    // Main computation loop
    while (keep_running && time(NULL) < end_time) {
        // Launch matrix multiplication kernel
        gpu_stress_kernel<<<blocksPerGrid, threadsPerBlock>>>(
            d_A, d_B, d_C, grid_size);
        
        // Launch compute-intensive kernel
        gpu_compute_intensive<<<blocksPerGridVector, threadsPerBlock>>>(
            d_data, grid_size * grid_size, 100);
        
        // Synchronize to ensure kernels complete
        cudaDeviceSynchronize();
        
        // Check for errors
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(err));
            break;
        }
        
        iteration++;
        if (iteration % 100 == 0) {
            printf("Iteration: %d, Time elapsed: %ld seconds\n", 
                   iteration, time(NULL) - start_time);
        }
    }
    
    // Cleanup
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    cudaFree(d_data);
    
    free(h_A);
    free(h_B);
    free(h_C);
    free(h_data);
    
    printf("\nGPU stress workload completed.\n");
    printf("Total iterations: %d\n", iteration);
    
    return 0;
}

