#!/bin/bash
TAGS=libc_posix_tags
TYPES=libc_posix.taghl
HEADERS=c_posix_headers.txt
declare -A bits_headers

rm -f $TAGS
echo Generating $TAGS file
while read header
do
	echo Parsing $header
	if `gcc -E $header > tmp.h`
	then
		ctags -f $TAGS --append=yes --excmd=number\
		--c-kinds=+px  --fields=+S --language-force=c --line-directives=yes tmp.h
		ctags -f $TAGS --append=yes --excmd=number --c-kinds=d \
		--language-force=c $header
		for h in `gcc -M $header | grep -oE '\S*bits\S*'`
		do 
			bits_headers[$h]=1
		done
	else
		echo Header not found, trying gcc headers
		ctags -f $TAGS --append=yes --excmd=number --c-kinds=d --fields=+S \
			--language-force=c /usr/lib/gcc/x86_64-redhat-linux/4.7.2/include/`basename $header` \
			&& echo gcc header found

	fi
done < $HEADERS

echo
echo "Parsing bits for additional macros (${#bits_headers[@]} headers)"
for h in ${!bits_headers[@]}
do
	echo Parsing $h
	ctags -f $TAGS --append=yes --excmd=number --c-kinds=d \
	--language-force=c $h
done

echo
echo Deleting _identifiers
vim -c 'g/^_/d' -c 'wq' $TAGS

echo Generating $TYPES
vim -c "let g:TagHighlightSettings['TypesFileNameForce']='$TYPES'"\
	-c "let g:TagHighlightSettings['Languages']=['c']"\
	-c "let g:TagHighlightSettings['TagFileName']='$TAGS'"\
	-c "UpdateTypesFileOnly"\
	-c "q"

echo Done

