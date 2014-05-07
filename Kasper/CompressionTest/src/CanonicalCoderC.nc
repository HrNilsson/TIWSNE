module CanonicalCoderC @safe() {
	
		provides interface CanonicalCoder;
	
}


implementation{
	
	int tree[256]; // import from h-file
	int code[256];
	
	void makeAlphabet(int * hist)
	{
		int i;
		for(i = 0 ; i < 256; i++)
		{
			code[hist[i]] = tree[i]; 			
			
			
		};
		
	
	}
	
	void makeTree(void)
	{
		// HJÆLP RENE ! ! !
		// Dummy code
		
	}
	
		
	void encodeImage(int * alphabet)
	{
	
	
	}
	
	
	
}