# Copyright (C) 2013-2014   SheetJS
SHELL=/bin/bash
# `github` macro uses svn to clone a subfolder and copy resources up
# usage: $(call github,user/repo_name,path/to/test/files)
GSVN=svn co --trust-server-cert --non-interactive
CPUP=cd $@; for i in *.x* *.ods; do if [ -e "$$i" ]; then cp "$$i" ../"$@_$$i"; fi; done
github = $(GSVN) https://github.com/$(1)/trunk/$(2) $@; $(CPUP)

## Make Targets

# Entry Point (init)
.PHONY: init clean
init: all

# All files
.PHONY: all
all: svn hg git

# Tests
.PHONY: test
test:
	bash test.sh all

# git clean
clean:
	bash test.sh clean
	git clean -fd

# Resources acquired via subversion
.PHONY: svn ghsvn
svn: apachepoi jxls oo34xml ghsvn

ghsvn: xlrd excel-reader-xlsx pyExcelerator roo spreadsheet-parsexlsx

# Resources acquired via mercurial
.PHONY: hg
hg: openpyxl

# Resources acquired via git
.PHONY: git
git: libreoffice

# Sheet Names
.PHONY: 2011
2011:
	tests/sheetnames.sh
	tests/csv.sh

## Acquisition

# Apache POI (Java)
.PHONY: apachepoi
apachepoi:
	svn co http://svn.apache.org/repos/asf/poi/trunk/test-data/spreadsheet/ apachepoi
	$(CPUP)

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
	if [ ! -e openpyxl ]; then hg clone https://bitbucket.org/openpyxl/openpyxl; fi
	cd openpyxl; hg pull && hg update || echo foo
	cd openpyxl/openpyxl/tests/data/genuine; for i in *.xls*; do cp $$i ../../../../../openpyxl_g_$$i; done
	cd openpyxl/openpyxl/tests/data/reader; for i in *.xls*; do cp $$i ../../../../../openpyxl_r_$$i; done

# pyExcelerator (Python)
.PHONY: pyExcelerator
pyExcelerator:
	$(call github,WoLpH/pyExcelerator,museum)

# jxls (java)
.PHONY: jxls jxls-reader jxls-examples jxls-core jxls-src
jxls: jxls-reader jxls-examples jxls-core jxls-src

# Originally these used SF but it has been unstable as of late, prefer github
jxls-core jxls-reader:
	#$(GSVN) https://svn.code.sf.net/p/jxls/code/trunk/$@/src/test/resources/templates/ $@
	#$(CPUP)
	$(call github,SheetJS/jxls,$@/src/test/resources/templates/)

jxls-examples:
	#$(GSVN) https://svn.code.sf.net/p/jxls/code/trunk/$@/src/main/resources/templates/ $@
	#$(CPUP)
	$(call github,SheetJS/jxls,$@/src/main/resources/templates/)

jxls-src:
	#$(GSVN) https://svn.code.sf.net/p/jxls/code/trunk/src/site/resources/xls/ $@
	#$(CPUP)
	$(call github,SheetJS/jxls,src/site/resources/xls/)

# roo (Ruby)
.PHONY: roo

roo:
	$(call github,Empact/roo,test/files)

# Spreadsheet::ParseXLSX (Perl)
.PHONY: spreadsheet-parsexlsx
spreadsheet-parsexlsx:
	$(call github,doy/spreadsheet-parsexlsx,t/data)

# OpenOffice (Java)
.PHONY: oo34xml
oo34xml:
	$(GSVN) https://svn.apache.org/repos/asf/openoffice/branches/AOO34/main/testautomation/xml/optional/input/calc/ExcelXML $@
	$(CPUP)

.PHONY: ootest
ootest:
	bash tests/ootest.sh

# LibreOffice (Java)
.PHONY: libreoffice
libreoffice:
	if [ ! -e libreoffice ]; then git clone git://anongit.freedesktop.org/libreoffice/contrib/test-files libreoffice; fi;
	cd libreoffice; git pull; cd -
	find libreoffice/calc -name \*.x\* | while read x; do y=$${x//\//_}; cp "$$x" "$$y"; done
