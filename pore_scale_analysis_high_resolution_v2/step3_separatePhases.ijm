//---------------Set Variables----------------------

maxPixel = 50000000;
maxPixel = 500000000;

doStep21 = true;//Crop and separate phase

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

for(summaryIndex = 4; summaryIndex < summaries.length; summaryIndex++){
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
	
	if(doStep21){
		print("[" + si + "/" + sl + "]-"+ subFolder + " Step20");
		//Define step root folders
		fliStep20Root = fliRoot+"imageJ/step1.6_RotationallyAligned/";
		floStep20Root = fliRoot+"imageJ/step2.1_SeparatePhases/";
		File.makeDirectory(floStep20Root);
		
		//Get SubFolder Path
		fliSubFolderPath = fliStep20Root + "/" + subFolder + "/";
		fliSubFolderPath0brine = fliStep20Root + "/0_brine/";
		floSlicePath = floStep20Root + "/Slice/";
		floPlotPath  = floStep20Root + "/Plot/";
		floSummaryPath  = floStep20Root + "/Summary/";
		
		File.makeDirectory(floSlicePath);
		File.makeDirectory(floPlotPath);
		File.makeDirectory(floSummaryPath);
		
		for(i = 4; i < numStackFolders; i++){
			open(fliSubFolderPath + stackFolderList[i] + ".tiff");
			rename(stackFolderList[i]);
			open(fliSubFolderPath0brine + stackFolderList[i] + ".tiff");
			rename("0_brine");
			imageCalculator("Subtract create stack", "0_brine",""+stackFolderList[i]);
			makeOval(0, 0, stackWidthHeight, stackWidthHeight);
			setBackgroundColor(0, 0, 0);
			run("Clear Outside", "stack");
			waitForUser("testing");
			close(stackFolderList[i]);
			return;
		}
	}	
}