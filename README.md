TagHighlight - libc/c++
==============

Scripts to generate `.taghl` files for libc and libc++ for vim's TagHighlight plugin.

Ready-to-use TagHL libraries are also included, more precisely:
- the C POSIX Library (2008 specification; includes all C99 headers);
- the C++ Standard Library (includes all C++11 headers).

Both of them are provided with the `library_types.txt` used by TagHL, in such a way that only the libraries actually used are loaded (the headers correspond to the ones listed here: <http://stackoverflow.com/a/2029106>, however I removed some of them because I didn't have them and they didn't really seem useful).

## Important remarks regarding the scripts

For the scripts to work, you will need `Bash 4+`, `ctags` and `vim` with TagHiglight.

Below are specific remarks for both of the scripts.

### gen\_libc\_posix.sh

In some case (at least in mine, that is under Fedora 18 x64), some POSIX headers are not in `/usr/include` but in the `gcc` headers path. It's very likely that you will have to modify that path (`GCC_HEADERS_PATH`) in the script because it depends on which version of `gcc` you have and under which distrib it runs.

### gen\_libc++.sh

Here it really gets funny. Because of `ctags` not complying with C++11, it totally fails to parse several C++11 headers. To solve that problem, I did some extreme hack in them (see the header of the script for more details) and I included them in `scripts/modif_c++_headers` (I do not guarantee they will work in your case, if you want to be sure you'd better do yourself the modifications on your system headers). Be very careful! Because of the way `gcc` includes headers, it is very complicated to index them from another place so you'll have to modify your system headers in place, DO BACKUPS! And don't forget to revert the changed headers with your backup afterwards...

On the other hand, the generated tags file is not usable because of another hack in the filenames (made required by TagHL); if you want to use it you should stop the script before l.50.


