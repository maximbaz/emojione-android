# JoyPixels for Android/Linux

## Building JoyPixels

Building JoyPixels requires a few files from nototools. Clone a copy from
https://github.com/googlei18n/nototools and either put it in your PYTHONPATH or
use 'python setup.py develop' ('install' currently won't fully install all the
data used by nototools). You will also need fontTools, get it from
https://github.com/behdad/fonttools.git.

Then run make. JoyPixels is the default target. It's suggested to use -j,
especially if you are using zopflipng for compression. Or you can use `NOCOMPRESSING=1`
to skip compressing. Intermediate products (compressed image files, for example)
will be put into a build subdirectory; the font will be at the top level.

## Prebuilt font file

[JoyPixels.ttf](https://github.com/mxalbert1996/emojione-android/raw/master/fonts/JoyPixels.ttf)

[JoyPixels_Watergun.ttf](https://github.com/mxalbert1996/emojione-android/raw/master/fonts/JoyPixels_Watergun.ttf) (Watergun alternative)

## License

Tools are under the [Apache license, version 2.0](./LICENSE).

[JoyPixels image license](https://www.joypixels.com/licenses/free)
