# Set config folder path
SRC_DIR := $(shell pwd)

# Early Init Source file
EI_SRC_FILE := $(SRC_DIR)/early-init.org

# Source file
SRC_FILE := $(SRC_DIR)/emacs.org

# Destination directory
DEST_DIR := $(SRC_DIR)/lisp

# Early init file
EI_DEST_FILE := $(SRC_DIR)/early-init.el

# Destination file
DEST_FILE := $(SRC_DIR)/emacs.el

# EMACS_BINARY should point to your installation of GNU emacs
EMACS_BINARY := $(HOME)/git/emacs/src/emacs

# The following will compile early-init.org to early-init.el
EARLY_INIT = $(shell $(EMACS_BINARY) -nw --batch --eval "(require 'org)" --eval "(org-babel-load-file \"early-init.org\")")

# The following will compile emacs.org to emacs.el
EMACS = $(shell $(EMACS_BINARY) -nw --batch --eval "(load-file \"early-init.el\")" --eval "(require 'org)" --eval "(org-babel-load-file \"emacs.org\")")

.PHONY: test build clear-cache clear-files clear-packages help install

## help: Output this message and exit
help:
	@fgrep -h '##' $(MAKEFILE_LIST) | fgrep -v fgrep | column -t -s ':' | sed -e 's/## //'

## all: Main Rule
all: build

setup-dest-dir:
	rm -rf $(DEST_DIR)
	mkdir -p $(DEST_DIR)

build-early-init: setup-dest-dir
	$(EARLY_INIT)

## build: Generate and compile lisp
build:
	$(EMACS)

## test: Test init file
test: build;
	$(shell $(EMACS_BINARY) -nw -Q -l $(DEST_FILE))

## print-test: Test init file
print-test:
	echo $(EMACS_BINARY) -nw -Q -l $(DEST_FILE)


## test-gui: Test gui version (if installed)
test-gui:
	$(shell $(EMACS_BINARY) -Q -l $(DEST_FILE))

## clear-packages: Clear straight.el packages
clear-packages:
	rm -rf $(HOME)/.emacs.d/straight

## clear-cache: Clear natively compiled cache
clear-cache:
	rm -rf $(HOME)/.emacs.d/eln-cache

## clear-lisp: Clear elisp files
clear-lisp:
	rm -rf $(DEST_DIR) $(DEST_FILE) $(EARLY_INIT_FILE)

## install: Tangle and move files to .emacs.d
install:
	cp $(EI_SRC_FILE) $(HOME)/.emacs.d
	cp $(SRC_FILE) $(HOME)/.emacs.d
	cp $(SRC_DIR)/Makefile $(HOME)/.emacs.d
	cd $(HOME)/.emacs.d && make build-early-init
	mv $(HOME)/.emacs.d/early-init.el $(HOME)/.emacs.d/early-init.el
	cd $(HOME)/.emacs.d && make build
	mv $(HOME)/.emacs.d/emacs.el $(HOME)/.emacs.d/init.el

## clean-install: Clean all pagages and lisp and rebuild
clean-install: clear-lisp clear-packages clear-cache install
