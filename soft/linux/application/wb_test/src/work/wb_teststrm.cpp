

#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include "utypes.h"
#include "wb_teststrm.h"
#include "cl_wbpex.h"
//#include "useful.h"

#define BUFSIZEPKG 62

#define TRDIND_MODE0					0x0
#define TRDIND_MODE1					0x9
#define TRDIND_MODE2					0xA
#define TRDIND_SPD_CTRL					0x204
#define TRDIND_SPD_ADDR					0x205
#define TRDIND_SPD_DATA					0x206

#define TRDIND_TESTSEQ					0x0C
#define TRDIND_CHAN						0x10
#define TRDIND_FSRC						0x13
#define TRDIND_GAIN						0x15
#define TRDIND_CONTROL1					0x17
#define TRDIND_DELAY_CTRL				0x1F


WB_TestStrm::WB_TestStrm( char* fname,  CL_WBPEX *pex )
{
    lc_status=0;

    Terminate=0;
    BlockRd=0;
    BlockOk=0;
    BlockError=0;
    TotalError=0;

    pBrd=pex;
    bufIsvi=NULL;

    SetDefault();
    GetParamFromFile( fname );
    CalculateParams();

   // if(5==isTest) {
   //     rd0.testBuf.buf_check_sine_init( SizeBlockOfWords, fftSize, lowRange, topRange, 3 );
   // }
   // cpuFreq = tk_freq();
    isFirstCallStep=true;
}

WB_TestStrm::~WB_TestStrm()
{
    pBrd->StreamDestroy( rd0.Strm );
    //delete bufIsvi; bufIsvi=NULL;

}

void WB_TestStrm::Prepare( void )
{


    PrepareAdm();

    rd0.trd=trdNo;
    rd0.Strm=strmNo;
    pBrd->StreamInit( rd0.Strm, CntBuffer, SizeBuferOfBytes, rd0.trd, 1, isCycle, isSystem, isAgreeMode );

    bufIsvi = new U32[SizeBlockOfWords*2];
    //pBrd->StreamInit( strm, CntBuffer, SizeBuferOfBytes, rd0.trd, 1, 0, 0 );
}

void WB_TestStrm::Start( void )
{
    int res = pthread_attr_init(&attrThread_);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_attr_setdetachstate(&attrThread_, PTHREAD_CREATE_JOINABLE);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_create(&hThread, &attrThread_, ThreadFunc, this);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_attr_init(&attrThreadIsvi_);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_attr_setdetachstate(&attrThreadIsvi_, PTHREAD_CREATE_JOINABLE);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }

    res = pthread_create(&hThreadIsvi, &attrThreadIsvi_, ThreadFuncIsvi, this);
    if(res != 0) {
        fprintf(stderr, "%s\n", "Stream not started");
        return;
    }
}

void WB_TestStrm::Stop( void )
{
    Terminate=1;
    lc_status=3;
}

void WB_TestStrm::Step( void )
{

    /*
	pkg_in.testBuf.check_result( &pkg_in.BlockOk , &pkg_in.BlockError, NULL, NULL, NULL );
	rd0.testBuf.check_result( &rd0.BlockOk , &rd0.BlockError, NULL, NULL, NULL );
	rd1.testBuf.check_result( &rd1.BlockOk , &rd1.BlockError, NULL, NULL, NULL );
	*/

    rd0.testBuf.check_result( &rd0.BlockOk , &rd0.BlockError, NULL, NULL, NULL );

    //BRDC_fprintf( stderr, "%10s %10d %10d %10d %10d\n", "PACKAGE :", pkg_out.BlockWr, pkg_in.BlockRd, pkg_in.BlockOk, pkg_in.BlockError );
    //BRDC_fprintf( stderr, "%10s %10d %10d %10d %10d\n", "FIFO_0 :", tr0.BlockWr, rd0.BlockRd, rd0.BlockOk, rd0.BlockError );
    //BRDC_fprintf( stderr, "%10s %10d %10d %10d %10d\n", "FIFO_1 :", tr1.BlockWr, rd1.BlockRd, rd1.BlockOk, rd1.BlockError );

    U32 status = 0; //pBrd->RegPeekDir( rd0.trd, 0 ) & 0xFFFF;
    BRDC_fprintf( stderr, "%6s %3d %10d %10d %10d %10d  %9.1f %10.1f     0x%.4X  %d %4d %4f\r", "TRD :", rd0.trd, rd0.BlockWr, rd0.BlockRd, rd0.BlockOk, rd0.BlockError, rd0.VelocityCurrent, rd0.VelocityAvarage, status, IsviStatus, IsviCnt, rd0.fftTime_us );




}

int WB_TestStrm::isComplete( void )
{
    if( (lc_status==4) && (IsviStatus==100) )
        return 1;
    return 0;
}

void WB_TestStrm::GetResult( void )
{
    //if(pkg_in.BlockRd!=0 && pkg_in.BlockError!=0)
    //	printf("%s\n", pkg_in.testBuf.report_word_error());

    BRDC_fprintf( stderr, "\n\nРезультат приёма данных через тетраду %d \n", trdNo );
    if(rd0.BlockRd!=0 && rd0.BlockError!=0)
        printf("%s\n", rd0.testBuf.report_word_error());

    BRDC_fprintf( stderr, "\n\n" );
}

void* WB_TestStrm::ThreadFunc( void* lpvThreadParm )
{
    WB_TestStrm *test=(WB_TestStrm*)lpvThreadParm;
    UINT ret;
    if( !test )
        return 0;
    ret=test->Execute();
    return (void*)ret;
}

void* WB_TestStrm::ThreadFuncIsvi( void* lpvThreadParm )
{
    WB_TestStrm *test=(WB_TestStrm*)lpvThreadParm;
    UINT ret;
    if( !test )
        return 0;

    Sleep( 200 );
    ret=test->ExecuteIsvi();
    return (void*)ret;
}

//! Установка параметров по умолчанию
void WB_TestStrm::SetDefault( void )
{
    int ii=0;

    array_cfg[ii++]=STR_CFG(  0, "CntBuffer",			"16", (U32*)&CntBuffer, "число буферов стрима" );
    array_cfg[ii++]=STR_CFG(  0, "CntBlockInBuffer",	"512",  (U32*)&CntBlockInBuffer, "Число блоков в буфере" );
    array_cfg[ii++]=STR_CFG(  0, "SizeBlockOfWords",	"2048",  (U32*)&SizeBlockOfWords, "Размер блока в словах" );
    array_cfg[ii++]=STR_CFG(  0, "isCycle",				"1",  (U32*)&isCycle, "1 - Циклический режим работы стрима" );
    array_cfg[ii++]=STR_CFG(  0, "isSystem",			"1",  (U32*)&isSystem, "1 - выделение системной памяти" );
    array_cfg[ii++]=STR_CFG(  0, "isAgreeMode",			"0",  (U32*)&isAgreeMode, "1 - согласованный режим" );

    array_cfg[ii++]=STR_CFG(  0, "trdNo",	"4",  (U32*)&trdNo, "Номер тетрады" );
    array_cfg[ii++]=STR_CFG(  0, "strmNo",	"0",  (U32*)&strmNo, "Номер стрма" );
    array_cfg[ii++]=STR_CFG(  0, "isTest",	"0",  (U32*)&isTest, "0 - нет, 1 - проверка псевдослучайной последовательности, 2 - проверка тестовой последовательности" );
    array_cfg[ii++]=STR_CFG(  0, "isMainTest",	"0",  (U32*)&isMainTest, "1 - включение режима тестирования в тетраде MAIN" );

    array_cfg[ii++]=STR_CFG(  0, "lowRange",	"0",  (U32*)&lowRange, "нижний уровень спектра" );
    array_cfg[ii++]=STR_CFG(  0, "topRange",	"0",  (U32*)&topRange, "верхний уровень спектра" );
    array_cfg[ii++]=STR_CFG(  0, "fftSize",	"2048",  (U32*)&fftSize, "размер БПФ" );


    fnameAdmReg=NULL;
    array_cfg[ii++]=STR_CFG(  2, "AdmReg",	    "adcreg.ini",  (U32*)&fnameAdmReg, "имя файла регистров" );

    array_cfg[ii++]=STR_CFG(  0, "isAdmReg",	"0",  (U32*)&isAdmReg, "1 - разрешение записи регистров из файла AdmReg" );

    fnameAdmReg2=NULL;
    array_cfg[ii++]=STR_CFG(  2, "AdmReg2",	    "adcreg2.ini",  (U32*)&fnameAdmReg2, "имя файла регистров (выполняется после старта стрима)" );

    array_cfg[ii++]=STR_CFG(  0, "isAdmReg2",	"0",  (U32*)&isAdmReg2, "1 - разрешение записи регистров из файла AdmReg2" );

    fnameIsvi=NULL;
    array_cfg[ii++]=STR_CFG(  2, "ISVI_FILE",	"",  (U32*)&fnameIsvi, "имя файла данных ISVI" );

    array_cfg[ii++]=STR_CFG(  0, "ISVI_HEADER",	"0",  (U32*)&IsviHeaderMode, "режим формирования суффикса ISVI, 0 - нет, 1 - DDC, 2 - ADC" );


    array_cfg[ii++]=STR_CFG(  0, "FifoRdy",		"0",  (U32*)&isFifoRdy, "1 - генератор тестовой последовательности анализирует флаг готовности FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "Cnt1",	"0",  (U32*)&Cnt1, "Число тактов записи в FIFO, 0 - постоянная запись в FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "Cnt2",	"0",  (U32*)&Cnt2, "Число тактов паузы при записи в FIFO" );

    array_cfg[ii++]=STR_CFG(  0, "DataType",	"0",  (U32*)&DataType, "Тип данных при фиксированном типе блока, 6 - счётчик, 8 - псевдослучайная последовательность" );

    array_cfg[ii++]=STR_CFG(  0, "DataFix",	"0",  (U32*)&DataFix, "1 - фиксированный тип блока, 0 - данные в блоке записят от номера блока" );

    array_cfg[ii++]=STR_CFG(  0, "isTestCtrl",	"0",  (U32*)&isTestCtrl, "1 - подготовка тетрады TEST_CTRL" );


    array_cfg[ii++]=STR_CFG(  0, "TestSeq",			"0",  (U32*)&TestSeq, "Значение регистра TEST_SEQ" );

    max_item=ii;

    {
	char str[1024];
        for( unsigned ii=0; ii<max_item; ii++ )
	{
            sprintf( str, "%s  %s", array_cfg[ii].name, array_cfg[ii].def );
            GetParamFromStr( str );
	}


    }

}

//! Расчёт параметров
void WB_TestStrm::CalculateParams( void )
{
    SizeBlockOfBytes = SizeBlockOfWords * 4;						// Размер блока в байтах
    SizeBuferOfBytes	= CntBlockInBuffer * SizeBlockOfBytes  ;	// Размер буфера в байтах
    SizeStreamOfBytes	= CntBuffer * SizeBuferOfBytes;				// Общий размер буфера стрима

    ShowParam();
}

//! Отображение параметров
void WB_TestStrm::ShowParam( void )
{
    TF_WorkParam::ShowParam();

    BRDC_fprintf( stderr, "Общий размер буфера стрима: %d МБ\n\n", SizeStreamOfBytes/(1024*1024) );

}


U32 WB_TestStrm::Execute( void )
{
    rd0.testBuf.buf_check_start( 32, 64 );

/*
    pBrd->RegPokeInd( rd0.trd, 0, 0x2010 );
    pBrd->StreamStart( rd0.Strm );
    pBrd->RegPokeInd( rd0.trd, 0, 0x2038 );
    if( isTestCtrl )
    {
        StartTestCtrl();
    }

    if( isAdmReg2 )
        PrepareAdmReg( fnameAdmReg2 );

    pBrd->RegPokeInd( 4, 0, 0x2038 );
*/
    rd0.time_last=rd0.time_start=0 ;//GetTickCount();


    for( ; ; )
    {
        if( Terminate )
        {
            break;
        }

        ReceiveData( &rd0 );
        //Sleep( 100 );
    }
/*
    pBrd->RegPokeInd( rd0.trd, 0, 2 );
    Sleep( 200 );
*/
    pBrd->StreamStop( rd0.Strm );
    Sleep( 10 );

    lc_status=4;
    return 1;
}




void WB_TestStrm::ReceiveData(  ParamExchange *pr )
{
    U32 *ptr;
    U32 *ptrBlock;
    U32 mode=0;
    mode |= pr->DataType<<8;
    mode |= pr->DataFix<<7;

    int ret;
    int kk;

    //pr->BlockRd++;
    //Sleep( 10 );
    //return;

    for( kk=0; kk<16; kk++ )
    {
        ret=pBrd->StreamGetBuf( pr->Strm, &ptr );
        if( ret )
        { // Проверка буфера стрима

                for( unsigned ii=0; ii<CntBlockInBuffer; ii++ )
                {
                    ptrBlock=ptr+ii*SizeBlockOfWords;
                    if( isIsvi )
                        IsviStep( ptrBlock );

                    if( 1==isTest )
                        pr->testBuf.buf_check_psd( ptrBlock, SizeBlockOfWords );
                    //int a=0;
                    else if( 2==isTest )
                        pr->testBuf.buf_check( ptrBlock, pr->BlockRd, SizeBlockOfWords, BlockMode );
                    else if( 4==isTest )
                        pr->testBuf.buf_check_inv( ptrBlock, SizeBlockOfWords );

                    pr->BlockRd++;
                }
                if( isAgreeMode )
                {
                    pBrd->StreamGetBufDone( pr->Strm );
                }

        } else
        {
            //Sleep( 0 );
            pr->freeCycle++;
            break;
        }
    }
    //Sleep( 0 );

/*
    U32 currentTime = GetTickCount();
    if( (currentTime - pr->time_last)>4000 )
    {
        float t1 = currentTime - pr->time_last;
        float t2 = currentTime - pr->time_start;
        float v = 1000.0*(pr->BlockRd-pr->BlockLast)*SizeBlockOfBytes/t1;
        v/=1024*1024;
        pr->VelocityCurrent=v;

        v = 1000.0*(pr->BlockRd)*SizeBlockOfBytes/t2;
        v/=1024*1024;
        pr->VelocityAvarage=v;
        pr->time_last = currentTime;
        pr->BlockLast = pr->BlockRd;
        pr->freeCycleZ=pr->freeCycle;
        pr->freeCycle=0;

        if(lowRange == 0)
            pr->testBuf.buf_check_sine_show();
        //pr->testBuf.buf_check_sine_calc_delta();
    }
    //Sleep(1);
*/

}


void WB_TestStrm::PrepareAdm( void )
{
/*
    U32 trd=trdNo;
    U32 id, id_mod, ver;
    BRDC_fprintf( stderr, "\nПодготовка тетрады\n" );


    id = pBrd->RegPeekInd( trd, 0x100 );
    id_mod = pBrd->RegPeekInd( trd, 0x101 );
    ver = pBrd->RegPeekInd( trd, 0x102 );

    //pBrd->RegPokeInd( trd, 0, 0x2038 );

    BRDC_fprintf( stderr, "\nТетрада %d  ID: 0x%.2X MOD: %d  VER: %d.%d \n\n",
            trd, id, id_mod, (ver>>8) & 0xFF, ver&0xFF );


    //if( fnameDDS )
    //	PrepareDDS();


    if( isMainTest )
        PrepareMain();


    BlockMode = DataType <<8;
    BlockMode |= DataFix <<7;

    if( isTestCtrl )
        PrepareTestCtrl();

    if( isAdmReg )
        PrepareAdmReg( fnameAdmReg );


    IsviStatus=0;
    IsviCnt=0;
    isIsvi=0;
    if( fnameIsvi )
    {
        IsviStatus=1;
        isIsvi=1;
    }

*/
}




//! Подготовка MAIN
void WB_TestStrm::PrepareMain( void )
{
/*
    if( 4==isTest )
    {
        BRDC_fprintf( stderr, "В тетраде MAIN установлен режим формирования двоично-инверсной последовательности\n" );
    } else
    {
        BRDC_fprintf( stderr, "В тетраде MAIN установлен режим формирования псевдослучайной последовательности\n" );
        pBrd->RegPokeInd( 0, 12, 1 );  // Регистр TEST_MODE[0]=1 - режим формирования псевдослучайной последовательности
    }
    pBrd->RegPokeInd( 0, 0, 2 );   // Сброс FIFO - перевод в начальное состояние
    Sleep( 1 );
    pBrd->RegPokeInd( 0, 0, 0 );
    Sleep( 1 );
*/
}

void WB_TestStrm::IsviStep( U32* ptr )
{
    unsigned ii;
    if( (1==IsviStatus) || (4==IsviStatus ) )
    {
        for( ii=0; ii<SizeBlockOfWords; ii++ ) bufIsvi[ii]=ptr[ii];
        IsviStatus++;
    }
}

void WB_TestStrm::WriteFlagSinc(int flg, int isNewParam)
{
    int fs = -1;
    int val[2];

    char fname[256];
    sprintf( fname, "%s.flg", fnameIsvi );

    while( fs==-1 )
    {
        fs = open( fname, O_RDWR|O_CREAT, 0666 );
        Sleep( 10 );
    }
    val[0] = flg;
    val[1] = isNewParam;
    write( fs, val, 8 );
    close( fs );
}

int  WB_TestStrm::ReadFlagSinc(void)
{
    int fs = -1;
    int flg;

    char fname[256];
    sprintf( fname, "%s.flg", fnameIsvi );

    while( fs==-1 )
    {
        fs = open( fname, O_RDWR|O_CREAT, 0666 );
        Sleep( 10 );
    }
    read( fs, &flg, 4 );
    close( fs );

    return flg;
}

void WB_TestStrm::WriteDataFile( U32 *pBuf, U32 sizew )
{
    char fname[256];
    sprintf( fname, "%s.bin", fnameIsvi );
    int     fl = open(fname, O_WRONLY|O_CREAT|O_TRUNC, 0666);

    if( fl==-1 )
    {
        return;
    }

    
    write( fl, pBuf, sizew*4 );

    write( fl, IsviHeaderStr, IsviHeaderLen );

    close( fl );
}


U32 WB_TestStrm::ExecuteIsvi( void )
{
    for( ; ; )
    {
        if( Terminate )
        {
            break;
        }

        int rr;
        switch( IsviStatus )
        {
        case 2: // Подготовка суффикса
            {
                IsviHeaderStr[0]=0;
                /*
					switch( IsviHeaderMode )
					{
						case 1:  SetFileHeaderDdc( SizeBlockOfWords, IsviHeaderStr ); break;
						case 2:  SetFileHeaderAdc( SizeBlockOfWords, IsviHeaderStr ); break;
					}
					*/
                IsviHeaderLen = 0; //strlen( IsviHeaderStr );
                WriteFlagSinc(0,0);
                WriteDataFile( bufIsvi, SizeBlockOfWords );
                WriteFlagSinc(0xffffffff,0xffffffff);

                IsviCnt++;
                IsviStatus=3;
            }
            break;

        case 3:
            {
                rr=ReadFlagSinc();
                if( 0==rr )
                    IsviStatus=4;

            }
            break;

        case 4:
            // Ожидание получения данных
            Sleep( 100 );
            break;

        case 5:
            {
                WriteDataFile( bufIsvi, SizeBlockOfWords );
                WriteFlagSinc(0xffffffff,0 );
                IsviStatus=3;
                IsviCnt++;
            }
            break;

        }

        Sleep( 100 );
    }
    IsviStatus=100;
    return 0;
}


#define TRD_CTRL 1

#define REG_MUX_CTRL  0x0F
#define REG_GEN_CNT1  0x1A
#define REG_GEN_CNT2  0x1B
#define REG_GEN_CTRL  0x1E
#define REG_GEN_SIZE  0x1F
#define TRD_DIO_IN    6
#define TRD_CTRL      1
//#define TRD_DIO_IN
//! Подготовка TEST_CTRL

void WB_TestStrm::PrepareTestCtrl( void )
{
    BRDC_fprintf( stderr, "\nПодготовка тетрады TEST_CTRL\n" );
/*
    BlockMode = DataType <<8;
    BlockMode |= DataFix <<7;

    if( !isFifoRdy )
        BlockMode |=0x1000;

    U32 block_mode=BlockMode;

    pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CTRL, 1 );

    //U32 mode0=pBrd->RegPeekInd( TRD_DIO_IN, 0 );
    // pBrd->RegPokeInd( TRD_DIO_IN, 0, 2 );

    Sleep( 1 );

    //pBrd->RegPokeInd( TRD_DIO_IN, 0, 0 );

    pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CTRL, 0 );

    pBrd->RegPokeInd( TRD_CTRL, REG_MUX_CTRL, 1 );

    U32  val=SizeBlockOfBytes/4096;

    pBrd->RegPokeInd( TRD_CTRL, REG_GEN_SIZE, val );

    if( block_mode & 0x80 )
    {
        BRDC_fprintf( stderr, "Используется сокращённая тестовая последовательность\r\n" );
    } else
    {
        BRDC_fprintf( stderr, "Используется полная тестовая последовательность\r\n" );
    }


    if( Cnt1 || Cnt2 )
    {
        pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CNT1, Cnt1 );
        pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CNT2, Cnt2 );
        float sp=1907.348632812 * (Cnt1-1)/(Cnt1+Cnt2-2);
        BRDC_fprintf( stderr, "Установлено ограничение скорости формирования потока:  %6.1f МБайт/с \r\n"
                "REG_CNT1=%d  REGH_CNT2=%d   \r\n", sp, Cnt1, Cnt2 );
        if( block_mode&0x1000 )
        {
            BRDC_fprintf( stderr, "Установлен режим без ожидания готовности FIFO\r\n\r\n" );
        } else
        {
            BRDC_fprintf( stderr, "Установлено ожидание готовности FIFO \r\n\r\n"        );
        }
    }  else
    {
        pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CNT1, 0 );
        pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CNT2, 0 );
        BRDC_fprintf( stderr, "Установлено формирование потока на максимальной скорости: 1907 МБайт/с \r\n"
                "Установлено ожидание готовности FIFO \r\n\r\n"        );
    }

*/
}

//! Запуск TestCtrl
void WB_TestStrm::StartTestCtrl( void )
{
/*
    U32 ctrl=0x20;
    ctrl|=BlockMode;
    if( Cnt1 || Cnt2 )
        ctrl|=0x40;

    if( !isFifoRdy )
        ctrl |=0x1000;
    //  ctrl&= ~0x1000;
    //BRDC_fprintf( stderr, "TEST_CTRL: REG_GEN_CTRL = 0x%.4X \r\n", ctrl );

    pBrd->RegPokeInd( TRD_CTRL, REG_GEN_CTRL, ctrl );  // Запуск DIO_IN

    //U32 mode0=pBrd->RegPeekInd( 6, 0 );
    //mode0 |=0x30;
    //pBrd->RegPokeInd( 6, 0, mode0 );		// Запуск DIO_IN
*/

}


//! Запись регистров из файла
void WB_TestStrm::PrepareAdmReg( char* fname )
{
    BRDC_fprintf( stderr, "\nУстановка регистров из файла %s\r\n\n", fname );
/*
    FILE *in = fopen( fname, "rt" );
    if( in==NULL )
    {
        throw( "Ошибка доступа к файлу " );
    }

    char str[256];
    U32 trd, reg, val;
    int ret;
    for( ; ; )
    {
        if( fgets( str, 200, in )==NULL )
            break;

        if( str[0]==';' )
            continue;

        ret=sscanf( str, "%i %i %i", &trd, &reg, &val );
        if( 3==ret )
        {
            BRDC_fprintf( stderr, "  TRD: %d  REG[0x%.2X]=0x%.4X \n", trd, reg, val );
            pBrd->RegPokeInd( trd, reg, val );
        }

    }
*/
    BRDC_fprintf( stderr, "\n\n" );
}

