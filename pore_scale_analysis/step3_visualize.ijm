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
fliOil = flRaw+"/imageJ/step2_OilPhase/";
fliWater = flRaw+"/imageJ/step2_WaterPhase/";
flo = flRaw+"/imageJ/step3.0_Visualize_InvadedPhase/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

imageCount = 0;

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	if(inImage == initialImageName){
		continue;
	}
	imageCount = imageCount + 1;
	print("Processing inImage:"+inImage);

	//Open new Image
	open(fliOil + inImage + ".tif");
	rename("new_oil");
	
	if(imageCount != 1){
		//Open Original Image
		open(fli + inImage + ".tif");
		rename("original");
		run("8-bit");
		
		//Create mask for invaded regions
		imageCalculator("Subtract create stack", "new_oil","old_oil");
		rename("oil_invaded");
		run("Divide...", "value=4 stack");
		imageCalculator("Subtract create stack", "old_oil","new_oil");
		rename("water_inaved");
		run("Divide...", "value=4 stack");
		
		//Merge images
		run("Merge Channels...", "c1=oil_invaded c3=water_inaved c4=original create");
		run("RGB Color", "slices");
		saveAs("Tiff", flo+inImage+".tif");
		close();
		close("old_oil");
		
	}
	selectImage("new_oil");
	rename("old_oil");
}
close("old_oil");
