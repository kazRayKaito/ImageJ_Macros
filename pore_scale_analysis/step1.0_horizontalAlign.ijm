//---------------Set Variables----------------------

//ImageSettings
targetWidthHeight = 720;

//Scan Settings
startCutoff = 150;
endCutoff = 250;

//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	fli = argument;
	print("Argument Dir:"+fli);
}else{
	print("\\Clear");
	fli = getDirectory("Choose a Directory for a folder which contains folder [initial, 0, 1,2,...]");
	print("Selected Dir:"+fli);
}

//----------CheckFolderStructure make imageJ folder----------------
folderList = getFileList(fli);
flo = fli+"/imageJ/step1.0_horizontalAlign/";

File.makeDirectory(fli+"/imageJ/");
File.makeDirectory(flo);

for(folderIndex = 0; folderIndex< folderList.length; folderIndex++){
	subFolder = folderList[folderIndex].substring(0, folderList[folderIndex].length - 1);
	
	if(subFolder == "imageJ"){
		continue;
	}
	
	print("Processing subfolder:"+subFolder);
	
	//Open image file
	run("Image Sequence...", "dir="+fli+"/"+subFolder+"/XY/ sort");
	rename(""+subFolder);
	
	title = getTitle;
	width = getWidth;
	height = getHeight;
	depth = nSlices;
	
	//Duplicate and Binarize
	print("Duplicating and Binarizing imageStack using Otsu's method...");
	binaryTitle = "OtsuBinaryTemp";
	run("Duplicate...", "title="+binaryTitle+" duplicate");
	setAutoThreshold("Otsu dark stack");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Otsu background=Dark black");
	
	//Remove Disconnected Particles
	run("Keep Largest Region");
	close(binaryTitle);
	rename(binaryTitle);
	
	//Get Translation infomation
	print("Obtaining BestFit circle for layers ["+startCutoff+"~"+depth-endCutoff+"]...");
	xList = newArray(depth-startCutoff-endCutoff);
	yList = newArray(depth-startCutoff-endCutoff);
	zList = newArray(depth-startCutoff-endCutoff);
	rList = newArray(depth-startCutoff-endCutoff);
	
	for(z=startCutoff;z<depth-endCutoff;z++){ 
		setSlice(z);
		
		//--------General Flow is following--------
		//    1. Close circule until it hits white
		//    2. Shift until circle wont hit white
		//    3. Reduce precision
		checkProgress = false;
		
		//Initialzie values
		x = floor(getWidth/2);
		y = floor(getHeight/2);
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
				if(getValue(xTemp,yTemp)==0){
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
					waitForUser("Close: r="+radius);
					makeOval(x-radius,y-radius,radius*2,radius*2);
				}
				continue;
			}else if(justTriedShift){
				//If just tried shifting...
				
				//Restore Saved Settings
				x = xSave;
				y = ySave;
				radius = radiusSave+precision*0.1;
				
				//Increase Precision
				precision /= 2;
				justTriedShift = false;
				if(checkProgress){
					waitForUser("Open: r="+radius);
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
				waitForUser("Shift: r="+radius);
				makeOval(x-radius,y-radius,radius*2,radius*2);
			}
		}
		makeOval(x-radius,y-radius,radius*2,radius*2);
		xList[z-startCutoff] = x;
		yList[z-startCutoff] = y;
		zList[z-startCutoff] = z;
		rList[z-startCutoff] = radius;
		//setResult("x",z-startCutoff,x);
		//setResult("y",z-startCutoff,y);
		//setResult("radius",z-startCutoff,radius);
	}
	
	//Get best fit center translation for x and y
	xTarget = targetWidthHeight/2;
	yTarget = targetWidthHeight/2;
	Fit.doFit("Straight Line",zList,xList);
	Fit.plot();
	xStart = Fit.p(0);
	xSlope = Fit.p(1);
	Fit.doFit("Straight Line",zList,yList);
	//Fit.plot();
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
	close("y = a+bx");
}