################################################################################
# JPEG build rules

MOD_DIR := $(USERMOD_DIR)

LVGL_BINDING_DIR = $(MOD_DIR)/../../lib/lv_bindings
JPEG_PP = $(BUILD)/jpeglib/jpeg.pp.c
JPEG_MPY = $(BUILD)/jpeglib/jpeg_mpy.c
JPEG_MPY_METADATA = $(BUILD)/jpeglib/jpeg_mpy.json

# Path to the existing fake libc include directory
FAKE_LIBC_INCLUDE = $(LVGL_BINDING_DIR)/pycparser/utils/fake_libc_include

# Use the full path for the JPEG header
JPEG_HEADER = /usr/include/jpeglib.h

$(JPEG_MPY): $(JPEG_HEADER) $(LVGL_BINDING_DIR)/gen/gen_mpy.py 
	$(ECHO) "JPEG-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CPP) $(CFLAGS_USERMOD) -nostdinc -DPYCPARSER -x c \
		-I $(FAKE_LIBC_INCLUDE) \
		$(JPEG_HEADER) > $(JPEG_PP)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_mpy.py -M jpeg -MP jpeg -MD $(JPEG_MPY_METADATA) -E $(JPEG_PP) $(JPEG_HEADER) > $@
	
.PHONY: JPEG_MPY
JPEG_MPY: $(JPEG_MPY)

SRC_USERMOD_C += $(JPEG_MPY)
LDFLAGS_USERMOD += -ljpeg

# Debugging: Print the include path and files
.PHONY: debug
debug:
	@echo "FAKE_LIBC_INCLUDE: $(FAKE_LIBC_INCLUDE)"
	@echo "JPEG_HEADER: $(JPEG_HEADER)"
	@echo "LVGL_BINDING_DIR: $(LVGL_BINDING_DIR)"
	@echo "FILES: $(wildcard $(JPEG_HEADER))"
