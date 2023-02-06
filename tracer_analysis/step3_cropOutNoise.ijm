//----------Parameters for filters----------------
gb_radius = 2;

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
fli = flRaw+"/imageJ/step2_filterAndSubtract/";
flo = flRaw+"/imageJ/step3_cropOutNoise/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Open images and crop out the noise


for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	
	//Open inImage and apply filter
	print("Processing inImage:"+inImage);
	open(fli + inImage + ".tif");

	// Duplicate and apply filter
	imageTitle = getTitle;
	run("Duplicate...", "title=copy duplicate");
	run("Gaussian Blur 3D...", "x="+gb_radius+" y="+gb_radius+" z="+gb_radius+"");
	
	// Binarize and get largest
	makeRectangle(0, 0, 400, 400);
	//makeOval(10, 10, 380, 380);
	setAutoThreshold("Otsu dark stack");
	run("Convert to Mask", "method=Otsu background=Dark black");
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	run("Keep Largest Label");
	
	//Close windows
	selectWindow("copy-lbl");
	close();
	selectWindow("copy");
	close();
	rename("copy");
	
	//Apply mask
	run("16-bit");
	run("Divide...", "value=255.000 stack");
	imageCalculator("Multiply create stack", ""+imageTitle,"copy");

	//Save and close
	saveAs("Tiff", flo+inImage+"_cropOutNoise.tif");
	close();
	close();
	close();
}
