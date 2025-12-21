//---------------Set Variables----------------------



//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a folder which contains [0_brine, 1_xxxx, 2_xxxx]");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------
fli = flRaw+"/imageJ/step1.0_horizontalAlign/";
flo = flRaw+"/imageJ/step1.1_VerticalAlign/";
floPlot = flRaw+"/imageJ/step1.1_VerticalAlign_Plots/";
inImageList = getFileList(fli);

File.makeDirectory(flo);
File.makeDirectory(floPlot);

//------------Open initial------------
open(fli + inImageList[0]);
saveAs("Tiff", flo + getTitle());
rename("initial");

//------------Get Parameters------------
width = getWidth;
height = getHeight;
depth = nSlices;

yLength = Math.floor(width/5);
xStart = Math.floor(height/2);
yStart = Math.floor((width - yLength)/2);

zLength = 600;
zStart = Math.floor((depth - zLength)/2);
zEnd = zStart + zLength;

zCenter = Math.floor(depth/2);

//---------Get Slice----------
makeRectangle(xStart, yStart, 1, yLength);
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
	makeRectangle(xStart, yStart, 1, yLength);
	run("Duplicate...", "title=temp duplicate range="+zStart+"-"+zEnd);
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("imageSlice");
	close("temp");
	selectWindow("imageSlice");
	run("Select All");
	run("Copy");
	for(i=2;i<=1000;i++){
		run("Add Slice");
		run("Paste");
	}
	for(i=1;i<=1000;i++){
		setSlice(i);
		run("Translate...", "x=0 y="+(i-500)/5+" interpolation=Bilinear slice");
	}
	
	//Calculate Difference and Crop outside
	imageCalculator("Difference create stack","imageSlice", "InitialSlice");
	rename("difference");
	makeRectangle(2, 100, yLength - 4, zLength - 200);
	
	//Plot the Error and get Minimum y
	run("Plot Z-axis Profile");
	saveAs("Tiff", floPlot+imageTitle+"_plot_vertical.tif");
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
	run("Translate...", "x=0 y="+(yMinIndex-500)/5+" interpolation=Bilinear stack");
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
	for(i=2;i<=600;i++){
		run("Add Slice");
		run("Paste");
	}
	for(i=1;i<=600;i++){
		setSlice(i);
		run("Rotate... ", "angle="+(i-200)/20+" grid=1 interpolation=Bilinear slice");
	}
	
	//Calculate Difference and Crop outside
	imageCalculator("Difference create stack","imagehCenter", "hCenter");
	rename("difference");
	
	//Plot the Error and get Minimum y
	run("Plot Z-axis Profile");
	saveAs("Tiff", floPlot+imageTitle+"_plot_rotational.tif");
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
		run("Rotate... ", "angle="+(yMinIndex-200)/20+" grid=1 interpolation=Bilinear slice");
	}
	saveAs("Tiff", flo + imageTitle);
	//waitForUser;
	
	//Close Party
	close();
	close("difference");
	close("plot");
	close("imagehCenter");
}

close();
close();