//---------------Set Variables----------------------
offset = 5;
fitCutoffRatio = 5;


//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a root dir");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------
fli = flRaw + "ImageJ\\";
folderList = getFileList(fli);

for(folderIndex = 0; folderIndex < folderList.length; folderIndex++){
	folderPath = fli + folderList[folderIndex] + "\\0_Original\\";
	
	fileList = getFileList(folderPath);
	for(fileIndex = 0; fileIndex < fileList.length; fileIndex++){
		open(folderPath + fileList[fileIndex]);
		title = getTitle();
		run("8-bit");
		run("Gaussian Blur...", "sigma=8");
		makeRectangle(offset, offset, getWidth() - offset * 2, getHeight() - offset * 2);
		run("Copy");
		for(i=2;i<=360;i++){
			run("Add Slice");
			run("Paste");
		}
		run("Select All");
		for(i=1;i<=360;i++){
			setSlice(i);
			run("Rotate... ", "angle="+(i - 1)+" grid=1 interpolation=None slice");
		}
		setSlice(1);
		run("Z Project...", "projection=[Max Intensity]");
		
		newImage("dark", "8-bit white", 2592, 1944, 1);
		imageCalculator("Subtract create", "dark","MAX_" + title);
		selectWindow("Result of dark");
		
		radiusStart = floor((getWidth()/2) * (1/fitCutoffRatio));
		radiusEnd = floor(getWidth()/2);
		radiusRange = radiusEnd - radiusStart + 1;
		radiusList = newArray(radiusRange);
		valueList = newArray(radiusRange);
		
		counter = 0;
		for(radius = radiusStart; radius < radiusEnd; radius++){
			x = floor((getWidth()/2) + radius);
			y = floor((getHeight()/2));
			radiusList[counter] = radius;
			valueList[counter] = getValue(x,y);
			counter = counter + 1;
		}
		Fit.doFit("2nd Degree Polynomial", radiusList, valueList);
		Fit.plot();
		
		newImage("black", "8-bit black", 2592, 1944, 1);
		valueC = Fit.p(2);
		print(valueC);
		centerX = floor(getWidth()/2);
		centerY = floor(getHeight()/2);
		for(x = 0; x < getWidth(); x ++){
			dx = x - centerX;
			dx2= dx * dx;
			for(y = 0; y < getHeight(); y++){
				dy = y - centerY;
				dy2= dy*dy;
				radius = sqrt(dx2 + dy2);
				value = radius * radius * valueC;
				setPixel(x, y, value);
			}
		}
		exit;
	}
	exit;
}


//3rd Degree Polynomial
//saveAs("Tiff", floPlot+subFolder+"_plot_zx 2.tif");
xStart = Fit.p(0);
xSlope = Fit.p(1);


selectWindow("frame0001.tif");
run("Duplicate...", " ");
selectWindow("frame0001-1.tif");
imageCalculator("Add create", "Result of dark","frame0001-1.tif");

return;
print("returned");
exit;
print("exited");
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