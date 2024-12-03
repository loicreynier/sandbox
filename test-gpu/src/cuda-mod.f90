module cuda_mod

  use, intrinsic :: iso_c_binding
  use cudafor

  implicit none

  logical, save :: cudaInitialized = .false.

  interface

     subroutine cudaGetDeviceUUIDStr(deviceID, str, str_length) bind(C, name="cudaGetDeviceUUIDStr")
       import :: c_char, c_int
       implicit none
       integer(c_int), value, intent(in) :: deviceID
       character(kind=c_char), dimension(*), intent(out) :: str
       integer(c_int), value :: str_length
     end subroutine cudaGetDeviceUUIDStr

     subroutine cudaListDevices() bind(C, name="cudaListDevices_stdout")
     end subroutine cudaListDevices

  end interface

contains

  subroutine cudaCheck(istat, message)

    implicit none

    integer, intent(in)                    :: istat
    character(len=*), intent(in), optional :: message

    if (istat /= cudaSuccess) then
      write (*,"('Error code: ',I0, ': ')") istat
      write (*,*) cudaGetErrorString(istat)
      if(present(message)) write(*,*) message
      stop
    end if

  end subroutine cudaCheck

  subroutine cudaGetUUID(deviceID, deviceUUID)

    use, intrinsic :: iso_c_binding

    implicit none

    integer, intent(in) :: deviceID
    character(len=100), intent(out) :: deviceUUID
    character(kind=c_char), dimension(100) :: deviceUUID_c
    integer(c_int) :: uuid_length
    integer :: i

    uuid_length = size(deviceUUID_c)
    call cudaGetDeviceUUIDStr(deviceID, deviceUUID_c, uuid_length)

    do i = 1, uuid_length
      if (deviceUUID_c(i) == C_NULL_CHAR) then
        deviceUUID(i:) = ""
        exit
      end if
      deviceUUID(i:i) = deviceUUID_c(i)
    end do

  end subroutine cudaGetUUID

  subroutine cudaInit(mpi_size, mpi_rank)

    use, intrinsic :: iso_c_binding

    implicit none

    integer, intent(in) :: mpi_size, mpi_rank
    integer :: deviceNumber, deviceCount, deviceID
    integer(c_int) :: deviceCount_c
    type(cudaDeviceProp) :: deviceProp
    character(len=100) :: deviceUUID

    if (cudaInitialized) return

    call cudaCheck(cudaGetDeviceCount(deviceCount))

    if (deviceCount < 1) then
      write (*, "(A,IO,A)") &
        "[CUDA  INIT] Task #", mpi_rank, &
        " :: Error: there are no devices available on this host. ABORTING."
      stop
    end if

    call cudaCheck(cudaSetDevice(mod(mpi_rank, deviceCount)))
    call cudaCheck(cudaGetDevice(deviceID))
    call cudaCheck(cudaGetDeviceProperties(deviceProp, deviceID))
    call cudaGetUUID(deviceID, deviceUUID)

    write(*, "(A,I0,A,I0,A,I0,A,A,A,A)")             &
      "[CUDA  INIT] Task #", mpi_rank,         &
      " :: Device ", deviceID, "/", deviceCount - 1, &
      " - ", trim(deviceProp%name),                  &
      " - ", trim(deviceUUID)

    cudaInitialized = .true.

  end subroutine

end module cuda_mod
