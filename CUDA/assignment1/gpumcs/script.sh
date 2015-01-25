#!/bin/bash
./gpu_out 16 16 > 16x16.txt
./gpu_out 32 8 > 32x8.txt
./gpu_out 8 32 > 8x32.txt 
./gpu_out 8 8 > 8x8.txt
./gpu_out 4 4 > 4x4.txt
./gpu_out 1 1 > 1.txt
./gpu_out 16 1 > 16.txt
./gpu_out 32 1 > 32.txt
./gpu_out 256 1 > 256.txt 

