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
