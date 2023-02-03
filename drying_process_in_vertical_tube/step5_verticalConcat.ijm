//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

time = 7;
folderList = newArray(13,14,15);

//Attempt to getArgument
arguments = getArgument();
if(arguments!=""){
	lines = split(arguments,"\n");
	parameter = lines[0];
	path = lines[1]; 
	folderList = split(lines[2],",");
	time = parseInt(lines[3]);
}

sliceStartList = newArray(folderList.length);
stepList = newArray("_step4_Air.tif","_step4_WaterFilm.tif","_step4_WaterNonFilm.tif");

for(folderIndex = 0; folderIndex<folderList.length;folderIndex++){
	//Open file
	open(path+"XY_"+folderList[folderIndex]+"_step2_aligned_xyz.tif");
	rename(folderIndex);
	if(folderIndex==0){
		//Cut top 50;
		sliceStartList[folderIndex] = 51;
		continue;
	}else{
		//Get slices
		getSlice(folderIndex-1,false);
		getSlice(folderIndex,true);
		for(z=1;z<=21;z++){
			setSlice(z);
			run("Translate...", "x=0 y="+(z-11)+" interpolation=Bilinear slice");
		}
		
		//Use Image Calculator to find the Error value for each translation (-10~10);
		imageCalculator("XOR create stack","top", "bottom");
		close("top");
		close("bottom");
		makeRectangle(0, 10, 400, 40);
		run("Crop");
		rename("XOR result");
	
		//Plot the Error
		run("Plot Z-axis Profile");
		Plot.getValues(xPoints,yPoints);
		rename("Plot");
		close("Plot");
		close("XOR result");
		yMin = yPoints[0];
		yMinIndex = 0;
		for(yIndex=1;yIndex<yPoints.length;yIndex++){
			if(yPoints[yIndex]<yMin){
				yMin = yPoints[yIndex];
				yMinIndex = yIndex;
			}
		}
		print(51-(yMinIndex-11));
		selectWindow(folderIndex);
		run("Select None");
		sliceStartList[folderIndex] = (51-(yMinIndex-11));
		continue;
	}
}
for(folderIndex = 0; folderIndex<folderList.length;folderIndex++){
	close(folderIndex);
}
if(time<10) time = "0"+time;
for(stepIndex = 0;stepIndex<stepList.length;stepIndex++){
	for(folderIndex = 0; folderIndex<folderList.length;folderIndex++){
		//Open file
		open(path+"XY_"+folderList[folderIndex]+""+stepList[stepIndex]);
		rename(folderIndex);
		run("Duplicate...", "title="+folderIndex+"_afterCut duplicate range="+sliceStartList[folderIndex]+"-600");
		close(folderIndex);
		//Concatenate them
		if(folderIndex>0){
			run("Concatenate...", "  title=0_temp open image1=0_afterCut image2="+folderIndex+"_afterCut image3=[-- None --]");
			rename("0_afterCut");
		}
	}
	rename("time_"+time+""+stepList[stepIndex]);
	saveAs("Tiff", path + "time_"+time+""+stepList[stepIndex]);
	close();
}

function getSlice(layerNumber, top){
	//Open image
	print("Opening XY images in folder: ["+layerNumber+"]...");
	
	if(parameter=="0")
		return;
	selectWindow(layerNumber);
	width = getWidth;
	height = getHeight;
	depth = nSlices;
	
	//Duplicate and slice
	makeRectangle(250, 50, 1, 400);
	if(top){
		run("Duplicate...", "title=temp duplicate range=21-80");
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		rename("top");
	}else{
		run("Duplicate...", "title=temp duplicate range=571-630");
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		rename("bottom");
	}
	close("temp");
	
	//filter the slice
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	setAutoThreshold("Otsu dark no-reset stack");
	run("Convert to Mask");
	
	//Duplicate slice
	run("Select All");
	run("Copy");
	for(i=0;i<20;i++){
		run("Add Slice");
		run("Paste");
	}
}