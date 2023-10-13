//---------------Set Variables----------------------

offset = 5;
fitCutoffRatio = 5;


//---------------Set Variables----------------------

//----------For batch, get rootFoler----------------
argument = getArgument();
if(argument!=""){
	flRaw = argument;
	print("Argument Dir:"+flRaw);
}else{
	print("\\Clear");
	flRaw = getDirectory("Choose a root dir");
	print("Selected Dir:"+flRaw);
}

//----------CheckFolderStructure make imageJ folder----------------

fli = flRaw + "videos\\";
flo = flRaw + "ImageJ\\";
File.makeDirectory(flo);

videoList = getFileList(fli);
print(fli);
print(videoList.length);

for(videoIndex = 0; videoIndex < videoList.length; videoIndex++){
	//Open each video
	videoFilePath = fli + videoList[videoIndex];
	run("Movie (FFMPEG)...", "choose=" + videoFilePath + " use_virtual_stack first_frame=0 last_frame=-1");
	
	//GetTitle
	title = File.getNameWithoutExtension(getTitle());
	
	//GetSaveFolder
	saveFolder = flo + title + "\\";
	File.makeDirectory(saveFolder);
	saveFolder = saveFolder + "0_Original\\";
	File.makeDirectory(saveFolder);
	
	//Save each image
	run("Image Sequence... ", "dir=" + saveFolder + " format=TIFF name=img_");
	close();
}