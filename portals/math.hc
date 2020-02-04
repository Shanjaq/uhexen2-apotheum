/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/math.hc,v 1.2 2007-02-07 16:59:34 sezero Exp $
 */



/*
 * crandom() -- Returns a random number between -1 and 1.
 */

float crandom()
{
	return random(-1,1);
}

/*
float fexp(float base,float exponent)
{//MG
float exp_count;

	exponent=rint(exponent);
	if(exponent==0)
		return 1;
	if(exponent<0)
	{
		base=1/base;
		exponent=fabs(exponent);
	}

	if(exponent==1)
		return base;
	
	exponent-=1;
	while(exp_count<exponent)
	{
		exp_count+=1;
		base=base*base;
	}
	return base;
}
*/

float byte_me(float mult)
{//MG
float mult_count,base;


	mult=rint(mult);
	if(mult==0)
		return 0;
	if(mult==1)
		return 1;
	if(mult==-1)
		return -1;

	if(mult<0)
	{
		base= -1;
		mult=fabs(mult);
	}
	else
		base=1;
	
	mult-=1;	
	while(mult_count<mult)
	{
		mult_count+=1;
		base=base*2;
	}
	return base;
}

vector RandomVector (vector vrange)
{
vector newvec;
	newvec_x=random(vrange_x,0-vrange_x);
	newvec_y=random(vrange_y,0-vrange_y);
	newvec_z=random(vrange_z,0-vrange_z);
	return newvec;
}

// Peanut ALL NEW CODE
float  (float num, float div)fmod =  {
	if (num == 0.00000)
		return 0.00000;
	
	while ( (num >= div) ) {

		num = (num - div);

	}
	while ( (num < 0.00000) ) {

		num = (num + div);

	}
	return ( num );
};

float  (float base,float exponent)fexp =  {
	local float exp_count = 0.00000;
	local float value;

	value = base;
	exponent = rint ( exponent);
	if ( (exponent == 0.00000) ) {

		return ( 1.00000 );

	}
	if ( (exponent < 0.00000) ) {

		value = (1.00000 / base);
		exponent = fabs ( exponent);

	}
	if ( (exponent == 1.00000) ) {

		return ( value );

	}
	exponent -= 1.00000;
	while ( (exp_count < exponent) ) {

		exp_count += 1.00000;
		value = (value * base);

	}
	return ( value );
};
// Peanut End of new code
