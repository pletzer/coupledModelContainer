program test
	use ESMF
	use NUOPC
	implicit none
	integer :: rc
	type(ESMF_VM) :: vm
	call ESMF_Initialize(logkindflag=ESMF_LOGKIND_MULTI,              &
                           defaultCalkind=ESMF_CALKIND_GREGORIAN,       &
                           vm=vm, rc=rc)
	call ESMF_Finalize(rc=rc)
end program test