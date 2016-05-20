CC := gcc
CFLAGS := -O0 -std=gnu99 -g3 -Wall -Werror -Wno-enum-compare

JCC_DEBUG := JCC_DEBUG

LEX_DIR          := ./lexical
SYNTAX_DIR       := ./syntax
SEMANTIC_DIR     := ./semantic
CORE_DIR         := ./core
SRC_DIR          := src
INCLUDE_DIR      := include
DEMO_DIR         := demo

define DIR_Variable_Creator
	$(1)_INCLUDES_DIR   := $($(1)_DIR)/$(INCLUDE_DIR)
	$(1)_SRC_DIR        := $($(1)_DIR)/$(SRC_DIR)
endef

define Create_All_DIR_Variable
	$(eval $(call DIR_Variable_Creator,$(1)))
	$(eval $(call DIR_Variable_Creator,$(2)))
	$(eval $(call DIR_Variable_Creator,$(3)))
	$(eval $(call DIR_Variable_Creator,$(4)))
endef

define Phase_Source
    $(1)_SOURCE := $(wildcard $($(1)_SRC_DIR)/*.c)
endef

define All_Source
    $(eval $(call Phase_Source,$(1)))
    $(eval $(call Phase_Source,$(2)))
    $(eval $(call Phase_Source,$(3)))
    $(eval $(call Phase_Source,$(4)))
endef

define All_Header
	INCLUDES_LIST := $(addprefix -I,$($(1)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(2)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(3)_INCLUDES_DIR)) \
					 $(addprefix -I,$($(4)_INCLUDES_DIR))
endef

define All_Variable
	$(eval $(call Create_All_DIR_Variable,$(1),$(2),$(3),$(4)))
	$(eval $(call All_Header,$(1),$(2),$(3),$(4)))
	$(eval $(call All_Source,$(1),$(2),$(3),$(4)))
endef

$(eval $(call All_Variable,LEX,SYNTAX,SEMANTIC,CORE))

TARGET := JCC


.PHONY: demo clean astyle cscope


all:$(TARGET)


#Open the debug output in JCC
#CFLAGS += -D$(JCC_DEBUG)

$(TARGET):$(CORE_SOURCE) $(LEX_SOURCE) $(SYNTAX_SOURCE) $(SEMANTIC_SOURCE)
	$(CC) $(CFLAGS) $(INCLUDES_LIST) \
          $^ -o $@

demo:$(TARGET)
	./JCC $(DEMO_DIR)/ex_noIndent.c

demo_gdb:$(TARGET)
	gdb --args ./$(TARGET) $(DEMO_DIR)/ex_noIndent.c


clean:
	rm -f $(TARGET)


cscope:
	cscope -Rbqf ./cscope.out

astyle:
	@echo "More details please see: coding-style.txt"
	astyle --style=linux --indent=tab -p -U -K -H --suffix=none --exclude=$(DEMO_DIR) --recursive ./*.c
	astyle --style=linux --indent=tab -p -U -K -H --suffix=none --exclude=$(DEMO_DIR) --recursive ./*.h
