---------------------------------------------------------------------------------------------------
--
-- Title       : trd_admdio64_out_v1
-- Author      : Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.3
--
---------------------------------------------------------------------------------------------------
--
-- Description :  ������� ��������� �����.
--				  ����������� 1 - ������������ FIFO 1024x64
--				
---------------------------------------------------------------------------------------------------
--
--	������ 1.3	18.07.2007	Dmitry Smekhov
--				��������� ������ cmd_data_out2, start, bx_clk
--				����� ���� b_clk
--
---------------------------------------------------------------------------------------------------
--
--	������ 1.2	18.08.2006	Dmitry Smekhov
--				������������ cl_fifo1024x64_v2
--
---------------------------------------------------------------------------------------------------
--
--	������ 1.1	07.09.2005	Dmitry Smekhov
--				�������� ����� fifo_cnt - ����� ���� � FIFO	
--				� ������ ��������� MODE0, MODE1, MODE2, MODE3
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

								   
	

library work;
use work.cl_chn_v3_pkg.all;				
use work.adm2_pkg.all;

package trd_admdio64_out_v4_pkg is
	
constant  ID_DIO_OUT		: std_logic_vector( 15 downto 0 ):=x"0012"; -- ������������� �������
constant  ID_MODE_DIO_OUT	: std_logic_vector( 15 downto 0 ):=x"0001"; -- ����������� �������
constant  VER_DIO_OUT		: std_logic_vector( 15 downto 0 ):=x"0103";	-- ������ �������
constant  RES_DIO_OUT		: std_logic_vector( 15 downto 0 ):=x"0020";	-- ������� �������
constant  FIFO_DIO_OUT		: std_logic_vector( 15 downto 0 ):=x"0400"; -- ������ FIFO
constant  FTYPE_DIO_OUT 	: std_logic_vector( 15 downto 0 ):=x"0040"; -- ������ FIFO

component trd_admdio64_out_v4 is 
	port(		
	
		-- GLOBAL
		reset			: in std_logic;		-- 0 - �����
		clk				: in std_logic;		-- �������� �������
		
		-- ���������� ��������
		data_in			: in std_logic_vector( 63 downto 0 ); -- ���� ������ DATA
		cmd_data_in		: in std_logic_vector( 15 downto 0 ); -- ���� ������ CMD_DATA
		cmd				: in bl_cmd;		-- ������� ����������
		
		cmd_data_out	: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� �����
		cmd_data_out2	: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ��� ������
		
		bx_irq			: out std_logic;  	-- 1 - ���������� �� �������
		bx_drq			: out bl_drq;		-- ���������� DMA	  
		
		mode0			: out std_logic_vector( 15 downto 0 );	-- ������� MODE0
		mode1			: out std_logic_vector( 15 downto 0 );	-- ������� MODE1
		mode2			: out std_logic_vector( 15 downto 0 );	-- ������� MODE2
		mode3			: out std_logic_vector( 15 downto 0 );	-- ������� MODE3
		
		fifo_rst		: out std_logic; 	-- 0 - ����� FIFO
		start			: out std_logic;	--  1 - ���������� ������ (MODE0[5])
		
		-- ������ �� FIFO
		data_out		: out std_logic_vector(63 downto 0);	-- ���� ������ FIFO
		data_cs         : in std_logic;							-- 0 - ������ ������
		flag_rd         : out bl_fifo_flag;						-- ����� FIFO
		clk_rd          : in std_logic;	   						-- �������� ������� ������ ������
		fifo_cnt		: out std_logic_vector( 12 downto 0 );	-- ����� ���� � FIFO
		
		-- �������� ������ -- 
		test			: out std_logic_vector(7 downto 0)		
		--------------------------------------------
	    );
end component;

end trd_admdio64_out_v4_pkg;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim;
use unisim.vcomponents.all;

library work;
use work.cl_chn_v4_pkg.all;				
use work.adm2_pkg.all;
use work.cl_fifo1024x65_v5_pkg.all;

entity trd_admdio64_out_v4 is 
	port(		
	
		-- GLOBAL
		reset			: in std_logic;		-- 0 - �����
		clk				: in std_logic;		-- �������� �������
		
		-- ���������� ��������
		data_in			: in std_logic_vector( 63 downto 0 ); -- ���� ������ DATA
		cmd_data_in		: in std_logic_vector( 15 downto 0 ); -- ���� ������ CMD_DATA
		cmd				: in bl_cmd;		-- ������� ����������
		
		cmd_data_out	: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� �����
		cmd_data_out2	: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ��� ������
		
		bx_irq			: out std_logic;  	-- 1 - ���������� �� �������
		bx_drq			: out bl_drq;		-- ���������� DMA	  
		
		mode0			: out std_logic_vector( 15 downto 0 );	-- ������� MODE0
		mode1			: out std_logic_vector( 15 downto 0 );	-- ������� MODE1
		mode2			: out std_logic_vector( 15 downto 0 );	-- ������� MODE2
		mode3			: out std_logic_vector( 15 downto 0 );	-- ������� MODE3
		
		fifo_rst		: out std_logic; 	-- 0 - ����� FIFO
		start			: out std_logic;	--  1 - ���������� ������ (MODE0[5])
		
		-- ������ �� FIFO
		data_out		: out std_logic_vector(63 downto 0);	-- ���� ������ FIFO
		data_cs         : in std_logic;							-- 0 - ������ ������
		flag_rd         : out bl_fifo_flag;						-- ����� FIFO
		clk_rd          : in std_logic;	   						-- �������� ������� ������ ������
		fifo_cnt		: out std_logic_vector( 12 downto 0 );	-- ����� ���� � FIFO
		
		-- �������� ������ -- 
		test			: out std_logic_vector(7 downto 0)		
		--------------------------------------------
	    );
end trd_admdio64_out_v4;
														 

architecture trd_admdio64_out_v4 of trd_admdio64_out_v4 is 


component ctrl_start_v3 is		
	port( 					
	
		reset	: in std_logic;							-- 0 - �����
		mode0	: in std_logic_vector( 15 downto 0 ); 	-- ������� MODE0
		stmode	: in std_logic_vector( 15 downto 0 );	-- ������� STMODE
		fmode	: in std_logic_vector(  5 downto 0 ); 	-- ������� FMODE
		fdiv	: in std_logic_vector( 15 downto 0 ); 	-- ������� FDIV
		fdiv_we	: in std_logic;							-- 1 - ������ � ������� FDIV
		
		cnt0	: in std_logic_vector( 15 downto 0 ); 	-- ������� ��������� ��������
		cnt1	: in std_logic_vector( 15 downto 0 ); 	-- ������� ����������� ����
		cnt2	: in std_logic_vector( 15 downto 0 ); 	-- ������� ������������ ����
		
		b_clk	: in std_logic_vector( 15 downto 0 ); 	-- ����� �������� �������
		b_start	: in std_logic_vector( 15 downto 0 ); 	-- ����� ������� START
		
		bx_clk	: out std_logic; 			-- ����� �������� �������, ����������
		bi_clk	: out std_logic;			-- ����� �������� �������, ��������� bx_clk
		bx_start		: out std_logic;	-- ����� ������� start ���������� � bx_clk
		bx_start_a		: out std_logic;	-- ����������� ����� ������� start 
		bx_start_sync	: out std_logic; 	-- ������� �������������
		
		goe0	: out std_logic;	  		-- ��������� ���������� 60MHz
		goe1	: out std_logic				-- ��������� ���������� 50MHz
		
	);
	
end  component; 

component cl_fifo1024x64_v3 is
	port(				
	 	-- �����
		 reset 				: in std_logic;		-- 0 - �����
		 
	 	-- ������
		 clk_wr 			: in std_logic;		-- �������� �������
		 data_in 			: in std_logic_vector(63 downto 0); -- ������
		 data_en			: in std_logic;		-- 1 - ������ � fifo
		 flag_wr			: out bl_fifo_flag;	-- ����� fifo, ��������� � clk_wr
		 cnt_wr				: out std_logic_vector( 9 downto 0 ); -- ������� ����
		 
		 -- ������
		 clk_rd 			: in std_logic;		-- �������� �������
		 data_out 			: out std_logic_vector(63 downto 0);   -- ������
		 data_cs			: in std_logic;		-- 0 - ������ �� fifo
		 flag_rd			: out bl_fifo_flag;	-- ����� fifo, ��������� � clk_rd
		 cnt_rd				: out std_logic_vector( 9 downto 0 ); -- ������� ���� 
		 
		 cnt_pae			: in std_logic_vector(12 downto 0);	-- ����� ����� FIFO ��� ������� ��� ��� ����� ������
		 cnt_paf			: in std_logic_vector(12 downto 0);	-- ����� ����� FIFO ��� ������� ��� ����� ������
		 rt_mode			: in std_logic		-- 1 - retransmit  
		 
	    );
end component;

signal rst,fifo_rst0		: std_logic;
signal flag_wr       		: bl_fifo_flag;	
signal c_mode0				: std_logic_vector(15 downto 0);
signal fdiv,stmode,fmode	: std_logic_vector(15 downto 0);
signal status				: std_logic_vector(15 downto 0);
signal cnt0,cnt1,cnt2		: std_logic_vector(15 downto 0);
signal fdiv_we				: std_logic;   
signal clk_trd,start_trd	: std_logic; 
signal clk_d,cw,cw0			: std_logic;
signal cnt_wr			    : std_logic_vector( 9 downto 0 );
signal cnt_rd			    : std_logic_vector( 9 downto 0 );	  
signal	sflag_pae			: std_logic_vector( 15 downto 0 );
signal	sflag_paf			: std_logic_vector( 15 downto 0 );


begin		   
	
xstatus: ctrl_buft16 port map( 
	t => cmd.status_cs,
	i =>  status,
	o => cmd_data_out );
	
cmd_data_out2 <= status;	
	
chn: cl_chn_v4 
	generic map(					 
	  -- 2 - out - ��� ������� ������
	  -- 1 - in  - ��� ������� �����
	  chn_type 			=> 2
	)

	port map (
		reset 			=> reset,
		clk 			=> clk,
		-- �����
		cmd_rdy 		=> '1',
		rdy				=> '1', --flag_wr.hf,
		fifo_flag		=> flag_wr,
		--st9				=> ready,
		-- �������	
		data_in			=> cmd_data_in,
		cmd				=> cmd,
		bx_irq			=> bx_irq,
		bx_drq			=> bx_drq,
		status			=> status,
		-- ����������
		mode0			=> c_mode0,	 
		mode1			=> mode1,
		mode2			=> mode2,
		mode3			=> mode3,
		sflag_pae		=> sflag_pae,
		sflag_paf		=> sflag_paf,
		fdiv			=> fdiv,	  
		fdiv_we 		=> fdiv_we,
		fmode			=> fmode,
		stmode			=> stmode,
		rst				=> rst,
		fifo_rst		=> fifo_rst0
	);

		
x_fifo: cl_fifo1024x65_v5
	port map(				
	 	-- �����
		 reset 			=> fifo_rst0,
	 	-- ������
		 clk_wr 		=> clk,
		 data_in 		=> data_in,
		 data_en		=> cmd.data_we,
		 flag_wr		=> flag_wr,
		 --cnt_wr         => cnt_wr,
		 -- ������
		 clk_rd 		=> clk_rd,
		 data_out 		=> data_out,
		 data_cs		=> data_cs,
		 flag_rd		=> flag_rd
		 --cnt_rd			=> cnt_rd
		 
	    );	 

fifo_rst<=fifo_rst0;

fifo_cnt( 9 downto 0 ) <= cnt_rd;
fifo_cnt( 12 downto 10 ) <= (others=>'0');

mode0 <= c_mode0;
start <= c_mode0(5);

end trd_admdio64_out_v4;


