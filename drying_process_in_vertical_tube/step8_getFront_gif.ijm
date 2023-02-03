fli = "R:/0_Information/from_Nasir-san/Experiment_3/";
for(i=3;i<=3;i++){
	zero = "";
	if(i<10){
		zero = "0";
	}
	fName = "time_"+zero+""+i+"_step7_Front.tif";
	open(fli+fName);
	if(false){
		//waitForUser("Title", "Message");
		run("3D Viewer");
		call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
		waitForUser("Alert", "Change Background Color to White");
	}
	
	//get title and add slices
	titleOriginal = getTitle;
	
	//Scale
	run("Scale...", "x=.5 y=.5 z=.5 interpolation=Bilinear average process");
	rename("scaled");
	close(titleOriginal);
	
	//Binarize
	setAutoThreshold("Default dark");
	setThreshold(1, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	rename("Binarized");
	
	//Add Slices
	setSlice(nSlices);
	while(true){
		run("Add Slice");
		if(nSlices>=1915){
			break;
		}
	}
	
	//Reslice
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	close("Binarized");
	rename("Resliced");
	
	//replace dots on corners
	setSlice(1);
	setPixel(0,0,1);
	setSlice(nSlices);
	setPixel(getWidth-1,getHeight-1,1);
	
	call("ij3d.ImageJ3DViewer.add", "Resliced", "Blue", "Result-rgb", "0", "true", "true", "true", "1", "0");
	close("Resliced");
	waitForUser("Adjust View");
	
	call("ij3d.ImageJ3DViewer.record360");
	call("ij3d.ImageJ3DViewer.select", "Result-rgb");
	call("ij3d.ImageJ3DViewer.delete");
	call("ij3d.ImageJ3DViewer.resetView");
	
	//Save and Close
	rename(titleOriginal);
	makeRectangle(206, 0, 100, 512);
	run("Crop");
	run("Animated Gif ... ", "name=Name set_global_lookup_table_options=[Do not use] optional=[] image=[No Disposal] set=100 number=-1 transparency=[No Transparency] red=0 green=0 blue=0 index=0 filename=[R:/0_Information/from_Nasir-san/Experiment_3/"+titleOriginal+".gif]");
	close(titleOriginal);
}