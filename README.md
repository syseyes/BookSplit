# BookSplit
Allows to split a set of images of a two-pages scanned book in two files in a fast way.
BookSplit
version 0.1
Made in Autohotkey by jbarcelo
Adapted from BookCrop from nod5.dcmembers.com 
Free Software -- http://www.gnu.org/licenses/gpl-3.0.html
Tested in Win7 x64

WHAT IT DOES
1. Drag and drop a folder of jpeg or tif images.
2. Show the images present in the folder in sequence
3. Allows click in the image and divide the image in two files. Left and Right
4. Goes to next image and repeat the proces until the end.


SETUP
- Get and install latest GraphicsMagick (Q8 version is faster)
- Get Jpegtran from libjpeg-turbo (faster than jpegclub version):
  - Download libjpeg-turbo-1.4.90-gcc.exe (64bit: gcc64.exe) or newer
  - Unzip the exe and browse \bin subfolder
  - copy jpegtran.exe + libjpeg-62.dll and place next to BookSplit.exe

NOTES
BookSplit split all and only jpeg or tif files in the dropped folder.
Other files and subfolders are ignored.

Advice: Use split to subfolder, so you can redo if you split in the wrong place.
Preview works well only if all input images have same size.
