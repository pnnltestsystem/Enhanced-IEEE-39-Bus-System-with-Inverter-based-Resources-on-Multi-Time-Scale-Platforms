/* This is the final version of the Plotting EPCL for Play-in function */
/* Authored by Yuan Liu, Dec 28, 2016 */

/* Notice: max string length is 32, max array dimention is 999 */

dim *chffile[998]
dim *csvfile[998]

/* Originally: for @Indx = 0 to 998 */
for @Indx = 0 to 0

	/* logbuf( $temp_str , @Indx ) */
	/* *chffile[ @Indx ] = "OUT\dt_" + $temp_str + ".chf" */
	/* *csvfile[ @Indx ] = "OUT\dt_" + $temp_str + ".csv" */
	
	*chffile[ @Indx ] = "IEEE39.chf"
	*csvfile[ @Indx ] = "PSLF.csv"
	
	@ret = getp( *chffile[ @Indx ])
	
	if ( @ret < 0)
		logterm("Conversion completed.<")
		quitfor
	endif
	
	@ret = chan2csv(1, 0, *chffile[ @Indx ], *csvfile[ @Indx ])	
		
next


end
