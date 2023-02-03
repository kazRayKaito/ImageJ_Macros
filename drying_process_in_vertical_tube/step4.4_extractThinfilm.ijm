//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";
gRadius = 2;

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
run("Duplicate...", "title=matrix duplicate");
close(fileNameMatrix);
run("Gaussian Blur 3D...", "x="+gRadius+" y="+gRadius+" z="+gRadius);

//Binarize
setThreshold(1, 255);
run("Convert to Mask", "background=Dark black");

for(fileIndex = 0; fileIndex<fileList.length;fileIndex++){
	//Open Air file and prepare for Image Calculation
	fileNameAir = "XY_"+fileList[fileIndex]+"_step4_Air.tif";
	open(path+fileNameAir);
	run("Duplicate...", "title=filmRegion duplicate");
	close(fileNameAir);
	run("Gaussian Blur 3D...", "x="+gRadius+" y="+gRadius+" z="+gRadius);
	
	//Binarize
	setThreshold(1, 255);
	run("Convert to Mask", "background=Dark black");

	//GetThinFilmRegion
	imageCalculator("AND stack", "filmRegion", "matrix");
	
	//Open file
	fileNameWater = "XY_"+fileList[fileIndex]+"_step4_Water.tif";
	newNameFilm = "XY_"+fileList[fileIndex]+"_step4_WaterFilm.tif";
	newNameNonFilm = "XY_"+fileList[fileIndex]+"_step4_WaterNonFilm.tif";
	print("Opening Image ["+fileNameWater+"]");
	open(path+fileNameWater);

	//Binarize
	setThreshold(0, 0);
	run("Convert to Mask", "background=Dark black");
	run("Invert", "stack");

	//Prepare film and non film images
	rename(newNameFilm);
	run("Duplicate...", "title="+newNameNonFilm+" duplicate");

	//Image calculation
	imageCalculator("AND stack", newNameFilm, "filmRegion"); 
	imageCalculator("Subtract stack", newNameNonFilm, "filmRegion");
	close("filmRegion");	

	//Save image and close
	selectWindow(newNameFilm);
	saveAs("Tiff", path + newNameFilm);
	selectWindow(newNameNonFilm);
	saveAs("Tiff", path + newNameNonFilm);
	close(newNameFilm);
	close(newNameNonFilm);
}
close("matrix");