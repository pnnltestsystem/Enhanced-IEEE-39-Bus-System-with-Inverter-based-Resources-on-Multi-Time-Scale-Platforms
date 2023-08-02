/* THIS IS EPCL FOR DYNAMIC SIMULATION FOR GEN TRIP */

@ret = psds()          /* let the program know you are running dynamics */

$dyfile = "IEEE39_Single_IBR.dyd"             /* defining dynamic file  */
$hfile  = "IEEE39_Single_IBR.sav"     		 /* defining hystory file  */
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
dypar[0].nscreen = 5
dypar[0].tpause  = 20.0
dypar[0].angle_ref_gen = -1  /* -sign = absolute value, if blank, default = swing machine */
dypar[0].delt=0.004166
@run = run()

/* Gen Trip at 20 sec and trip Gen bus 32 */
/* Plotting and printing at a higher resolution during fault transient */
dypar[0].nplot   = 1
dypar[0].nscreen = 5

/* Gen trip */

@tripgen = rec_index(1,3,32,-1,"1",0,0)
/*rec_index(1=>external bus, 3=>type of the element is generator, 32=> from bus number where the element is connected, -1 (to bus) => not needed, 1=> ckt id, 0=> section, 0=> open status of the element. Here the element is generator on bus 32*/
dypar[0].tpause  = 50


@run = run()

@ret = dsst()  /* stop and post chans */

end
