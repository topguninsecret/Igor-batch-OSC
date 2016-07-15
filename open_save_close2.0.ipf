#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.0
// Program to open files, save them as tab delimidated, then close them out of memory.

// Example:
//osc("C:Documents and Settings:computation:Desktop:AFM_6-2-16:", "SKPM_", 21, basepaths ="C:Documents and Settings:computation:Desktop:testfolder:",  startsuffix = 0000)
// Simpler example:
//osc("C:Documents and Settings:computation:Desktop:AFM_6-2-16:", "SKPM_", 21)
//osc(base_path_to_open, base_name_to_open, ending_suffix)


//startsuffix is an optional parameter and if given must be given as "startsuffix=0000"
// see->    DisplayHelpTopic "ParamIsDefault"
// basepatho = base path to open  
// basenameo = base name to open
// suffend = last number in the batch to process
// basepaths = base path to save
// basenames = base name to save
// startsuffix = base number to begin iterating from, useful if your first few images are actually graphs
// Aubrey

Menu "Export to .txt"
	//Submenu "Batch Export Folder"
	//	"Default", osc()
	//	"Custom Labeling", osc()
	//end
	"Batch Export Folder", FolderUI()
	"Single File Export", SingleUI()
end

	
Function FolderUI()
	Variable refNum
	String basepatho
	
	// Ask user for folder that contains .ibw files
	String message = "Select folder containing *.ibw files to be exported"
	NewPath /M = message /O/Q basepatho
	if (V_Flag)
		return -1		//user canceled prompt
	endif 
	PathInfo basepatho  // obtain symbolic path info from "basepatho"
	basepatho = S_path  // take string generated by PathInfo and call "basepatho"
	
	// request open parameters
	Variable suffend = 0001, saves = 1
	String basenameo = "Image"  //"SKPM_"
	Prompt basenameo, "Enter the base name of the files (enclose in quotes, CASE matters): " 
	Prompt suffend, "What suffix number do you want the export to END with?"
	Prompt saves, "Use default save parameters? (e.g. save folder, save name, inital file exported) ", popup "Yes;No"
	
	DoPrompt "Information Required for File Open", basenameo, suffend, saves
	if (V_Flag)
		return -1		//user canceled
	endif 
	
	//  Add this section back once bugs are worked out
	// do they want default save parameters if no do:
	if (saves !=1)
		//request save path
		message = "What folder would you like the exported *.txt files to be saved in?"
		NewPath /M  = message /O basepaths
		PathInfo basepaths  // obtain symbolic path
		string basepaths = S_path  // set path string to basepaths
		if (V_Flag)		//user canceled this prompt, do not set basepaths (let OSC() deal with it)
			basepaths = basepatho
		endif
		
		// request optional parameters
		Variable startsuffix = 0000
		String basenames = "NewName"  //"SKPM_"
		Prompt basenames, "Enter the new base name of the files (enclose in quotes, CASE matters): " 
		Prompt startsuffix, "What suffix number do you want the import to BEGIN with?"
		
		DoPrompt "Optional Information", basenames, startsuffix
		if (V_Flag)
			return -1		//user canceled something
		endif
	endif
	
	
	//run appropriate scripts to open identified files\
	//PathInfo/S basepatho
	if (saves ==1)
		osc(basepatho, basenameo, suffend)
	else
		osc(basepatho, basenameo, suffend, basepaths = basepaths, basenames = basenames, startsuffix = startsuffix)
	endif
end


Function SingleUI()
	print "HA, ...Didn't get around to programming this one yet...\r"
	
end


Function osc(basepatho, basenameo, suffend, [basepaths, basenames, startsuffix]) 		// basepatho = base path to open  // basepaths = base path to save
	string basepatho
	string basenameo, basepaths, basenames
	variable startsuffix, suffend
	variable suffix
	
	// check for the startsuffix, if it isn't present, default to 0000
	if (ParamIsDefault(startsuffix))
		startsuffix =0000
	endif
	// check for the basenames, if it isn't present, default to the same as basenameo
	if (ParamIsDefault(basenames))
		basenames =basenameo
		//NewPath/C/O stuff "C:Documents and Settings:computation:Desktop:130826:output:"
	endif
	// check for the basepaths, if it isn't present, default to the same as basepatho
	if(ParamIsDefault(basepaths))
		basepaths = basepatho + "output:"
	endif
	suffix = startsuffix

	// Set the symbolic file path for the open operation
	NewPath/O/Q opensezme basepatho
	// Set the symbolic file path for the save operation
	NewPath/C/O/Q savesezme basepaths
	
	do
	// form the filename
	// note that num2string() drops preceeding 0s.  So we must add them back to stay with igor's naming scheme
		if (suffix<10)
			string zeros = num2istr(0) + num2istr(0) + num2istr(0)
		elseif (suffix<100 && suffix>=10)
			zeros = num2istr(0) + num2istr(0)
		elseif (suffix<1000 && suffix>=100)
			zeros =  num2istr(0)
		elseif (suffix<10000 && suffix>=1000)
			// do not add zeros
		elseif (suffix>=10000)
			print "I'm sorry, we don't know what to do with this number suffix. See command osc()."
			abort
		endif
		
		string nameo = basenameo + zeros +num2istr(suffix)
		
		// open the wave
		LoadWave /P=opensezme nameo
		
		
		// Part 2  Save the wave as tab seperated
		// create the name to save the wave under
		string names = basenames + zeros + num2str(suffix) + ".txt"  			// this is the name of the file
		string namesfp = basepaths + names				// this is the names full path
		// Save/J SKPM_0000 as "SKPM_0000.txt"
		Save/O/J $nameo as namesfp  // '$' operator converts the string to a file reference
		print "Saved\r"
		// Part 3 Close out the wave
		killwaves $nameo
		suffix +=1
		if (V_Flag)
			return -1		//user canceled something
		endif
	while(suffix<=suffend)
	
	print "\r dun dun ..Doneee. \r"
	
end


//Function help()
	//print "Example: osc(basepatho, basenameo, suffend, [basepaths, basenames, startsuffix]) \r"
	//print  "basepatho = base path to open  \r basenameo = base name to open \r suffend = last number in the batch to process\r basepaths = base path to save \r basenames = base name to save \r startsuffix = base number to begin iterating from, useful if your first few images are actually graphs"
	//print "Note that to use optional parameters you must explicitly define them in the function call using 'ParamName =Value' syntax"
	//print "Note that in path specification, you should use ':' instead of '/' to specify subdirectories.\r"
	//DisplayHelpTopic "ParamIsDefault"
	//DisplayHelpTopic "Using Optional Parameters"
//end


Function/S DoOpenFileDialog()
	Variable refNum
	String message = "Select first that will be exported"
	String outputPath
	String fileFilters = "Igor binary files (*.ibw):.ibw;"
	fileFilters += "All Files:.*;"
	Open /D /R /F=fileFilters /M=message refNum
	outputPath = S_fileName
	return outputPath // Will be empty if user canceled
End

