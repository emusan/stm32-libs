TOP=$(shell readlink -f "$(dir $(lastword $(MAKEFILE_LIST)))")
LIBDIR=$(TOP)

# Change this line for your version!
STMLIB=$(LIBDIR)/STM32F4xx_DSP_StdPeriph_Lib_V1.0.1/Libraries

TC=arm-none-eabi
CC=$(TC)-gcc
LD=$(TC)-gcc
OBJCOPY=$(TC)-objcopy
AR=$(TC)-ar
AS=$(TC)-as
GDB=$(TC)-gdb

INCLUDE= -I$(STMLIB)/CMSIS/Include
INCLUDE+=-I$(STMLIB)/CMSIS/Device/ST/STM32F4xx/Include/
INCLUDE+=-I$(STMLIB)/STM32F4xx_StdPeriph_Driver/inc

COMMONFLAGS= -O0 -g -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffast-math
CFLAGS+=$(COMMONFLAGS) -Wall -Werror $(INCLUDE)

LIBS+=libstm32.a
CFLAGS+=-c

all: libs

libs: $(LIBS)

libstm32.a:
	@echo -n "Building $@..."
	cd $(STMLIB)/CMSIS/Device/ST/STM32F4xx/Source/Templates && \
		$(CC) $(CFLAGS) \
		system_stm32f4xx.c
	@cd $(STMLIB)/STM32F4xx_StdPeriph_Driver/src && \
		$(CC) $(CFLAGS) \
		-D"assert_param(expr)=((void)0)"\
		-I../../CMSIS/Include \
		-I../../CMSIS/Device/ST/STM32F4xx/Source/Templates \
		-I../inc \
		*.c
	@$(AR) cr $(LIBDIR)/$@ \
		$(STMLIB)/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.o \
		$(STMLIB)/STM32F4xx_StdPeriph_Driver/src/*.o
	@echo "done."

.PHONY: libs clean

clean:
	rm -f $(STMLIB)/STM32F4xx_StdPeriph_Driver/src/*.o
	rm -f $(STMLIB)/CMSIS/Include/core_cm4.o
	rm -f $(STMLIB)/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.o
	rm -f $(LIBS)
