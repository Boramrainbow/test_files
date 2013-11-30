# Copyright (C) 2013   SheetJS

# `github` macro uses svn to clone a subfolder and copy resources up
# usage: $(call github,user/repo_name,path/to/test/files)
GSVN=svn co --trust-server-cert --non-interactive
CPUP=cd $@; for i in *.xls*; do cp "$$i" ../"$@_$$i"; done
CPU2=cd $@; for i in *.xls*; do cp "$$i" ../"$$i"; done
github = $(GSVN) https://github.com/$(1)/trunk/$(2) $@; $(CPUP)

## Make Targets 

# Entry Point (init)
.PHONY: init clean
init: svn

# All files
all: svn hg

# git clean
clean:
	git clean -fd

# Resources acquired via subversion
.PHONY: svn
svn: apachepoi xlrd excel-reader-xlsx pyExcelerator

# Resources acquired via mercurial 
.PHONY: hg
hg: openpyxl


## Acquisition

# Apache POI (Java)
.PHONY: apachepoi
apachepoi:
	svn co http://svn.apache.org/repos/asf/poi/trunk/test-data/spreadsheet/ apachepoi
	$(CPU2)

# xlrd (Python)
.PHONY: xlrd
xlrd:
	$(call github,python-excel/xlrd,tests)

# Excel::Reader::XLSX (Perl)
.PHONY: excel-reader-xlsx
excel-reader-xlsx:
	$(call github,jmcnamara/excel-reader-xlsx,t/regression/xlsx_files)

# openpyxl (Python)
.PHONY: openpyxl
openpyxl:
	if [ ! -e openpyxl ]; then hg clone https://bitbucket.org/ericgazoni/openpyxl; fi
	cd openpyxl; hg pull || echo foo
	cd openpyxl/openpyxl/tests/test_data/genuine; for i in *.xls*; do cp $$i ../../../../../openpyxl_g_$$i; done
	cd openpyxl/openpyxl/tests/test_data/reader; for i in *.xls*; do cp $$i ../../../../../openpyxl_r_$$i; done

# pyExcelerator (Python)
.PHONY: pyExcelerator
pyExcelerator:
	$(call github,WoLpH/pyExcelerator,museum)
