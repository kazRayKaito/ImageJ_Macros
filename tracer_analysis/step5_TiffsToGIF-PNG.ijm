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
flo = flRaw+"/imageJ/step5_Visualization/";
inImageList = getFileList(fli);

floGif = flo + "/Gif/";
floPNG = flo + "/PNG/";

File.makeDirectory(flo);
File.makeDirectory(floGif);
File.makeDirectory(floPNG);

fileList = getFileList(fli);

maxValue = 0;

run("3D Viewer");
call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
waitForUser("Change Background Color", "Change Background Color to White");
for(fileIndex=0;fileIndex<fileList.length;fileIndex++){
	action(fli,fileList[fileIndex]);
}
call("ij3d.ImageJ3DViewer.close");

function action(fli,fileName){
	open(fli+fileName);
	fileName = replace(fileName,".tif","");

	//Get the max value
	if(maxValue == 0){
		for(sliceIndex = 0; sliceIndex < nSlices; sliceIndex++){
			setSlice(sliceIndex + 1);
			getStatistics(area, mean, min, max, std, histogram);
			if(max > maxValue) maxValue = max;
		}
	}
	
	//Graphics
	setMinAndMax(0, maxValue);
	run("16_colors");
	run("RGB Color");
	run("Reslice [/]...", "output=1.000 start=Top avoid");

	//replace dots on corners
	width = getWidth;
	height = getHeight;
	depth = nSlices;
	setSlice(1);
	setPixel(0,0,1);
	setSlice(depth);
	setPixel(width-1,height-1,1);
	
	call("ij3d.ImageJ3DViewer.add", getTitle, "White", "Result-rgb", "0", "true", "true", "true", "1", "0");
	call("ij3d.ImageJ3DViewer.record360");
	call("ij3d.ImageJ3DViewer.resetView");
	//run("Animated Gif ... ", "name=4_beads_Bo=0.000_BreakThrough set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set=15 number=1 transparency=[Set to index with specified color] red=0 green=0 blue=0 index=0 filename="+floGif+"GIF_"+fileName+".gif");
	saveAs("PNG", floPNG+"PNG_"+fileName+".png");
	call("ij3d.ImageJ3DViewer.select", "Result-rgb");
	
	//Close Windows
	call("ij3d.ImageJ3DViewer.delete");
	close();
	close();
	close();
}