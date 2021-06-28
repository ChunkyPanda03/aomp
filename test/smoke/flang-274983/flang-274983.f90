program test
    use omp_lib
    use f90deviceio
      integer :: i
      real, pointer  :: res, x(:)

      allocate(x(128))

      do i=1, 128
         x(i)=1
      enddo

      !$omp target enter data  map(to:x)

      do i=1, 128
         x(i)=2
      enddo

      write(0, *) "before device_ptr ", x(1)
      !$omp target data use_device_ptr(x)
         write(0, *) "in device_ptr", x(1)
         if (x(1) .ne. 1) write (0,*) 'FAILED wrong def on x(1)', x(1)
         stop
      !$omp end target data

     !$omp target 
       if (omp_get_thread_num() .eq. 0) then
         call f90printf("In tagret data=", x(1))
       endif
     !$omp end target

      !$omp target teams distribute parallel do
      do i=1, 128
         x(i)=3
      enddo
      !$omp end target teams distribute parallel do

     !$omp target 
       if (omp_get_thread_num() .eq. 0) then
         call f90printf("In tagret data 2=", x(1))
       endif
     !$omp end target

     write(*, *) "Outside tagret data3=", x(1)

     !$omp target exit data map(from:x)
     write(*, *) "Outside tagret data4=", x(1)

      nullify(x)

end program test
