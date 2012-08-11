
//-----------------------------------------------------------------------------

#include "dma_memory.h"

//-----------------------------------------------------------------------------

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>
#include <cstdio>
#include <errno.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

dma_memory::dma_memory()
{
    m_fd = -1;
    allocated = false;
    m_memory.m_blocks = NULL;
    m_memory.m_descr = NULL;
    m_memory.m_stub = NULL;
    m_page_size = sysconf(_SC_PAGESIZE);
}

//-----------------------------------------------------------------------------

dma_memory::~dma_memory()
{
}

//-----------------------------------------------------------------------------

struct memory_block dma_memory::allocate_block(u32 blockSize)
{
    struct memory_block zero = {0,0,0};
    struct memory_block block = {0,0,0};

    block.size = blockSize;

    int res = ::ioctl(m_fd, IOCTL_PEX_MEM_ALLOC, &block);
    if(res < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        return zero;
    }

    void *mapped_addr = mmap(NULL, block.size, PROT_READ|PROT_WRITE, MAP_SHARED, m_fd, (off_t)block.phys);
    if( mapped_addr == MAP_FAILED ) {
        fprintf(stderr, "%s\n", strerror(errno));
        return zero;
    }

    block.virt = mapped_addr;

    fprintf(stderr, "%s(): map PA = 0x%zx ---> %p\n", __FUNCTION__, block.phys, block.virt);

    return block;
}

//-----------------------------------------------------------------------------

int dma_memory::free_block(struct memory_block block)
{
    int res = munmap(block.virt, block.size);
    if( res < 0 ) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    fprintf(stderr, "%s(): unmap PA = 0x%zx ---> %p\n", __FUNCTION__, block.phys, block.virt);

    res = ioctl(m_fd, IOCTL_PEX_MEM_FREE, &block);
    if(res < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    return 0;
}

//-----------------------------------------------------------------------------
/*
int dma_memory::alloc_memory(int fd, unsigned long cmd, u32 blockNumber, u32 blockSize )
{
    int res = 0;

    if(allocated) return 0;

    // выделяем память под блоки данных
    for(unsigned i=0; i<blockNumber; i++) {

        struct memory_block block;

        block.phys = 0;
        block.virt = 0;
        block.size = blockSize;

        res = ioctl(fd, cmd, &block);
        if(res < 0) {
            fprintf(stderr, "%s\n", strerror(errno));
            return -1;
        }

        m_blocks.push_back(block);
    }

    // выделяем память под блочек
    m_stub.phys = 0;
    m_stub.virt = 0;
    m_stub.size = blockSize;

    res = ioctl(fd, cmd, &m_stub);
    if(res < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    // выполняем отображение выделенных блоков данных в пространство пользователя
    for(unsigned i=0; i<m_blocks.size(); i++) {

        struct memory_block& block = m_blocks.at(i);

        void *mapped_addr = mmap(NULL, block.size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)block.phys);
        if( mapped_addr == MAP_FAILED ) {
            fprintf(stderr, "%s\n", strerror(errno));
            return -1;
        }

        block.virt = mapped_addr;

        fprintf(stderr, "%d: map PA = 0x%zx ---> %p\n", i, block.phys, block.virt);
    }

    // выполним отображение блочка
    void *mapped_addr = mmap(NULL, m_stub.size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)m_stub.phys);
    if( mapped_addr == MAP_FAILED ) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    m_stub.virt = mapped_addr;

    fprintf(stderr, "Map stub = 0x%zx ---> %p\n", m_stub.phys, m_stub.virt);

    allocated = true;

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::free_memory(int fd, unsigned long cmd)
{
    int res = 0;
    if(!allocated) return 0;

    for(unsigned i=0; i<m_blocks.size(); i++) {

        struct memory_block& block = m_blocks.at(i);

        if(block.virt) {

            res = munmap(block.virt, block.size);
            if( res < 0 ) {
                fprintf(stderr, "%s\n", strerror(errno));
                return -1;
            }

            fprintf(stderr, "%d: unmap PA = 0x%zx ---> %p\n", i, block.phys, block.virt);

            res = ioctl(fd, cmd, &block);
            if(res < 0) {
                fprintf(stderr, "%s\n", strerror(errno));
                return -1;
            }
        }
    }

    m_blocks.clear();

    res = munmap(m_stub.virt, m_stub.size);
    if( res < 0 ) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    fprintf(stderr, "Stub unmap PA = 0x%zx ---> %p\n", m_stub.phys, m_stub.virt);

    res = ioctl(fd, cmd, &m_stub);
    if(res < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        return -1;
    }

    m_stub.phys = 0;
    m_stub.virt = 0;
    m_stub.size = 0;

    allocated = false;

    return 0;
}
*/
//-----------------------------------------------------------------------------

int dma_memory::request_stub(void** pStub)
{
    int	StubSize = sizeof(AMB_STUB) > m_page_size ? sizeof(AMB_STUB) : m_page_size;

    m_Stub = allocate_block(StubSize);
    if(!m_Stub.virt) {
        fprintf(stderr, "%s(): Not enought memory for stub\n", __FUNCTION__);
        return -ENOMEM;
    }

    *pStub = m_Stub.virt;

    fprintf(stderr, "%s(): Stub physical address: %zx\n", __FUNCTION__, m_Stub.phys);
    fprintf(stderr, "%s(): Stub virtual address: %p\n", __FUNCTION__, m_Stub.virt);

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::release_stub()
{
    return free_block(m_Stub);
}

//-----------------------------------------------------------------------------

int dma_memory::request_buffers(void **pMemPhysAddr)
{
    u32 iBlock = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)m_BufDscr.virt;

    fprintf(stderr, "%s():\n", __FUNCTION__);

    m_blocks.clear();

    for(iBlock = 0; iBlock < m_BlockCount; iBlock++)
    {
        struct memory_block block = {0};

        block = allocate_block(m_BlockSize);
        if(!block.virt) {

            fprintf(stderr, "%s(): Not enought memory for %i block location. m_BlockSize = 0x%X\n",
                   __FUNCTION__, (int)iBlock, (int)m_BlockSize );
            return -ENOMEM;
        }

        pMemDscr[iBlock].SystemAddress = block.virt;
        pMemDscr[iBlock].LogicalAddress = block.phys;
        pMemPhysAddr[iBlock] = block.virt;

        fprintf(stderr, "%s(): %i: %p\n", __FUNCTION__, iBlock, pMemPhysAddr[iBlock]);

        m_blocks.push_back(block);
    }

    m_BlockCount = m_blocks.size();
    m_ScatterGatherTableEntryCnt = m_blocks.size();

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::release_buffers()
{
    u32 iBlock = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)m_BufDscr.virt;

    fprintf(stderr, "%s()\n", __FUNCTION__);

    for(iBlock = 0; iBlock < m_blocks.size(); iBlock++) {

        struct memory_block& block = m_blocks.at(iBlock);

        free_block(block);

        pMemDscr[iBlock].SystemAddress = NULL;
        pMemDscr[iBlock].LogicalAddress = 0;
    }

    m_blocks.clear();

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::request_memory(void** ppVirtAddr, u32 size, u32 *pCount, void** pStub)
{
    int res = -ENOMEM;

    fprintf(stderr, "%s(): Channel = %d\n", __FUNCTION__, m_Channel);

    m_BlockCount = *pCount;
    m_BlockSize = size;
    m_ScatterGatherTableEntryCnt = 0;

    // выделяем память под описатели блоков (системный, и логический адрес для каждого блока)
    m_BufDscr = allocate_block(m_BlockCount * sizeof(SHARED_MEMORY_DESCRIPTION));
    if(!m_BufDscr.virt) {

        fprintf(stderr, "%s(): Not memory for buffer descriptions\n", __FUNCTION__);
        return -ENOMEM;
    }

    res = request_stub(pStub);
    if(res == 0) {

        res = request_buffers(ppVirtAddr);
        if(res == 0) {

                fprintf(stderr, "%s(): Scatter/Gather Table Entry is %d\n", __FUNCTION__, m_ScatterGatherTableEntryCnt);

                set_sg_list();

                *pCount = m_blocks.size();

                m_pStub = (PAMB_STUB)m_Stub.virt;
                m_pStub->lastBlock = -1;
                m_pStub->totalCounter = 0;
                m_pStub->offset = 0;
                m_pStub->state = STATE_STOP;

                m_UseCount++;

        } else {

            release_stub();
            release_buffers();
            free_block(m_BufDscr);

            fprintf(stderr, "%s(): Error allocate memory\n", __FUNCTION__);

            return -ENOMEM;
        }

    } else {

            free_block(m_BufDscr);
            fprintf(stderr, "%s(): Error allocate memory\n", __FUNCTION__);

            return -ENOMEM;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::release_memory()
{
    int res = 0;

    fprintf(stderr, "%s(): Entered. Channel = %d\n", __FUNCTION__, m_Channel);

    res = release_stub();
    res = release_sg_list();
    res = release_buffers();
    res = free_block(m_BufDscr);

    m_UseCount--;

    return res;
}

//-----------------------------------------------------------------------------

int dma_memory::request_sg_list()
{
    u32 SGListMemSize = 0;
    u32 SGListSize = 0;

    fprintf(stderr, "%s()\n", __FUNCTION__);

    m_ScatterGatherBlockCnt = m_ScatterGatherTableEntryCnt / (DSCR_BLOCK_SIZE-1);
    m_ScatterGatherBlockCnt = (m_ScatterGatherTableEntryCnt % (DSCR_BLOCK_SIZE-1)) ? (m_ScatterGatherBlockCnt+1) : m_ScatterGatherBlockCnt;
    SGListSize = sizeof(DMA_CHAINING_DESCR_EXT) * DSCR_BLOCK_SIZE * m_ScatterGatherBlockCnt;
    fprintf(stderr, "%s(): SGBlockCnt = %d, SGListSize = %d.\n", __FUNCTION__, m_ScatterGatherBlockCnt, SGListSize);

    SGListMemSize = (SGListSize >= m_page_size) ? SGListSize : m_page_size;

    m_SGTableDscr = allocate_block(SGListMemSize);
    if(!m_SGTableDscr.virt) {
        fprintf(stderr, "%s(): Not enought memory for scatter/gather list\n", __FUNCTION__);
        return -ENOMEM;
    }

    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::set_sg_list()
{
    int Status = 0;
    u32 iBlock = 0, ii = 0;
    u32 iEntry = 0;
    u32 iBlkEntry = 0;
    u64 *pDscrBuf = NULL;
    u16* pNextDscr = NULL;
    u32 DscrSize = 0;
    SHARED_MEMORY_DESCRIPTION *pMemDscr = (SHARED_MEMORY_DESCRIPTION*)m_BufDscr.virt;
    DMA_CHAINING_DESCR_EXT	*pSGTEx = NULL;

    fprintf(stderr, "<0>%s()\n", __FUNCTION__);

    Status = request_sg_list();
    if(Status < 0)
        return Status;

    //получим адрес таблицы для хранения цепочек DMA
    pSGTEx = (DMA_CHAINING_DESCR_EXT*)m_SGTableDscr.virt;

    DscrSize = DSCR_BLOCK_SIZE*sizeof(DMA_CHAINING_DESCR_EXT);

    //обнулим таблицу дескрипторов DMA
    memset(pSGTEx, 0, m_ScatterGatherBlockCnt*DscrSize);

    fprintf(stderr, "%s(): m_SGTableDscr.VirtualAddress = %p\n", __FUNCTION__, m_SGTableDscr.virt );
    fprintf(stderr, "%s(): m_SGTableDscr.PhysicalAddress = %zx\n", __FUNCTION__, m_SGTableDscr.phys );

    //заполним значениями таблицу цепочек DMA
    for(iBlock=0, iEntry=0; iBlock < m_blocks.size(); iBlock++) {

        //адрес и размер DMA блока
        u64	address = pMemDscr[iBlock].LogicalAddress;
        u64	DmaSize = m_BlockSize - 0x1000;


        //заполним поля элментов таблицы дескрипторов
        pSGTEx[iEntry].AddrByte1  = (u8)((address >> 8) & 0xFF);
        pSGTEx[iEntry].AddrByte2  = (u8)((address >> 16) & 0xFF);
        pSGTEx[iEntry].AddrByte3  = (u8)((address >> 24) & 0xFF);
        pSGTEx[iEntry].AddrByte4  = (u8)((address >> 32) & 0xFF);
        pSGTEx[iEntry].SizeByte1  = (u8)((DmaSize >> 8) & 0xFF);
        pSGTEx[iEntry].SizeByte2  = (u8)((DmaSize >> 16) & 0xFF);
        pSGTEx[iEntry].SizeByte3  = (u8)((DmaSize >> 24) & 0xFF);
        pSGTEx[iEntry].Cmd.JumpNextDescr = 1; //перейти к следующему дескриптору
        pSGTEx[iEntry].Cmd.JumpNextBlock = 0; //перейти к следующему блоку дескрипторов
        pSGTEx[iEntry].Cmd.JumpDescr0 = 0;
        pSGTEx[iEntry].Cmd.Res0 = 0;
        pSGTEx[iEntry].Cmd.EndOfTrans = 1;
        pSGTEx[iEntry].Cmd.Res = 0;
        pSGTEx[iEntry].SizeByte1 |= m_DmaDirection;

        {
            u32 *ptr=(u32*)&pSGTEx[iEntry];
            fprintf(stderr, "%s(): %d: Entry Addr: %p, Data Addr: %llx  %.8X %.8X\n",
                   __FUNCTION__, iEntry, &pSGTEx[iEntry], address, ptr[1], ptr[0]);

        }

        if(((iEntry+2)%DSCR_BLOCK_SIZE) == 0)
        {
            u32 NextDscrBlockAddr = 0;
            DMA_NEXT_BLOCK *pNextBlock = NULL;

            pSGTEx[iEntry].Cmd.JumpNextBlock = 1;
            pSGTEx[iEntry].Cmd.JumpNextDescr = 0;

            NextDscrBlockAddr = (u32)((u8*)m_SGTableDscr.phys + sizeof(DMA_CHAINING_DESCR_EXT)*(iEntry +2));

            fprintf(stderr, "%s(): NextDscrBlock [PA]: %x\n", __FUNCTION__, NextDscrBlockAddr);
            fprintf(stderr, "%s(): NextDscrBlock [VA]: %p\n", __FUNCTION__, &pSGTEx[iEntry+2]);

            pNextBlock = (DMA_NEXT_BLOCK*)&pSGTEx[iEntry+1];

            fprintf(stderr, "%s(): pNextBlock: %p\n", __FUNCTION__, pNextBlock);

            pNextBlock->NextBlkAddr = (NextDscrBlockAddr >> 8) & 0xFFFFFF;
            pNextBlock->Signature = 0x4953;
            pNextBlock->Crc = 0;
            iEntry++;
        }
        iEntry++;
    }

    fprintf(stderr, "%s(): iEntry = %d\n", __FUNCTION__, iEntry);

    if(((iEntry % DSCR_BLOCK_SIZE)) != 0)
    {
        DMA_NEXT_BLOCK *pNextBlock = NULL;
        u32 i = 0;

        pSGTEx[iEntry-1].Cmd.JumpNextDescr = 0;

        pNextBlock = (DMA_NEXT_BLOCK*)(&pSGTEx[iEntry]);
        pNextBlock->NextBlkAddr = (m_SGTableDscr.phys >> 8);

        i = (DSCR_BLOCK_SIZE * m_ScatterGatherBlockCnt) - 1;
        pNextBlock = (DMA_NEXT_BLOCK*)(&pSGTEx[i]);

        fprintf(stderr, "%s(): %d: pNextBlock: %p\n", __FUNCTION__, i, pNextBlock );

        pNextBlock->NextBlkAddr = 0;
        pNextBlock->Signature = 0x4953;
        pNextBlock->Crc = 0;
    }

    fprintf(stderr, "%s(): DmaDirection = %d, DmaLocalAddress = 0x%X\n", __FUNCTION__, m_DmaDirection, m_DmaLocalAddress);

    for( ii=0; ii<m_ScatterGatherBlockCnt*DSCR_BLOCK_SIZE; ii++ )
    {
        u32 *ptr=(u32*)&pSGTEx[ii];
        fprintf(stderr, "%s(): %d: %.8X %.8X\n", __FUNCTION__, ii, ptr[1], ptr[0]);

    }

    pDscrBuf = (u64*)m_SGTableDscr.virt;

    for(iBlkEntry = 0; iBlkEntry < m_ScatterGatherBlockCnt; iBlkEntry++)
    {
        u32 ctrl_code = 0xFFFFFFFF;

        for(iBlock = 0; iBlock < DSCR_BLOCK_SIZE; iBlock++)
        {
            u16 data0 = (u16)(pDscrBuf[iBlock] & 0xFFFF);
            u16 data1 = (u16)((pDscrBuf[iBlock] >> 16) & 0xFFFF);
            u16 data2 = (u16)((pDscrBuf[iBlock] >> 32) & 0xFFFF);
            u16 data3 = (u16)((pDscrBuf[iBlock] >> 48) & 0xFFFF);
            if(iBlock == DSCR_BLOCK_SIZE-1)
            {
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;

                fprintf(stderr, "%s(): DSCR_BLCK[%d] - NextBlkAddr = 0x%8X, Signature = 0x%4X, Crc = 0x%4X\n", __FUNCTION__,
                       iBlkEntry,
                       (u32)(pDscrBuf[iBlock] << 8),
                       (u16)((pDscrBuf[iBlock] >> 32) & 0xFFFF),
                       (u16)ctrl_code);
            }
            else
            {
                u32 ctrl_tmp = 0;
                ctrl_code = ctrl_code ^ data0 ^ data1 ^ data2 ^ data3;
                ctrl_tmp = ctrl_code << 1;
                ctrl_tmp |= (ctrl_code & 0x8000) ? 0: 1;
                ctrl_code = ctrl_tmp;

                fprintf(stderr, "%s(): %d(%d) - PciAddr = 0x%8X, Cmd = 0x%2X, DmaLength = %d(%2X %2X %2X)\n",  __FUNCTION__,
                                                                                        iBlock, iBlkEntry,
                                                                                        (u32)(pDscrBuf[iBlock] << 8),
                                                                                        (u8)(pDscrBuf[iBlock] >> 32),
                                                                                        (u32)((pDscrBuf[iBlock] >> 41) << 9),
                                                                                        (u8)(pDscrBuf[iBlock] >> 56),
                                                                                        (u8)(pDscrBuf[iBlock] >> 48),
                                                                                        (u8)(pDscrBuf[iBlock] >> 40));
            }
        }
        pNextDscr = (u16*)pDscrBuf;
        pNextDscr[255] |= (u16)ctrl_code;
        pDscrBuf += DSCR_BLOCK_SIZE;
    }
    return 0;
}

//-----------------------------------------------------------------------------

int dma_memory::release_sg_list()
{
    return free_block(m_SGTableDscr);
}

//-----------------------------------------------------------------------------
