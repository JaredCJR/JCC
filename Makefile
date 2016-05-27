CC := gcc
CFLAGS := -O0 -std=gnu99 -g3 -Wall -Werror

JCC_DEBUG := JCC_DEBUG


LEX_DIR          := ./lexical
SYNTAX_DIR       := ./syntax
SEMANTIC_DIR     := ./semantic
CODEGEN_DIR      := ./codeGen
CORE_DIR         := ./core
SRC_DIR          := src
INCLUDE_DIR      := include
DEMO_DIR         := ./demo

DEMO_FILE_NAME   := demo_code
DEMO_SOURCE_FILE := $(DEMO_DIR)/$(DEMO_FILE_NAME).c
DEMO_OUTPUT_FILE := $(DEMO_DIR)/$(DEMO_FILE_NAME).s

define DIR_Variable_Creator
	$(1)_INCLUDES_DIR   := $($(1)_DIR)/$(INCLUDE_DIR)
	$(1)_SRC_DIR        := $($(1)_DIR)/$(SRC_DIR)
endef

define Create_All_DIR_Variable
	$(eval $(call DIR_Variable_Creator,$(1)))
	$(eval $(call DIR_Variable_Creator,$(2)))
	$(eval $(call DIR_Variable_Creator,$(3)))
	$(eval $(call DIR_Variable_Creator,$(4)))
	$(eval $(call DIR_Variable_Creator,$(5)))
endef

define Phase_Source
    $(1)_SOURCE := $(wildcard $($(1)_SRC_DIR)/*.c)
endef

define All_Source
    $(eval $(call Phase_Source,$(1)))
    $(eval $(call Phase_Source,$(2)))
    $(eval $(call Phase_Source,$(3)))
    $(eval $(call Phase_Source,$(4)))
    $(eval $(call Phase_Source,$(5)))
endef

define All_Header
	INCLUDES_LIST := $(addprefix -I,$($(1)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(2)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(3)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(4)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(5)_INCLUDES_DIR))
endef

define All_Variable
	$(eval $(call Create_All_DIR_Variable,$(1),$(2),$(3),$(4),$(5)))
	$(eval $(call All_Header,$(1),$(2),$(3),$(4),$(5)))
	$(eval $(call All_Source,$(1),$(2),$(3),$(4),$(5)))
endef

$(eval $(call All_Variable,LEX,SYNTAX,SEMANTIC,CODEGEN,CORE))

TARGET := JCC


.PHONY: demo clean astyle cscope


all:$(TARGET)


#Open the debug output in JCC
#CFLAGS += -D$(JCC_DEBUG)

$(TARGET):$(CORE_SOURCE) $(LEX_SOURCE) $(SYNTAX_SOURCE) $(SEMANTIC_SOURCE) $(CODEGEN_SOURCE)
	$(CC) $(CFLAGS) $(INCLUDES_LIST) \
          $^ -o $@

demo:$(TARGET)
	./JCC $(DEMO_SOURCE_FILE)
	cat $(DEMO_OUTPUT_FILE)

demo_gdb:$(TARGET)
	gdbtui -x ./demo/test_autoGDB --args ./$(TARGET) $(DEMO_SOURCE_FILE)


clean:
	rm -f $(TARGET) demo/demo_code.s


cscope:
	cscope -Rbqf ./cscope.out

astyle:
	@echo "More details please see: coding-style.txt"
	astyle --style=linux --indent=tab -p -U -K -H --suffix=none --exclude=$(DEMO_DIR) --recursive ./*.c
	astyle --style=linux --indent=tab -p -U -K -H --suffix=none --exclude=$(DEMO_DIR) --recursive ./*.h
