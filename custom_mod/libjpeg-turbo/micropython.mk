################################################################################
# libjpeg-turbo build rules


JPEG_MOD_DIR := $(USERMOD_DIR)
LIB_JPEG = $(abspath $(BUILD)/libjpeg-turbo)
LIB_JPEG_BUILD = $(abspath $(BUILD)/libjpeg-turbo/build)

# this gets you down to the root directory of the repo. You will need to
# adjust this path is it is wrong. It needs to point to the binding directory
# located in the lib folder of the lv_micropython repository.
BINDING_DIR = $(abspath $(JPEG_MOD_DIR)/../../lib/lv_bindings)

LIB_JPEG_FAKE_LIB_C = $(BINDING_DIR)/pycparser/utils/fake_libc_include
LIB_JPEG_PP = $(abspath $(BUILD)/jpeg_encoder.pp)
LIB_JPEG_MPY = $(abspath $(BUILD)/jpeg_encoder_mpy.c)
LIB_JPEG_MPY_METADATA = $(abspath $(BUILD)/jpeg_encoder.json)

CFLAGS_USERMOD += -Wno-unused-function
CFLAGS_USERMOD += -Wno-missing-field-initializers
CFLAGS_USERMOD += -Wno-discarded-qualifiers
CFLAGS_USERMOD += -I$(LIB_JPEG)
CFLAGS_USERMOD += -I$(JPEG_MOD_DIR)

SRC_USERMOD_C +=  $(JPEG_MOD_DIR)/jpeg_encoder.c
SRC_USERMOD_C += $(LIB_JPEG_MPY)

LDFLAGS_USERMOD += -L$(LIB_JPEG_BUILD)
LDFLAGS_USERMOD += -l:libjpeg.a
LDFLAGS_USERMOD += -lc

# Use the full path for the JPEG header
JPEG_HEADER = $(JPEG_MOD_DIR)/jpeg_encoder.h
LIB_JPEG_HEADER = &(LIB_JPEG)/jpeglib.h

$(LIB_JPEG_HEADER):
	$(ECHO) "LIB_JPEG-BUILD $@"
	$(Q)git clone https://github.com/libjpeg-turbo/libjpeg-turbo -- $(LIB_JPEG)
	$(Q)mkdir -p $(LIB_JPEG_BUILD)
	$(Q)cd $(LIB_JPEG_BUILD) && cmake -G"Unix Makefiles" -DENABLE_SHARED=FALSE -DENABLE_STATIC=TRUE -DCMAKE_BUILD_TYPE=Release ..
	$(Q)cd $(LIB_JPEG_BUILD) && make
	# $(Q)sed -i '/#ifndef JPEGLIB_H/a #include "math.h"' $(JPEG_HEADER)

.PHONY: LIB_JPEG_HEADER
JPEG_HEADER: $(LIB_JPEG_HEADER)


$(LIB_JPEG_PP): $(LIB_JPEG_HEADER) $(JPEG_HEADER)
	$(ECHO) "LIB_JPEG-PP $@"
	$(Q)$(CPP) -E -I$(LIB_JPEG) -I$(JPEG_MOD_DIR) -I$(LIB_JPEG_FAKE_LIB_C) $(JPEG_HEADER) > $@
.PHONY: LIB_JPEG_PP
LIB_JPEG_PP: $(LIB_JPEG_PP)


$(LIB_JPEG_MPY): $(BINDING_DIR)/gen/gen_mpy.py $(LIB_JPEG_PP)
	$(ECHO) "LIB_JPEG-MPY $@"
	$(Q)$(PYTHON) $(BINDING_DIR)/gen/gen_mpy.py -M jpeg -MP jpeg -MD $(LIB_JPEG_MPY_METADATA) -E $(LIB_JPEG_PP) $(JPEG_HEADER) > $@
.PHONY: LIB_JPEG_MPY
LIB_JPEG_MPY: $(LIB_JPEG_MPY)