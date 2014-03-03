PACKAGE := phplint
VER := 1.1

BUILD := $(VER)_$(shell date +%Y%m%d)
DISTFILE := $(PACKAGE)-$(BUILD)

all: phplint

phplint:
	(cd src; make phplint)

clean:
	(cd src; make clean)
	(cd test; make clean)

distclean: clean

test: phplint
	(cd test; make test)

.PHONY: doc
doc:
	utils/make-libraries-doc

dist: clean
	echo $(BUILD) > VERSION
	cd .. \
	&& ln -sf $(PACKAGE) $(DISTFILE) \
	&& tar chf - $(DISTFILE) --owner=root --group=root --exclude=CVS \
		| gzip > /tmp/$(DISTFILE).tar.gz \
	&& rm $(DISTFILE)
	#### Package available in /tmp/$(DISTFILE).tar.gz

install: phplint
	@echo ""
	@echo "PHPLint Installation Procedure"
	@echo "=============================="
	@echo ""
	@echo "PHPLint does not require to be installed on any particular place."
	@echo "Simply, copy the executable 'src/phplint' and the modules directory"
	@echo "'modules/' anywhere you want - the other files aren't required to"
	@echo "simply execute the program."
	@echo ""
	@echo "Read more about PHPLint at:"
	@echo ""
	@echo "     http://www.icosaedro.it/phplint/"
	@echo ""

uninstall:
	@echo ""
	@echo "PHPLint Uninstallation Procedure"
	@echo "================================"
	@echo ""
	@echo "Since PHPLint does not require to be installed on any particular place,"
	@echo "you may simply delete this directory.
	@echo ""

upgrade:
	@echo ""
	@echo "PHPLint Upgrade Procedure"
	@echo "========================="
	@echo ""
	@echo "The version of this package is $$(cat VERSION). Check for new releases at:"
	@echo ""
	@echo "    http://www.icosaedro.it/phplint/"
	@echo ""
