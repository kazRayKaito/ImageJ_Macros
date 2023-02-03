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
	
	run("Z Project...", "projection=[Sum Slices]");
	run("Duplicate...", "title=sum");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	run("Rotate 90 Degrees Right");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	run("Z Project...", "projection=[Sum Slices]");
	totalBrightness = getPixel(0, 0);
	print(totalBrightness);
	close();
	close();
	close();
	close();
	close();
	close();
	run("Duplicate...", "title=p duplicate");
	run("32-bit");
	run("Divide...", "value="+totalBrightness+" stack");
	run("Duplicate...", "title=ln(p) duplicate");
	run("Log", "stack");
	imageCalculator("Multiply create stack", "p","ln(p)");
	DI = 0;
	for(z = 0; z < nSlices; z++){
	//for(z = 910; z < 911; z++){
	setSlice(z+1);
		for(x = 0; x < getWidth; x++){
			for(y = 0; y < getWidth; y++){
				if(isNaN(getValue(x,y))){
					continue; 
				}else{
					DI += getValue(x,y);
				}
			}
		}
	}
	setResult(""+imageTitle, 0, exp(-DI));
	
	close();
	close();
	close();
	close();
}

//Save Results
saveAs("Results", flo+"DI.csv");

