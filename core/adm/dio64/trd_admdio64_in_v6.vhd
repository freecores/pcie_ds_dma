---------------------------------------------------------------------------------------------------
--
-- Title       : trd_admdio64_in_v6
-- Author      : Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.2
---------------------------------------------------------------------------------------------------
--
-- Description : 	���� ��������� ������
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.2  17.07.2007
--                ��������� ������ ��������� MODE0, MODE1, MODE2, MODE3
--				  �������� ����� �������� ����
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.1  18.08.2006
--                ������������ FIFO cl_fifo1024x64_v2                          
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



	

library work;
use work.cl_chn_v3_pkg.all;				
use work.adm2_pkg.all;

package trd_admdio64_in_v6_pkg is
	
constant  ID_DIO_IN			: std_logic_vector( 15 downto 0 ):=x"0013"; -- ������������� �������
constant  ID_MODE_DIO_IN	: std_logic_vector( 15 downto 0 ):=x"0006"; -- ����������� �������
constant  VER_DIO_IN		: std_logic_vector( 15 downto 0 ):=x"0102";	-- ������ �������
constant  RES_DIO_IN		: std_logic_vector( 15 downto 0 ):=x"0010";	-- ������� �������
constant  FIFO_DIO_IN		: std_logic_vector( 15 downto 0 ):=x"0400"; -- ������ FIFO
constant  FTYPE_DIO_IN	 	: std_logic_vector( 15 downto 0 ):=x"0040"; -- ������ FIFO

component trd_admdio64_in_v6 is 
	port(		
		-- GLOBAL
		reset				: in std_logic;		-- 0 - �����
		clk					: in std_logic;		-- �������� �������
		
		-- ���������� ��������
		data_out			: out std_logic_vector( 63 downto 0 ); -- ���� ������ DATA, ����� ����� �����
		data_out2			: out std_logic_vector( 63 downto 0 ); -- ���� ������ DATA, ����� ��� ������
		cmd_data_in			: in std_logic_vector( 15 downto 0 ); -- ���� ������ CMD_DATA
		cmd					: in bl_cmd;		-- ������� ����������
		
		cmd_data_out		: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� ����� �����
		cmd_data_out2		: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� ��� ������
		
		bx_irq				: out std_logic;  	-- 1 - ���������� �� �������
		bx_drq				: out bl_drq;		-- ���������� DMA
		
		mode0				: out std_logic_vector( 15 downto 0 );	-- ������� MODE0
		mode1				: out std_logic_vector( 15 downto 0 );	-- ������� MODE1
		mode2				: out std_logic_vector( 15 downto 0 );	-- ������� MODE2
		mode3				: out std_logic_vector( 15 downto 0 );	-- ������� MODE3
		
		fifo_rst_in			: in  std_logic:='1';			-- 0 - ����� FIFO (����)
		fifo_rst			: out std_logic; 				-- 0 - ����� FIFO (�����)
		
		start				: out std_logic;	--  1 - ���������� ������ (MODE0[5])
		
		-- ������ FIFO					
		data_in             : in std_logic_vector(63 downto 0);	-- ������ ��� ������ � FIFO
		data_wr             : in std_logic;		-- 1 - ����� ������
		flag_wr				: out bl_fifo_flag;	-- ����� FIFO, ��������� � clk_wr
		flag_rd				: out bl_fifo_flag;	-- ����� FIFO, ��������� � clk
		clk_wr 				: in std_logic; 	-- �������� ������� ������ � FIFO
		fifo_cnt_wr			: out std_logic_vector( 9 downto 0 ); -- ����� ���� � FIFO, ��������� � clk_wr		 
		fifo_cnt_rd			: out std_logic_vector( 9 downto 0 )  -- ����� ���� � FIFO, ��������� � clk		 
		
		--------------------------------------------
	    );
end component;

end trd_admdio64_in_v6_pkg;

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.cl_chn_v3_pkg.all;				
use work.adm2_pkg.all;
use work.cl_fifo1024x65_v5_pkg.all;

entity trd_admdio64_in_v6 is 
	port(		
		-- GLOBAL
		reset				: in std_logic;		-- 0 - �����
		clk					: in std_logic;		-- �������� �������
		
		-- ���������� ��������
		data_out			: out std_logic_vector( 63 downto 0 ); -- ���� ������ DATA, ����� ����� �����
		data_out2			: out std_logic_vector( 63 downto 0 ); -- ���� ������ DATA, ����� ��� ������
		cmd_data_in			: in std_logic_vector( 15 downto 0 ); -- ���� ������ CMD_DATA
		cmd					: in bl_cmd;		-- ������� ����������
		
		cmd_data_out		: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� ����� �����
		cmd_data_out2		: out std_logic_vector( 15 downto 0 ); -- ������ ���������, ����� ��� ������

		bx_irq				: out std_logic;  	-- 1 - ���������� �� �������
		bx_drq				: out bl_drq;		-- ���������� DMA
		
		mode0				: out std_logic_vector( 15 downto 0 );	-- ������� MODE0
		mode1				: out std_logic_vector( 15 downto 0 );	-- ������� MODE1
		mode2				: out std_logic_vector( 15 downto 0 );	-- ������� MODE2
		mode3				: out std_logic_vector( 15 downto 0 );	-- ������� MODE3
		
		fifo_rst_in			: in  std_logic:='1';			-- 0 - ����� FIFO (����)
		fifo_rst			: out std_logic; 				-- 0 - ����� FIFO (�����)
		
		start				: out std_logic;	--  1 - ���������� ������ (MODE0[5])
		
		-- ������ FIFO					
		data_in             : in std_logic_vector(63 downto 0);	-- ������ ��� ������ � FIFO
		data_wr             : in std_logic;		-- 1 - ����� ������
		flag_wr				: out bl_fifo_flag;	-- ����� FIFO, ��������� � clk_wr
		flag_rd				: out bl_fifo_flag;	-- ����� FIFO, ��������� � clk
		clk_wr 				: in std_logic; 	-- �������� ������� ������ � FIFO
		fifo_cnt_wr			: out std_logic_vector( 9 downto 0 ); -- ����� ���� � FIFO, ��������� � clk_wr		 
		fifo_cnt_rd			: out std_logic_vector( 9 downto 0 )  -- ����� ���� � FIFO, ��������� � clk		 
		
		--------------------------------------------
	    );
end trd_admdio64_in_v6;
														 
architecture trd_admdio64_in_v6 of trd_admdio64_in_v6 is 


signal rst,fifo_rst0		: std_logic;
signal flag_rdi		        : bl_fifo_flag;	
signal cmode0				: std_logic_vector(15 downto 0);
signal status,sflag			: std_logic_vector(15 downto 0);  
signal do					: std_logic_vector(63 downto 0);
signal fifo_rst1			: std_logic;

begin		   

xstatus: ctrl_buft16 port map( 
	t => cmd.status_cs,
	i =>  status,
	o => cmd_data_out );

cmd_data_out2 <= status;	

xdata: ctrl_buft64 port map(
	t => cmd.data_oe,
	i  => do,
	o => data_out );	
	
data_out2 <= do;	
	
chn: cl_chn_v3 
	generic map(					 
	  -- 2 - out - ��� ������� ������
	  -- 1 - in  - ��� ������� �����
	  chn_type 			=> 1
	)
	port map (
		reset 			=> reset,
		clk 			=> clk,
		-- �����
		cmd_rdy 		=> '1',
		rdy				=> flag_rdi.ef,
		fifo_flag		=> flag_rdi,
		-- �������	
		data_in			=> cmd_data_in,
		cmd				=> cmd,
		bx_irq			=> bx_irq,
		bx_drq			=> bx_drq,
		status			=> status,
		-- ����������
		mode0			=> cmode0,
		mode1			=> mode1,
		mode2			=> mode2,
		mode3			=> mode3,
		sflag			=> sflag,
		rst				=> rst,
		fifo_rst		=> fifo_rst0
	);

x_fifo: cl_fifo1024x65_v5
	port map(				
	 	-- �����
		 reset 			=> fifo_rst1,
	 	-- ������
		 clk_wr 		=> clk_wr,
		 data_in 		=> data_in,
		 data_en		=> data_wr, 
		 flag_wr		=> flag_wr,
		 --cnt_wr			=> fifo_cnt_wr,
		 
		 -- ������
		 clk_rd 		=> clk,
		 data_out 		=> do,
		 data_cs		=> cmd.data_cs,
		 flag_rd		=> flag_rdi
		 --cnt_rd			=> fifo_cnt_rd
		 
	    );	   	
		
flag_rd <= flag_rdi;

fifo_rst1 <= fifo_rst0 and fifo_rst_in;		
fifo_rst<=fifo_rst1;		

start <= cmode0(5);
mode0 <= cmode0;

end trd_admdio64_in_v6;
