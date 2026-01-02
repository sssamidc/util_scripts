# CPU and GPU Stress Workload for Jetson Nano

This directory contains scripts to create artificial workloads that push both CPU and GPU utilization to their maximum limits on Jetson Nano running Ubuntu 20.04 and JetPack 5.1.2.

## Files

- **`cpu_stress.sh`** - CPU-intensive workload script
- **`gpu_stress.cu`** - CUDA source code for GPU-intensive workload
- **`run_stress_workload.sh`** - Main orchestrator script that runs both CPU and GPU workloads simultaneously
- **`WORKLOAD_README.md`** - This file

## Prerequisites

1. **CUDA Toolkit**: Should be installed with JetPack 5.1.2
   - Verify with: `nvcc --version`
   - Verify GPU with: `nvidia-smi`

2. **Basic Tools**: 
   - `bc` (for CPU calculations) - will be installed automatically if missing
   - `bash` (standard on Ubuntu)

## Quick Start

### Option 1: Run Both CPU and GPU Stress (Recommended)

```bash
cd UtilScripts/benchmarking
chmod +x *.sh
./run_stress_workload.sh [duration_seconds] [cpu_threads] [gpu_grid_size]
```

**Examples:**
```bash
# Run for 1 hour with default settings (all CPU cores, 512x512 GPU grid)
./run_stress_workload.sh

# Run for 30 minutes
./run_stress_workload.sh 1800

# Run for 1 hour with 2 CPU threads and 256x256 GPU grid
./run_stress_workload.sh 3600 2 256

# Run for 2 hours with all CPU cores and 1024x1024 GPU grid
./run_stress_workload.sh 7200 $(nproc) 1024
```

### Option 2: Run CPU Stress Only

```bash
./cpu_stress.sh [duration_seconds] [num_threads]
```

**Examples:**
```bash
# Run for 1 hour using all CPU cores
./cpu_stress.sh

# Run for 30 minutes using 2 threads
./cpu_stress.sh 1800 2
```

### Option 3: Run GPU Stress Only

First compile the CUDA program:
```bash
nvcc -o gpu_stress gpu_stress.cu -arch=sm_53 -O3
```

Then run:
```bash
./gpu_stress [duration_seconds] [grid_size]
```

**Examples:**
```bash
# Run for 1 hour with 512x512 grid
./gpu_stress

# Run for 30 minutes with 256x256 grid
./gpu_stress 1800 256

# Run for 2 hours with 1024x1024 grid
./gpu_stress 7200 1024
```

## Parameters

### CPU Stress (`cpu_stress.sh`)
- **duration_seconds** (default: 3600): How long to run the workload
- **num_threads** (default: all CPU cores): Number of parallel CPU threads

### GPU Stress (`gpu_stress`)
- **duration_seconds** (default: 3600): How long to run the workload
- **grid_size** (default: 512): Matrix size for GPU computation (N x N)

### Combined Workload (`run_stress_workload.sh`)
- **duration_seconds** (default: 3600): How long to run both workloads
- **cpu_threads** (default: all CPU cores): Number of CPU threads
- **gpu_grid_size** (default: 512): GPU computation grid size

## What These Workloads Do

### CPU Stress
- Creates multiple threads (one per CPU core by default)
- Each thread performs intensive floating-point calculations
- Uses mathematical operations (sqrt, sin) in tight loops
- Keeps CPU utilization near 100%

### GPU Stress
- Launches CUDA kernels that perform:
  - Matrix multiplication operations
  - Vector operations with transcendental functions (sin, cos, exp, log, sqrt)
- Multiple iterations per kernel launch
- Keeps GPU utilization near 100%

### Combined Workload
- Runs both CPU and GPU stress simultaneously
- Maximum system utilization for thermal testing
- Useful for measuring CPU and GPU temperatures under full load

## Monitoring

While the workloads are running, you can monitor system resources:

### CPU Usage
```bash
htop
# or
top
```

### GPU Usage
```bash
watch -n 1 nvidia-smi
```

### Temperature
```bash
# CPU temperature
cat /sys/class/thermal/thermal_zone*/temp

# GPU temperature (via nvidia-smi)
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
```

### Combined Monitoring
Use the existing benchmarking scripts in this directory:
```bash
# Terminal 1: CPU stats
./cpu_stats.sh

# Terminal 2: Run the workload
./run_stress_workload.sh
```

## Stopping the Workload

Press `Ctrl+C` to gracefully stop all workloads. The orchestrator script will:
- Stop all CPU stress threads
- Stop the GPU stress process
- Clean up resources

## Notes

1. **Thermal Throttling**: Jetson Nano may throttle CPU/GPU if temperatures get too high. This is normal behavior.

2. **Power Mode**: Ensure Jetson Nano is in MAXN mode for maximum performance:
   ```bash
   sudo nvpmodel -m 0
   sudo jetson_clocks
   ```

3. **Cooling**: Ensure adequate cooling (fan/heatsink) when running extended stress tests.

4. **Memory**: GPU workload allocates memory based on grid size. Larger grids require more GPU memory.

5. **Jetson Nano GPU**: Uses compute capability 5.3 (sm_53), which is specified in the compilation command.

## Troubleshooting

### CUDA Not Found
```bash
# Check if CUDA is installed
nvcc --version
nvidia-smi

# If not found, CUDA should be part of JetPack 5.1.2
# Reinstall JetPack if needed
```

### Compilation Errors
- Ensure you're using the correct compute capability: `-arch=sm_53` for Jetson Nano
- Check CUDA toolkit version compatibility

### Permission Denied
```bash
chmod +x *.sh
```

### Out of Memory (GPU)
- Reduce the `grid_size` parameter
- Jetson Nano has limited GPU memory (4GB shared)

## Performance Tips

1. **For Maximum CPU Load**: Use all available cores (default)
2. **For Maximum GPU Load**: Use larger grid sizes (512, 1024) if memory allows
3. **For Balanced Load**: Use default settings in `run_stress_workload.sh`
4. **For Extended Tests**: Monitor temperatures and ensure adequate cooling

## Integration with Benchmarking Scripts

These workloads are designed to work alongside the existing benchmarking scripts:
- `cpu_stats.sh` - Monitor CPU usage during workload
- `memory_stats.sh` - Monitor memory usage
- `iops_stats.sh` - Monitor disk I/O (minimal with these workloads)

Run the monitoring scripts in separate terminals while the workload is running.

