
#!/bin/bash

function compare_png {
    
        OLD="$1"
	NEW="$2"
	NUMBER="$3"
	FILENAME="./diff/diff_$NUMBER.png"

	compare -compose src $OLD $NEW $FILENAME
	# Markierter Bereich vergrössern 
	convert $FILENAME -morphology Erode Disk:10 $FILENAME

}

function pdf2png {

     	PDF="$1"
	BASE="$2"

     	gs -dNOPAUSE -dSAFER -dBATCH \
		-sDEVICE=png16m \
		-r300 \
	        -sOutputFile="$BASE-%03d.png" \
	        $PDF
 
}

function png2black-white {

    OLD="$1"
	NUMBER="$2"
	FILENAME="./black_white/gray_$NUMBER.png"
	convert $OLD -type Grayscale $FILENAME
}

function combine_old_diff {
 
    OLD_GRAY="$1"
	DIFF="$2"
	NUMBER="$3"
	FILENAME="./combine/resultat$NUMBER.png"

    composite -compose Multiply $DIFF $OLD_GRAY $FILENAME
}

function combine_all_png_to_pdf {
    
    PNGFILE="$1"
	FILENAME="$2"
	echo $3
	
	convert $PNGFILE*.png $FILENAME


}

#-------------------------------------------------------------------------------
#
# Check for depency
#
#-------------------------------------------------------------------------------
#sudo apt-get install zenity imagemagick

#-------------------------------------------------------------------------------
#
# Run the skript in  excecutable mode "chmod +x DiffSkript.sh" 
# ./DiffSkript.sh
#
#-------------------------------------------------------------------------------

C=1
OLDFILE=$(zenity --file-selection --title="Auswahl 'alte' Version; Ordner old")
NEWFILE=$(zenity --file-selection --title="Auswahl 'neue' Version; Ordner new")
#generate png
pwd=$(pwd)
cd ./old
pdf2png $OLDFILE "png_old"
cd ../new
pdf2png $NEWFILE "png_new"
cd ..
echo -e "generate png DONE!\n"
echo "generate DiffFile...."
for file in ./old/*.png
do
	compare_png "$pwd/new/png_new-00$C.png" "$pwd/old/png_old-00$C.png" "$C"
	
	png2black-white "$pwd/old/png_old-00$C.png" "$C"
	
	combine_old_diff "$pwd/black_white/gray_$C.png" "$pwd/diff/diff_$C.png" "$C"
        
	C=$((C+1))
	 
done
echo DONE!
timestamp=$( date +"%H-%M-%S" )
combine_all_png_to_pdf "$pwd/combine/" "DiffFile_"$timestamp".pdf"
echo "Remove png files "
rm ./new/*.png ./old/*.png ./diff/* ./combine/* ./black_white/*
zenity --info --text="Das Differenzfile wurde erfolgreich erstellt" --title="Info"
