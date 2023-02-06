//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a Directory for a folder which contains folder [initial, 0, 1,2,...]");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------
fli = flRaw+"/imageJ/step3_cropOutNoise/";
//fli = flRaw+"/imageJ/step2_filterAndSubtract/";
flo = flRaw+"/imageJ/step4_AnalyzeConcentration/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Calculate SDR
run("Clear Results");
setOption("ShowRowNumbers", false);

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	
	//Open inImage and apply filter
	print("Processing inImage:"+inImage);
	open(fli + inImage + ".tif");
	imageTitle = getTitle;
	wh = getWidth()*getHeight();

	//Get Topview Average
	run("Z Project...", "projection=[Average Intensity]");
	run("Duplicate...", "title=dxdy0");
	run("Duplicate...", "title=dx1");
	run("Translate...", "x=1 y=0 interpolation=None");
	selectWindow("dxdy0");
	run("Duplicate...", "title=dy1");
	run("Translate...", "x=0 y=1 interpolation=None");
	imageCalculator("Difference create", "dx1","dxdy0");
	selectWindow("Result of dx1");
	imageCalculator("Difference create", "dy1","dxdy0");
	selectWindow("Result of dx1");
	run("Square");
	selectWindow("Result of dy1");
	run("Square");
	imageCalculator("Add create 32-bit", "Resuslt of dx1","Result of dy1");
	selectWindow("Result of Result of dx1");
	run("Square Root");
	if(inImageIndex == 8) waitForUser("string");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	run("Rotate 90 Degrees Right");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	
	//SAVE DATA
	setResult(""+imageTitle, 0, getPixel(0, 0)/wh);
	
	close();
	close();
	close();
	close();
	close();
	close();
	close();
	close();
	close();
	close();
	close();
	close();
}

//Save Results
saveAs("Results", flo+"DSR.csv");

