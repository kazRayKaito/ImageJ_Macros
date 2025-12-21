//---------------Set Variables----------------------

//ImageSettings
targetWidthHeight = 2150;

//Scan Settings
startCutoff = 150;//0〜
endCutoff = 150;//0〜

//For Debugging
checkProgress = false;//true:stop and check, false:auto

//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	fli = argument;
	print("Argument Dir:"+fli);
}else{
	print("\\Clear");
	fli = getDirectory("Choose a folder which contains [0_brine, 1_xxxx, 2_xxxx]");
	print("Selected Dir:"+fli);
}

//----------CheckFolderStructure make imageJ folder----------------
folderList = getFileList(fli);
flo = fli+"/imageJ/step1.0_horizontalAlign/";
floPlot = fli+"/imageJ/step1.0_horizontalAlign_Plots/";

File.makeDirectory(fli+"/imageJ/");
File.makeDirectory(flo);
File.makeDirectory(floPlot);

for(folderIndex = 0; folderIndex< folderList.length; folderIndex++){
	
	//Process each folder except "imageJ" folder
	subFolder = folderList[folderIndex].substring(0, folderList[folderIndex].length - 1);
	subFolderPath = fli + "/" + subFolder + "/XY/";
	
	if(subFolder == "imageJ"){
		print("Skipping 'imageJ' folder....");
		continue;
	}else{
		print("Processing subfolder:"+subFolder);
	}
	
	//Check files in subfolder and remove if its not tif file
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
	close();
		
	//print("ImageTitle:" + title);
	//print("ImageXleng:" + height);
	//print("ImageYleng:" + width);
	//print("ImageCount:" + depth);
		
	
	//Get Translation infomation
	print("Obtaining BestFit circle for layers ["+startCutoff+"~"+depth-endCutoff+"]...");
	xList = newArray(depth-startCutoff-endCutoff);
	yList = newArray(depth-startCutoff-endCutoff);
	zList = newArray(depth-startCutoff-endCutoff);
	rList = newArray(depth-startCutoff-endCutoff);
	
	for(z=startCutoff;z<depth-endCutoff;z++)
	{ 
		open(subFolderPath + imageList[z]);
		
		//Duplicate and Binarize
		print("Duplicating and Binarizing using Otsu's method...");
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
		xList[z-startCutoff] = x;
		yList[z-startCutoff] = y;
		zList[z-startCutoff] = z;
		rList[z-startCutoff] = radius;
		print("r: " + radius);
		//setResult("x",z-startCutoff,x);
		//setResult("y",z-startCutoff,y);
		//setResult("radius",z-startCutoff,radius);
		
		close();
	}
	
	//Get best fit center translation for x and y
	xTarget = targetWidthHeight/2;
	yTarget = targetWidthHeight/2;
	Fit.doFit("Straight Line", zList, xList);
	Fit.plot();
	saveAs("Tiff", floPlot+subFolder+"_plot_zx 1.tif");
	xStart = Fit.p(0);
	xSlope = Fit.p(1);
	Fit.doFit("Straight Line", zList, yList);
	Fit.plot();
	saveAs("Tiff", floPlot+subFolder+"_plot_zy 1.tif");
	
	yStart = Fit.p(0);
	ySlope = Fit.p(1);
	
	//Determine indexs to remove by raidus
	numOfIndex = zList.length;
	numOfIndexToDelete = floor(numOfIndex * 0.50);
	listOfIndexsToDelete = newArray(numOfIndexToDelete);
	for(indexOfList = 0; indexOfList < numOfIndexToDelete; indexOfList++){
		champRadius = -1;
		champIndex = -1;
		for(rListIndex = 0; rListIndex < rList.length; rListIndex++){
			if(rList[rListIndex] > champRadius){
				champRadius = rList[rListIndex];
				champIndex = rListIndex;
			}
		}
		listOfIndexsToDelete[indexOfList] = champIndex;
		rList[champIndex] = 0;
	}
	
	//Remove Indexes
	xListTrue = newArray(depth-startCutoff-endCutoff-numOfIndexToDelete);
	yListTrue = newArray(depth-startCutoff-endCutoff-numOfIndexToDelete);
	zListTrue = newArray(depth-startCutoff-endCutoff-numOfIndexToDelete);
	
	foundCount = 0;
	for(index = 0; index < zList.length; index++){
		theIndexIsNotOnList = 1;
		for(indexOfListOfIndexToDelete = 0; indexOfListOfIndexToDelete < numOfIndexToDelete; indexOfListOfIndexToDelete++){
			if(listOfIndexsToDelete[indexOfListOfIndexToDelete] == index){
				theIndexIsNotOnList = 0;
				foundCount = foundCount + 1;
				break;
			}
		}
		if(theIndexIsNotOnList){
			xListTrue[index - foundCount] = xList[index];
			yListTrue[index - foundCount] = yList[index];
			zListTrue[index - foundCount] = zList[index];
		}
	}
	
	
	//Get best fit center translation for x and y
	xTarget = targetWidthHeight/2;
	yTarget = targetWidthHeight/2;
	Fit.doFit("Straight Line", zListTrue, xListTrue);
	Fit.plot();
	saveAs("Tiff", floPlot+subFolder+"_plot_zx 2.tif");
	xStart = Fit.p(0);
	xSlope = Fit.p(1);
	Fit.doFit("Straight Line", zListTrue, yListTrue);
	Fit.plot();
	saveAs("Tiff", floPlot+subFolder+"_plot_zy 2.tif");
	yStart = Fit.p(0);
	ySlope = Fit.p(1);
	
	//Translate x/y and crop
	print("Translating Original Image....");
	selectWindow(title);
	for(sliceIndex = 1;sliceIndex<=depth;sliceIndex++){
		setSlice(sliceIndex);
		xOffset = xTarget-xStart-xSlope*(sliceIndex-1);
		yOffset = yTarget-yStart-ySlope*(sliceIndex-1);
		run("Translate...", "x="+xOffset+" y="+yOffset+" interpolation=Bilinear slice");
	}
	makeOval(0, 0, targetWidthHeight, targetWidthHeight);
	run("Crop");
	rename("TransCropped");
	
	//For xSlope, lift horizontally
	makeRectangle(0, 0, targetWidthHeight, targetWidthHeight);
	run("Reslice [/]...", "output=1.000 start=Left flip rotate avoid");
	rename("ResliceX");
	run("Flip Horizontally", "stack");
	depth = nSlices;
	for(sliceIndex = 1;sliceIndex<=depth;sliceIndex++){
		setSlice(sliceIndex);
		xOffset = (sliceIndex - targetWidthHeight/2) * xSlope;
		yOffset = 0;
		run("Translate...", "x="+xOffset+" y="+yOffset+" interpolation=Bilinear slice");
	}
	//For xSlope, reslice.. again
	run("Reslice [/]...", "output=1.000 start=Left flip rotate avoid");
	rename("ResliceBack");
	run("Flip Horizontally", "stack");
	
	//For ySlope, lift horizontally
	makeRectangle(0, 0, targetWidthHeight, targetWidthHeight);
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	rename("ResliceY");
	depth = nSlices;
	for(sliceIndex = 1;sliceIndex<=depth;sliceIndex++){
		setSlice(sliceIndex);
		xOffset = 0;
		yOffset = (sliceIndex - targetWidthHeight/2) * ySlope;
		run("Translate...", "x="+xOffset+" y="+yOffset+" interpolation=Bilinear slice");
	}
	//For ySlope, reslice.. again
	run("Reslice [/]...", "output=1.000 start=Top avoid");
	
	saveAs("Tiff", flo+subFolder+".tif");
	print("image saved at " + flo+subFolder+".tif");selectWindow("OtsuBinaryTemp");
	
	//Close windows party
	close();
	close("ResliceY");
	close("ResliceX");
	close("ResliceBack");
	close("TransCropped");
	close("" + binaryTitle);
	close(subFolder+".tif");
	close();
	close();
	close();
	close();
}