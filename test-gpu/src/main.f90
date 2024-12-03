module parameters


  use iso_fortran_env, only: real64

  implicit none

  integer, parameter                              :: dp = real64
  integer                                         :: i, j, k
  integer                                         :: nx, ny, nz
  integer                                         :: nx_p, ny_p, nz_p
  integer                                         :: sx, sy, sz
  real(kind=dp), dimension(:), allocatable        :: x, y, z
  real(kind=dp), dimension(:, :, :), allocatable  :: u, v
  real(kind=dp)                                   :: dx, dy, dz

  integer                                         :: mpi_size, mpi_rank, mpi_err

  !$acc declare create(sx, sy, sz, u, v)

end module parameters

module test_acc_computation

  use parameters
  use mpi

  implicit none

  contains

    subroutine init_computation()

      use parameters

      implicit none

      nx = 64
      ny = 64
      nz = 64

      nx_p = nx / mpi_size
      ny_p = ny
      nz_p = nz

      sx = mpi_rank * nx_p
      sy = 0.0
      sz = 0.0

      allocate(u(nx_p, ny_p, nz_p))
      allocate(v(nx_p, ny_p, nz_p))
      allocate(x(nx))
      allocate(y(ny))
      allocate(z(nz))

      dx = 2.0_dp * acos(-1.0_dp) / real(nx - 1, dp)
      dy = 2.0_dp * acos(-1.0_dp) / real(ny - 1, dp)
      dz = 2.0_dp * acos(-1.0_dp) / real(nz - 1, dp)

      do i = 1, nx
         x(i) = -acos(-1.0_dp) + (i - 1) * dx
      end do

      do j = 1, ny
         y(j) = -acos(-1.0_dp) + (j - 1) * dy
      end do

      do k = 1, nz
         z(k) = -acos(-1.0_dp) + (k - 1) * dz
      end do

      do k = 1, nz_p
        do j = 1, ny_p
          do i = 1, nx_p
            u(i, j, k) = sin(x(sx + i)) * sin(y(sy + j)) * sin(z(sz + k))
            v(i, j, k) = cos(x(sx + i)) * cos(y(sy + j)) * cos(z(sz + k))
          end do
        end do
      end do

    end subroutine init_computation

    subroutine test_computation()

      use parameters

      implicit none

      real(kind=dp) :: res

      !$acc update device(sx, sy, sz, u, v)

      res = 0_dp

      call scalar(res)

      if (mpi_rank == 0) print *, "=== res =", res

      return
    end subroutine test_computation

    subroutine scalar(res)
      implicit none
      real(kind=dp), intent(out) :: res
      real(kind=dp) :: res_p

      res_p = 0.0_dp

      !$acc parallel loop gang reduction(+:res_p) collapse(3)
      do k = 1, nz_p
        do j = 1, ny_p
          do i = 1, nx_p
            res_p = res_p + u(i, j, k) * v(i, j, k)
          end do
        end do
      end do
      !$acc end parallel loop

      call MPI_Allreduce(res_p, res, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, mpi_err)

      return
    end subroutine scalar

end module test_acc_computation

program test_gpu

  use mpi
  use openacc
  use openacc_mod
  use parameters
  use test_acc_computation

  implicit none

  integer :: n_devices, device_i

  call MPI_Init(mpi_err)
  call MPI_Comm_size(MPI_COMM_WORLD, mpi_size, mpi_err)
  call MPI_Comm_rank(MPI_COMM_WORLD, mpi_rank, mpi_err)
  call acc_init_mpi(mpi_size, mpi_rank)

  ! n_devices = acc_get_num_devices(acc_get_device_type())
  ! device_i = mod(mpi_rank, n_devices)
  ! call acc_set_device_num(device_i, acc_get_device_type())

  call init_computation()
  call test_computation()

  call MPI_Finalize(mpi_err)

end program test_gpu
