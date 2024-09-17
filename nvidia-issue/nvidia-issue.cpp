#include <vector>
#include <iostream>
#include <easyvk.h>
#include <cassert>
#include <vector>
#include <unistd.h>

#define BATCH_SIZE 8

void computeReferencePrefixSum(uint32_t* ref, int size) {
  ref[0] = 0;
  for (int i = 1; i < size; i++) {
    ref[i] = ref[i - 1] + i;
  }
}

int main(int argc, char* argv[]) {
  int workgroupSize = 128;
  int numWorkgroups = 1;
  int deviceID = 0;
  bool enableValidationLayers = false;
  bool checkResults = false;
  int c;

    while ((c = getopt (argc, argv, "vct:w:d:")) != -1)
    switch (c)
      {
      case 't':
        workgroupSize = atoi(optarg);
        break;
      case 'w':
        numWorkgroups = atoi(optarg);
        break;
      case 'v':
	enableValidationLayers = true;
	break;
      case 'c':
	checkResults = true;
	break;
      case 'd':
	deviceID = atoi(optarg);
	break;
      case '?':
        if (optopt == 't' || optopt == 'w')
          std::cerr << "Option -" << optopt << "requires an argument\n";
        else 
          std::cerr << "Unknown option" << optopt << "\n";
        return 1;
      default:
        abort ();
      }
  auto size = numWorkgroups * workgroupSize * BATCH_SIZE;
  auto sizeBytes = numWorkgroups * workgroupSize * BATCH_SIZE * sizeof(uint);
	// Initialize instance.
	auto instance = easyvk::Instance(enableValidationLayers);
	// Get list of available physical devices.
	auto physicalDevices = instance.physicalDevices();
	// Create device from first physical device.
	auto device = easyvk::Device(instance, physicalDevices.at(deviceID));
	std::cout << "Using device: " << device.properties.deviceName << "\n";
  std::cout << "Device subgroup size: " << device.subgroupSize() << "\n";
	// Define the buffers to use in the kernel. 


	std::vector<uint> hostDebug(2, 0);

	auto debug = easyvk::Buffer(device, sizeof(uint) * 2, true);
	auto partitionCtr = easyvk::Buffer(device, sizeof(uint), true);

	std::vector<easyvk::Buffer> bufs = {partitionCtr, debug};

	std::vector<uint32_t> spvCode = 
	#include "../bin/nvidia-issue.cinit"
	;
	auto program = easyvk::Program(device, spvCode, bufs);

	program.setWorkgroups(numWorkgroups);
	program.setWorkgroupSize(workgroupSize);
	program.setWorkgroupMemoryLength(workgroupSize*sizeof(uint32_t), 0);

	// Run the kernel.
	program.initialize("nvidia_issue");

	float time = program.runWithDispatchTiming();

	debug.load(hostDebug.data(), sizeof(uint) * 2);

	// time is returned in ns, so don't need to divide by bytes to get GBPS
    std::cout << "GPU Time: " << time / 1000000 << " ms\n";
	std::cout << "Throughput: " << (((long) size) * 4 * 2)/(time) << " GBPS\n";
	std::cout << std::endl;
	std::cout << "first subgroup observes local_scan " << hostDebug[0] << "\n";
	std::cout << "second subgroup observes local_scan " << hostDebug[1] << "\n";
	// Cleanup.
	program.teardown();
	partitionCtr.teardown();
	debug.teardown();
	device.teardown();
	instance.teardown();
	return 0;
}
