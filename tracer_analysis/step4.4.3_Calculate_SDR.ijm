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
	//run("Calibrate...", "function=[Straight Line] unit=% text1=[0\015 5323.937986\015 10541.70416\015 15874.17306\015 20345.53182\015 24379.83788] text2=[0\015 2\015 4\015 6\015 8\015 10\015 \015 ]");
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
	imageCalculator("Add create 32-bit", "Result of dx1","Result of dy1");
	//if(inImageIndex == 8) waitForUser("string");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	run("Rotate 90 Degrees Right");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	run("Divide...", "value=5943765");
	
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
saveAs("Results", flo+"SDR.csv");

