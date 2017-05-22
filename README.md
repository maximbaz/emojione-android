## Building EmojiOne

Building EmojiOne requires a few files from nototools.  Clone a copy from
https://github.com/googlei18n/nototools and either put it in your PYTHONPATH or
use 'python setup.py develop' ('install' currently won't fully install all the
data used by nototools).  You will also need fontTools, get it from
https://github.com/behdad/fonttools.git.

Then run make.  EmojiOne is the default target.  It's suggested to use -j,
especially if you are using zopflipng for compression.  Intermediate products
(compressed image files, for example) will be put into a build subdirectory; the
font will be at the top level.

## License

Tools and most image resources are under the [Apache license, version 2.0](./LICENSE).
[EmojiOne image license](https://www.emojione.com/developers/free-license)
