//----------For batch, get rootFoler----------------
cropWindow = newArray(296, 296, 400, 400);//[x, y, width, height]
gb_radius = 2.0;

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
fli = flRaw+"/imageJ/step1_horizontalAlign/";
flo = flRaw+"/imageJ/step2_filterAndSubtract/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Open initial and apply filter
open(fli + "initial.tif");
run("Gaussian Blur 3D...", "x="+gb_radius+" y="+gb_radius+" z="+gb_radius+"");
rename("initial");

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	if(inImage == "initial"){
		continue;
	}
	print("Processing inImage:"+inImage);


	//Open inImage and apply filter
	open(fli + inImage + ".tif");
	run("Gaussian Blur 3D...", "x="+gb_radius+" y="+gb_radius+" z="+gb_radius+"");
	
	//Subtract
	imageCalculator("Subtract create stack", ""+inImage+".tif", "initial");
	selectWindow(""+inImage+".tif");
	close();
	selectWindow("Result of "+inImage+".tif");
	rename(""+inImage+"_gb="+gb_radius+".tif");
	
	saveAs("Tiff", flo+inImage+"_gb="+gb_radius+".tif");
	close();
}
selectWindow("initial");
close();
