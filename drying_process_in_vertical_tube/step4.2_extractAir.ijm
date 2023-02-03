//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

/*
//Base image for subtraction
matrixFile = 4;
//File list
fileList = newArray(5, 6, 7, 9, 11, 13, 16, 19, 22, 25, 29, 33, 37, 42, 47, 52, 58, 64, 70, 77);


//Base image for subtraction
matrixFile = 8;
//File list
fileList = newArray(10, 12, 14, 17, 20, 23, 26, 30, 34, 38, 43, 48, 53, 59, 65, 71, 78);



//Base image for subtraction
matrixFile = 15;
//File list
fileList = newArray(18, 21, 24, 27, 31, 35, 39, 44, 49, 54, 60, 66, 72, 79);


//Base image for subtraction
matrixFile = 28;
//File list
fileList = newArray(32, 36, 40, 45, 50, 55, 61, 67, 73, 80);


//Base image for subtraction
matrixFile = 41;
//File list
fileList = newArray(46, 51, 56, 62, 68, 74, 81);


//Base image for subtraction
matrixFile = 57;
//File list
fileList = newArray(63, 69, 75, 82);


//Base image for subtraction
matrixFile = 76;
//File list
fileList = newArray(1);
fileList[0]=83;
*/

//Attempt to getArgument
arguments = getArgument();
if(arguments!=""){
	lines = split(arguments,"\n");
	parameter = lines[0];
	path = lines[1]; 
	fileList = split(lines[2],",");
	matrixFile = lines[3];
}

//Open base image and prepare for image Calculation
matrixFileName = "XY_"+matrixFile+"_step4_Matrix.tif";
open(path+matrixFileName);
run("Duplicate...", "title=mask duplicate");
run("Invert", "stack");
run("Divide...", "value=255 stack");
close(matrixFileName);

for(fileIndex = 0; fileIndex<fileList.length;fileIndex++){
	//Open file
	fileName = "XY_"+fileList[fileIndex]+"_step3_denoised.tif";
	newName = "XY_"+fileList[fileIndex]+"_step4_Air.tif";
	print("Opening Image ["+fileName+"]");
	open(path+fileName);
	rename(newName);

	//Remove Matrix
	imageCalculator("Multiply stack", newName,"mask");
	resetMinAndMax();
	
	setAutoThreshold("Otsu dark stack");
	run("Convert to Mask", "method=Default background=Default black");
	run("Invert", "stack");
	imageCalculator("Multiply stack", newName,"mask");

	//Keep Largest
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	rename("label");
	close(newName);
	newImage(newName, "8-bit black", getWidth, getHeight, nSlices);
	
	while(true){
		//Extract [newLargest] from [label]
		selectWindow("label");
		run("Remove Largest Label");
		imageCalculator("Subtract stack", "label","label-killLargest");
		selectWindow("label");
		rename("newLargest");
		selectWindow("label-killLargest");
		rename("label");
	
		//Binarize [newLargest]
		selectWindow("newLargest");
		setAutoThreshold("Default dark");
		//run("Threshold...");
		setThreshold(1, 65535);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
	
		//Count size and break if needed
		run("Histogram", "bins=2 stack");
		Plot.getValues(values, counts);
		close("Histogram of newLargest");
		if(counts[1]<10000){
			close("newLargest");
			close("label");
			break;
		}
		imageCalculator("Add stack", newName,"newLargest");
		close("newLargest");
	}

	//Save image and close
	saveAs("Tiff", path + newName);
	close(newName);
}
close("mask");