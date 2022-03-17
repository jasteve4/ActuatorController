[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

# Actuator Controller 
## Harding Design
```
make actuator_driver_controller
make user_project_wrrappper
```
## RTL Simulation
```
make verify-spi_transfer_test-rtl # run spi passthrough
make verify-memory_test-rtl # run read and write to memory test
make verify-actuator_driver_test0-rtl # set actuator to all zeros position test
make verify-actuator_driver_test1-rtl # set actuator to count up and done one bit at a time
make verify-actuator_driver_test1-rt2 # set actuator to count up and done one bit at a time, invert output test
```
 ## GL Simulation
```
make verify-spi_transfer_test-gl # run spi passthrough
make verify-memory_test-gl # run read and write to memory test
make verify-actuator_driver_test0-gl # set actuator to all zeros position test
make verify-actuator_driver_test1-gl # set actuator to count up and done one bit at a time
make verify-actuator_driver_test1-gl # set actuator to count up and done one bit at a time, invert output test
```
 ## GL+SDF Simulation
```
make verify-spi_transfer_test-gl-sdf # run spi passthrough
make verify-memory_test-gl-sdf # run read and write to memory test
make verify-actuator_driver_test0-gl-sdf # set actuator to all zeros position test
make verify-actuator_driver_test1-gl-sdf # set actuator to count up and done one bit at a time
make verify-actuator_driver_test1-gl-sdf # set actuator to count up and done one bit at a time, invert output test
```
## Spi Commuation Packet

## Memory Mapped Registers

