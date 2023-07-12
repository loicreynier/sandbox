program main
    implicit none

    character(len=*), parameter :: VERSION = "1.0"
    character(len=32)           :: name
    character(len=32)           :: arg
    integer                     :: i

    call get_command_argument(0, name)

    do i = 1, command_argument_count()
        call get_command_argument(i, arg)

        select case (arg)
        case ("-v", "--version")
            print "(2a)", "version ", VERSION
            stop

        case ("-h", "--help")
            call print_help(name)
            stop

        case default
            print "(2a, /)", "Unrecognised command-line option: ", arg
            call print_help(name)
            stop
        end select
    end do

    print "(a)", "Hello, World!"

contains

    subroutine print_help(name)

        character(len=32), intent(in) :: name

        print "(a, /)", "Usage: "//name(1:len_trim(name))//" [--options]"
        print "(a, /)", "Options:"
        print "(a)", "  -v, --version     Show version and exit"
        print "(a, /)", "  -h, --help        Show usage and exit"
    end subroutine print_help

end program main
