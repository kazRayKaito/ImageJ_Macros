//---------------Set Variables----------------------


//If "", then ask for folder, if not, the path will be used
fliRoot = "E:/LilysSSD/nw_raw_xySlopeTest/";


//---------------Set Variables----------------------

//Initialize log, macroList, macroStart and End
print("\\Clear");


//Get SubFolder Path
fli = fliRoot + "/0_brine/XY/";
floList = newArray(4);
floList[0] = fliRoot + "/1_brine/XY/";
floList[1] = fliRoot + "/2_brine/XY/";
floList[2] = fliRoot + "/3_brine/XY/";


imageListTemp = getFileList(fli);
imageList = newArray(0);
for(i = 0; i < lengthOf(imageListTemp); i++){
	if(endsWith(imageListTemp[i], "tif")){
		imageList = Array.concat(imageList,imageListTemp[i]);
	}
}

for(i = 0; i < 1300; i++){
	open(fli + imageList[i]);
	run("Rotate 90 Degrees Left");
	saveAs("Tiff", floList[0] + imageList[i]);
	run("Rotate 90 Degrees Left");
	saveAs("Tiff", floList[1] + imageList[i]);
	run("Rotate 90 Degrees Left");
	saveAs("Tiff", floList[2] + imageList[i]);
	close(imageList[i]);

}
