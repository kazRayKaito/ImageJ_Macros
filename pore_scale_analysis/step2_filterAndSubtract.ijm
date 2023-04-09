//---------------Set Variables----------------------

gb_radius = 0.0;
initialImageName = "0_brine";


//---------------Set Variables----------------------

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
fli = flRaw+"/imageJ/step1.1_VerticalAlign/";
flo = flRaw+"/imageJ/step2_filterAndSubtract/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Open initial and apply filter
open(fli + initialImageName + ".tif");
run("Gaussian Blur 3D...", "x="+gb_radius+" y="+gb_radius+" z="+gb_radius+"");

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	if(inImage == initialImageName){
		continue;
	}
	print("Processing inImage:"+inImage);


	//Open inImage and apply filter
	open(fli + inImage + ".tif");
	run("Gaussian Blur 3D...", "x="+gb_radius+" y="+gb_radius+" z="+gb_radius+"");
	
	//Subtract
	imageCalculator("Subtract create stack", ""+inImage+".tif", initialImageName + ".tif");
	selectWindow(""+inImage+".tif");
	close();
	selectWindow("Result of "+inImage+".tif");
	rename(""+inImage+".tif");
	
	saveAs("Tiff", flo+inImage+".tif");
	close();
}
selectWindow(initialImageName + ".tif");
close();
