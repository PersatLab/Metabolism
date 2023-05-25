dir=getDirectory("Choose a Directory")
print(dir)
list=getFileList(dir)


for(i=0; i<list.length;i++){	
		open(dir+list[i]);

// Split channel, Gaussian Blur, Stitch

rename("composite");
run("Split Channels");


	selectWindow("C1-composite");
		rename("raw_image");
		run("Duplicate...", "duplicate");
		rename("Gaussian_Blur");
		selectWindow("Gaussian_Blur");
		run("Gaussian Blur...", "sigma=78 scaled stack"); //adjust sigma
		imageCalculator("Subtract create 32-bit stack", "raw_image","Gaussian_Blur");
		rename("BGS-1");
		selectWindow("raw_image");
		close();
		selectWindow("Gaussian_Blur");
		close();

    		selectWindow("C2-composite");
				rename("raw_image");
				run("Duplicate...", "duplicate");
				rename("Gaussian_Blur");
				selectWindow("Gaussian_Blur");
				run("Gaussian Blur...", "sigma=78 scaled stack"); //adjust sigma
				imageCalculator("Subtract create 32-bit stack", "raw_image","Gaussian_Blur");
				rename("BGS-2");
				selectWindow("raw_image");
				close();
				selectWindow("Gaussian_Blur");
    			close();

    			selectWindow("BGS-1");
					run("Duplicate...", "duplicate range=1-20"); //adjust range based on stack
					rename("Top");
					selectWindow("BGS-1");
					run("Duplicate...", "duplicate range=21-40"); //adjust range based on stack
					rename("Bottom_inverted");
					selectWindow("BGS-1");
					close();
					selectWindow("Top");
					run("Make Montage...", "columns=20 rows=1 scale=1");
					rename("Top Channel");
					selectWindow("Top");
					close();
					selectWindow("Bottom_inverted");
					run("Reverse");
					run("Make Montage...", "columns=20 rows=1 scale=1");
					rename("Bottom Channel");
					selectWindow("Bottom_inverted");
					close();
					run("Images to Stack", "name=Stack title=[] use");
					run("Make Montage...", "columns=1 rows=2 scale=1");
					rename("Red channel");
					selectWindow("Stack");
					close();


					
    			selectWindow("BGS-2");
					run("Duplicate...", "duplicate range=1-20"); //adjust range based on stack
					rename("Top 2");
					selectWindow("BGS-2");
					run("Duplicate...", "duplicate range=21-40"); //adjust range based on stack
					rename("Bottom_inverted 2");
					selectWindow("BGS-2");
					close();
					selectWindow("Top 2");
					run("Make Montage...", "columns=20 rows=1 scale=1");
					rename("Top Channel 2");
					selectWindow("Top 2");
					close();
					selectWindow("Bottom_inverted 2");
					run("Reverse");
					run("Make Montage...", "columns=20 rows=1 scale=1");
					rename("Bottom Channel 2");
					selectWindow("Bottom_inverted 2");
					close();
					run("Images to Stack", "name=Stack title=2 use");
					run("Make Montage...", "columns=1 rows=2 scale=1");
					rename("Green channel");
					selectWindow("Stack");
					close();


run("Merge Channels...", "c1=[Red channel] c2=[Green channel] create");
saveAs("Tiff",dir+"BGS_stitch_"+list[i]+".tif");
run("Close All");
}
