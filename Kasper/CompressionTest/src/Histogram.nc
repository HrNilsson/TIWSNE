interface Histogram {
	
	command void accumulate(uint8_t pixelValue);
	
	event bool done();
	
	
	
}