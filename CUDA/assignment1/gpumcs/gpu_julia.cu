#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__device__ inline int iterate_pixel(float x, float y, float c_re, float c_im)
{
	int c=0; 
	float z_re=x;
	float z_im=y;
	while (c<255) {
		float re2=z_re*z_re;
		float im2=z_im*z_im;
		if ((re2+im2) > 4) break; 
		z_im=2*z_re*z_im + c_im;
		z_re=re2-im2 + c_re;
		c++;
	}
	return c;
}

__global__ void calc_fractal(int width, int height, float c_re, float c_im, unsigned char* dest)
{
	int x = (blockIdx.x * blockDim.x) + threadIdx.x;
	int y = (blockIdx.y * blockDim.y) + threadIdx.y;

	float f_x=(float)(x*0.8f)/(float)(width)-0.8f;
	float f_y=(float)(y*0.8f)/(float)(height)-0.8f;

	dest[x+y*width]=iterate_pixel(f_x,f_y,c_re,c_im);
}
//bullshit

// Write a width by height 8-bit color image into File "filename"
void write_ppm(unsigned char* data,unsigned int width,unsigned int height,char* filename)
{
	if (data == NULL) {
		printf("Provide a valid data pointer!\n");
		return;
	}
	if (filename == NULL) {
		printf("Provide a valid filename!\n");
		return;
	}
	if ( (width>4096) || (height>4096)) {
		printf("Only pictures upto 4096x4096 are supported!\n");
		return;
	}
	FILE *f=fopen(filename,"wb");
	if (f == NULL) 
	{
		printf("Opening File %s failed!\n",filename);
		return;
	}
	if (fprintf(f,"P6 %i %i 255\n",width,height) <= 0) {
		printf("Writing to file failed!\n");
		return;
	};
	int i;
	for (i=0;i<height;i++) {
		unsigned char buffer[4096*3];
		int j;
		for (j=0;j<width;j++) {
			int v=data[i*width+j];
			int s;
			s= v << 0;
			s=s > 255? 255 : s;
			buffer[j*3+0]=s;
			s= v << 1;
			s=s > 255? 255 : s;
			buffer[j*3+1]=s;
			s= v << 2;
			s=s > 255? 255 : s;
			buffer[j*3+2]=s;
		}
		if (fwrite(buffer,width*3,1,f) != 1) {
			printf("Writing of line %i to file failed!\n",i);
			return;
		}
	}
	fclose(f);
}


int main(int argc, char** argv) {
	int blockx = atoi(argv[1]);
	int blocky = atoi(argv[2]);

	int imagesize = 256*256;
	unsigned char* image=(unsigned char*)malloc(imagesize);
	assert(image != NULL);

	unsigned char *in;
	cudaMalloc((void**)&in,sizeof(unsigned char)*imagesize);

	dim3 block(blockx, blocky); 
	dim3 grid(256/block.x, 256/block.y); 
		
	//calc_fractal(256,256,0.28,0.008,image);
	calc_fractal<<<grid,block>>>(256,256,0.28,0.008,in);
	cudaMemcpy(image,in,sizeof(char)*imagesize,cudaMemcpyDeviceToHost);

	write_ppm(image,256,256,"julia.ppm");
	free(image);
	return 0;
}


