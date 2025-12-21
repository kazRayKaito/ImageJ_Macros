//---------------Set Variables----------------------

//Macro Start - End
forceStartMacro = 1;
forceEndMacro = 1;

//Macro List
//Step1:GetStackInfo
//Step2:AlignCylinder


//Ask before each step
askBeforeEachStep = true;

//Defining path for Macro and get macro list
flMacro = "/Users/kazukikaito/Workspace/github/ImageJ_Macros/pore_scale_analysis_high_resolution_v2/"

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
flRaw = getDirectory("Choose a folder which contains [0_brine, 1_xxxx, 2_xxxx]");

//Run Each Macro
for(i = startMacroIndex; i < endMacroIndex; i++){
	if(askBeforeEachStep){
		waitForUser("Is it ok to run "+macroList[i]+"?");
	}
	print("running "+macroList[i]);
	runMacro(flMacro+macroList[i],flRaw);
}
