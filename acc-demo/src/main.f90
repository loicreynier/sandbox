program main
  implicit none
  integer, parameter :: n = 100000

  call vector_add(n)

end program main

subroutine vector_add(n)

  implicit none

  integer :: i, n
  integer :: a(n), b(n), c(n)
  integer :: ref_value, mismatch_count
  logical :: all_equal

  do i = 1, n
    a(i) = i
    b(i) = n - i
  end do
  ref_value = n
  mismatch_count = 0

  !$acc parallel loop copyin(a(1:n), b(1:n)) copyout(c(1:n))
  do i = 1, n
    c(i) = a(i) + b(i)
  end do
  !$acc end parallel loop

  ! Check if all elements of `c` are equal
  !$acc parallel loop reduction(+: mismatch_count)
  do i = 1, n
    if (c(i) /= ref_value) then
      mismatch_count = mismatch_count + 1
    end if
  end do
  !$acc end parallel loop

  all_equal = (mismatch_count == 0)

  if (.not. all_equal) then
    print *, 'Assertion failed: Not all elements are equal.'
    stop 1
  end if

end subroutine vector_add
