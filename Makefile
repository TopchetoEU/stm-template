# Do not modify this file here. Put your config in conf.mk instead
BIN_DIR := bin
ST_DIR := stfiles

ST_MKFILE := $(ST_DIR)/Makefile

include $(ST_MKFILE)

include ./conf.mk

# Paths in stfiles/Makefile are relative to stfiles. We need to make them relative to us (prefix $(ST_DIR))
FIX_RELATIVE = $(foreach FILE,$1,$(if $(filter /%,$(FILE)),$(FILE),$(ST_DIR)/$(FILE)))
FIX_INC = $(foreach FLAG,$1,$(FLAG:-I%=%))
RECURSE = $(foreach FILE,$(wildcard $(1:%=%/*)),$(call RECURSE,$(FILE),$2) $(filter $2,$(FILE)))

.SUFFIXES:
.SECONDARY:

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

INC_DIRS += $(call FIX_RELATIVE,$(call FIX_INC,$(C_INCLUDES)))

SOURCES_C += $(call RECURSE,$(SRC_DIRS),%.c)
SOURCES_C += $(call FIX_RELATIVE,$(C_SOURCES))

SOURCES_ASM += $(call RECURSE,$(SRC_DIRS),%.s)
SOURCES_ASM += $(call FIX_RELATIVE,$(ASM_SOURCES))

OBJECTS += $(foreach SRC,$(SOURCES_C),$(BIN_DIR)/$(if $(filter /%,$(SRC)),$(SRC:/%.c=abs/%.o),$(SRC:%.c=rel/%.o)))
OBJECTS += $(foreach SRC,$(SOURCES_ASM),$(BIN_DIR)/$(if $(filter /%,$(SRC)),$(SRC:/%.s=abs/%.o),$(SRC:%.s=rel/%.o)))

CFLAGS += $(INC_DIRS:%="-I%")
CFLAGS += $(MCU) $(C_DEFS) -MMD -MP -Wall -Wextra -fdata-sections -ffunction-sections

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
$(BIN_DIR)/$(TARGET).elf: $(OBJECTS) Makefile $(ST_MKFILE) | $(BIN_DIR)/
	@echo CC -o $@
	@$(CC) $(CFLAGS) -o $@ $(OBJECTS) $(LDFLAGS)
	@$(SIZE) $@

.SECONDEXPANSION:
$(BIN_DIR)/rel/%.o: %.c Makefile conf.mk $(ST_MKFILE) | $$(dir $$@)
	@echo CC $<
	@$(CC) -x c -c $(CFLAGS) -o $@ $<
.SECONDEXPANSION:
$(BIN_DIR)/abs/%.o: /%.c Makefile conf.mk $(ST_MKFILE) | $$(dir $$@)
	@echo CC $<
	@$(CC) -x c -c $(CFLAGS) -o $@ $<

.SECONDEXPANSION:
$(BIN_DIR)/rel/%.o: %.s Makefile conf.mk $(ST_MKFILE) | $$(dir $$@)
	@echo ASM $<
	@$(ASM) -c $(CFLAGS) -o $@ $<
.SECONDEXPANSION:
$(BIN_DIR)/abs/%.o: /%.s Makefile conf.mk $(ST_MKFILE) | $$(dir $$@)
	@echo ASM $<
	@$(ASM) -c $(CFLAGS) -o $@ $<

%/:
	@mkdir -p $@

-include $(OBJECTS:.o=.d)
