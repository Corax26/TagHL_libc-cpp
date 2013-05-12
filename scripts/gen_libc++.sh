#!/bin/bash
#Hack to be done (see folder modif_cpp_headers): 
#	* erase class bitset implementation (bitset header)
#	* hack template of __detail::_Shift ('__w <' => '__w ==') (bits/random.h header)
#	* same for struct __static_sign and struct __big_less (ratio header)

TAGS=libc++_tags
TYPES=libc++.taghl
HEADERS=c++_headers.txt
declare -A bits_headers

rm -f $TAGS
echo Generating $TAGS file
while read header
do
	echo Parsing $header
	if `g++ -E -std=c++11 -x c++-header $header > tmp.h`
	then
		ctags -f $TAGS --append=yes --excmd=number\
			--c++-kinds=+p  --c++-kinds=-m --extra=+q --fields=+iaS --language-force=c++ \
			--line-directives=yes -I noexcept -I static_assert+ tmp.h
		# Note, no x in c++-kinds: a bug in ctags prevents it from generating entries for extern declarations
		# inside a namespace (but there are tons of useless extern template/class declarations
		# so it's better to fully disable externs)
		ctags -f $TAGS --append=yes --excmd=number\
			--c++-kinds=d --language-force=c++ --line-directives=yes $header
		for h in `g++ -M -std=c++11 -x c++-header $header | grep -oE '(\S*/bits/\S*)|(/usr/include/[a-z.]*\s)'`
		do 
			bits_headers[$h]=1
		done
	else
		echo Header not found
	fi
done < $HEADERS

echo
echo "Parsing bits for additional macros (${#bits_headers[@]} headers)"
for h in ${!bits_headers[@]}
do
	echo Parsing $h
	ctags -f $TAGS --append=yes --excmd=number --c++-kinds=d \
	--language-force=c++ $h
done

echo Deleting _identifiers and removing duplicates
vim -c 'g/\v::_|^_/d' -c 'g/\%(^\1\>.*$\n\)\@<=\(\k\+\).*$/d' -c 'wq' $TAGS


echo Hacking $TAGS: adding .h to standard unsuffixed C++ headers...
vim -c '%s/\v(\/usr\S*)(\.h)@<!\t/\1.h\t/g' -c 'wq' $TAGS

echo Generating $TYPES
vim -c "let g:TagHighlightSettings['TypesFileNameForce']='$TYPES'" \
	-c "let g:TagHighlightSettings['Languages']=['c']" \
	-c "let g:TagHighlightSettings['TagFileName']='$TAGS'" \
	-c "UpdateTypesFileOnly" \
	-c "q"

# Because of the aforementioned ctags extern in namespace bug, manually add the few true
# C++ extern & C extern (extracted from libc_posix.taghl)
sed -i '1s/^/syn keyword CTagsExtern cin cout cerr clog wcin wcout wcerr wclog nothrow\nsyn keyword CTagsExtern stdout optind sys_siglist sigevent daylight gdbm_version timezone sys_nerr gdbm_errno tm optopt in6addr_any optarg gdbm_errlist re_syntax_options opterr rusage stdin sys_errlist signgam tzname stderr in6addr_loopback gdbm_version_number\n/' $TYPES 

echo Done

