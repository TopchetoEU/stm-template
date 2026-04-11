# Do not modify this file here. Put your config in conf.mk instead
BIN_DIR := bin
ST_DIR := stfiles

include ./conf.mk

# Paths in stfiles/Makefile are relative to stfiles. We need to make them relative to us (prefix $(ST_DIR))
FIX_RELATIVE = $(foreach FILE,$1,$(if $(filter /%,$(FILE)),$(FILE),$(ST_DIR)/$(FILE)))
FIX_INC = $(foreach FILE,$1,$(if $(filter -I/%,$(FILE)),$(FILE),$(FILE:-I%=-I$(ST_DIR)/%)))
RECURSE = $(foreach FILE,$(wildcard $(1:%=%/*)),$(call RECURSE,$(FILE),$2) $(filter $(subst *,%,$2),$(FILE)))

.SUFFIXES:
.SECONDARY:

ST_MKFILE := $(ST_DIR)/Makefile

include $(ST_MKFILE)

#### Toolchain
CC := $(PREFIX)gcc
ASM := $(PREFIX)gcc -x assembler-with-cpp
OBJCP := $(PREFIX)objcopy
SIZE := $(PREFIX)size


#### Flags
ifeq ($(DEBUG),yes)
	CFLAGS += -Og -g -gdwarf-2 -DDEBUG
else
	CFLAGS += -Os
endif


HEADERS += $(call RECURSE,$(INC_DIRS),*.h)

SOURCES_C += $(call RECURSE,$(SRC_DIRS),*.c)
SOURCES_C += $(call FIX_RELATIVE,$(C_SOURCES))

SOURCES_ASM += $(call RECURSE,$(SRC_DIRS),*.s)
SOURCES_ASM += $(call FIX_RELATIVE,$(ASM_SOURCES))

OBJECTS += $(subst //,/root/,$(SOURCES_C:%.c=$(BIN_DIR)/%.o))
OBJECTS += $(subst //,/root/,$(SOURCES_ASM:%.s=$(BIN_DIR)/%.o))

CFLAGS += $(INC_DIRS:%="-I%")
CFLAGS += $(MCU) $(C_DEFS) $(call FIX_INC,$(C_INCLUDES)) -Wall -Wextra -fdata-sections -ffunction-sections

LDFLAGS += -lc -lm -lnosys
LDFLAGS += $(MCU) -specs=nano.specs -T$(ST_DIR)/$(LDSCRIPT) -Wl,-Map=$(BIN_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

all: $(BIN_DIR)/$(TARGET).hex $(BIN_DIR)/$(TARGET).bin
clean:
	@rm -rf $(BIN_DIR)/

requirements:
	@echo sed
	@echo $(CC)
	@echo $(OBJCP)
	@echo $(SIZE)

$(BIN_DIR)/$(TARGET).hex: $(BIN_DIR)/$(TARGET).elf | $(BIN_DIR)/
	@echo HEX -o $@
	@$(OBJCP) -O ihex $^ $@
$(BIN_DIR)/$(TARGET).bin: $(BIN_DIR)/$(TARGET).elf | $(BIN_DIR)/
	@echo BIN -o $@
	@$(OBJCP) -O binary -S $^ $@
$(BIN_DIR)/$(TARGET).elf: $(OBJECTS) | Makefile $(ST_MKFILE) $(BIN_DIR)/
	@echo CC -o $@
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(SIZE) $@

.SECONDEXPANSION:
$(BIN_DIR)/%.o: %.c | $(HEADERS) Makefile $(ST_MKFILE) $$(dir $$@)
	@echo CC $^
	@$(CC) -x c -c $(CFLAGS) -o $@ $^
.SECONDEXPANSION:
$(BIN_DIR)/root/%.o: /%.c | $(HEADERS) Makefile $(ST_MKFILE) $$(dir $(BIN_DIR)/root/%)
	@echo CC $^
	@$(CC) -x c -c $(CFLAGS) -o $@ $^

.SECONDEXPANSION:
$(BIN_DIR)/%.o: %.s | $(HEADERS) Makefile $(ST_MKFILE) $$(dir $$@)
	@echo ASM $^
	@$(ASM) -c $(CFLAGS) -o $@ $^
.SECONDEXPANSION:
$(BIN_DIR)/root/%.o: /%.s | $(HEADERS) Makefile $(ST_MKFILE) $$(dir $$@)
	@echo ASM $^
	@$(ASM) -c $(CFLAGS) -o $@ $^

%/:
	@mkdir -p $@
