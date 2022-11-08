program test_nmlinput

    use nmlinput
    implicit none

    integer :: file_unit
    integer :: iostat_
    logical :: file_exists

    integer :: test_int
    logical :: test_logical

    namelist /sample/ test_int, test_logical

    call open_inputfile("test.nml", file_unit, iostat_)
    if (iostat_ /= 0) then
        stop
    end if
    read (nml=sample, iostat=iostat_, unit=file_unit)
    call close_inputfile("test.nml", file_unit, iostat_)

    print *, test_int
    print *, test_logical

end program test_nmlinput
