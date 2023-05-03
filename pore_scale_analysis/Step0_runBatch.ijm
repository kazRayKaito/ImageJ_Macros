//---------------Set Variables----------------------

//Macro Start - End
forceStartMacro = 4;
forceEndMacro = 5;

//Ask before each step
askBeforeEachStep = false;

//Defining path for Macro and get macro list
flMacro = "C:/Users/lizij/Documents/imageJ_Macros/ImageJ_Macros/pore_scale_analysis/";
//flMacro = "C:/Users/Kazuk/Documents/2_Projects/VSCode/ImageJ_Macros/pore_scale_analysis/";

//---------------Set Variables----------------------

//Initialize log, macroList, macroStart and End
print("\\Clear");
macroList = getFileList(flMacro);
startMacroIndex  = 1;
endMacroIndex = macroList.length;

//Override Start and End Macro
if(forceStartMacro != 0) startMacroIndex = forceStartMacro;
if(forceEndMacro   != 0) endMacroIndex   = forceEndMacro + 1;


//Get Image Directory
flRaw = getDirectory("Choose a Directory for a folder which contains folders with [initial, 0, 1,2,...]");

//Run Each Macro
for(i = startMacroIndex; i < endMacroIndex; i++){
	if(askBeforeEachStep){
		waitForUser("Is it ok to run "+macroList[i]+"?");
	}
	print("running "+macroList[i]);
	runMacro(flMacro+macroList[i],flRaw);
}