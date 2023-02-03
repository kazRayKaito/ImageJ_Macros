//Initialize log
print("\\Clear");
parameter = "0";//0: Just Log 1: Run

//Defining Path for Images
pathImages = "R:/0_Information/from_Nasir-san/Experiment_3/";

//Defining path for Macro and CSV
machine = 0;
if(machine==0) pathMacro = "C:/Users/Kazuk/Google Drive/0_研究/Fiji_Macro/ForNasir/";//RayDesktop
if(machine==1) pathMacro = "C:/Users/Kazuki Kaito/Google Drive/0_研究/Fiji_Macro/ForNasir/";
if(machine==2) pathMacro = "C:/Users/Kazuk/Google Drive/0_研究/Fiji_Macro/ForNasir/";
if(machine==3) pathMacro = "C:/Users/suekane/Google ドライブ/0_研究/Fiji_Macro/ForNasir/";//Lab　PC

//Extract CSV information
rawString = File.openAsString(pathMacro+"imageLayerInfo.csv");
lines = split(rawString,"\n");
imageList = split(lines[0],",");
layerList = split(lines[1],",");

//Enable BatchMode to run macro in background
setBatchMode(false);

if(false){
	//STEP 1 Horizontal Alignment
	arguments = parameter+"\n"+pathImages+"\n"+lines[0];
	macroName = "step1_horizontalAlignment.ijm";
	print("\nRunning"+macroName+"\n");
	runMacro(pathMacro+macroName,arguments);
}

if(false){
	//STEP 2 Vertical Alignment
	for(layer=1;layer<=7;layer++){
		folderList = "";
		baseFolder = "";
		firstFolderFound = false;//We need to skip first ","
		baseFolderFound = false;//We need to skip base
		for(i=0;i<imageList.length;i++){
			if(layer==parseInt(layerList[i])){
				if(baseFolderFound){
					if(firstFolderFound){
						folderList = folderList +","+imageList[i];
					}else{
						firstFolderFound = true;
						folderList = imageList[i];
					}
				}else{
					baseFolder = imageList[i];
					baseFolderFound = true;
				}
			}
		}
	
		//Prepare Arguemnts and Macro Name
		arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+baseFolder;
		macroName = "step2_verticalAlignment.ijm";
		print("\nRunning"+macroName);
		print("Args... Parameter,pathImages,folderList,baseFolder");
		print(arguments+"\n");
		runMacro(pathMacro+macroName,arguments);
	}
}

if(false){
	//STEP 3 Denoising
	arguments = parameter+"\n"+pathImages+"\n"+lines[0];
	macroName = "step3_denoising.ijm";
	print("\nRunning"+macroName+"\n");
	runMacro(pathMacro+macroName,arguments);
}

if(false){
	//STEP 4.1 extract matrix
	for(layer=1;layer<=7;layer++){
		folderList = "";
		baseFolder = "";
		for(i=0;i<imageList.length;i++){
			if(layer==parseInt(layerList[i])){
				baseFolder = imageList[i];
				folderList = imageList[i];
				break;
			}
		}
	
		//Prepare Arguemnts and Macro Name
		arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+baseFolder;
		macroName = "step4.1_extractMatrix.ijm";
		print("\nRunning"+macroName);
		print("Args... Parameter,pathImages,folderList,baseFolder");
		print(arguments+"\n");
		runMacro(pathMacro+macroName,arguments);
	}
}

if(false){
	//STEP 4.2 extract air
	for(layer=1;layer<=7;layer++){
		folderList = "";
		baseFolder = "";
		baseFolderFound = false;//We need to skip base
		for(i=0;i<imageList.length;i++){
			if(layer==parseInt(layerList[i])){
				if(baseFolderFound){
					folderList = folderList +","+imageList[i];
				}else{
					baseFolder = imageList[i];
					folderList = imageList[i];
					baseFolderFound = true;
				}
			}
		}
	
		//Prepare Arguemnts and Macro Name
		arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+baseFolder;
		macroName = "step4.2_extractAir.ijm";
		print("\nRunning"+macroName);
		print("Args... Parameter,pathImages,folderList,baseFolder");
		print(arguments+"\n");
		runMacro(pathMacro+macroName,arguments);
	}
}

if(false){
	//STEP 4.3 extract water
	for(layer=1;layer<=7;layer++){
		folderList = "";
		baseFolder = "";
		baseFolderFound = false;//We need to skip base
		for(i=0;i<imageList.length;i++){
			if(layer==parseInt(layerList[i])){
				if(baseFolderFound){
					folderList = folderList +","+imageList[i];
				}else{
					baseFolder = imageList[i];
					folderList = imageList[i];
					baseFolderFound = true;
				}
			}
		}
	
		//Prepare Arguemnts and Macro Name
		arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+baseFolder;
		macroName = "step4.3_extractWater.ijm";
		print("\nRunning"+macroName);
		print("Args... Parameter,pathImages,folderList,baseFolder");
		print(arguments+"\n");
		runMacro(pathMacro+macroName,arguments);
	}
}

if(false){
	//STEP 4.4 extract thinfilm
	for(layer=1;layer<=7;layer++){
		folderList = "";
		baseFolder = "";
		baseFolderFound = false;//We need to skip base
		for(i=0;i<imageList.length;i++){
			if(layer==parseInt(layerList[i])){
				if(baseFolderFound){
					folderList = folderList +","+imageList[i];
				}else{
					baseFolder = imageList[i];
					folderList = imageList[i];
					baseFolderFound = true;
				}
			}
		}
	
		//Prepare Arguemnts and Macro Name
		arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+baseFolder;
		macroName = "step4.4_extractThinfilm.ijm";
		print("\nRunning"+macroName);
		print("Args... Parameter,pathImages,folderList,baseFolder");
		print(arguments+"\n");
		runMacro(pathMacro+macroName,arguments);
	}
}

if(true){
	//STEP 5 concat
	time = 0;
	folderList = "";
	for(i=0;i<imageList.length;i++){
		if(parseInt(layerList[i])==1){
			//New layer. Run previous folderList
			if(folderList!=""){
				arguments = parameter+"\n"+pathImages+"\n"+folderList+"\n"+time;
				macroName = "step5_verticalConcat.ijm";
				print("\nRunning"+macroName);
				print("Args... Parameter,pathImages,folderList,baseFolder");
				print(arguments+"\n");
				runMacro(pathMacro+macroName,arguments);
			}
			folderList = imageList[i];
			time++;
		}else{
			folderList = folderList +","+imageList[i];
		}
	}
}

setBatchMode(false);