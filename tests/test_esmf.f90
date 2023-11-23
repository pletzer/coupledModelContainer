program test
	use ESMF
	use NUOPC
	implicit none
	integer :: rc, mypet,  npets
	type(ESMF_VM) :: vm
	call ESMF_Initialize(logkindflag=ESMF_LOGKIND_MULTI,              &
                           defaultCalkind=ESMF_CALKIND_GREGORIAN,       &
                           vm=vm, rc=rc)

        call ESMF_VMGet(vm=vm, localPet=mypet, petCount=npets, rc=rc)
        if (rc /= 0) print *,'ERROR: rc = ', rc

        print *, '[', mypet, '] out of ', npets

	call ESMF_Finalize(rc=rc)
end program test
