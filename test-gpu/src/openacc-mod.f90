module openacc_mod

  use openacc

  implicit none

  logical, save :: openacc_initialized = .false.

contains

  subroutine acc_init_mpi(mpi_size, mpi_rank)

    use openacc

    implicit none

    integer, intent(in) :: mpi_size, mpi_rank
    integer :: n_devices, device_i
    integer(acc_device_kind) :: device_t
    character*256 :: device_name, device_driver

    if (openacc_initialized) return

    n_devices = acc_get_num_devices(acc_get_device_type())
    if (n_devices < 1) then
      write (*, "(A,IO,A)") "[OPENACC INIT] Task #", mpi_rank, &
        " :: Error: there are no device available on this host. ABORTING."
      stop
    end if

    device_i = mod(mpi_rank, n_devices)
    device_t = acc_get_device_type()
    call acc_get_property_string(device_i, device_t, acc_property_name, device_name)
    call acc_get_property_string(device_i, device_t, acc_property_driver, device_driver)

    if (device_t == acc_device_host) then
      write (*, "(A,IO,A)") "[OPENACC INIT] Task #", mpi_rank, &
        " :: Error: accelerator is host"
    end if

    call acc_set_device_num(device_i, device_t)
    call acc_init(device_t)

    write (*, "(A,I0,A,I0,A,I0,A,A,A,A,A)")        &
      "[OPENACC INIT] Task #", mpi_rank,       &
      " :: Device ", device_i, "/", n_devices - 1, &
      " - ", trim(device_name),                    &
      " - Driver ", trim(device_driver)

    openacc_initialized = .true.

  end subroutine acc_init_mpi

end module openacc_mod
