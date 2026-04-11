# Build configuration. You can modify this safely.

TARGET := example-project

# This will work if you don't have a nested source structure.
# Otherwise, list wildcard the subdirectories, too
SRC_DIRS += src
INC_DIRS += inc

# Put any dependencies here
SRC_DIRS += dep/boson/src
INC_DIRS += dep/boson/inc

# Put any custom flags here
CFLAGS +=
