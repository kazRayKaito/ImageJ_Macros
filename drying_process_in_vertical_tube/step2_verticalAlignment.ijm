//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

//"3" is the base (reference) for top layer
baseImage = 57;
//"4,5,6,7..." are the images of top layer
folderList = newArray(63, 69, 75, 82);

//Attempt to getArgument
arguments = getArgument();
if(arguments!=""){
	lines = split(arguments,"\n");
	parameter = lines[0];
	path = lines[1]; 
	folderList = split(lines[2],",");
	baseImage = lines[3];
}

function getSlice(folderNumber, sliceName, base){
	//Open base image
	if(base){
		print("Opening Base Image: "+folderNumber+"...");
	}else{
		print("Opening XY images in folder: ["+folderNumber+"]...");
	}
	if(parameter=="0")
		return;
	open(path+"XY_"+folderNumber+"_step1_aligned_xy.tif");
	title = getTitle;
	width = getWidth;
	height = getHeight;
	depth = nSlices;
	
	//Duplicate and Binarize
	makeRectangle(250, 50, 1, 400);
	run("Duplicate...", "title=temp duplicate range=151-550");
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename(sliceName);
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	setAutoThreshold("Otsu dark no-reset stack");
	run("Convert to Mask");
	close("temp");
	if(base){
		selectWindow(title);
		saveAs("Tiff", path + "XY_"+folderNumber+"_step2_aligned_xyz.tif");
		close(getTitle);
	}else{
		run("Select All");
		run("Copy");
		for(i=2;i<=100;i++){
			run("Add Slice");
			run("Paste");
		}
	}
	return title;
}

getSlice(baseImage,"OtsuBinaryBase",true);

for(folderIndex = 0; folderIndex<folderList.length;folderIndex++){
	//Get Slice of Image File and translate them vertically (-10~10);
	originalImageTitle = getSlice(folderList[folderIndex],"OtsuBinary"+folderList[folderIndex],false);
	if(parameter=="0")
		continue;
	for(z=1;z<=100;z++){
		setSlice(z);
		run("Translate...", "x=0 y="+(z-50)/5+" interpolation=Bilinear slice");
	}
	rename("translated");

	//Use Image Calculator to find the Error value for each translation (-10~10);
	imageCalculator("XOR create stack","translated", "OtsuBinaryBase");
	makeRectangle(0, 10, 400, 380);
	run("Crop");
	rename("XOR result");

	//Plot the Error
	run("Plot Z-axis Profile");
	Plot.getValues(xPoints,yPoints);
	yMin = yPoints[0];
	yMinIndex = 0;
	for(yIndex=1;yIndex<yPoints.length;yIndex++){
		if(yPoints[yIndex]<yMin){
			yMin = yPoints[yIndex];
			yMinIndex = yIndex;
		}
	}
	rename("Plot of XOR result");

	//Translate the Original Image and save them acoordingly
	selectWindow(originalImageTitle);
	run("Select All");
	run("Reslice [/]...", "output=1.000 start=Right avoid");
	rename("reslice a");
	run("Translate...", "x=0 y="+(yMinIndex-50)/5+" interpolation=Bilinear stack");
	run("Reslice [/]...", "output=1.000 start=Top flip rotate avoid");
	saveAs("Tiff", path + "XY_"+folderList[folderIndex]+"_step2_aligned_xyz.tif");

	//Close windows
	close(getTitle);
	close(originalImageTitle);
	close("translated");
	close("reslice a");
	close("Plot of XOR result");
	close("XOR result");
}
close("OtsuBinaryBase");