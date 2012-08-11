
#ifndef __DMA_MEMORY_H__
#define __DMA_MEMORY_H__

#ifndef __BOARD__H__
    #include "board.h"
#endif
#ifndef _PEXIOCTL_H_
    #include "pexioctl.h"
#endif

#include <vector>
#include <string>
#include <stdint.h>

//-----------------------------------------------------------------------------

struct dma_blocks {

    std::vector<struct memory_block> *m_blocks;
    std::vector<struct memory_block> *m_descr;
    struct memory_block *m_stub;

};

//-----------------------------------------------------------------------------

class dma_memory {

private:
    int m_fd;
    bool allocated;
    std::vector<struct memory_block> m_blocks;
    std::vector<struct memory_block> m_descr;
    struct dma_blocks m_memory;
    struct memory_block allocate_block(u32 blockSize);
    int free_block(struct memory_block block);

    int m_Channel;
    int m_UseCount;
    u32 m_ScatterGatherTableEntryCnt;
    u32 m_ScatterGatherBlockCnt;
    u32 m_BlockCount;
    u32 m_BlockSize;
    struct memory_block m_BufDscr;
    struct memory_block m_Stub;
    struct memory_block m_SGTableDscr;
    AMB_STUB* m_pStub;
    u32 m_page_size;
    u32 m_DmaDirection;
    u32 m_DmaLocalAddress;

public:
    dma_memory();
    virtual ~dma_memory();

    int free_memory(int fd, unsigned long cmd);
    int request_memory(void** ppVirtAddr, u32 size, u32 *pCount, void** pStub);
    int release_memory();
    int request_stub(void** pStub);
    int release_stub();
    int request_buffers(void **pMemPhysAddr);
    int release_buffers();
    int request_sg_list();
    int set_sg_list();
    int release_sg_list();
};

//-----------------------------------------------------------------------------

#endif //__DMA_MEMORY_H__
