TARGET = app

SRC_DIR = src
TB_DIR = testbenches
BUILD_DIR = build
OUT_DIR = bin

CONSTRAINTS = ./icesugar.pcf
TOP_FILE = $(SRC_DIR)/top.v
TOP_MODULE = top
TB_FILES = $(wildcard $(TB_DIR)/*.v)
TB_TARGETS = $(patsubst $(TB_DIR)/%.v,$(OUT_DIR)/%.vcd,$(TB_FILES))

NEXTPNR_FLAGS = --freq 12 --package sg48 --up5k --pcf $(CONSTRAINTS)

YOSYS_FLAGS =
YOSYS_SYNTH = synth_ice40 -dsp -top $(TOP_MODULE)

IVERILOG_FLAGS = -g2012

VERBOSE ?= 0
ifeq ($(VERBOSE),0)
	YOSYS_FLAGS += -q
	NEXTPNR_FLAGS += -q
endif


all: $(OUT_DIR)/$(TARGET).bin

test: $(TB_TARGETS)

flash: all
	@tcc $(shell pkg-config --libs --cflags libusb-1.0 hidapi-hidraw) -w -run ./tools/icesprog.c\
		-w "$(OUT_DIR)/$(TARGET).bin"

clean:
	@rm -rf $(BUILD_DIR) $(OUT_DIR)

verify-dependencies:
	@failed=0; \
	which yosys >/dev/null 2>&1 || { echo "Error: yosys not found"; failed=1; }; \
	which nextpnr-ice40 >/dev/null 2>&1 || { echo "Error: nextpnr-ice40 not found"; failed=1; }; \
	which icepack >/dev/null 2>&1 || { echo "Error: icepack not found"; failed=1; }; \
	which iverilog >/dev/null 2>&1 || { echo "Error: iverilog not found"; failed=1; }; \
	which tcc >/dev/null 2>&1 || { echo "Error: tcc not found"; failed=1; }; \
	pkg-config --exists libusb-1.0 || { echo "Error: libusb-1.0 not found"; failed=1; }; \
	pkg-config --exists hidapi-hidraw || { echo "Error: hidapi-hidraw not found"; failed=1; }; \
	if [ $$failed -ne 0 ]; then exit 1; else echo "All required tools are installed"; fi

$(OUT_DIR)/%.bin: $(SRC_DIR)/*.v | $(BUILD_DIR) $(OUT_DIR)
	yosys $(YOSYS_FLAGS) -p "$(YOSYS_SYNTH) -json $(BUILD_DIR)/$*.json" $(TOP_FILE)
	nextpnr-ice40 $(NEXTPNR_FLAGS) --asc $(BUILD_DIR)/$*.asc --json $(BUILD_DIR)/$*.json
	icepack $(BUILD_DIR)/$*.asc $@

$(OUT_DIR)/%.vcd: $(BUILD_DIR)/%.out | $(OUT_DIR)
	cd $(OUT_DIR); "$(realpath $^)"

$(BUILD_DIR)/%.out: $(TB_DIR)/%.v | $(BUILD_DIR)
	iverilog -o $@ $(IVERILOG_FLAGS) $^

$(BUILD_DIR):
	@mkdir -p $@

$(OUT_DIR):
	@mkdir -p $@

.PHONY: all test flash clean verify-dependencies
