//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

//Base image for subtraction
matrixFile = 4;
//File list
fileList = newArray(5,6,7,9,11,13,16,19,25);

//Base image for subtraction
matrixFile = 8;
//File list
fileList = newArray(10,12,14,17,20,26);

//Base image for subtraction
matrixFile = 15;
//File list
fileList = newArray(18,21,27);

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
fileNameMatrix = "XY_"+matrixFile+"_step4_Matrix.tif";
open(path+fileNameMatrix);
run("Duplicate...", "title=maskNonMatrix duplicate");
run("Invert", "stack");
run("Divide...", "value=255 stack");
close(fileNameMatrix);

for(fileIndex = 0; fileIndex<fileList.length;fileIndex++){
	//Open Air file and prepare for Image Calculation
	fileNameAir = "XY_"+fileList[fileIndex]+"_step4_Air.tif";
	open(path+fileNameAir);
	run("Duplicate...", "title=maskNonAir duplicate");
	run("Invert", "stack");
	run("Divide...", "value=255 stack");
	close(fileNameAir);
	
	//Open file
	fileName = "XY_"+fileList[fileIndex]+"_step3_denoised.tif";
	newName = "XY_"+fileList[fileIndex]+"_step4_Water.tif";
	print("Opening Image ["+fileName+"]");
	open(path+fileName);
	rename(newName);

	//Remove Matrix
	imageCalculator("Multiply stack", newName,"maskNonMatrix");
	imageCalculator("Multiply stack", newName,"maskNonAir");
	resetMinAndMax();

	//Save image and close
	saveAs("Tiff", path + newName);
	close("maskNonAir");
	close(newName);
}
close("maskNonMatrix");