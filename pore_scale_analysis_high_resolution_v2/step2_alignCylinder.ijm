//---------------Set Variables----------------------

maxPixel = 50000000;
maxPixel = 500000000;

doStep10 = false;//shift XY, crop, Stack and Segment
doStep11 = false;//reStack, transform and segment
doStep12 = false;//find vertical offset
doStep13 = true;//reStack, transform, vertically align and segment
doStep14 = true//find rough rotational offset
doStep15 = true;//find procise rotational offset
doStep16 = true;//reStack, vertically align and save

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

fliSummary= fliRoot+"imageJ/step0.1_getStackInfo_Summary/";
fliStackInfoPath = fliSummary + "stackInfo.csv";

//Aquire Stack Info
stackInfoString = File.openAsString(fliStackInfoPath);
stackInfoRaws = split(stackInfoString,"\n");
stackInfoItems = split(stackInfoRaws[1],",");
stackWidthHeight = parseInt(stackInfoItems[1]);
stackDepth = parseInt(stackInfoItems[2]);

//Calculate stack parameters
maxTac  = floor(maxPixel / stackWidthHeight/ stackWidthHeight);
maxLice = floor(maxPixel / stackWidthHeight/ stackDepth);
maxDia  = floor(sqrt(maxPixel / stackDepth)/2)*2 + 1;
maxDiaOffset = (stackWidthHeight - maxDia) / 2;

//Define stackFolders, sliceFolders
numSliceFolders = floor(stackWidthHeight / maxLice) + 1;
sliceFolderList = newArray(numSliceFolders);
for(i = 0; i < numSliceFolders; i++){
	sliceFolderList[i] = i * maxLice;
}
numStackFolders = floor(stackDepth / maxTac) + 1;
stackFolderList = newArray(numSliceFolders);
for(i = 0; i < numSliceFolders; i++){
	stackFolderList[i] = i * maxTac;
}

//Aquire summary.csv
summaryFile = File.openAsString(fliSummary + "Summary.csv");
summaries = split(summaryFile,"\n");

for(summaryIndex = 1; summaryIndex < summaries.length; summaryIndex++){
//for(summaryIndex = 1; summaryIndex < 2; summaryIndex++){
//for(summaryIndex = 1; summaryIndex < 2; summaryIndex++){
	//Extract parameters
	summary = summaries[summaryIndex];
	items = split(summary, ",");
	subFolder = items[1];
	targetWidthHeight = parseFloat(items[2]);
	xStart = parseFloat(items[3]);
	xSlope = parseFloat(items[4]);
	yStart = parseFloat(items[5]);
	ySlope = parseFloat(items[6]);
	xTarget = targetWidthHeight/2;
	yTarget = targetWidthHeight/2;
	
	//Print status
	si = summaryIndex;
	sl = summaries.length - 1;
	print("[" + si + "/" + sl + "]-"+ subFolder);
	
	if(doStep10){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step10");
		//Define step root folders
		floStep10Root        = fliRoot+"imageJ/step1.0_HorizontalAlignSegmentedStacks/";
		floStep10Root_MaxDia = fliRoot+"imageJ/step1.0_HorizontalAlignMaxDiameterStacks/";
		File.makeDirectory(floStep10Root);
		File.makeDirectory(floStep10Root_MaxDia);
		
		//Get SubFolder Path
		fliSubFolderPath = fliRoot + "/" + subFolder + "/XY/";
		floSubFolderPath = floStep10Root + subFolder + "/";
		floSubFolderPath_MaxDia = floStep10Root_MaxDia + subFolder + "/";
		File.makeDirectory(floSubFolderPath);
		File.makeDirectory(floSubFolderPath_MaxDia);
		for(zStart = 1; zStart < stackDepth; zStart += maxTac){
			print("[" + si + "/" + sl + "]-"+ subFolder + " Step10 [" + zStart + "/" + stackDepth + "]");
			File.openSequence(fliSubFolderPath, "start="+zStart+" count="+maxTac);
			
			sliceDepth = nSlices;
			
			//Translate the restacked image
			for(z = 0; z < sliceDepth; z++){
				setSlice(z+1);
				absoluteZ = zStart + z;
				xOffset = xTarget-xStart-xSlope*(absoluteZ);
				yOffset = yTarget-yStart-ySlope*(absoluteZ);
				run("Translate...", "x="+xOffset+" y="+yOffset+" interpolation=Bilinear slice");
			}		
			makeOval(0, 0, targetWidthHeight, targetWidthHeight);	
			run("Crop");
			
			//Cut the maxTac into slices and save them to each sliceFolders
			for(sliceFolderIndex = 0; sliceFolderIndex < numSliceFolders; sliceFolderIndex++){
				sliceCoord = sliceFolderList[sliceFolderIndex];
				floSliceFolderPath = floSubFolderPath + sliceCoord + "/";
				File.makeDirectory(floSliceFolderPath);
				makeRectangle(0, sliceCoord, stackWidthHeight, maxLice);
				run("Duplicate...", "duplicate range=1-"+maxTac);
				saveAs("Tiff", floSliceFolderPath + zStart+".tiff");
				close();
			}
			
			//Cut out the maxDia and save them to each sliceFolders
			makeRectangle(maxDiaOffset, maxDiaOffset, maxDia, maxDia);
			run("Duplicate...", "duplicate range=1-"+maxTac);
			saveAs("Tiff", floSubFolderPath_MaxDia + zStart+".tiff");
			close();
			close();
		}
	}
	
	if(doStep11){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step11");
		//Define step root folders
		fliStep11Root = fliRoot+"imageJ/step1.0_HorizontalAlignSegmentedStacks/";
		floStep11Root = fliRoot+"imageJ/step1.1_TranslatedSegmentedStacks/";
		File.makeDirectory(floStep11Root);

		//Get SubFolder Path
		fliSubFolderPath = fliStep11Root + subFolder + "/";
		floSubFolderPath = floStep11Root + subFolder + "/";
		File.makeDirectory(floSubFolderPath);
			
		//for each sliced folders, restack the [Width x maxLice x Height] images
		for(sliceFolderIndex = 0; sliceFolderIndex < numSliceFolders; sliceFolderIndex++){
			print("[" + si + "/" + sl + "]-"+ subFolder + " Step11 [" + sliceFolderIndex + "/" + numSliceFolders + "]");
			sliceCoord = sliceFolderList[sliceFolderIndex];
			fliSlicedSubFolderPath = fliSubFolderPath + sliceCoord + "/";
			File.openSequence(fliSlicedSubFolderPath);
			run("Rotate 90 Degrees Left");
			run("Reslice [/]...", "output=1.000 start=Left avoid");
			
			sliceDepth = nSlices;
			
			//Translate the restacked image
			for(z = 0; z < sliceDepth; z++){
				setSlice(z+1);
				absoluteY = sliceCoord + z;
				yOffset = ySlope*(absoluteY - stackWidthHeight / 2);
				run("Translate...", "x=0 y="+yOffset+" interpolation=Bilinear slice");
			}
			
			//Crop the [Width x maxLice x Height] image to [Width x maxLice x maxTac] images and save
			for(sliceFolderIndex2 = 0; sliceFolderIndex2 < numSliceFolders; sliceFolderIndex2++){
				sliceCoord2 = sliceFolderList[sliceFolderIndex2];
				floSlicedSubFolderPath = floSubFolderPath + sliceCoord2 + "/";
				File.makeDirectory(floSlicedSubFolderPath);
				makeRectangle(sliceCoord2, 0, maxLice, stackDepth);
				run("Duplicate...", "duplicate range=1-"+maxLice);
				saveAs("Tiff", floSlicedSubFolderPath + sliceCoord+".tiff");
				close();
			}
			close();
			close();
		}
	}
	
	if(doStep12){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step12");
		//Define step root folders
		fliStep12Root = fliRoot+"imageJ/step1.0_HorizontalAlignMaxDiameterStacks/";
		floStep12Root = fliRoot+"imageJ/step1.2_VerticalOffset/";
		File.makeDirectory(floStep12Root);
		
		//Get SubFolder Path
		fliSubFolderPath = fliStep12Root + "/" + subFolder + "/";
		floSlicePath = floStep12Root + "/Slice/";
		floPlotPath  = floStep12Root + "/Plot/";
		floSummaryPath  = floStep12Root + "/Summary/";
		File.makeDirectory(floSlicePath);
		File.makeDirectory(floPlotPath);
		File.makeDirectory(floSummaryPath);
		
		//Open subfolder and Crop out center 11pix x 11 pix then apply median filter
		File.openSequence(fliSubFolderPath);
		imageWidth = getWidth();
		imageMargin2 = floor((imageWidth-11)/2);
		makeRectangle(imageMargin2, imageMargin2, 11, 11);
		run("Crop");
		run("Median 3D...", "x=2 y=2 z=2");
		
		//Aquire center 1px x 1px 
		imageTitle = getTitle();
		imageWidth = getWidth();
		imageDepth = nSlices;
		imageMargin = floor(imageWidth/2);
		makeRectangle(imageMargin, imageMargin, 1, 1);
		run("Crop");
		rename("BeforeReslice");
		
		//Reslice to prepare for layer duplication
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		rename(imageTitle);
		close("BeforeReslice");
		selectWindow(imageTitle);
		run("Select All");
		run("Copy");
		
		//Duplicate layers
		slideDepth = floor(stackDepth/5);
		for(i=2;i<=slideDepth*2;i++){
			run("Add Slice");
			run("Paste");
		}
		
		//Slide layers if not 0_brine
		if(subFolder!="0_brine"){
			for(i=1;i<=slideDepth*2;i++){
				setSlice(i);
				run("Translate...", "x=0 y="+(i-slideDepth)+" interpolation=Bilinear slice");
			}	
		}
		
		//Reslice and save
		rename("BeforeReslice");
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		saveAs("Tiff", floSlicePath + imageTitle+".tiff");
		rename(imageTitle);
		close("BeforeReslice");
		
		//Calculate and record vertical offset
		if(subFolder != "0_brine"){
			//Calculate image difference
			open(floSlicePath + "0_brine.tiff");
			rename("0_brine");
			imageCalculator("Difference", imageTitle,"0_brine");
			makeRectangle(floor(slideDepth + imageDepth * 0.1), 0, floor(imageDepth*0.8 - slideDepth * 2), slideDepth*2);
			run("Crop");
			tempTitle2 = getTitle();
			
			//Reslice to aquire Z-axis Profile
			run("Reslice [/]...", "output=1.000 start=Top avoid");
			tempTitle = getTitle();
			run("Plot Z-axis Profile");
			
			//Get values from plot and get min Y value and index
			Plot.getValues(xPoints,yPoints);
			yMin = yPoints[0];
			yMinIndex = 0;
			for(yIndex=1;yIndex<yPoints.length;yIndex++){
				if(yPoints[yIndex]<yMin){
					yMin = yPoints[yIndex];
					yMinIndex = yIndex;
				}
			}
			
			//Save plot and close windows
			saveAs("Tiff", floPlotPath + "plot_"+imageTitle+".tiff");
			rename("plot");
			close(tempTitle);
			close(tempTitle2);
			close("plot");
			
			//Save result
			run("Clear Results");
			setResult("verticalOffset",0,yMinIndex - slideDepth);
			saveAs("Results", floSummaryPath+imageTitle+".csv");
			close();
		}
		//close 0_brine
		close("0_brine");
	}
	
	if(doStep13){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step13");
		//Define common variables
		tenPercentWidth = floor(stackWidthHeight / 10);
		margin = floor(stackWidthHeight * 9 / 10 / 2);
		
		//Define step root folders
		fliStep13Root  = fliRoot+"imageJ/step1.1_TranslatedSegmentedStacks/";
		fliStep13_verOffset  = fliRoot+"imageJ/step1.2_VerticalOffset/Summary/";
		floStep13Root  = fliRoot+"imageJ/step1.3_TranslatedVerticallyAlignedSegmentedStacks/";
		File.makeDirectory(floStep13Root);
		
		//Process Each scanSubFolder
		fliSubFolderPath = fliStep13Root + subFolder + "/";
		floSubFolderPath = floStep13Root + subFolder + "/";
		File.makeDirectory(floSubFolderPath);
		
		//Get Vertical Offset
		offsetValue = 0;
		if(subFolder != "0_brine"){
			offsetFile = File.openAsString(fliStep13_verOffset + subFolder + ".csv");
			offsetFileLines = split(offsetFile,"\n");
			offsetFileLine1Items = split(offsetFileLines[1], ",");
			offsetValue = parseFloat(offsetFileLine1Items[1]);
		}
			
		//for each sliced folders, restack the [Width x maxLice x Height] images
		for(sliceFolderIndex = 0; sliceFolderIndex < numSliceFolders; sliceFolderIndex++){
			print("[" + si + "/" + sl + "]-"+ subFolder + " Step13 [" + sliceFolderIndex + "/" + numSliceFolders + "]");
			sliceCoord = sliceFolderList[sliceFolderIndex];
			fliSlicedSubFolderPath = fliSubFolderPath + sliceCoord + "/";
			File.openSequence(fliSlicedSubFolderPath);
			run("Reslice [/]...", "output=1.000 start=Left avoid");
			run("Rotate 90 Degrees Right");
			sliceDepth = nSlices;
			
			//Translate the restacked image
			for(z = 0; z < sliceDepth; z++){
				setSlice(z+1);
				absoluteX = sliceCoord + z;
				xOffset = - xSlope*(absoluteX - stackWidthHeight / 2);
				run("Translate...", "x=0 y="+(xOffset + offsetValue)+" interpolation=Bilinear slice");
			}
			
			//Crop the [Width x maxTak x Height] image to [Width x maxLice x maxTac] images and save
			for(stackFolderIndex = 0; stackFolderIndex < numStackFolders; stackFolderIndex++){
				stackCoord = stackFolderList[stackFolderIndex];
				floStackedSubFolderPath = floSubFolderPath + stackCoord + "/";
				File.makeDirectory(floStackedSubFolderPath);
				makeRectangle(0, stackCoord, stackWidthHeight, maxTac);
				run("Duplicate...", "duplicate range=1-"+maxLice);//maxTac toLice
				saveAs("Tiff", floStackedSubFolderPath + sliceCoord+".tiff");
				close();
			}
			close();
			close();
		}
	}
	
	if(doStep14){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step14");
		//Define step root folders
		fliStep14Root  = fliRoot+"imageJ/step1.3_TranslatedVerticallyAlignedSegmentedStacks/";
		floStep14Root  = fliRoot+"imageJ/step1.4_RoughRotationalOffset/";
		File.makeDirectory(floStep14Root);
		
		//Define parameters
		max360WidthHeight = floor(sqrt(maxPixel / 360));
		max360WidthHeight = minOf(stackWidthHeight, max360WidthHeight);
		
		//Get SubFolder Path
		fliSubFolderPath = fliStep14Root + "/" + subFolder + "/";
		floSlicePath = floStep14Root + "/Slice/";
		floPlotPath  = floStep14Root + "/Plot/";
		floSummaryPath  = floStep14Root + "/Summary/";
		File.makeDirectory(floSlicePath);
		File.makeDirectory(floPlotPath);
		File.makeDirectory(floSummaryPath);
		
		//Process Each scanSubFolder
		fliSubFolderPath = fliStep14Root + subFolder + "/";
		
		//Open target slice
		targetZ = floor(stackDepth / 2);
		targetStackCoord = floor(targetZ / maxTac) * maxTac;
		File.openSequence(fliSubFolderPath + targetStackCoord);
		rename("beforeReslice");
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		rename("beforeCrop");
		setSlice(targetZ - targetStackCoord);
		run("Select All");
		run("Duplicate...", " ");
		rename(subFolder);
		close("beforeReslice");
		close("beforeCrop");
		selectWindow(subFolder);
		run("Size...", "width="+max360WidthHeight+" height="+max360WidthHeight+" depth=1 constrain average interpolation=Bilinear");
		makeOval(0, 0, max360WidthHeight, max360WidthHeight);
		run("Clear Outside");
		run("Select All");
		run("Copy");
		
		//Duplicate layers
		for(i=2;i<=360;i++){
			run("Add Slice");
			run("Paste");
		}
		
		//Slide layers if not 0_brine
		if(subFolder=="0_brine"){
			for(i=1;i<=360;i++){
				setSlice(i);
				run("Rotate... ", "angle=-"+i+" grid=1 interpolation=Bilinear slice");
			}	
		}
		
		//Reslice and save
		saveAs("Tiff", floSlicePath + subFolder+".tiff");
		rename(subFolder);
		
		//Calculate and record vertical offset
		if(subFolder != "0_brine"){
			//Calculate image difference and plot
			open(floSlicePath + "0_brine.tiff");
			rename("0_brine");
			imageCalculator("Difference stack", subFolder,"0_brine");
			run("Plot Z-axis Profile");
			
			//Get values from plot and get min Y value and index
			Plot.getValues(xPoints,yPoints);
			yMin = yPoints[0];
			yMinIndex = 0;
			for(yIndex=1;yIndex<yPoints.length;yIndex++){
				if(yPoints[yIndex]<yMin){
					yMin = yPoints[yIndex];
					yMinIndex = yIndex;
				}
			}
			
			//Save plot and close windows
			saveAs("Tiff", floPlotPath + "plot_"+subFolder+".tiff");
			rename("plot");
			close("plot");
			
			//Save result
			run("Clear Results");
			setResult("RoughRotationalOffset",0,yMinIndex);
			saveAs("Results", floSummaryPath+subFolder+".csv");
			close();
			close(subFolder);
		}
		close("0_brine");
	}
	
	if(doStep15){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step15");
		//Define step root folders
		fliStep15Root  = fliRoot+"imageJ/step1.3_TranslatedVerticallyAlignedSegmentedStacks/";
		fliStep15Root_roughOffset  = fliRoot+"imageJ/step1.4_RoughRotationalOffset/Summary/";
		floStep15Root  = fliRoot+"imageJ/step1.5_RotationalOffset/";
		File.makeDirectory(floStep15Root);
		
		//Get rough rotational Offset
		offsetValue = 0;
		if(subFolder != "0_brine"){
			offsetFile = File.openAsString(fliStep15Root_roughOffset + subFolder + ".csv");
			offsetFileLines = split(offsetFile,"\n");
			offsetFileLine1Items = split(offsetFileLines[1], ",");
			offsetValue = parseFloat(offsetFileLine1Items[1]);
		}
		
		//Define parameters
		max30WidthHeight = floor(sqrt(maxPixel / 30));
		max30WidthHeight = minOf(stackWidthHeight, max30WidthHeight);
		
		//Get SubFolder Path
		fliSubFolderPath = fliStep15Root + "/" + subFolder + "/";
		floSlicePath = floStep15Root + "/Slice/";
		floPlotPath  = floStep15Root + "/Plot/";
		floSummaryPath  = floStep15Root + "/Summary/";
		File.makeDirectory(floSlicePath);
		File.makeDirectory(floPlotPath);
		File.makeDirectory(floSummaryPath);
		
		//Process Each scanSubFolder
		fliSubFolderPath = fliStep15Root + subFolder + "/";
		
		//Open target slice
		targetZ = floor(stackDepth / 2);
		targetStackCoord = floor(targetZ / maxTac) * maxTac;
		File.openSequence(fliSubFolderPath + targetStackCoord);
		rename("beforeReslice");
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		rename("beforeCrop");
		setSlice(targetZ - targetStackCoord);
		run("Select All");
		run("Duplicate...", " ");
		rename(subFolder);
		close("beforeReslice");
		close("beforeCrop");
		selectWindow(subFolder);
		run("Size...", "width="+max30WidthHeight+" height="+max30WidthHeight+" depth=1 constrain average interpolation=Bilinear");
		makeOval(0, 0, max30WidthHeight, max30WidthHeight);
		run("Clear Outside");
		run("Select All");
		run("Copy");
		
		//Duplicate layers
		for(i=2;i<=30;i++){
			run("Add Slice");
			run("Paste");
		}
		
		//Slide layers if not 0_brine
		if(subFolder!="0_brine"){
			for(i=1;i<=30;i++){
				setSlice(i);
				run("Rotate... ", "angle="+offsetValue+(i-5)/10+" grid=1 interpolation=Bilinear slice");
			}	
		}
		
		//Reslice and save
		saveAs("Tiff", floSlicePath + subFolder+".tiff");
		rename(subFolder);
		
		//Calculate and record vertical offset
		if(subFolder != "0_brine"){
			//Calculate image difference and plot
			open(floSlicePath + "0_brine.tiff");
			rename("0_brine");
			imageCalculator("Difference stack", subFolder,"0_brine");
			run("Plot Z-axis Profile");
			
			//Get values from plot and get min Y value and index
			Plot.getValues(xPoints,yPoints);
			yMin = yPoints[0];
			yMinIndex = 0;
			for(yIndex=1;yIndex<yPoints.length;yIndex++){
				if(yPoints[yIndex]<yMin){
					yMin = yPoints[yIndex];
					yMinIndex = yIndex;
				}
			}
			
			//Save plot and close windows
			saveAs("Tiff", floPlotPath + "plot_"+subFolder+".tiff");
			rename("plot");
			close("plot");
			
			//Save result
			run("Clear Results");
			setResult("RoughRotationalOffset",0,offsetValue+(yMinIndex-5)/10);
			saveAs("Results", floSummaryPath+subFolder+".csv");
			close();
			close(subFolder);
		}
		close("0_brine");
	}
	
	if(doStep16){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step16");
		//Define step root folders
		fliStep16Root  = fliRoot+"imageJ/step1.3_TranslatedVerticallyAlignedSegmentedStacks/";
		fliStep16Root_preciseOffset  = fliRoot+"imageJ/step1.5_RotationalOffset/";
		floStep16Root  = fliRoot+"imageJ/step1.6_RotationallyAligned/";
		File.makeDirectory(floStep16Root);
		
		//Get rough rotational Offset
		offsetValue = 0;
		if(subFolder != "0_brine"){
			offsetFile = File.openAsString(fliStep16Root_preciseOffset + "Summary/" +subFolder + ".csv");
			offsetFileLines = split(offsetFile,"\n");
			offsetFileLine1Items = split(offsetFileLines[1], ",");
			offsetValue = parseFloat(offsetFileLine1Items[1]);
		}
		
		//Process Each scanSubFolder
		fliSubFolderPath = fliStep16Root + subFolder + "/";
		floSubFolderPath = floStep16Root + subFolder + "/";
		File.makeDirectory(floSubFolderPath);
		
		//
		for(stackFolderIndex = 0; stackFolderIndex < numStackFolders; stackFolderIndex++){
			stackCoord = stackFolderList[stackFolderIndex];
			fliStackedSubFolderPath = fliSubFolderPath + stackCoord + "/";
			File.openSequence(fliStackedSubFolderPath);
			run("Reslice [/]...", "output=1.000 start=Top avoid");
			run("Rotate... ", "angle="+offsetValue+" grid=1 interpolation=Bilinear stack");
			saveAs("Tiff", floSubFolderPath + stackCoord+".tiff");
			close();
			close();
		}
	}
}