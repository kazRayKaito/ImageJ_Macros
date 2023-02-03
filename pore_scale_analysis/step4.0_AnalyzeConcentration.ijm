//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a Directory for a folder which contains folder [initial, 0, 1,2,...]");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------
fli = flRaw+"/imageJ/step3_cropOutNoise/";
//fli = flRaw+"/imageJ/step2_filterAndSubtract/";
flo = flRaw+"/imageJ/step4_AnalyzeConcentration/";
inImageList = getFileList(fli);

File.makeDirectory(flo);

//------------Analyze Concentration over Z-Axis
run("Clear Results");
setOption("ShowRowNumbers", false);
maxC = -1;

for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	
	//Open inImage and apply filter
	print("Processing inImage:"+inImage);
	open(fli + inImage + ".tif");
	imageTitle = getTitle;

	//Get Sideview Sum
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("sideView");
	run("Z Project...", "projection=[Sum Slices]");
	rename("sideViewSum");
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("sideView-resliced");
	run("Z Project...", "projection=[Sum Slices]");
	rename("Z-AxisSum");
	makeLine(0, 0, getWidth, 0);

	//get totalMass
	totalMass = 0;
	for(zIndex = 0; zIndex < getWidth; zIndex++){
		totalMass += getValue(zIndex, 0);
	}

	//get z-mean (first central moment)
	firstMoment = 0;
	for(zIndex = 0; zIndex < getWidth; zIndex++){
		firstMoment += zIndex * getValue(zIndex, 0) / totalMass;
	}
	zMean = firstMoment;
	zMeanUp = (992 - zMean)/10;
	print(zMeanUp);

	//get spatial variance (second central moment)
	secondMoment = 0;
	for(zIndex = 0; zIndex < getWidth; zIndex++){
		secondMoment += (zIndex - zMean) * (zIndex - zMean) * getValue(zIndex, 0) / totalMass;
	}
	spatialVariance = secondMoment;
	standardDeviation = sqrt(spatialVariance);
	print(spatialVariance/1000);
	//print(standardDeviation); 

	//get skewness (third central moment)
	thirdMoment = 0;
	for(zIndex = 0; zIndex < getWidth; zIndex++){
		thirdMoment += (zIndex - zMean) * (zIndex - zMean)* (zIndex - zMean) * getValue(zIndex, 0) / (spatialVariance * standardDeviation * totalMass);
	}
	skewness = thirdMoment;
	//print(skewness);

	//get kurtosis (forth central moment)
	forthMoment = 0;
	for(zIndex = 0; zIndex < getWidth; zIndex++){
		forthMoment += (zIndex - zMean) * (zIndex - zMean)* (zIndex - zMean)* (zIndex - zMean) * getValue(zIndex, 0) / (spatialVariance * spatialVariance * totalMass) - 3;
	}
	kurtosis = forthMoment + 2973;
	//print(kurtosis);
	
	//Start plotting data
	profile = getProfile();
	if(maxC == -1){
		//Find max
		for(i = 0; i < profile.length; i++){
			if(profile[i] > maxC){
				maxC = profile[i];
			}
		}
	}
	for(i = 0; i < profile.length; i++){
		setResult(""+imageTitle, i, profile[i] / maxC * 100);
	}
	close("Z-AxisSum");
	close("sideView-resliced");
	close("sideViewSum");
	close("sideView");
	close(imageTitle);
}

//Save Results
saveAs("Results", flo+"Concentration_Z-Axis.csv");


//------------Analyze Concentration over X-Axis
run("Clear Results");
setOption("ShowRowNumbers", false);
maxC = -1;


for(inImageIndex = 0; inImageIndex< inImageList.length; inImageIndex++){
	inImage = inImageList[inImageIndex].substring(0, inImageList[inImageIndex].length-4);
	
	//Open inImage and apply filter
	print("Processing inImage:"+inImage);
	open(fli + inImage + ".tif");
	imageTitle = getTitle;

	//Get Topview Sum
	run("Z Project...", "projection=[Sum Slices]");
	rename("topViewSum");
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("topView-resliced");
	run("Z Project...", "projection=[Sum Slices]");
	rename("X-AxisSum");
	makeLine(0, 0, 400, 0);

	//Start plotting data
	profile = getProfile();
	if(maxC == -1){
		//Find max
		for(i = 0; i < profile.length; i++){
			if(profile[i] > maxC){
				maxC = profile[i];
			}
		}
	}
	for(i = 0; i < profile.length; i++){
		setResult(""+imageTitle, i, profile[i] / maxC * 100);
	}
	close("X-AxisSum");
	close("topView-resliced");
	close("topViewSum");
	close(imageTitle);
}

//Save Results
saveAs("Results", flo+"Concentration_X-Axis.csv");


