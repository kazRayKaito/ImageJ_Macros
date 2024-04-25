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
fliOil = flRaw+"/imageJ/step3_OilInvasionPhase/";
fliWater = flRaw+"/imageJ/step3_WaterInvasionPhase/";
flo = flRaw+"/imageJ/step3.1_3D_Visualization/";

floGif = flo + "/Gif/";
floPNG = flo + "/PNG/";

File.makeDirectory(flo);
File.makeDirectory(floGif);
File.makeDirectory(floPNG);

fileListOil = getFileList(fliOil);
fileListWater= getFileList(fliWater);

maxValue = 0;

run("3D Viewer");
call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
waitForUser("Change Background Color", "Change Background Color to White");
for(fileIndex=0;fileIndex<fileListOil.length;fileIndex++){
	action(fliOil,fileListOil[fileIndex], true);
	action(fliWater,fileListWater[fileIndex], false);
}
call("ij3d.ImageJ3DViewer.close");

function action(fli,fileName, isOil){
	print("Opening File");
	open(fli+fileName);
	if(isOil){
		fileName = replace(fileName,".tif","_oil");
	}else{
		fileName = replace(fileName,".tif","_water");
	}
	rename("Original");
	
	//Graphics
	print("Changing Color");
	run("Duplicate...", "duplicate range=125-867");
	rename("Cropped");
	
	//Parepare Mask
	run("Duplicate...", "title=mask duplicate");
	run("Gaussian Blur 3D...", "x=2 y=2 z=2");
	setThreshold(125, 255, "raw");
	run("Convert to Mask", "method=Default background=Default black");
	run("Gaussian Blur 3D...", "x=2 y=2 z=2");
	setThreshold(5, 255, "raw");
	run("Convert to Mask", "method=Default background=Default black");
	run("Divide...", "value=255 stack");
	
	//Apply Mask
	imageCalculator("Multiply stack", "Cropped","mask");
	close("mask");
	
	selectWindow("Cropped");
	if(isOil){
		run("Red");
	}else{
		run("Blue");
	}

	print("Reslicing");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename(fileName);
	close("Original");
	close("Cropped");

	//replace dots on corners
	width = getWidth;
	height = getHeight;
	depth = nSlices;
	setSlice(1);
	setPixel(0,0,1);
	setSlice(depth);
	setPixel(width-1,height-1,1);

	
	print("Adding 3D Model");
	call("ij3d.ImageJ3DViewer.add", getTitle, "White", ""+fileName, "0", "true", "true", "true", "2", "0");
	
	print("Changing Transparency");
	call("ij3d.ImageJ3DViewer.select", ""+fileName);
	call("ij3d.ImageJ3DViewer.setTransparency", "0.66");
	call("ij3d.ImageJ3DViewer.select", "");
	
	print("Record 360");
	call("ij3d.ImageJ3DViewer.record360");
	
	print("Reset View");
	call("ij3d.ImageJ3DViewer.resetView");
	//run("Animated Gif ... ", "name=4_beads_Bo=0.000_BreakThrough set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set=15 number=1 transparency=[Set to index with specified color] red=0 green=0 blue=0 index=0 filename="+floGif+"GIF_"+fileName+".gif");
	saveAs("PNG", floPNG+"PNG_"+fileName+".png");
	call("ij3d.ImageJ3DViewer.select", ""+fileName);
	
	//Close Windows
	call("ij3d.ImageJ3DViewer.delete");
	close();
	close();
}