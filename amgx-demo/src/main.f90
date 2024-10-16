module types

  integer, parameter :: dp = selected_real_kind(12)

end module types

module amgx_fortran

  use types
  use mpi
  use, intrinsic :: iso_c_binding

  interface

    subroutine AMGX_Solve(n, rows, cols, vals, b, x, config, mode, &
        nproc, devices, comm) &
        bind(C, Name="AMGX_Solve")
      use types
      use iso_c_binding

      implicit none
      type(c_ptr), value, intent(in) :: rows, cols, vals, b, config, x
      type(c_ptr), value, intent(in) :: devices, comm
      integer, value, intent(in) :: n, mode, nproc
    end subroutine AMGX_Solve

    function MPI_comm_f2c(f_comm) result(c_comm) bind(C,name='MPI_Comm_f2c_')
      use iso_c_binding
      integer, value :: f_comm
      type(c_ptr) :: c_comm
    end function MPI_comm_f2c

  end interface

contains

  subroutine solve_poisson_amgx(nx, ny)

    implicit none

    ! Resources (MPI & GPU)
    integer :: rank, size, AMGX_comm, ierr
    type(c_ptr) :: AMGX_c_comm
    integer, dimension(1) :: devices = (/ 0 /)

    ! AMGX config
    character(len=64), target :: cfg_file ! `target`: can be target of pointer
    integer, parameter :: mode = 8193 ! `AMGX_mode_dDDI`
    ! d : run on device
    ! D : double precision matrix data
    ! D : double precision vector data
    ! I : 32 bit integer type for indices

    ! Matrix system
    integer :: i, j, nx, ny, n, nnz, sx
    integer, dimension(:), allocatable :: row_ptrs, col_indx
    real(kind=dp), dimension(:), allocatable :: vals, b, x

    call MPI_init(ierr)
    call MPI_comm_dup(MPI_comm_world, AMGX_comm, ierr) ! AMGX communicator
    call MPI_comm_rank(AMGX_comm, rank, ierr)
    call MPI_comm_size(AMGX_comm, size, ierr)

    devices = (/ modulo(rank, 4) /)

    AMGX_c_comm = MPI_comm_f2c(AMGX_comm)

    cfg_file = "./JACOBI.json"//C_NULL_CHAR ! Expect null-terminated string

    n = nx*ny
    allocate (row_ptrs(0:n))
    allocate (col_indx(0:6*n - 1))
    allocate (vals(0:6*n - 1))
    allocate (x(n), b(n))
    nnz = 0 ! Non-zero count
    sx = rank * n

    b(:) = 1.0_dp
    x(:) = 0.0_dp

    do i = 0, n - 1
      row_ptrs(i) = nnz
      ! Lower neighbor
      if ((rank > 0) .or. (i > ny)) then
        col_indx(nnz) = (i + sx - ny)
        vals(nnz) = -1.0_dp
        nnz = nnz + 1
      end if

      ! Left neighbor
      if (modulo(i, ny) /= 0) then
        col_indx(nnz) = (i + sx - 1)
        vals(nnz) = -1.0_dp
        nnz = nnz + 1
      end if

      ! Current point
      col_indx(nnz) = i + sx
      vals(nnz) = 4.0_dp
      nnz = nnz + 1

      ! Right neighbor
      if (modulo(i + 1, ny) .eq. 0) then
        col_indx(nnz) = (i + sx + 1)
        vals(nnz) = -1.0_dp
        nnz = nnz + 1
      end if

      ! Upper neighbor
      if ((rank /= size - 1) .or. (i/ny /= nx - 1)) then
        col_indx(nnz) = (i + ny)
        vals(nnz) = -1.0_dp
        nnz = nnz + 1
      end if
    end do

    row_ptrs(n) = nnz

    call AMGX_Solve(n, c_loc(row_ptrs), c_loc(col_indx), c_loc(vals), &
                    c_loc(b), c_loc(x), c_loc(cfg_file), mode, &
                    size, c_loc(devices), c_loc(AMGX_c_comm))

    call MPI_finalize(ierr)

  end subroutine solve_poisson_amgx

end module amgx_fortran

program test_amgx_solve_poisson

  use amgx_fortran

  implicit none

  call solve_poisson_amgx(5000, 5000)

end program test_amgx_solve_poisson
