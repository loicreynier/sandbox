module types

  integer, parameter :: dp = selected_real_kind(12)

end module types

module amgx_fortran

  use types
  use, intrinsic :: iso_c_binding

  interface

    subroutine AMGXSolve(n, rows, cols, vals, b, x, config, mode) &
      bind(C, Name="AMGXSolve")
      use types
      use iso_c_binding

      implicit none
      type(c_ptr), value, intent(in) :: rows, cols, vals, b, config
      type(c_ptr), value, intent(in) :: x
      integer, value, intent(in) :: n
      integer, value, intent(in) :: mode
    end subroutine AMGXSolve

  end interface

contains

  subroutine solve_poisson_amgx(nx, ny)

    implicit none

    character(len=64), target :: cfg_file ! `target`: can be target of pointer
    integer, parameter :: mode = 8193 ! `AMGX_mode_dDDI`
    ! d : run on device
    ! D : double precision matrix data
    ! D : double precision vector data
    ! I : 32 bit integer type for indices
    integer :: i, j, nx, ny, n, nnz
    integer, dimension(:), allocatable :: row_ptrs, col_indx
    real(kind=dp), dimension(:), allocatable :: vals, b, x

    cfg_file = "./JACOBI.json"//C_NULL_CHAR ! Expect null-terminated string

    n = nx*ny
    allocate (row_ptrs(0:n))
    allocate (col_indx(0:6*n - 1))
    allocate (vals(0:6*n - 1))
    allocate (x(n), b(n))
    nnz = 0 ! Non-zero count

    b(:) = 1.0_dp
    x(:) = 0.0_dp

    do i = 0, n - 1
      row_ptrs(i) = nnz
      ! Lower neighbor
      if (i .gt. ny) then
        col_indx(nnz) = (i - ny)
        vals(nnz) = -1.
        nnz = nnz + 1
      end if

      ! Left neighbor
      if (modulo(i, ny) .ne. 0) then
        col_indx(nnz) = (i - 1)
        vals(nnz) = -1.
        nnz = nnz + 1
      end if

      ! Current point
      col_indx(nnz) = i
      vals(nnz) = 4.
      nnz = nnz + 1

      ! Right neighbor
      if (modulo(i + 1, ny) .eq. 0) then
        col_indx(nnz) = (i + 1)
        vals(nnz) = -1.
        nnz = nnz + 1
      end if

      ! Upper neighbor
      if (i/ny .ne. nx - 1) then
        col_indx(nnz) = (i + ny)
        vals(nnz) = -1.
        nnz = nnz + 1
      end if
    end do

    row_ptrs(n) = nnz

    call AMGXSolve(n, c_loc(row_ptrs), c_loc(col_indx), c_loc(vals), &
                   c_loc(b), c_loc(x), c_loc(cfg_file), mode)

  end subroutine solve_poisson_amgx

end module amgx_fortran

program test_amgx_solve_poisson

  use amgx_fortran

  implicit none

  call solve_poisson_amgx(5000, 5000)

end program test_amgx_solve_poisson
