//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";
print("\\Clear");

//Enable BatchMode to run macro in background
setBatchMode(true);

for(timeIndex=1;timeIndex<=20;timeIndex++){
	time = timeIndex;
	if(time<10) time = "0"+time;

	//Open files
	fileNameFilm = "time_"+time+"_step4_WaterFilm.tif";
	fileNameLargest = "time_"+time+"_step6_Largest.tif";
	newNameFront = "time_"+time+"_step7_Front.tif";
	print("Opening Image ["+fileNameFilm+"]");
	open(path+fileNameFilm);
	rename("film");
	open(path+fileNameLargest);
	rename("largest");

	//Dilate film after top reslice
	selectWindow("film");
	run("Reslice [/]...", "output=1.000 start=Top flip rotate avoid");
	rename("topSlice");
	run("Dilate", "stack");
	run("Reslice [/]...", "output=1.000 start=Right avoid");
	rename("topSlice_dilate");
	close("topSlice");

	//Dilate film
	selectWindow("film");
	run("Dilate", "stack");

	//Combine them
	imageCalculator("OR stack", "film","topSlice_dilate");
	close("topSlice_dilate");

	//GetFilm
	imageCalculator("AND stack", "film","largest");
	saveAs("Tiff", path + newNameFront);
	close(newNameFront);
	close("largest");

}