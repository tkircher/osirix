#import "PSGenerator.h"

@implementation PSGenerator

// Initialization with all parameters. Currently not used.
- (id) initWithFormatString: (NSMutableString *) str
			  sourceStrings: (NSMutableDictionary *) stringDict
				  minLength: (unsigned) min
				  maxLength: (unsigned) max
{
	if ( self = [super init] )  {
		[self setFormatString: str];
		[self setSourceStrings: stringDict];
		[self setMinLength: min];
		[self setMaxLength: max];
		[self setAlternativeNum: 0];
		
		srandom( time(NULL));            // Seeding random number generator
	}
	return self;
}

// Initialization without format String. Normal case.
- (id) initWithSourceString: (NSString *) str
				  minLength: (unsigned) min
				  maxLength: (unsigned) max
{
	if ( self = [super init] )  {
		
		// Setting standard format string "000000...."
		[self setStandardFormatString];
		
		// Creating string dictionary with standard key "0" and object str
		[self setSourceStrings: [NSMutableDictionary dictionaryWithCapacity: 2]];
		[self addStringToDict: str
					  withKey: @"0"];
		
		// Other variables
		[self setMinLength: min];
		[self setMaxLength: max];
		[self setAlternativeNum: 0];
		
		srandom( time(NULL));            // Seeding random number generator
	}
	return self;
}

- (void) dealloc
{
	[formatString release];
	[sourceStringsDict release];
	
	[super dealloc];
}

	////
////// Accessor Methods
	/////////////////////

- (void) setFormatString: (NSMutableString *) str
{
	[formatString autorelease];
	formatString = [str retain];
}

- (void) setStandardFormatString
{
    tempString = [NSMutableString stringWithCapacity: maxLength];
    for ( i=1; i <= maxLength; i++ )
        [tempString appendString: @"0"];
    [self setFormatString: tempString];
}

- (void) setSourceStrings: (NSMutableDictionary *) stringDict
{
	[sourceStringsDict autorelease];
	sourceStringsDict = [stringDict retain];
}

- (void) setMinLength: (unsigned) min
{
	minLength = min;
}

- (void) setMaxLength: (unsigned) max
{
	maxLength = max;
}

- (void) setAlternativeNum: (unsigned) num
{
	alternativeNum = num;
}

- (void) addStringToDict: (NSString *) str
				 withKey: (NSString *) key
{
	if (str)
		[sourceStringsDict setObject: str
							  forKey: key];
}

- (NSString *) mainCharacterString
{
	return [sourceStringsDict objectForKey: @"0"];
}

- (NSString *) altCharacterString
{
	return [sourceStringsDict objectForKey: @"1"];
}

- (unsigned) minLength
{
	return minLength;
}

- (unsigned) maxLength
{
	return maxLength;
}

- (unsigned) alternativeNum
{
	return alternativeNum;
}


	////
////// The Password Generator
	///////////////////////////

- (NSArray *) generate: (unsigned) numPasswords
{
	tempArray   = [NSMutableArray arrayWithCapacity: numPasswords];
	sourceString = [[NSString alloc] init]; [sourceString autorelease]; 
	
    [self setStandardFormatString]; // Ensure that Format string is of correct length 
	
	for ( i = 0; i < numPasswords; i++ )	{
		thisLength = (unsigned) randomNumberBetween( (int)minLength, (int)maxLength );
		tempString = [NSMutableString stringWithCapacity: thisLength];
		
		// If we want alternative characters or format string permutations (those are only planned...)
		if ( ( alternativeNum != 0 ) || ( shouldMix = YES ) )
			[self prepareFormatString]; // creates randomly built tempFormatString
		else	{
			tempFormatString = [[NSMutableString alloc] initWithCapacity: maxLength];
			[tempFormatString  setString: formatString];
		}
		
		for ( j = 0; j < thisLength; j++ )  { // In every loop, one character of the password is created
			  // First we determine the appropriate sourceString for the format String character at position j 
			tempKey = [tempFormatString substringWithRange: NSMakeRange(j,1)];
			sourceString = [sourceStringsDict objectForKey: tempKey];
			  // Then, a character is chosen by random from the sourceString
			randCharPos = (unsigned) randomNumberBetween( 0, (int) [sourceString length] );
			  // Finally, we append the new character to our password
			[tempString appendString: [sourceString substringWithRange: NSMakeRange(randCharPos,1)]];
		}
		// ... and package all passwords in the array we want to return
		[tempArray addObject: tempString];
		[tempFormatString release];
	}
	return tempArray;
}

- (void) prepareFormatString	// Permutation not yet implemented
{
	tempFormatString = [[NSMutableString alloc] initWithCapacity: maxLength];
	[tempFormatString  setString: formatString];
	
	// We need to check that desired number of alternatve characters isn't longer than the password we construct
	if ( alternativeNum < thisLength )  
		tempAltNum = alternativeNum;
	else
		tempAltNum = thisLength;
	
	// This loop is highly inefficient - no one knows when it ends...
	x = 1;
	while ( x <= tempAltNum )   { 
		y = randomNumberBetween( 0, (int)thisLength );
		if ( [[tempFormatString substringWithRange: NSMakeRange(y,1)] isEqualToString: @"0"] )   {
			[tempFormatString replaceCharactersInRange: NSMakeRange(y,1)
											withString: @"1"];
			x++;
		}
	}
}

@end

// C random number generator
int randomNumberBetween ( int low, int high )
{
	int number;
	
	number = (((float)random() / RAND_MAX) * ( high - low ) ) + low;
	if (number > ( high ) ) number = low;
	
	return number;
}
