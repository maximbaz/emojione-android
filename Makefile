# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

EMOJI = JoyPixels
font: $(EMOJI).ttf

# zopflipng is better (about 5-10%) but much slower.  it will be used if
# present.  pass ZOPFLIPNG= as an arg to make to use optipng instead.

NOCOMPRESSING ?= 0
ZOPFLIPNG = zopflipng
OPTIPNG = optipng

EMOJI_BUILDER = third_party/color_emoji/emoji_builder.py
# flag for emoji builder.  Default to legacy small metrics for the time being.
SMALL_METRICS := -S
ADD_GLYPHS = add_glyphs.py
ADD_GLYPHS_FLAGS = -a emoji_aliases.txt
PUA_ADDER = map_pua_emoji.py
VS_ADDER = add_vs_cmap.py # from nototools

BUILD_DIR := build
EMOJI_DIR := png/128
COMPRESSED_DIR := $(BUILD_DIR)/compressed_pngs

EMOJI_SRC_NAMES = $(notdir $(wildcard $(EMOJI_DIR)/*.png))
EMOJI_FILES = $(addprefix $(EMOJI_DIR)/,$(EMOJI_SRC_NAMES)))
EMOJI_NAMES = $(addprefix emoji_u,$(subst -,_,$(EMOJI_SRC_NAMES)))

ALL_FILES = $(addprefix $(COMPRESSED_DIR)/,$(EMOJI_SRC_NAMES))
ALL_COMPRESSED_FILES = $(addprefix $(COMPRESSED_DIR)/,$(EMOJI_NAMES))

# tool checks
ifeq (,$(shell which $(ZOPFLIPNG)))
  ifeq (,$(wildcard $(ZOPFLIPNG)))
    MISSING_ZOPFLI = fail
  endif
endif

ifeq (,$(shell which $(OPTIPNG)))
  ifeq (,$(wildcard $(OPTIPNG)))
    MISSING_OPTIPNG = fail
  endif
endif

ifdef MISSING_ZOPFLI
  ifdef MISSING_OPTIPNG
    NOCOMPRESSING = 1
  endif
endif

ifeq (, $(shell which $(VS_ADDER)))
  MISSING_ADDER = fail
endif


emoji: $(EMOJI_FILES)

compressed: $(ALL_FILES)

check_compress_tool:
ifdef MISSING_ZOPFLI
  ifdef MISSING_OPTIPNG
	@echo "neither $(ZOPFLIPNG) nor $(OPTIPNG) is available"
  else
    ifeq ($(NOCOMPRESSING),0)
	@echo "using $(OPTIPNG)"
    endif
  endif
else
  ifeq ($(NOCOMPRESSING),0)
	@echo "using $(ZOPFLIPNG)"
  endif
endif
ifeq ($(NOCOMPRESSING),1)
	@echo "no compressing"
endif

check_vs_adder:
ifdef MISSING_ADDER
	$(error "$(VS_ADDER) not in path, run setup.py in nototools")
endif


$(EMOJI_DIR) $(FLAGS_DIR) $(RESIZED_FLAGS_DIR) $(RENAMED_FLAGS_DIR) $(QUANTIZED_DIR) $(COMPRESSED_DIR):
	mkdir -p "$@"

$(COMPRESSED_DIR)/%.png: $(EMOJI_DIR)/%.png | check_compress_tool $(COMPRESSED_DIR)
ifeq ($(NOCOMPRESSING),0)
  ifdef MISSING_ZOPFLI
	@$(OPTIPNG) -quiet -o7 -clobber -force -out "$@" "$<"
  else
	@$(ZOPFLIPNG) -y "$<" "$@" 1> /dev/null 2>&1
  endif
else
	@cp "$<" "$@"
endif

define NL


endef

rename: $(ALL_FILES)
	$(foreach pair, $(join $(ALL_FILES:%=%^), $(ALL_COMPRESSED_FILES)), @mv $(subst ^, ,$(pair))$(NL))

$(ALL_COMPRESSED_FILES): rename


# Make 3.81 can endless loop here if the target is missing but no
# prerequisite is updated and make has been invoked with -j, e.g.:
# File `font' does not exist.
#      File `NotoColorEmoji.tmpl.ttx' does not exist.
# File `font' does not exist.
#      File `NotoColorEmoji.tmpl.ttx' does not exist.
# ...
# Run make without -j if this happens.

%.ttx: %.ttx.tmpl $(ADD_GLYPHS) $(ALL_COMPRESSED_FILES)
	@python2 $(ADD_GLYPHS) -f "$<" -o "$@" -d "$(COMPRESSED_DIR)" $(ADD_GLYPHS_FLAGS)

%.ttf: %.ttx
	@rm -f "$@"
	ttx "$<"

$(EMOJI).ttf: $(EMOJI).tmpl.ttf $(EMOJI_BUILDER) $(PUA_ADDER) \
	$(ALL_COMPRESSED_FILES) | check_vs_adder
	@python2 $(EMOJI_BUILDER) $(SMALL_METRICS) -V $< "$@" "$(COMPRESSED_DIR)/emoji_u"
	@python2 $(PUA_ADDER) "$@" "$@-with-pua"
	@$(VS_ADDER) -vs 2640 2642 2695 --dstdir '.' -o "$@-with-pua-varsel" "$@-with-pua"
	@mv "$@-with-pua-varsel" "$@"
	@rm "$@-with-pua"

clean:
	rm -f $(EMOJI).ttf $(EMOJI).tmpl.ttf $(EMOJI).tmpl.ttx
	rm -rf $(BUILD_DIR)

.SECONDARY: $(EMOJI_FILES) $(ALL_COMPRESSED_FILES)

.PHONY:	clean emoji compressed rename check_compress_tool

