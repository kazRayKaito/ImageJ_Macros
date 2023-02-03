//path is a directory which contains "XY_num_step1_aligned_xy.tif" files
path  = "R:/0_Information/from_Nasir-san/Experiment_3/";

//Enable BatchMode to run macro in background
setBatchMode(true);

for(timeIndex=20;timeIndex<=20;timeIndex++){
	time = timeIndex;
	if(time<10) time = "0"+time;

	//Open file
	fileName = "time_"+time+"_step4_WaterNonFilm.tif";
	newClusterName = "time_"+time+"_step6_Cluster.tif";
	newLargestName = "time_"+time+"_step6_Largest.tif";
	print("Opening Image ["+fileName+"]");
	open(path+fileName);

	//ExtractLargest
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	rename("label");
	close(fileName);
	selectWindow("label");
	run("Remove Largest Label");
	imageCalculator("Subtract stack", "label","label-killLargest");
	rename(newLargestName);
	
	//Binarize [newLargest]
	setAutoThreshold("Default dark");
	setThreshold(1, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	selectWindow("label-killLargest");
	rename(newClusterName);
	
	//Save Largest and Clusters
	saveAs("Tiff", path + newClusterName);
	close(newClusterName);
	saveAs("Tiff", path + newLargestName);
	close(newLargestName);
}