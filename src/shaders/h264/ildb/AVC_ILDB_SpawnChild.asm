/*
 * Copyright © <2010>, Intel Corporation.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sub license, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice (including the
 * next paragraph) shall be included in all copies or substantial portions
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
 * IN NO EVENT SHALL PRECISION INSIGHT AND/OR ITS SUPPLIERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * This file was originally licensed under the following license
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
//=============== Spawn a child thread for Luma or Chroma ===============

	//----- Create child thread R0 header -----
#if defined(_DEBUG) 
	mov		(1)		EntrySignature:w			0xAAAA:w
#endif

	//***** Set CT_R0Hdr fields that change for every thread 
	
	// Restore CT_R0Hdr.4:ud to r0.4:ud 
	mov (1) CT_R0Hdr.4:ud		r0.4:ud

	// R0.2: Interface Discriptor Ptr.  Add a child offset for child kernel
//	add (1) CT_R0Hdr.2:ud 		r0.2:ud 		CHILD_OFFSET:w

	// Assign a new Thread Count for this child
	mov (1) CT_R0Hdr.6:ud 		ChildThreadsID:uw

	//----- Prepare URB for launching a child thread -----
	mov (16) m2.0:w		ChildParam<16;16,1>:w

	shr (1)	 MRF0.0:uw	URBOffset:uw	1:w

	add	(1)	ChildThreadsID:uw		ChildThreadsID:uw	2:uw	// Luma child=even, chroma child=odd
		
	//--------------------------------------------------
//	#include "writeURB.asm"
	send  null:uw 	MRF0	 null:ud	URBWRITE	URBWriteMsgDesc:ud		// URB write	

	//--------------------------------------------------
	// Set URB handle for child thread launching:
	// URB handle Length	 	(bit 15:10) - 0000 0000 0000 0000  yyyy yy00 0000 0000
	// URB handle offset  		(bit 9:0) 	- 0000 0000 0000 0000  0000 00xx xxxx xxxx

	or  (1) CT_R0Hdr.4:ud		URB_EntriesPerMB_2:w	URBOffset:uw
	
	// 2 URB entries:
	// Entry 0 - CT_R0Hdr
	// Entry 1 - input parameter to child kernel

	//----- Spawn a child now -----
	send (8) null:ud 	CT_R0Hdr	  null:ud    TS	TSMSGDSC
//	send (8) null:ud 	CT_Spawn_Reg	null:ud    0x07100001


	// Restore CT_R0Hdr.4:ud to r0.4:ud for next use
//	mov (1) CT_R0Hdr.4:ud		r0.4:ud
