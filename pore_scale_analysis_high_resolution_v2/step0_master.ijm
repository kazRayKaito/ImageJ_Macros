//---------------Set Variables----------------------

//Macro start-end [ 1 ~ 5 ]
startMacroIndex = 2;
endMacroIndex = 2;

//Macro List
//   Step1:getStackInfo
//   Step2:alignCylinder
//   Step3:separatePhases
//   Step4:analyzeInvasion
//   Step5:visualizeEachPhase

//Defining path for Macro and get macro list
flMacro = "C:/Users/kazuk/Documents/GitHub/ImageJ_Macros/pore_scale_analysis_high_resolution_v2/";

//If "", then ask for folder, if not, the path will be used
//overWrittenFlRaw = ""
//overWrittenFlRaw = "/Volumes/raySSD2T/Data/Lily\'sResearch/LowRes_test/";
overWrittenFlRaw = "B:/ForLily/2025-12-27_LilysSSD/nw_raw_only3/";

//---------------Set Variables----------------------

//Initialize log, macroList, macroStart and End
print("\\Clear");

macroList = getFileList(flMacro);

//Get Image Directory
if(overWrittenFlRaw == ""){
	flRaw = getDirectory("Choose a folder which contains [0_brine, 1_xxxx, 2_xxxx]");
}else{
	flRaw = overWrittenFlRaw;
}

//Run Each Macro
for(i = startMacroIndex; i <= endMacroIndex; i++){
	print("running "+macroList[i]);
	runMacro(flMacro+macroList[i],flRaw);
}