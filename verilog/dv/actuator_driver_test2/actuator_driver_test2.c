/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

// --------------------------------------------------------

/*
	MPRJ Logic Analyzer Test:
		- Observes counter value through LA probes [31:0] 
		- Sets counter initial value through LA probes [63:32]
		- Flags when counter value exceeds 500 through the management SoC gpio
		- Outputs message to the UART when the test concludes successfuly
*/

// LA 0
#define MASK_DATA_0    0x00000001
#define MASK_DATA_1    0x00000002
#define MASK_DATA_2    0x00000004
#define MASK_DATA_3    0x00000008
#define MASK_DATA_4    0x00000010
#define MASK_DATA_5    0x00000020
#define MASK_DATA_6    0x00000040
#define MASK_DATA_7    0x00000080
#define MASK_DATA_8    0x00000100
#define MASK_DATA_9    0x00000200
#define MASK_DATA_10   0x00000400
#define MASK_DATA_11   0x00000800
#define MASK_DATA_12   0x00001000
#define MASK_DATA_13   0x00002000
#define MASK_DATA_14   0x00004000
#define MASK_DATA_15   0x00008000
#define MASK_DATA_16   0x00010000
#define MASK_DATA_17   0x00020000
#define MASK_DATA_18   0x00040000
#define MASK_DATA_19   0x00080000
#define MASK_DATA_20   0x00100000
#define MASK_DATA_21   0x00200000
#define MASK_DATA_22   0x00400000
#define MASK_DATA_23   0x00800000
#define MASK_DATA_24   0x01000000
#define MASK_DATA_25   0x02000000
#define MASK_DATA_26   0x04000000
#define MASK_DATA_27   0x08000000
#define MASK_DATA_28   0x10000000
#define MASK_DATA_29   0x20000000
#define MASK_DATA_30   0x40000000
#define MASK_DATA_31   0x80000000

// LA 1
#define MASK_DATA_32   0x00000001
#define MASK_DATA_33   0x00000002
#define MASK_DATA_34   0x00000004
#define MASK_DATA_35   0x00000008
#define MASK_DATA_36   0x00000010
#define MASK_DATA_37   0x00000020
#define MASK_ENABLE_0  0x00000040
#define MASK_ENABLE_1  0x00000080
#define MASK_ENABLE_2  0x00000100
#define MASK_ENABLE_3  0x00000200
#define MASK_ENABLE_4  0x00000400
#define MASK_ENABLE_5  0x00000800
#define MASK_ENABLE_6  0x00001000
#define MASK_ENABLE_7  0x00002000
#define MASK_ENABLE_8  0x00004000
#define MASK_ENABLE_9  0x00008000
#define MASK_ENABLE_10 0x00010000
#define MASK_ENABLE_11 0x00020000
#define MASK_ENABLE_12 0x00040000
#define MASK_ENABLE_13 0x00080000
#define MASK_ENABLE_14 0x00100000
#define MASK_ENABLE_15 0x00200000
#define MASK_ENABLE_16 0x00400000
#define MASK_ENABLE_17 0x00800000
#define MASK_ENABLE_18 0x01000000
#define MASK_ENABLE_19 0x02000000
#define MASK_ENABLE_20 0x04000000
#define MASK_ENABLE_21 0x08000000
#define MASK_ENABLE_22 0x10000000
#define MASK_ENABLE_23 0x20000000
#define MASK_ENABLE_24 0x40000000
#define MASK_ENABLE_25 0x80000000

// LA 2
#define MASK_ENABLE_26 0x00000001
#define MASK_ENABLE_27 0x00000002
#define MASK_ENABLE_28 0x00000004
#define MASK_ENABLE_29 0x00000008
#define MASK_ENABLE_30 0x00000010
#define MASK_ENABLE_31 0x00000020
#define MASK_ENABLE_32 0x00000040
#define MASK_ENABLE_33 0x00000080
#define MASK_ENABLE_34 0x00000100
#define MASK_ENABLE_35 0x00000200
#define MASK_ENABLE_36 0x00000400
#define MASK_ENABLE_37 0x00000800
void main()
{
	int j;

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	// reg_spi_enable = 1;
	// reg_spimaster_cs = 0x00000;

	// reg_spimaster_control = 0x0801;

	// reg_spimaster_control = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// The upper GPIO pins are configured to be output
	// and accessble to the management SoC.
	// Used to flad the start/end of a test 
	// The lower GPIO pins are configured to be output
	// and accessible to the user project.  They show
	// the project count value, although this test is
	// designed to read the project count through the
	// logic analyzer probes.
	// I/O 6 is configured for the UART Tx line

        reg_mprj_io_37 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 37 : input
        reg_mprj_io_36 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 36 : input  
        reg_mprj_io_35 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 35 : input
        reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;        // 34 : output
        reg_mprj_io_33 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 33 : input
        reg_mprj_io_32 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 32 : input
        reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 31 : input
        reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;        // 30 : output
        reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;        // 29 : output
        reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;        // 28 : output
        reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;        // 27 : output
        reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;        // 26 : output
        reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;        // 25 : output
        reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;        // 24 : output
        reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;        // 23 : output
        reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;        // 22 : output
        reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;        // 21 : output
        reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;        // 20 : output
        reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;        // 19 : output
        reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;        // 18 : output
        reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;        // 17 : output
        reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;        // 16 : output
        reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;        // 15 : output	  
        reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;        // 14 : output
        reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;        // 13 : output
        reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;        // 12 : output
        reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;        // 11 : output
        reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;        // 10 : output
        reg_mprj_io_9  = GPIO_MODE_USER_STD_OUTPUT;        // 9	 : output
        reg_mprj_io_8  = GPIO_MODE_USER_STD_OUTPUT;        // 8	 : output
        reg_mprj_io_7  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 7	 : input
        reg_mprj_io_5  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 5	 : input
        reg_mprj_io_4  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 4	 : input
        reg_mprj_io_3  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 3	 : input
        reg_mprj_io_2  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 2	 : input
        reg_mprj_io_1  = GPIO_MODE_USER_STD_INPUT_NOPULL;  // 1	 : input
        reg_mprj_io_0  = GPIO_MODE_USER_STD_OUTPUT;        // 0  : output         


	// Set UART clock to 64 kbaud (enable before I/O configuration)
	// reg_uart_clkdiv = 625;
	reg_uart_enable = 1;

    // Now, apply the configuration
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // Configure LA probes [31:0], [127:64] as inputs to the cpu 
	// Configure LA probes [63:32] as outputs from the cpu
	//reg_la0_oenb = reg_la0_iena = 0x00000000;      // [31:0]
	//reg_la1_oenb = reg_la1_iena = MASK_DATA_37;    // [63:32]
	//reg_la2_oenb = reg_la2_iena = MASK_ENABLE_37;  // [95:64]
	//reg_la3_oenb = reg_la3_iena = 0x80000000;      // [127:96]

	reg_la0_oenb = reg_la0_iena = MASK_DATA_0;      // [31:0]
	reg_la1_oenb = reg_la1_iena = MASK_ENABLE_0;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0x00000000;  // [95:64]
	reg_la3_oenb = reg_la3_iena = 0x00000000;      // [127:96]


	reg_la0_data = MASK_DATA_0;
	reg_la1_data = 0x00000000;
	reg_la2_data = 0x00000000;
	reg_la3_data = 0x00000000;


	//reg_la0_oenb = reg_la0_iena = 0x00000000;      // [31:0]
	//reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
	//reg_la2_oenb = reg_la2_iena = 0x00000000;  // [95:64]
	//reg_la3_oenb = reg_la3_iena = 0x00000000;      // [127:96]

	// Flag start of the test 
	

	// Configure LA probes from [63:32] as inputs to disable counter write
	//reg_la1_oenb = reg_la1_iena = 0x00000000;    

	while (1) {
		if (reg_la0_data_in & MASK_DATA_1) {
			break;
		}
	}
	//print("\n");
	//print("BEEP\n");
	reg_la0_data = 0x00000000;
	//print("\n");
	//print("Monitor: Test 1 Passed\n\n");	// Makes simulation very long!
}

