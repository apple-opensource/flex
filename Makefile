##
# Makefile for Flex
##

# Project info
Project           = flex
UserType          = Developer
ToolType          = Commands
GnuAfterInstall   = after_install
Extra_CC_Flags    = -mdynamic-no-pic
Extra_Environment = STRIP_LIB_FLAGS="-S"

# It's a GNU Source project
include $(MAKEFILEPATH)/CoreOS/ReleaseControl/GNUSource.make

# Automatic Extract & Patch
AEP            = YES
AEP_Project    = $(Project)
AEP_Version    = 2.5.33
AEP_ProjVers   = $(AEP_Project)-$(AEP_Version)
AEP_Filename   = $(AEP_ProjVers).tar.bz2
AEP_ExtractDir = $(AEP_ProjVers)

#
# Update $(Project).plist when changing AEP_Patches
#
AEP_Patches    = scanEOF.diff filter-stdin.diff scanopt.c.diff Makefile.in.diff libmain.c.diff main.c.diff

ifeq ($(suffix $(AEP_Filename)),.bz2)
AEP_ExtractOption = j
else
AEP_ExtractOption = z
endif

OSV = $(DSTROOT)/usr/local/OpenSourceVersions
OSL = $(DSTROOT)/usr/local/OpenSourceLicenses

# Extract the source.
install_source::
ifeq ($(AEP),YES)
	$(TAR) -C $(SRCROOT) -$(AEP_ExtractOption)xf $(SRCROOT)/$(AEP_Filename)
	$(RMDIR) $(SRCROOT)/$(Project)
	$(MV) $(SRCROOT)/$(AEP_ExtractDir) $(SRCROOT)/$(Project)
	for patchfile in $(AEP_Patches); do \
		cd $(SRCROOT)/$(Project) && patch -p0 < $(SRCROOT)/patches/$$patchfile || exit 1; \
	done
	# Avoid calling help2man
	printf "1d\nw\nq\n" | ed -s $(SRCROOT)/$(Project)/doc/flex.1
endif

after_install::
	$(INSTALL) lex.sh $(DSTROOT)$(USRBINDIR)/lex
	$(LN) -f $(DSTROOT)/usr/share/man/man1/flex.1 $(DSTROOT)/usr/share/man/man1/flex++.1
	$(LN) -f $(DSTROOT)/usr/share/man/man1/flex.1 $(DSTROOT)/usr/share/man/man1/lex.1
	$(LN) -fs flex $(DSTROOT)$(USRBINDIR)/flex++
	$(LN) -fs libfl.a $(DSTROOT)$(USRLIBDIR)/libl.a
	@for arch in $(RC_ARCHS); do \
		case $$arch in \
		ppc64|x86_64) \
			echo "Deleting $$arch executable from $(DSTROOT)/$(USRBINDIR)/flex"; \
			lipo -remove $$arch $(DSTROOT)/$(USRBINDIR)/flex -output $(DSTROOT)/$(USRBINDIR)/flex;; \
		esac; \
	done
	$(MKDIR) $(OSV)
	$(INSTALL_FILE) "$(SRCROOT)/$(Project).plist" $(OSV)/$(Project).plist
	$(MKDIR) $(OSL)
	$(INSTALL_FILE) $(Sources)/COPYING $(OSL)/$(Project).txt
	$(RM) -f "$(DSTROOT)/usr/share/info/dir"
