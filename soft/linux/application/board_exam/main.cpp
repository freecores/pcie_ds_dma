
#ifndef __PEX_H__
    #include "pex_board.h"
#endif

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>
#include <cstdio>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------
#define NUM_BLOCK   4
#define BLOCK_SIZE  0x1000
//-----------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    if(argc == 1) {
        std::cerr << "usage: %s <device name>" << argv[0] << endl;
        return -1;
    }

    std ::cout << "Start testing device " << argv[1] << endl;

    int dmaChan = 0;
    void* pBuffers[NUM_BLOCK] = {NULL};

    board *brd = new pex_board();
    brd->brd_open(argv[1]);
    brd->brd_init();
    brd->brd_pld_info();

    std ::cout << "Press enter to allocate DMA memory..." << endl;
    getchar();

    // Check BRDSHELL DMA interface
    BRDctrl_StreamCBufAlloc sSCA = {
        1,
        1,
        NUM_BLOCK,
        BLOCK_SIZE,
        &pBuffers[0],
        NULL,
    };

    brd->dma_alloc(dmaChan, &sSCA);

    std ::cout << "Press enter to start DMA channel..." << endl;
    getchar();

    brd->dma_start(dmaChan, 0);

    std ::cout << "Press enter to stop DMA channel..." << endl;
    getchar();

    brd->dma_stop(dmaChan);

    std ::cout << "Press enter to view DMA data (buffer 0)..." << endl;
    getchar();

    u32 *buffer = (u32*)pBuffers[0];
    for(unsigned i=0; i<BLOCK_SIZE/4; i+=128) {
        std::cout << hex << buffer[i] << " ";
    }
    std::cout << dec << endl;

    std ::cout << "Press enter to free DMA memory..." << endl;
    getchar();

    brd->dma_free_memory(dmaChan);
/*
    for(int i=0; i<16; i++)
        std ::cout << "BAR0[" << i << "] = 0x" << hex << brd->brd_bar0_read(i) << dec << endl;

    fprintf(stderr, "Press enter to read BAR1...\n");
    getchar();

    for(int i=0; i<16; i++)
        std ::cout << "BAR1[" << i << "] = 0x" << hex << brd->brd_bar1_read(i) << dec << endl;
*/
    brd->brd_close();

    delete brd;

    return 0;
}
