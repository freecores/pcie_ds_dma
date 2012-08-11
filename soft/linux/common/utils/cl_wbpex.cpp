//---------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>

#include	"board.h"
//#include	"brderr.h"
//#include	"ctrlstrm.h"
//#include        "ctrlreg.h"
//#include        "useful.h"
//#include	"cl_wbpex.h"

#ifndef __PEX_BOARD_H__
    #include "pex_board.h"
#endif

#ifndef __BOARD_H__
    #include "board.h"
#endif

#include "cl_wbpex.h"
#include "sys/select.h"
//BRD_Handle g_hBrd=0;

//!  Инициализация модуля
U32  CL_WBPEX::init( void )
{
    S32 err;
    S32 num;

    /*
    if( g_hBrd<=0)
    {
        BRDC_fprintf( stderr, _BRDC("\r\nМодуль не найден\r\n") );
        return 1;
    } else {
        BRDC_fprintf( stderr, _BRDC("BRD_open() - Ok\r\n") );
        BRD_getInfo(1, &info );
    }
    */

    board *brd = new pex_board();
    m_pBoard = brd;

    brd->brd_open( "/dev/AMBPEX50" );
    brd->brd_init();
    brd->brd_board_info();
    //brd->brd_pld_info();

    // сброс прошивки ПЛИС
    return 0;
}

//!  Завершение работы с модулем
void  CL_WBPEX::cleanup( void )
{
    S32 ret;
    //ret=BRD_cleanup();

}




// Доступ к регистрам 



CL_WBPEX::CL_WBPEX()
{

}



int CL_WBPEX::StreamInit( U32 strm, U32 cnt_buf, U32 size_one_buf_of_bytes, U32 trd, U32 dir, U32 cycle, U32 system, U32 agree_mode )
{
    if( strm>1 )
        return 1;

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=0 )
        return 1;

    pStrm->cnt_buf	= cnt_buf;
    pStrm->size_one_buf_of_bytes =	size_one_buf_of_bytes;
    pStrm->trd		= trd;
    pStrm->cycle	= cycle;
    pStrm->system	= system;

    pStrm->indexDma=-1;
    pStrm->indexPc=-1;
    pStrm->agree_mode=agree_mode;

    StreamDestroy( strm );


    //U32 size=cnt_buf*size_one_buf_of_bytes/(1024*1024);
    __int64 size=cnt_buf*(__int64)size_one_buf_of_bytes/(1024*1024);

    if( system )
    {
        BRDC_fprintf( stderr, _BRDC("Выделение памяти: \r\n")
                     _BRDC(" Тип блока:    Непрерывный (системная память)\r\n")
                     _BRDC(" Размер блока: %lld МБ\r\n"), size );
    } else
    {
        BRDC_fprintf( stderr, _BRDC("Выделение памяти: \r\n")
                     _BRDC(" Тип блока:    Разрывный (пользовательская память)\r\n")
                     _BRDC(" Размер блока: %lld МБ  (%dx%d МБ)\r\n"), size, cnt_buf, size_one_buf_of_bytes/(1024*1024) );
    }




    // Перевод на согласованный режим работы
    if( agree_mode )
    {
    } else
    {
        BRDC_fprintf( stderr, _BRDC("Стрим работает в несогласованном режиме\r\n") );
    }
    BRDC_fprintf( stderr, "\r\n" );

/*
    err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_CBUF_STOP, NULL);

    err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_RESETFIFO, NULL );


    err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_RESETFIFO, NULL );
*/
    pStrm->status=1;

    return 0;
}

int CL_WBPEX::StreamGetNextIndex( U32 strm, U32 index )
{
    if( strm>1 )
        return 0;

    StreamParam *pStrm= m_streamParam+strm;
    int n=index+1;
    if( (U32)n>=pStrm->cnt_buf )
        n=0;
    return n;

}

void CL_WBPEX::StreamDestroy( U32 strm )
{
    S32 err;

    if( strm>1 )
        return;

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status==0 )
        return;

    StreamStop( strm );

    if( 1 )
    {
        BRDC_fprintf( stderr, _BRDC("\r\nОсвобождение стрима  %.8X\r\n"), err );
       // pStrm->hStream=0;
    }
    pStrm->status=0;

}

U32* CL_WBPEX::StreamGetBufByNum( U32 strm, U32 numBuf )
{
    if( strm>1 )
        return NULL;

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=1 )
        return NULL;

    U32 *ptr;
    if( numBuf>=pStrm->cnt_buf )
        return NULL;
    ptr=(U32*)(pStrm->pBlk[numBuf]);
    return ptr;
}

void CL_WBPEX::StreamStart( U32 strm )
{

    if( strm>1 )
        return;

    StreamParam *pStrm= m_streamParam+strm;
    if( pStrm->status!=1 )
        return;

    S32 err;
    U32 val;

    //val=RegPeekInd( pStrm->trd, 0 );
    //err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_CBUF_STOP, NULL);


    pStrm->indexDma=-1;
    pStrm->indexPc=-1;

    val=pStrm->cycle; // 0 - однократный режим, 1 - циклический
    //err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_CBUF_START, &val );
}

void CL_WBPEX::StreamStop( U32 strm )
{
    if( strm>1 )
        return;

    StreamParam *pStrm= m_streamParam+strm;

    S32 err;

    //RegPokeInd( pStrm->trd, 0, 2 );

    //err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_CBUF_STOP, NULL);

    //err = BRD_ctrl( pStrm->hStream, 0, BRDctrl_STREAM_RESETFIFO, NULL );

    //RegPokeInd( pStrm->trd, 0, 0 );

}

int CL_WBPEX::StreamGetBuf( U32 strm, U32** ptr )
{
    U32 *buf;
    int ret=0;

    if( strm>1 )
        return 0;

    StreamParam *pStrm= m_streamParam+strm;


    if( pStrm->indexPc==pStrm->indexDma )
    {
        pStrm->indexDma = StreamGetIndexDma( strm );
    }
    if( pStrm->indexPc!=pStrm->indexDma )
    {
        pStrm->indexPc=StreamGetNextIndex( strm, pStrm->indexPc );
        buf = StreamGetBufByNum( strm, pStrm->indexPc );
        *ptr = buf;
        ret=1;
        //StreamGetBufDone( strm );
    }
    return ret;
}

int CL_WBPEX::StreamGetIndexDma( U32 strm )
{
    if( strm>1 )
        return -1;

    StreamParam *pStrm= m_streamParam+strm;



//    int ret = pStrm->pStub->lastBlock;
    return 0;
}

void CL_WBPEX::StreamGetBufDone( U32 strm )
{
    if( strm>1 )
        return;

    StreamParam *pStrm= m_streamParam+strm;
    S32 err;
    static U32 err_code=0;

    if( pStrm->agree_mode )
    {
    }
}

/*
void Sleep( int ms )
{
    struct timeval tv = {0, 0};
    tv.tv_usec = 1000*ms;

    select(0,NULL,NULL,NULL,&tv);

}
*/



//! Запись в регистр блока на шине WB
void CL_WBPEX::wb_block_write( U32 nb, U32 reg, U32 val )
{
    if( (nb>1) || (reg>31) )
        return;
    m_pBoard->brd_bar1_write( nb*0x2000/4+reg*2, val );
}

//! Чтение из регистра блока на шине WB
U32 CL_WBPEX::wb_block_read( U32 nb, U32 reg )
{
    U32 ret;
    if( (nb>1) || (reg>31) )
        return -1;
    ret=m_pBoard->brd_bar1_read( nb*0x2000/4+reg*2 );
    return ret;
}


