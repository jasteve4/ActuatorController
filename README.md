<!--[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)-->

# License

This is licensed under GNU General Public License v3.0 . Presently the efabless mpw_precheck tool recognizes the GPL 3.0 license file as the AGPL-3.0 license file which is prohibited. However, the GPL 3.0 is in the approved license lists (```https://github.com/efabless/mpw_precheck/tree/mpw-5c/checks/license_check/_licenses/_approved_licenses```). Thus, we have changed the LICENSE to reflect the Apache 2.0 License for the purpose of passing the mpw_precheck only. Again, the license is GPL 3.0.

# Actuator Controller 

This design is to precisely control the timing sequence of 10 micro-motors. The SPI enterface allows a microcontroller to pass the required commands to adjust the firing order and width of the PWM pulses.

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

