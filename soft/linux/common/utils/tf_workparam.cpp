#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include "utypes.h"
//#include "useful.h"
#include "tf_workparam.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


//


TF_WorkParam::TF_WorkParam(void)
{

    max_item=0;
    memset( this, 0, sizeof( TF_WorkParam ) );

    SetDefault();


}

TF_WorkParam::~TF_WorkParam(void)
{
    U32 ii=0;

    // Освобождение памяти от строковых параметров
    for( ii=0; ii<max_item; ii++ )
    {
        if( array_cfg[ii].is_float==2 ) 
        {
            STR_CFG *cfg=array_cfg+ii;
            char **ptr=(char**)cfg->ptr;

            char *ps=*ptr;
            if( ps!=NULL )
                free( ps );
        }
    }
}

//! Установка параметров по умолчанию
void TF_WorkParam::SetDefault( void )
{

    U32 ii=0;

    // Освобождение памяти от строковых параметров
    for( ii=0; ii<max_item; ii++ )
    {
        if( array_cfg[ii].is_float==2 ) 
        {
            STR_CFG *cfg=array_cfg+ii;
            char **ptr=(char**)cfg->ptr;

            char *ps=*ptr;
            if( ps!=NULL )
                free( ps );
        }
    }


    //ZeroMemory( this, sizeof( TF_WorkParam ) );





    ii=0;
    /*
array_cfg[ii++]=STR_CFG(  0, "RGG_SideObservation", "1", (U32*)&st.Nav_LR_Side, "борт наблюдения (правый +1, левый -1)" );
array_cfg[ii++]=STR_CFG(  1, "lambda",		"0.0032",	(U32*)&st.lambda, "длина волны (м)" );
array_cfg[ii++]=STR_CFG(  2, "RliFileName",				"..\\gol\\bmp\\_A_4Kx16k.bmp",		(U32*)&pRliFileName, "имя файла с изображением для режима иммитации РЛИ " );
array_cfg[ii++]=STR_CFG(  3, "SYNTH_OBZOR_cutDoppler",  "1",	(U32*)(&st.cutDoppler), "cutDoppler" );
*/

    max_item=ii;


    /*

   { 
	   if( pPathVega==NULL )
	   {
		 pPathVega = (char*)malloc( 1024 );
	   }

		int ret=GetEnvironmentVariableA(
			"VEGA",
			pPathVega,
			1020
			);
		char buf[1024];
		if( ret==0 )
			sprintf( pPathVega, "c:\\vega" );

		sprintf( buf, "%s\\temp\\obzor\\", pPathVega );


	strcpy( st.output_dir, buf );                        // директория файлов вычислений(server)
	strcpy( st.output_dir_loc, buf );                    // директория файлов вычислений(client)

	strcpy( sk.output_dir, buf );                        // директория файлов вычислений(server)
	strcpy( sk.output_dir_loc, buf );                    // директория файлов вычислений(client)

	//free( pPathVega );
   };
*/
    {
	char str[1024];
        for( unsigned ii=0; ii<max_item; ii++ )
	{
            sprintf( str, "%s  %s", array_cfg[ii].name, array_cfg[ii].def );
            GetParamFromStr( str );
	}


    }


}


//! Получение параметров из файла инициализации
void TF_WorkParam::GetParamFromFile( BRDCHAR* fname )
{

    FILE *in;

    in=BRDC_fopen( fname, _BRDC("rt") );
    if( in==NULL ) {
        //log_out( "Не могу открыть файл конфигурации %s\r\n", fname );
        BRDC_fprintf( stderr, _BRDC("Can't open configuration file: %s\r\n"), fname );
        return;
    }
    //log_out( "\r\nЧтение параметров из файла %s\r\n\r\n", fname );
    BRDC_fprintf( stderr, _BRDC("\r\nReading parameters from file: %s\r\n\r\n"), fname );

    char str[512];

    for( ; ; ) {
        if( fgets( str, 510, in )==NULL ) {
            break;
        }
        str[510]=0;
        GetParamFromStr( str );
    }
    log_out( "\r\n" );
    fclose( in );

}

//! Получение параметра из строки
U32 TF_WorkParam::GetParamFromStr( char* str )
{
    char name[256], val[256];
    U32 ii;
    int ret;
    U32 len=strlen( str )+1;
    ret=sscanf( str, "%128s %128s", name, val );
    if( ret==2 ) {
        for( ii=0; ii<max_item; ii++ ) {
            if( strcmp( array_cfg[ii].name, name )==0 ) {
                if( array_cfg[ii].is_float==0 ) {
                    sscanf( val, "%i", array_cfg[ii].ptr );
                    // scr.log_out( "%-20s  %d\r\n", array_cfg[ii].name, *(array_cfg[ii].ptr) );
                } else if( array_cfg[ii].is_float==1 ) {
                    sscanf( val, "%g", (float*)array_cfg[ii].ptr );
                    // scr.log_out( "%-20s  %g\r\n", array_cfg[ii].name, *((float*)(array_cfg[ii].ptr)) );
                } else if( array_cfg[ii].is_float==2 ) {
                    //*((CString*)array_cfg[ii].ptr)=val;
                    {

                        STR_CFG *cfg=array_cfg+ii;
                        char **ptr=(char**)cfg->ptr;

                        char *ps=*ptr;
                        if( ps!=NULL )
                            free( ps );
                        ps = (char*)malloc( 128 );
                        *(cfg->ptr)=((size_t)ps);
                        sprintf( ps, "%s", val );
                        //scr.log_out("%-20s  %s\r\n", array_cfg[ii].name, ps );

                    }
                } else if( array_cfg[ii].is_float==3 ) {
                    U32 v;
                    bool *p=(bool*)(array_cfg[ii].ptr);
                    sscanf( val, "%d", &v );
                    if( v ) {
                        *p=true;
                        //scr.log_out( "%-20s  true\r\n", array_cfg[ii].name );
                    } else {
                        *p=false;
                        //scr.log_out( "%-20s  false\r\n", array_cfg[ii].name );
                    }
                }
                break;
            }
        }
    }
    return len;
}


//! Расчёт параметров
void TF_WorkParam::CalculateParams( void )
{
    ShowParam();
}


//! Сохранение параметров в памяти
U32 TF_WorkParam::PutParamToMemory( char* ptr, U32 max_size )
{
    char str[256];
    int len;
    int total=0;
    unsigned ii;
    STR_CFG *cfg;

    *((U32*)ptr)=max_item;
    total=4;

    for( ii=0; ii<max_item; ii++ )
    {
        cfg=array_cfg+ii;
        str[0]=0;
        switch( cfg->is_float )
        {
        case 0: sprintf( str, "%s  %d \r\n", cfg->name, *(cfg->ptr) ); break;
        case 1:
            {
                float* v=(float*)(cfg->ptr);
                sprintf( str, "%s  %g \r\n", cfg->name, *v ); break;
            }
            break;
        case 2:
            {
                if( *(cfg->ptr)==0 )
                {
                    sprintf( str, "%s  \r\n", cfg->name );
                } else
                {
                    sprintf( str, "%s  %s \r\n", cfg->name,(char*)(*cfg->ptr) );
                }

            }
            break;

        }
        len=strlen( str )+1;
        if( (total+len)<(int)max_size )
        {
            strcpy( ptr+total, str );
            total+=len;
        }
    }
    return total;
}

//! Получение параметров из памяти
void TF_WorkParam::GetParamFromMemory( char* ptr )
{
    char *src=ptr;
    U32 len;
    U32 n;
    n=*((U32*)ptr);
    unsigned ii;
    int total=4;

    for( ii=0; ii<n; ii++ )
    {
        src=ptr+total;
        len=GetParamFromStr( src );
        total+=len;
    }

}


//! Отображение параметров
void TF_WorkParam::ShowParam( void )
{
	U32 ii;
	STR_CFG  *item;
        log_out( "\r\n\r\n\r\nParameters value:\r\n\r\n" );
	for( ii=0; ii<max_item; ii++ )
	{
		item=array_cfg+ii;
        if( item->is_float==2 )
		{

			char **ptr=(char**)item->ptr;
			char *ps=*ptr;
			log_out( "%s  %s\r\n", item->name, ps );
		} else if( item->is_float==0 )
		{
			U32 ps=*((U32*)item->ptr);
			log_out( "%s  %d\r\n", item->name, ps );
		} else if( item->is_float==1 )
		{
			float ps=*((float*)item->ptr);
			log_out( "%s  %g\r\n", item->name, ps );
		} else if( item->is_float==3 )
		{
			U32 ps=*((U32*)item->ptr);
                        if( ps ) log_out( "%s  %s\r\n", item->name, "true" );
                        else log_out( "%s  %s\r\n", item->name, "false" );
		}
	}
	log_out( "\r\n\r\n\r\n" );

}


void TF_WorkParam::log_out( const char* format, ... )
{

		char buffer[2048];

		va_list marker;
		va_start( marker, format );
		vsprintf( buffer, format, marker );
		va_end( marker );

                BRDC_fprintf( stderr, "%s", buffer );

}
