//---------------Set Variables----------------------



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
fli = flRaw+"/imageJ/step1.0_horizontalAlign/";
flo = flRaw+"/imageJ/step1.1_VerticalAlign/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Open initial------------
open(fli + inImageList[0]);
saveAs("Tiff", flo + "step2_aligned_xyz_" + getTitle());
rename("initial");

//------------Get Parameters------------
width = getWidth;
height = getHeight;
depth = nSlices;

xLength = Math.floor(width/5);
xStart = Math.floor((width - xLength)/2);
yStart = Math.floor(height/2);
zLength = 400;
zStart = Math.floor((depth - zLength)/2);
zEnd = zStart + zLength;

zCenter = Math.floor(depth/2);

//---------Get Slice----------
makeRectangle(xStart, yStart, 1, xLength);
run("Duplicate...", "title=temp duplicate range="+zStart+"-"+zEnd);
run("Reslice [/]...", "output=1.000 start=Left avoid");
rename("InitialSlice");
close("temp");

//--------Get horizontal slice----------
selectWindow("initial");
run("Select All");
setSlice(zCenter);
run("Duplicate...", "title=hCenter");
close("initial");

//------------Open Each Image and align------------
for(imageIndex = 1; imageIndex < inImageList.length; imageIndex ++){
	open(fli + inImageList[imageIndex]);
	imageTitle = getTitle();
	
	//---------Get Slice----------
	makeRectangle(xStart, yStart, 1, xLength);
	run("Duplicate...", "title=temp duplicate range="+zStart+"-"+zEnd);
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("imageSlice");
	close("temp");
	selectWindow("imageSlice");
	run("Select All");
	run("Copy");
	for(i=2;i<=100;i++){
		run("Add Slice");
		run("Paste");
	}
	for(i=1;i<=100;i++){
		setSlice(i);
		run("Translate...", "x=0 y="+(i-50)/5+" interpolation=Bilinear slice");
	}
	
	//Calculate Difference and Crop outside
	imageCalculator("Difference create stack","imageSlice", "InitialSlice");
	rename("difference");
	makeRectangle(2, 20, xLength - 4, zLength - 40);
	
	//Plot the Error and get Minimum y
	run("Plot Z-axis Profile");
	rename("plot");
	Plot.getValues(xPoints,yPoints);
	yMin = yPoints[0];
	yMinIndex = 0;
	for(yIndex=1;yIndex<yPoints.length;yIndex++){
		if(yPoints[yIndex]<yMin){
			yMin = yPoints[yIndex];
			yMinIndex = yIndex;
		}
	}
	
	//Translate the Original Image and save them acoordingly
	selectWindow(imageTitle);
	run("Select All");
	run("Reslice [/]...", "output=1.000 start=Right avoid");
	rename("reslice a");
	run("Translate...", "x=0 y="+(yMinIndex-50)/5+" interpolation=Bilinear stack");
	run("Reslice [/]...", "output=1.000 start=Top flip rotate avoid");
	
	//Close things for now
	close("plot");
	close(imageTitle);
	close("reslice a");
	close("imageSlice");
	close("difference");
	rename(imageTitle);
	
	//Get horizontal Slice
	run("Select All");
	setSlice(zCenter);
	run("Duplicate...", "title=imagehCenter");
	run("Select All");
	run("Copy");
	for(i=2;i<=200;i++){
		run("Add Slice");
		run("Paste");
	}
	for(i=1;i<=200;i++){
		setSlice(i);
		run("Rotate... ", "angle="+(i-100)/20+" grid=1 interpolation=Bilinear slice");
	}
	
	//Calculate Difference and Crop outside
	imageCalculator("Difference create stack","imagehCenter", "hCenter");
	rename("difference");
	
	//Plot the Error and get Minimum y
	run("Plot Z-axis Profile");
	rename("plot");
	Plot.getValues(xPoints,yPoints);
	yMin = yPoints[0];
	yMinIndex = 0;
	for(yIndex=1;yIndex<yPoints.length;yIndex++){
		if(yPoints[yIndex]<yMin){
			yMin = yPoints[yIndex];
			yMinIndex = yIndex;
		}
	}
	
	selectWindow(imageTitle);
	for(i=1;i<=depth;i++){
		setSlice(i);
		run("Rotate... ", "angle="+(yMinIndex-100)/20+" grid=1 interpolation=Bilinear slice");
	}
	saveAs("Tiff", flo + "step2_aligned_xyz_" + imageTitle);
	
	//Close Party
	close();
	close("difference");
	close("plot");
	close("imagehCenter");
}

close();
close();