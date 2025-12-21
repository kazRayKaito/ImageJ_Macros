//---------------Set Variables----------------------

//For Debugging
checkProgress = false;//true:stop and check, false:auto

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	fliRoot = argument;
	print("Argument Dir:"+fliRoot);
}else{
	print("\\Clear");
	waitForUser("You must run 'step0_master', not individual macro.");
	exit();
}

//----------CheckFolderStructure make imageJ folder----------------

//Check folders and exclude "imageJ" folder
folderListTemp = getFileList(fliRoot);
Array.sort(folderListTemp);
folderList = newArray(0);
for(i = 0; i < folderListTemp.length; i++){
	if(folderListTemp[i] != "imageJ/"){
		folderList = Array.concat(folderList,folderListTemp[i]);
	}
}

//Quit if no folders found
if(folderList.length == 0){
	print("No folders found.");
	print("Exiting.");
	exit();
}else{
	print(folderList.length + " folders found.");
}

//Configure Paths and make Dir
floRoot = fliRoot+"imageJ/step0.0_getStackInfo_EachFolder/";
floSummary = fliRoot+"imageJ/step0.1_getStackInfo_Summary/";
File.makeDirectory(fliRoot+"imageJ/");
File.makeDirectory(floRoot);
File.makeDirectory(floSummary);

processing_0_brine = false;
targetWidthHeight = 0;
totalDepth = 0;

//Define Array
grandArray_subFolderName = newArray(folderList.length);
grandArray_targetWidthHeight = newArray(folderList.length);
grandArray_x_start = newArray(folderList.length);
grandArray_x_slope = newArray(folderList.length);
grandArray_y_start = newArray(folderList.length);
grandArray_y_slope = newArray(folderList.length);

for(folderIndex = 0; folderIndex< folderList.length; folderIndex++){
	
	//Get subFolder name, and subFolder/XY/ path
	subFolder = folderList[folderIndex].substring(0, folderList[folderIndex].length - 1);
	subFolderPath = fliRoot + "/" + subFolder + "/XY/";
	flo = floRoot + "/" + subFolder + "/";
	File.makeDirectory(flo);
	
	//Start Processing
	print("Processing subfolder:"+subFolder);
	
	processing_0_brine = (subFolder == "0_brine");
	
	//Check files in subfolder and remove if its not .tif file
	imageListTemp = getFileList(subFolderPath);
	imageList = newArray(0);
	for(i = 0; i < lengthOf(imageListTemp); i++){
		if(endsWith(imageListTemp[i], "tif")){
			imageList = Array.concat(imageList,imageListTemp[i]);
		}
	}
	
	//Get title, width height depth
	open(subFolderPath + imageList[0]);	
	title = subFolder;
	width = getWidth;
	height = getHeight;
	depth = lengthOf(imageList);
	totalDepth = depth;
	close();
	
	//Set Parameters
	scanLayer = floor(depth/30);
	selectedScanLayer = floor(scanLayer/6);
	cutoffLayer = floor(depth/10);
	startLayer = newArray(2);
	endLayer = newArray(2);
	
	startLayer[0] = cutoffLayer;
	endLayer[0] = startLayer[0] + scanLayer;
	endLayer[1] = depth - startLayer[0];
	startLayer[1] = endLayer[1] - scanLayer;
	
	//Prepare Variables
	xListAll = newArray(scanLayer * 2);
	yListAll = newArray(scanLayer * 2);
	zListAll = newArray(scanLayer * 2);
	rListAll = newArray(scanLayer * 2);
	xListSelected = newArray(selectedScanLayer * 2);
	yListSelected = newArray(selectedScanLayer * 2);
	zListSelected = newArray(selectedScanLayer * 2);
	rListSelected = newArray(selectedScanLayer * 2);
	
	for(scanIndex = 0; scanIndex < 2; scanIndex++){
		
		//Get Translation infomation
		dataIndex = 0;
		xList = newArray(scanLayer);
		yList = newArray(scanLayer);
		zList = newArray(scanLayer);
		rList = newArray(scanLayer);
		
		for(z=startLayer[scanIndex];z<endLayer[scanIndex];z++){
			
			//Open image
			open(subFolderPath + imageList[z]);
			
			//Duplicate and Binarize
			rename("OtsuBinaryTemp");
			setAutoThreshold("Otsu dark");
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Otsu background=Dark black");
			run("Despeckle");
			
			//--------General Flow is following--------
			//    1. Close circule until it hits white
			//    2. Shift until circle wont hit white
			//    3. Reduce precision
			
			//Initialzie values
			x = floor(width/2);
			y = floor(height/2);
			radius = minOf(x,y)-2;
		
			//Parameters for "Closing" and "Shifting"
			moveTowardAngle = 0;
			precision = floor(radius/4);
			targetPrecision = 0.1;
			justTriedShift = false;
			
			while(precision>targetPrecision){
				//Prepare intensity and angle arrays
				numData = floor(radius*2*PI);
				angleArray = newArray(numData);
				intensityArray = newArray(numData);
		
				//"Start of Widest Black" calculation variable
				nowBlack = true;
				startOfCurrentBlack = 0;
				currentBlackWidth = 0;
				widestBlackWidth = -1;
				startOfWidestBlack = 0;
				for(i=0;i<numData;i++){
					angleArray[i] = i/numData*2*PI;
					//Scan in radial direction
					xTemp = floor(radius*cos(angleArray[i])+x);
					yTemp = floor(radius*sin(angleArray[i])+y);
		
					//Check "Black Width" status
					if(getValue(xTemp,yTemp)!=255){
						if(nowBlack){
							//Black Continueing
							currentBlackWidth++;
						}else{
							//Beggining of new Current Black
							nowBlack = true;
							startOfCurrentBlack = i;
							currentBlackWidth = 0;
						}
					}else{
						if(nowBlack){
							//End of Current Black
							if(currentBlackWidth>widestBlackWidth){
								widestBlackWidth = currentBlackWidth;
								startOfWidestBlack = startOfCurrentBlack;
							}
							nowBlack = false;
						}else{
							//White Continueing
						}
					}
				}
				if(widestBlackWidth==-1){
					//if no white found...
					
					//Save Current Settings
					xSave = x;
					ySave = y;
					radiusSave = radius;
					
					//Reduce Radius
					justTriedShift = false;
					radius -= precision;
					if(checkProgress){
						waitForUser("Closing: r="+radius);
						makeOval(x-radius,y-radius,radius*2,radius*2);
					}
					continue;
				}else if(justTriedShift){
					//If just tried shifting...
					
					//Restore Saved Settings
					x = xSave;
					y = ySave;
					radius = radiusSave+precision*0.0;
					
					//Increase Precision
					precision *= 0.5;
					justTriedShift = false;
					if(checkProgress){
						waitForUser("Opening: r="+radius);
						makeOval(x-radius,y-radius,radius*2,radius*2);
					}
					continue;
				}
				justTriedShift = true;
				//Check if current black is wider, update "Start of widest"
				if(currentBlackWidth>widestBlackWidth){
					widestBlackWidth = currentBlackWidth;
					startOfWidestBlack = startOfCurrentBlack;
				}
		
				//"Next Shift" calculation variables
				totalIntensity = 0;
				intensityAngle = 0;
				for(i=0;i<numData;i++){
					angleArray[i] = (i+startOfWidestBlack)/numData*2*PI;
					xTemp = floor(radius*cos(angleArray[i])+x);
					yTemp = floor(radius*sin(angleArray[i])+y);
					intensityArray[i] = getValue(xTemp,yTemp);
					intensityAngle += intensityArray[i]*i/numData*2*PI;
					totalIntensity += intensityArray[i];
				}
				//Determine the direction of Shift
				if(totalIntensity==0){
					moveTowardAngle = 0;
				}else{
					moveTowardAngle = intensityAngle/totalIntensity + startOfWidestBlack/numData*2*PI;
				}
				
				//Scan in radial direction
				x = x + cos(moveTowardAngle)*precision;
				y = y + sin(moveTowardAngle)*precision;
		
				//Check Progress
				if(checkProgress){
					waitForUser("Shifting: r="+radius);
					makeOval(x-radius,y-radius,radius*2,radius*2);
				}
			}
			makeOval(x-radius,y-radius,radius*2,radius*2);
			
			//Save to Array
			xList[dataIndex] = x;
			yList[dataIndex] = y;
			zList[dataIndex] = z;
			rList[dataIndex] = radius;
			xListAll[dataIndex+scanIndex * scanLayer] = x;
			yListAll[dataIndex+scanIndex * scanLayer] = y;
			zListAll[dataIndex+scanIndex * scanLayer] = z;
			rListAll[dataIndex+scanIndex * scanLayer] = radius;
			dataIndex = dataIndex + 1;
			
			close();
		}
		
		//Save Array
		run("Clear Results");
		Array.sort(rList,zList,xList,yList);
		if(targetWidthHeight == 0){
			targetWidthHeight = floor(rList[0]*1.02)*2 + 1;
		}
		
		for(i=0;i<scanLayer;i++){
			//Save to Array
			if(i<selectedScanLayer){
				xListSelected[scanIndex * selectedScanLayer + i] = xList[i];
				yListSelected[scanIndex * selectedScanLayer + i] = yList[i];
				zListSelected[scanIndex * selectedScanLayer + i] = zList[i];
				rListSelected[scanIndex * selectedScanLayer + i] = rList[i];
			}
			
			setResult("z",i,zList[i]);
			setResult("x",i,xList[i]);
			setResult("y",i,yList[i]);
			setResult("r",i,rList[i]);
		}
		saveAs("Results", flo + "CircleInfo_"+scanIndex+".csv");
	}
	
	//Save All Plots
	Fit.doFit("Straight Line", zListAll, xListAll);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zx_all.tif");
	Fit.doFit("Straight Line", zListAll, yListAll);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zy_all.tif");
	Fit.doFit("Straight Line", zListAll, rListAll);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zr_all.tif");
	
	//Save Seleceted Z-X Plots
	Fit.doFit("Straight Line", zListSelected, xListSelected);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zx_selected.tif");
	xStart = Fit.p(0);
	xSlope = Fit.p(1);
	
	//Save Seleceted Z-Y Plots
	Fit.doFit("Straight Line", zListSelected, yListSelected);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zy_selected.tif");
	yStart = Fit.p(0);
	ySlope = Fit.p(1);
	
	//Save Z-R Plots
	Fit.doFit("Straight Line", zListSelected, rListSelected);
	Fit.plot();
	saveAs("Tiff", flo+"plot_zr_selected.tif");
	
	//Save Results
	grandArray_subFolderName[folderIndex] = subFolder;
	grandArray_targetWidthHeight[folderIndex] = targetWidthHeight;
	grandArray_x_start[folderIndex] = xStart;
	grandArray_x_slope[folderIndex] = xSlope;
	grandArray_y_start[folderIndex] = yStart;
	grandArray_y_slope[folderIndex] = ySlope;
	
	//Close windows
	close();
	close();
	close();
	close();
	close();
	close();
}

//Save results to csv
run("Clear Results");
for(i = 0; i < folderList.length; i++){
	setResult("folderName",i,grandArray_subFolderName[i]);
	setResult("targetWidthHeight",i,grandArray_targetWidthHeight[i]);
	setResult("xStart",i,grandArray_x_start[i]);
	setResult("xSlope",i,grandArray_x_slope[i]);
	setResult("yStart",i,grandArray_y_start[i]);
	setResult("ySlope",i,grandArray_y_slope[i]);
}
saveAs("Results", floSummary + "Summary.csv");

//Save stackInfo to csv
run("Clear Results");
setResult("targetWidthHeight",0,targetWidthHeight);
setResult("depth",0,totalDepth);
saveAs("Results", floSummary + "stackInfo.csv");
