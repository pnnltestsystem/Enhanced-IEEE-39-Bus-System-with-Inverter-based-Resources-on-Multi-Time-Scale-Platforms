/* Dynamic Simulation */

@ret = psds()          /* let the program know you are running dynamics */

$dyfile = "IEEE39_2.dyd"
$sfile = "IEEE39bus_original_Modified_v34.sav"
$pfile  = "IEEE39.chf"
$rfile  = "IEEE39.rep"
$fixup  = "1"
$sort   = "1"

@ret = getf($sfile)
@ret = rdyd($dyfile,$rfile,$sort)
@ret = epcl("convl.p")  /* convert load */
@ret = soln("1") /* load flow */
@ret = init($pfile,$rfile,$fixup)

/* RUN OUT FLAT ONE SECOND */
dypar[0].nplot   = 1
dypar[0].nscreen = 10
dypar[0].tpause  = 5
dypar[0].angle_ref_gen = -1  /* -sign = absolute value, if blank, default = swing machine */
dypar[0].delt=0.004166
@run = run()

@case_idx = 2 /* Case index */

switch (@case_idx)

	case 1:
		/* Bus Fault Starts*/
		dypar[0].faultloc = "16"
		dypar[0].faulton  = 1
		dypar[0].faultr = 0.0 /* pu value required, Sbase = 100 MVA, Vbase 345 kV, 1 Ohm equivalent to 0.000840159 pu*/
		dypar[0].faultx= 0.0000840159  
		dypar[0].tpause  = 25.10
		@run = run()
		/* Post Fault */
		dypar[0].nplot   = 1
		dypar[0].nscreen = 10
		dypar[0].tpause  = 50
		dypar[0].faulton = 0 /* fault flag status = 0, to ensure clear fault */
		@ret = run()
	break
	
	Case 2:
		/* Generator trip */
		@tripgen = rec_index(1,3,32,-1,"1",0,0)
		dypar[0].tpause  = 50
		/* rec_index(1=>external bus, 3=>type of the element is generator, 32=> from bus number where the element is connected, -1 (to bus) => not needed, 1=> ckt id, 0=> section, 0=> open status of the element. Here the element is generator on bus 32 */
		@ret = run()
	break
endcase
@ret = dsst()  /* stop and post chans */

end