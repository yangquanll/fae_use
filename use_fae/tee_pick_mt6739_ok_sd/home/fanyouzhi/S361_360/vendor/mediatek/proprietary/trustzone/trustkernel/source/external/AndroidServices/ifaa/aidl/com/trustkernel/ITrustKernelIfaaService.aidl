package com.trustkernel;

interface ITrustKernelIfaaService {
    int invoke_command(in byte[] input,
                        out byte[] output,
                        int output_capacity);
}
