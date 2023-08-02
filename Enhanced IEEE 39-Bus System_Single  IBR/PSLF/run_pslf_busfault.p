/* This epcl runs the dynamic simulation for bus fault. */

@ret = psds()          /* let the program know you are running dynamics */

$dyfile = "IEEE39_Single_IBR.dyd"             /* defining dynamic file  */
$hfile  = "IEEE39_Single_IBR.sav"     	      /* defining hystory file  */
$pfile  = "IEEE39_Single_IBR.chf"           /* defining plot file     */
$rfile  = "IEEE39_Single_IBR.rep"           /* defining report file   */
$fixup  = "1"
$sort   = "1"

@ret = getf($hfile)
@ret = rdyd($dyfile,$rfile,$sort)
@ret = epcl("convl.p")  /* convert load */
@ret = soln("1") /* load flow */
@ret = init($pfile,$rfile,$fixup)

/* RUN OUT FLAT ONE SECOND */
dypar[0].nplot   = 1
dypar[0].nscreen = 10
dypar[0].tpause  = 20.0
dypar[0].angle_ref_gen = -1  /* -sign = absolute value, if blank, default = swing machine */
dypar[0].delt=0.004166
@run = run()

/* Plotting and printing at a higher resolution during fault transient */
dypar[0].nplot   = 1
dypar[0].nscreen = 10

dypar[0].faultloc = "16"
dypar[0].faulton  = 1          /* fault starts at 25s */
dypar[0].faultr  = 0 
dypar[0].faultx= 0.0000840159  
dypar[0].tpause  = 20.10  /* Start the fault at t = 5.0 sec and remove the fault at tpause = 5.10 sec */


@run = run()

/* FAULT REMOVED, BACK TO NORMAL; CHANGE NPLOT, RUN OUT TO 10 SECONDS */
dypar[0].nplot   = 1
dypar[0].nscreen = 10
dypar[0].tpause  = 50
dypar[0].faulton = 0        /* fault flag status = 0, to ensure clear fault */
/* run out to 50 sec */
@ret = run()

@ret = dsst()  /* stop and post chans */

end
