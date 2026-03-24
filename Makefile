appname := fastNGSadmix

CC := gcc
CXX := g++

FLAGS := -O3 -lz

SRC_DIR := src
MAIN_SRC := $(SRC_DIR)/$(appname).cpp
srcfiles := $(shell find $(SRC_DIR) -maxdepth 1 -iname "*V3.cpp")
objects  := $(patsubst %.cpp, %.o, $(srcfiles))
hfiles  := $(patsubst %.cpp, %.h, $(srcfiles))

all: $(appname)

$(appname): $(MAIN_SRC)
	$(CXX) $(MAIN_SRC) $(srcfiles) $(FLAGS) -o $(appname)

clean:
	rm  -f $(objects) $(appname)
