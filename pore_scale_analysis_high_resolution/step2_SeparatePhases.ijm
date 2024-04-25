//---------------Set Variables----------------------

initialImageName = "0_brine";


//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a Directory for a folder which contains [imageJ] Folder");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------
fli = flRaw+"/imageJ/step1.1_VerticalAlign/";
floOil = flRaw+"/imageJ/step2_OilPhase/";
floWater = flRaw+"/imageJ/step2_WaterPhase/";
inImageList = getFileList(fli);

File.makeDirectory(floOil);
File.makeDirectory(floWater);

//------------Open 0_brine, Binarize, Save
open(fli + initialImageName + ".tif");
run("Duplicate...", "title=mask duplicate");
setAutoThreshold("Otsu dark stack");
run("Make Binary", "method=Otsu background=Dark black");
saveAs("Tiff", floOil+initialImageName+".tif");
saveAs("Tiff", floWater+initialImageName+".tif");

//------------Prepare Mask
rename("mask");
run("Invert", "stack");
run("Divide...", "value=255 stack");
makeOval(15, 15, 690, 690);
run("Clear Outside", "stack");

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	if(inImage == initialImageName){
		continue;
	}
	print("Processing inImage:"+inImage);


	//Open inImage
	open(fli + inImage + ".tif");
	
	//Subtract and Binarize
	imageCalculator("Subtract stack", ""+inImage+".tif", initialImageName + ".tif");
	setAutoThreshold("Otsu dark stack");
	run("Make Binary", "method=Otsu background=Dark black");
	imageCalculator("Multiply stack", ""+inImage+".tif","mask");
	
	//Save as an oil phase
	saveAs("Tiff", floOil+inImage+".tif");
	
	//Get waterphase
	rename("waterPhase");
	run("Invert", "stack");
	imageCalculator("Multiply stack", "waterPhase","mask");
	saveAs("Tiff", floWater+inImage+".tif");
	close();
}
close(initialImageName + ".tif");
close("mask");
