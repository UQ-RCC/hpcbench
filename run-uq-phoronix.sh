#!/bin/sh

# Set the test result directory. This should work in bash, dash, or ksh
export TEST_RESULTS_NAME=uq-hpc-bench-${HOSTNAME:-$(hostname)}

# Install PHP
sudo apt install php-cli 

# Install optional prerequisites. NOTE package names may be different on RHEL.
sudo apt install php-gd unzip apt-utils mesa-utils php-xml git-core apt-file php-curl php-fpdf

git clone https://github.com/phoronix-test-suite/phoronix-test-suite.git
cd phoronix-test-suite
git checkout tags/v10.8.4

# Install test prerequisites - optional
sudo apt install libopenblas-dev libopenblas64-dev libopenmpi-dev openmpi-bin libmpich-dev libfftw3-dev fftw-dev libboost-all-dev libasio-dev libboost-iostreams-dev libhdf5-dev libhdf5-mpi-dev libxml2-dev vulkan-tools libvulkan-dev spirv-tools

# Alternative to manual dependency installation above - will need privilege escalation
#./phoronix-test-suite install-dependencies pts/qmcpack-1.8.0
#./phoronix-test-suite install-dependencies pts/vkfft-1.3.0

./phoronix-test-suite user-config-set AnonymousUsageReporting=FALSE
./phoronix-test-suite user-config-set DynamicRunCount=FALSE

# Configure batch mode (the following settings are all located under <BatchMode> in /etc/phoronix-test-suite.xml)
./phoronix-test-suite user-config-set OpenBrowser=FALSE 
./phoronix-test-suite user-config-set UploadResults=FALSE 
./phoronix-test-suite user-config-set PromptForTestIdentifier=FALSE 
./phoronix-test-suite user-config-set PromptForTestDescription=FALSE 
./phoronix-test-suite user-config-set PromptSaveName=FALSE 
./phoronix-test-suite user-config-set RunAllTestCombinations=TRUE 
./phoronix-test-suite user-config-set Configured=TRUE

# If you didn't install prerequisites above you will get prompted for sudo privileges here
./phoronix-test-suite install pts/qmcpack-1.8.0
./phoronix-test-suite install pts/vkfft-1.3.0

# Start Tests
./phoronix-test-suite diagnostics | grep -v "Operation not permitted"
./phoronix-test-suite system-info | grep -v "Operation not permitted"
./phoronix-test-suite system-sensors | grep -v "Operation not permitted"

./phoronix-test-suite batch-run pts/qmcpack-1.8.0
./phoronix-test-suite batch-run pts/vkfft-1.3.0

# Export Results
./phoronix-test-suite result-file-to-csv $TEST_RESULTS_NAME
./phoronix-test-suite result-file-to-pdf $TEST_RESULTS_NAME

echo "Send above result files"
