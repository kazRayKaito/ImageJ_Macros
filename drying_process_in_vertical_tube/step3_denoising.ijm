//Directory Location
parameter = "1";
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

//List of files to work on
fileList = newArray(3,4,5,6,7);

//Attempt to getArgument
arguments = getArgument();
if(arguments!=""){
	lines = split(arguments,"\n");
	parameter = lines[0];
	path = lines[1]; 
	fileList = split(lines[2],",");
}

//Defining "DENOISING" function
function denoiseAndDivide_nonLocal(){
	for(i=1;i<=nSlices;i++){
		setSlice(i);
		run("Non-local Means Denoising", "sigma=7000 smoothing_factor=1 slice");
		//wait(500);
	}
	run("Divide...", "value=3 stack");
}
function denoiseAndDivide_outlier(){
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark stack");
	run("Divide...", "value=3 stack");
}

//Defining "THREE WAY RESLICE" function
function threeWayDenoise(){
	//Denoise nonSlice
	originalTitle = getTitle;
	run("Duplicate...", "title=nonSlice duplicate");
	print("Denoising in z direction...");
	denoiseAndDivide_outlier();
	rename("nonSlice_denoised");

	//Denoise rightSlice
	selectWindow(originalTitle);
	run("Reslice [/]...", "output=1.000 start=Right avoid");
	print("Denoising in x direction...");
	denoiseAndDivide_outlier();
	rename("rightSlice");
	run("Reslice [/]...", "output=1.000 start=Top flip rotate avoid");
	rename("rightSlice_denoised");
	close("rightSlice");
	
	//Denoise topSlice
	selectWindow(originalTitle);
	run("Reslice [/]...", "output=1.000 start=Top flip rotate avoid");
	print("Denoising in y direction...");
	denoiseAndDivide_outlier();
	rename("topSlice");
	run("Reslice [/]...", "output=1.000 start=Right avoid");
	rename("topSlice_denoised");
	close("topSlice");

	//Add the results (Averaging)
	imageCalculator("Add stack", "nonSlice_denoised","rightSlice_denoised");
	close("rightSlice_denoised");
	imageCalculator("Add stack", "nonSlice_denoised","topSlice_denoised");
	close("topSlice_denoised");

	//Rename to match the original title
	close(originalTitle);
	selectWindow("nonSlice_denoised");
	rename(originalTitle);
}

for(fileIndex=0;fileIndex<fileList.length;fileIndex++){
	//Get file name
	fileName = "XY_"+fileList[fileIndex]+"_step2_aligned_xyz.tif";

	//Open image file
	print("Opening "+fileName+"...");
	if(parameter=="0")
		continue;
	open(path+fileName);
	
	//Get new name for the third step
	newName = replace(fileName,"step2_aligned_xyz.tif","step3_Denoised.tif");
	rename(newName);
	run("Select None");
	threeWayDenoise();

	//Saved the denoised image and close
	print("Saving "+fileName+"...");
	resetMinAndMax();
	saveAs("Tiff", path + newName);
	close(newName);
}