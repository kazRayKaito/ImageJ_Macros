//---------------Set Variables----------------------

//Macro Start - End
forceStartMacro = 1;
forceEndMacro = 1;

//Ask before each step
askBeforeEachStep = false;

//Defining path for Macro and get macro list
macroDir = getDirectory("macros");
macroDir = "C:/Users/Kazuk/Documents/2_Projects/VSCode/ImageJ_Macros/bubbleTracking_shiraishi/"

//---------------Set Variables----------------------

//Initialize log, macroList, macroStart and End
print("\\Clear");
print(macroDir);

macroList = getFileList(macroDir);
startMacroIndex  = 1;
endMacroIndex = macroList.length;

//Override Start and End Macro
if(forceStartMacro != 0) startMacroIndex = forceStartMacro;
if(forceEndMacro   != 0) endMacroIndex   = forceEndMacro + 1;


//Get Image Directory
flRoot = getDirectory("Choose a root dir");
flList = getFileList(flRoot);

for(flIndex = 0; flIndex <flList.length; flIndex++){
	folderPath = flRoot + flList[flIndex];
	print("working on Path: " + folderPath);
	for(macroIndex = startMacroIndex; macroIndex < endMacroIndex; macroIndex++){
		if(askBeforeEachStep){
			waitForUser("Is it ok to run "+macroList[macroIndex]+"?");
		}
		macroPath = macroDir+macroList[macroIndex];
		print("running "+macroPath);
		print("running "+macroList[macroIndex]);
		runMacro(macroPath, folderPath);
	}
	return;
}
