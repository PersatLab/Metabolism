// @File(label="Select the images to process", style="directory") data_root
Start = getTime();
filelist = getFileList(data_root);
NameOfTable = "Data";
strains = newArray(filelist.length);
sugars = newArray(filelist.length);
MWs = newArray(filelist.length);

for (i = 0; i < filelist.length; i++) {
	name = split(filelist[i], " ");
	name=Array.deleteIndex(name, 0);
	strains[i] = name[0];
	sugars[i] = name[2];
	MW_raw= split(name[4], "k");
	MWs[i] = MW_raw[0];
}
Unique_strains = findUnique(strains);
Unique_sugars = findUnique(sugars);
Unique_MWs = findUnique(MWs);
k=1;
for (strain = 0; strain < Unique_strains.length; strain++) {
	for (mw = 0; mw < Unique_MWs.length; mw++) {
		regex_expression = ".*"+Unique_strains[strain]+".*"+Unique_sugars[0]+".*"+Unique_MWs[mw]+".*";
		indexes_to_process = getMatchingIndex(filelist, regex_expression);
		nb_biorep = indexes_to_process.length;
		for (br = 1; br < nb_biorep+1; br++) {
			print("Working on "+filelist[indexes_to_process[br-1]]);
			run("Bio-Formats Importer", "open=["+data_root+File.separator+filelist[indexes_to_process[br-1]]+"] autoscale color_mode=Default open_all_series rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
			images_titles = getList("image.titles");
			nb_series = nImages/2;
			
			Red_images = newArray(nb_series);
			Green_images = newArray(nb_series);
			
			for (s = 1; s < nb_series+1; s++) {
				for (i = 1; i < nImages+1; i++) {
					serie = "series "+s;
					ind=indexOf(images_titles[i-1], serie);
					if (ind>0) {
						ind_channel = indexOf(images_titles[i-1], "C=0");
						if (ind_channel>0) {
							Red_images[s-1] = images_titles[i-1];
						} else {
							Green_images[s-1] = images_titles[i-1];
						}
						run("Subtract Background...", "rolling=50");
					}
				}
			}
			for (serie = 0; serie < Red_images.length; serie++) {
				n = getNResultsFromTabel("Data");
				roiManager("reset");
				selectWindow(Red_images[serie]);
				run("Duplicate...", "title=Bkg");
				ID_bkg = getImageID();
				setAutoThreshold("RenyiEntropy dark");
				setOption("BlackBackground", false);
				run("Convert to Mask");
				run("Median...", "radius=2");
				run("Analyze Particles...", "size=0.50-10.00 exclude add");
				run("Clear Results");
				
				Ncells_detected = roiManager("count");
				selectImage(ID_bkg);
				close();
				
				selectWindow(Red_images[serie]);
				if(isOpen(NameOfTable)){
					IJ.renameResults(NameOfTable,"Results");
				}
				else {
					if(isOpen("Results")) IJ.renameResults("Results","Tmp");
				}
				for (i = 0; i < Ncells_detected; i++) {
					roiManager("select", i);
					getStatistics(area, mean, min, max, std, histogram);
					setResult("Strain", i+n, Unique_strains[strain]);
					setResult("Sugar", i+n, Unique_sugars[0]);
					setResult("MW", i+n, Unique_MWs[mw]);
					setResult("YPosition", i+n, k);
					setResult("BioRep", i+n, br);
					setResult("Serie", i+n, serie+1);
					setResult("Label", i+n, "Cell"+(i+1));
					setResult("Area", i+n, area);
					setResult("MeanRed", i+n, mean);
				}
				
				selectImage(Green_images[serie]);
				for (i = 0; i < Ncells_detected; i++) {
					roiManager("select", i);
					getStatistics(area, mean, min, max, std, histogram);
					setResult("MeanGreen", i+n, mean);
				}
				IJ.renameResults("Results",NameOfTable);
				if(isOpen("Tmp")) IJ.renameResults("Tmp","Results");
			}
			run("Close All");
			print("done!");
		}
	k=k+1;
	}
}

End = getTime();

Time = End-Start;

print("Elapsed time = "+Time/1000 + " s");






/*  findUnique(array) returns an array with all unique occurences within an array
 */
function findUnique(array){
	Array.sort(array);
	Occurences = newArray(1);
	Occurences[0] = array[0];
	for (i = 1; i < array.length-1; i++) {
		if (!matches(array[i], array[i-1])) {
			Occurences = Array.concat(Occurences,array[i]);
		}
	}
	return Occurences;
}

/*  getMatchingIndex(array, regex_criteria) returns an array with the indexes of an array occurence corresponding to 
 *  the regular expression
 */
function getMatchingIndex(array, regex_criteria){
	Indexes = newArray(1);
	for (i = 0; i < array.length; i++) {
		if (matches(array[i], regex_criteria)) {
			Indexes = Array.concat(Indexes,i);
		}
	}
	Indexes = Array.deleteIndex(Indexes, 0);
	return Indexes;
}

/*  getNResultsFromTabel(NameOfTable) write the value on the column and row of the Result
 *  table of NameOfTable. If NameOfTable exists it calls it and make the desired change, if it
 *  doesn't exists it ceates it.
 * 
 */
 function getNResultsFromTabel(NameOfTable){
 	if(isOpen(NameOfTable)){
		IJ.renameResults(NameOfTable,"Results");
		n=nResults;
		IJ.renameResults("Results",NameOfTable);
 	} else n=0;
 	return n;
 }

/*  writeResult(NameOfTable, Column, Row, Value) write the value on the column and row of the Result
 *  table of NameOfTable. If NameOfTable exists it calls it and make the desired change, if it
 *  doesn't exists it ceates it.
 * 
 */
function writeResult(NameOfTable, Column, Row, Value){
	if(isOpen(NameOfTable)){
		IJ.renameResults(NameOfTable,"Results");
		setResult(Column, Row, Value);
		IJ.renameResults("Results",NameOfTable);
	}
	else {
		if(isOpen("Results")) IJ.renameResults("Results","Tmp");
		setResult(Column, Row, Value);
		IJ.renameResults("Results",NameOfTable);
		if(isOpen("Tmp")) IJ.renameResults("Tmp","Results");
	}
}