CC = gcc
CFLAGS = -O2 -fopenmp

FC = gfortran
FFLAGS = -O2 -fopenmp

all: stream_f.exe stream_c.exe

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FC) $(FFLAGS) -c stream.f
	$(FC) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) stream.c -o stream_c.exe

clean:
	rm -f stream*.exe stream*.exe *.o

# an example of a larger buffer using the default compiler
stream.large.exe: stream.c
	$(CC) $(CFLAGS) -DSTREAM_ARRAY_SIZE=1000000000l $< -o $@

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc

# an example of a more complex build line for the AMD compiler with GPU offload
stream.amd_gpu.exe: stream.c
	amdclang -march=native -mtune=native -O3 -fopenmp -DSTREAM_ARRAY_SIZE=1000000000l -DOMPGPU --offload-arch=gfx942 $< -o $@

stream.amd_apu.exe: stream.c
	amdclang -march=native -mtune=native -O3 -fopenmp -DSTREAM_ARRAY_SIZE=1000000000l -DOMPGPU -DOMPGPU_UNIFIED --offload-arch=gfx942 $< -o $@
