###############################################################################
#	makefile
#	by Mohamad Elzohbi.
#
#	A makefile script for building mixed C & Assembly programs RPI3
###############################################################################

OUT=salamander
# The intermediate directory for compiled object files.
BUILD = build/

# The directory in which source files are stored.
SOURCE = source/

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS := $(patsubst $(SOURCE)%.s,$(BUILD)%.o,$(wildcard $(SOURCE)*.s))
COBJECTS := $(patsubst $(SOURCE)%.c,$(BUILD)%.o,$(wildcard $(SOURCE)*.c))

# Rule to make the executable files.
myProg: $(OBJECTS) $(COBJECTS)
	gcc -lwiringPi -o $(OUT) $(OBJECTS) $(COBJECTS)

# Rule to make the object files.
$(BUILD)%.o: $(SOURCE)%.s
	as --gstabs -I $(SOURCE) $< -o $@

$(BUILD)%.o: $(SOURCE)%.c
	gcc -g -c -O1 -Wall -I $(SOURCE) $< -o $@

# Rule to clean files.
clean : 
	-rm -f $(BUILD)*.o $(OUT)

