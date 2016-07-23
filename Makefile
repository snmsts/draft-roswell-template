archive.lisp:
	echo "(\"init.lisp\" \"" > $@
	cat init.lisp|gzip -f -9|base64 >> $@
	echo "\")" >> $@
	echo "(\"template.asd\" \"" >> $@
	cat template.asd|gzip -f -9|base64 >> $@
	echo "\")" >> $@

.PHONY: archive.lisp all test
