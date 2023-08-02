
/*  convert loads usually from the base case load flow to dynamics set up */


dim     *inp[10],       *des[10][40],   #total[2][6],   *string[6]

*string[0] = "const P MW  "
*string[1] = "const I MW  "
*string[2] = "const Z MW  "
*string[3] = "const P MVAR"
*string[4] = "const I MVAR"
*string[5] = "const Z MVAR"

label begin

$title  = "convert load"
*des[0] = "% const power     real portion"
*des[1] = "% const current   real portion"
*des[2] = "% const impedance real portion"
*des[3] = "                              "
*des[4] = "% const power     imag portion"
*des[5] = "% const current   imag portion"
*des[6] = "% const impedance imag portion"

*inp[0] = "0"
*inp[1] = "0"
*inp[2] = "100"
*inp[3] = " "
*inp[4] = "0"
*inp[5] = "0"
*inp[6] = "100"

@ret = panel($title,*des[0],*inp[0],7,1)
if( @ret < 0 )
	end
endif

@pscale  = 1   /* default loads to constant p and q */
@qscale  = 1
@ipscale = 0
@iqscale = 0
@zpscale = 0
@zqscale = 0

/*  #total[0][0-5] before loads */
/*  #total[1][0-5] after  loads */

for @i= 0 to 5
	for @l= 0 to 1
		#total[@l][@i] = 0
	next
next

@pscale  = atof( *inp[0] ) / 100
@ipscale = atof( *inp[1] ) / 100
@zpscale = atof( *inp[2] ) / 100

/* check real portion */

@sum = @pscale + @ipscale + @zpscale
if ( (@sum<.99) or (@sum>1.01 ) )
	logterm("Real portion doesn't add to 100 % - try again<")
	goto begin
endif

/* check imaginary portion */

@qscale  = atof( *inp[4] ) / 100
@iqscale = atof( *inp[5] ) / 100
@zqscale = atof( *inp[6] ) / 100

@sum=@qscale+@iqscale+@zqscale
if ( (@sum<.99) or (@sum>1.01) )
	logterm("Imaginary portion doesn't add to 100 % - try again<")
	goto begin
endif

for @i = 0 to casepar[0].nload-1
	#total[0][0] = #total[0][0] + load[@i].p
	#total[0][1] = #total[0][1] + load[@i].ip
	#total[0][2] = #total[0][2] + load[@i].g

	#total[0][3] = #total[0][3] + load[@i].q
	#total[0][4] = #total[0][4] + load[@i].iq
	#total[0][5] = #total[0][5] + load[@i].b

	@j=load[@i].lbus
	@volt=volt[@j].vm

/* move all loads to constant p and q - corrected for voltage */

	@pload=load[@i].p+(load[@i].ip*@volt)+ (load[@i].g*@volt*@volt)
	@qload=load[@i].q+(load[@i].iq*@volt)+(load[@i].b*@volt*@volt)
	load[@i].p=@pload
	load[@i].q=@qload
next

for @i = 0 to casepar[0].nload-1
	@pload = load[@i].p
	@qload = load[@i].q
	@j  = load[@i].lbus
	@vv = volt[@j].vm        /* bus voltage */
	@ip = @pload/@vv
	@iq = @qload/@vv
	@zp = @pload/(@vv*@vv)
	@zq = @qload/(@vv*@vv)

	load[@i].p  = @pscale  * @pload  /* modify existing loads */
	load[@i].q  = @qscale  * @qload
	load[@i].ip = @ipscale * @ip
	load[@i].iq = @iqscale * @iq
	load[@i].g  = @zpscale * @zp
	load[@i].b  = @zqscale * @zq

	#total[1][0] = #total[1][0] + load[@i].p   /* new totals */
	#total[1][1] = #total[1][1] + load[@i].ip
	#total[1][2] = #total[1][2] + load[@i].g

	#total[1][3] = #total[1][3] + load[@i].q
	#total[1][4] = #total[1][4] + load[@i].iq
	#total[1][5] = #total[1][5] + load[@i].b

next

/* display new load totals */

logterm("<<<                  before      after <")
for @i = 0 to 5
if( @i = 3 )
     logterm("<")
endif

logterm(*string[@i],"  ",#total[0][@i]:10:2," ",#total[1][@i]:10:2,"<")
next

logterm("<<<")

end
