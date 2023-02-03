//Initialize log
print("\\Clear");

//Defining path for Macro and get macro list
flMacro = "R:/1_ReserachRelated/ruBatch_3D_tracer/batch/";
macroList = getFileList(flMacro);

//Inception mode
inceptionMode = 0;

if(inceptionMode == 0){
	//Get root folder of the raw folders
	flRoot = getDirectory("Choose the very root directory.");
	flRawList = getFileList(flRoot);
	
	for(flRawIndex = 0; flRawIndex< flRawList.length; flRawIndex++){
		flRaw = flRawList[flRawIndex].substring(0, flRawList[flRawIndex].length - 1) + "\\";
		for(i = 4; i <= 4; i++){
			print("running "+macroList[i] + "at Folder:" + flRaw);
			runMacro(flMacro+macroList[i],flRoot + flRaw);
		}
	}
}else{
	//Get Image Directory
	flRaw = getDirectory("Choose a Directory for a folder which contains folder [initial, 0, 1,2,...]");
	for(i=1;i<macroList.length;i++){
		waitForUser("Is it ok to run step"+i+"?");
		print("running "+macroList[i]);
		runMacro(flMacro+macroList[i],flRaw);
	}
}