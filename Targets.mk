#-------------------------------------------------------------------------------
# Copyright (c) 2010-2013, Jean-David Gadina - www.xs-labs.com
# All rights reserved.
# 
# XEOS Software License - Version 1.0 - December 21, 2012
# 
# Permission is hereby granted, free of charge, to any person or organisation
# obtaining a copy of the software and accompanying documentation covered by
# this license (the "Software") to deal in the Software, with or without
# modification, without restriction, including without limitation the rights
# to use, execute, display, copy, reproduce, transmit, publish, distribute,
# modify, merge, prepare derivative works of the Software, and to permit
# third-parties to whom the Software is furnished to do so, all subject to the
# following conditions:
# 
#       1.  Redistributions of source code, in whole or in part, must retain the
#           above copyright notice and this entire statement, including the
#           above license grant, this restriction and the following disclaimer.
# 
#       2.  Redistributions in binary form must reproduce the above copyright
#           notice and this entire statement, including the above license grant,
#           this restriction and the following disclaimer in the documentation
#           and/or other materials provided with the distribution, unless the
#           Software is distributed by the copyright owner as a library.
#           A "library" means a collection of software functions and/or data
#           prepared so as to be conveniently linked with application programs
#           (which use some of those functions and data) to form executables.
# 
#       3.  The Software, or any substancial portion of the Software shall not
#           be combined, included, derived, or linked (statically or
#           dynamically) with software or libraries licensed under the terms
#           of any GNU software license, including, but not limited to, the GNU
#           General Public License (GNU/GPL) or the GNU Lesser General Public
#           License (GNU/LGPL).
# 
#       4.  All advertising materials mentioning features or use of this
#           software must display an acknowledgement stating that the product
#           includes software developed by the copyright owner.
# 
#       5.  Neither the name of the copyright owner nor the names of its
#           contributors may be used to endorse or promote products derived from
#           this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, TITLE AND NON-INFRINGEMENT ARE DISCLAIMED.
# 
# IN NO EVENT SHALL THE COPYRIGHT OWNER, CONTRIBUTORS OR ANYONE DISTRIBUTING
# THE SOFTWARE BE LIABLE FOR ANY CLAIM, DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN ACTION OF CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH
# THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#-------------------------------------------------------------------------------

# $Id$

VPATH =
vpath

vpath %$(EXT_C)      $(DIR_SRC)
vpath %$(EXT_ASM)    $(DIR_SRC)
vpath %$(EXT_ASM_32) $(DIR_SRC)
vpath %$(EXT_ASM_64) $(DIR_SRC)

.SUFFIXES:

.PHONY: all clean

.PRECIOUS: $(DIR_BUILD)%$(EXT_O)               \
           $(DIR_BUILD)%$(EXT_O_PIC)           \
           $(DIR_BUILD)%$(EXT_C)$(EXT_O)       \
           $(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC)   \
           $(DIR_BUILD)%$(EXT_ASM)$(EXT_O)     \
           $(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC) \
           $(DIR_DEPS)%

.SECONDEXPANSION:

all: _OBJ  = $(foreach _A,$(ARCHS),$(patsubst %,$(DIR_BUILD)%$(EXT_O),$(_A)) $(patsubst %,$(DIR_BUILD)%$(EXT_O_PIC),$(_A)))
all: _DEPS = $(foreach _D,$(DEPS),$(patsubst %,update-$(DIR_DEPS)%,$(_D)))
all: $$(_DEPS) $$(_OBJ)
	
	@:
	
clean:
	
	$(call PRINT,Cleaning all build files)
	@rm -rf $(DIR_BUILD)*

update-$(DIR_DEPS)%: $$(DIR_DEPS)$$*
	
	$(call PRINT,Updating dependancy: $(COLOR_YELLOW)$*$(COLOR_NONE))
	@cd $< && git pull
	
$(DIR_DEPS)%:
	
	$(call PRINT,Cloning dependancy: $(COLOR_YELLOW)$*$(COLOR_NONE))
	@git clone https://github.com/macmade/$*.git $@

$(DIR_BUILD)%$(EXT_O): _ARCH  = $*
$(DIR_BUILD)%$(EXT_O): _FILES = $(call XEOS_FUNC_OBJ,$(_ARCH),$(suffix $@))
$(DIR_BUILD)%$(EXT_O): $$(shell mkdir -p $$(DIR_BUILD)$$(_ARCH)) $$(_FILES)
	
	$(call PRINT_FILE,$(_ARCH),$(COLOR_CYAN)Linking main object file$(COLOR_NONE),$(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))

$(DIR_BUILD)%$(EXT_O_PIC): _ARCH = $*
$(DIR_BUILD)%$(EXT_O_PIC): _FILES = $(call XEOS_FUNC_OBJ,$(_ARCH),$(suffix $@))
$(DIR_BUILD)%$(EXT_O_PIC): $$(shell mkdir -p $$(DIR_BUILD)$$(_ARCH)) $$(_FILES)
	
	$(call PRINT_FILE,$(_ARCH) - PIC,$(COLOR_CYAN)Linking main object file$(COLOR_NONE),$(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))

$(DIR_BUILD)%$(EXT_C)$(EXT_O): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD)%$(EXT_C)$(EXT_O): _FILE  = $(subst .,/,$(patsubst $(_ARCH)/%,%,$*))$(EXT_C)
$(DIR_BUILD)%$(EXT_C)$(EXT_O): _CC    = $(CC_$(_ARCH))
$(DIR_BUILD)%$(EXT_C)$(EXT_O): _INC   = $(foreach _D,$(DEPS),$(patsubst %,-I $(DIR_DEPS)%/$(DIR_INC),$(_D)))
$(DIR_BUILD)%$(EXT_C)$(EXT_O): _FLAGS = $(ARGS_CC_$(_ARCH))
$(DIR_BUILD)%$(EXT_C)$(EXT_O): $$(_FILE)
	
	$(call PRINT_FILE,$(_ARCH),Compiling C file,$(COLOR_YELLOW)$(_FILE)$(COLOR_NONE) "->" $(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))
	@$(_CC) $(_FLAGS) $(_INC) -o $@ -c $<

$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): _ARCH = $(firstword $(subst /, ,$*))
$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): _FILE = $(subst .,/,$(patsubst $(_ARCH)/%,%,$*))$(EXT_C)
$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): _CC   = $(CC_PIC_$(_ARCH))
$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): _INC  = $(foreach _D,$(DEPS),$(patsubst %,-I $(DIR_DEPS)%/$(DIR_INC),$(_D)))
$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): _FLAGS = $(ARGS_CC_PIC_$(_ARCH))
$(DIR_BUILD)%$(EXT_C)$(EXT_O_PIC): $$(_FILE)
	
	$(call PRINT_FILE,$(_ARCH) - PIC,Compiling C file,$(COLOR_YELLOW)$(_FILE)$(COLOR_NONE) "->" $(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))
	@$(_CC) $(_FLAGS) $(_INC) -o $@ -c $<

$(DIR_BUILD)%$(EXT_ASM)$(EXT_O): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O): _FILE  = $(patsubst %/$(_ARCH),%.$(_ARCH),$(subst .,/,$(patsubst $(_ARCH)/%,%,$*)))$(EXT_ASM)
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O): _AS    = $(AS_$(_ARCH))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O): _FLAGS = $(ARGS_AS_$(_ARCH))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O): $$(_FILE)
	
	$(call PRINT_FILE,$(_ARCH),Compiling ASM file,$(COLOR_YELLOW)$(_FILE)$(COLOR_NONE) "->" $(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))
	@$(_AS) $(_FLAGS) -o $@ $<
		
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC): _FILE  = $(patsubst %/$(_ARCH),%.$(_ARCH),$(subst .,/,$(patsubst $(_ARCH)/%,%,$*)))$(EXT_ASM)
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC): _AS    = $(AS_PIC_$(_ARCH))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC): _FLAGS = $(ARGS_AS_PIC_$(_ARCH))
$(DIR_BUILD)%$(EXT_ASM)$(EXT_O_PIC): $$(_FILE)
	
	$(call PRINT_FILE,$(_ARCH) - PIC,Compiling ASM file,$(COLOR_YELLOW)$(_FILE)$(COLOR_NONE) "->" $(COLOR_GRAY)$(notdir $@)$(COLOR_NONE))
	@$(_AS) $(_FLAGS) -o $@ $<
