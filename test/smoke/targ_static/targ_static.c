#include <stdio.h>
#include "assert.h"
#include <unistd.h>

#define NZ 10
#define NA 9
#pragma omp declare target
static int colstat[NZ];
#pragma omp end declare target

int main(){
	colstat[0]=-1;
#pragma omp target map(alloc:colstat[0:NZ])
#pragma omp teams 
  {
    colstat[1] = 1111;
  }
#pragma omp target map(alloc:colstat[:0])
#pragma omp teams 
  {
    colstat[2] = 2222;
  }
#pragma omp target update from(colstat)
  printf("colstat[0..2] %d %d %d \n", colstat[0], colstat[1], colstat[2]);
  return 0;
}

