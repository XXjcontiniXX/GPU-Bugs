CXX = g++
CXXFLAGS = -std=c++17
CLSPVFLAGS = -cl-std=CL2.0 -inline-entry-points

BUILDDIR1 = nvidia-issue

BUILDDIR2 = amd-issue

.PHONY: clean easyvk

all: build easyvk nvidia-issue amd-issue 

build:
	mkdir -p build

clean:
	rm -r build

easyvk: easyvk/src/easyvk.cpp easyvk/src/easyvk.h
	$(CXX) $(CXXFLAGS) -Ieasyvk/src -c easyvk/src/easyvk.cpp -o build/easyvk.o

nvidia-issue: bin/nvidia-issue.cinit $(BUILDDIR1)/nvidia-issue.cpp
	$(CXX) $(CXXFLAGS) -Ieasyvk/src build/easyvk.o $(BUILDDIR1)/nvidia-issue.cpp -lvulkan -o build/nvidia-issue.run	

amd-issue: bin/amd-issue.cinit $(BUILDDIR2)/amd-issue.cpp
	$(CXX) $(CXXFLAGS) -Ieasyvk/src build/easyvk.o $(BUILDDIR2)/amd-issue.cpp -lvulkan -o build/amd-issue.run




## build Spirv from OpenCL  

# $(BUILDDIR1).cinit: $(BUILDDIR1)/$(BUILDDIR1).cl
# 	clspv -w -cl-std=CL2.0 -inline-entry-points -output-format=c $< -o build/$@

# $(BUILDDIR2).cinit: $(BUILDDIR2)/$(BUILDDIR2).cl
# 	clspv -w -cl-std=CL2.0 -inline-entry-points -output-format=c $< -o build/$@	
