//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

//File list
fileList = newArray(4,8,15,28,41,57,76);

//Attempt to getArgument
arguments = getArgument();
if(arguments!=""){
	lines = split(arguments,"\n");
	parameter = lines[0];
	path = lines[1]; 
	fileList = split(lines[2],",");
}

for(fileIndex = 0; fileIndex<fileList.length;fileIndex++){
	//Open file
	fileName = "XY_"+fileList[fileIndex]+"_step3_denoised.tif";
	newName = "XY_"+fileList[fileIndex]+"_step4_Matrix.tif";
	print("Opening Image ["+fileName+"]");
	open(path+fileName);

	//GetImageInfo
	depth = nSlices;
	width = getWidth;
	height= getHeight;

	//Parameters
	centerX = width/2;
	centerY = height/2;
	radius = 241;

	//Gaussian Blur
	run("Gaussian Blur 3D...", "x=2 y=2 z=2");

	//Get threshold and Binarize
	setSlice(floor(depth/2));
	makeOval(centerX-radius*0.8,centerY-radius*0.8,radius*2*0.8,radius*2*0.8);
	setAutoThreshold("Otsu dark");
	run("Convert to Mask", "method=Default background=Default black");

	//clear outside then invert again
	run("Invert", "stack");
	makeOval(centerX-radius,centerY-radius,radius*2,radius*2);
	run("Clear Outside", "stack");
	run("Select None");
	run("Invert", "stack");

	//Save image and close
	saveAs("Tiff", path + newName);
	close(newName);
}