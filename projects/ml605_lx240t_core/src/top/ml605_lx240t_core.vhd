-------------------------------------------------------------------------------
--
-- Title       : ml605_lx240t_core
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 	�������� ���� PCI Express �� ������ AMBPEX5 
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;	   

package ml605_lx240t_core_pkg is

component ml605_lx240t_core is 
	generic (
		is_simulation	: integer:=0	-- 0 - ������, 1 - ������������� ADM
	);
	port(
		---- PCI-Express ----
	  	pci_exp_txp         : out std_logic_vector(3 downto 0);
	  	pci_exp_txn         : out std_logic_vector(3 downto 0);
	  	pci_exp_rxp         : in std_logic_vector(3 downto 0);
	  	pci_exp_rxn         : in std_logic_vector(3 downto 0);
	
	  	sys_clk_p           : in std_logic;
	  	sys_clk_n           : in std_logic;
	  	sys_reset_n         : in std_logic;						   
		
		---- ���������� ----
		gpio_led0			: out std_logic;
		gpio_led1			: out std_logic; 
		gpio_led2			: out std_logic; 
		gpio_led3			: out std_logic;
		gpio_led4			: out std_logic 
		
	);
end component;

end package;

library ieee;
use ieee.std_logic_1164.all;	  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library unisim;
use unisim.vcomponents.all;


use work.adm2_pkg.all;
use work.cl_ml605_pkg.all;				
use work.trd_main_v8_pkg.all;
use work.trd_pio_std_v4_pkg.all;
use work.trd_admdio64_out_v4_pkg.all;
use work.trd_admdio64_in_v6_pkg.all;
use work.trd_test_ctrl_m1_pkg.all;


entity ml605_lx240t_core is 
	generic (
		is_simulation	: integer:=0	-- 0 - ������, 1 - ������������� ADM
	);
	port(
		---- PCI-Express ----
	  	pci_exp_txp         : out std_logic_vector(3 downto 0);
	  	pci_exp_txn         : out std_logic_vector(3 downto 0);
	  	pci_exp_rxp         : in std_logic_vector(3 downto 0);
	  	pci_exp_rxn         : in std_logic_vector(3 downto 0);
	
	  	sys_clk_p           : in std_logic;
	  	sys_clk_n           : in std_logic;
	  	sys_reset_n         : in std_logic;					   
		
		---- ���������� ----
		gpio_led0			: out std_logic;
		gpio_led1			: out std_logic; 
		gpio_led2			: out std_logic; 
		gpio_led3			: out std_logic; 
		gpio_led4			: out std_logic 

	);
end ml605_lx240t_core;


architecture ml605_lx240t_core of ml605_lx240t_core is
 


---- �������� ������� ���������� ���� ----
signal	clk				: std_logic;
	
---- 0 - ����� ��� ������� MAIN ----
signal	reset_main		: std_logic;
	
---- 0 - ����� ��� ���� ������ ����� MAIN ----
signal	reset			: std_logic;
	
---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----
signal trd_host_adr		: std_logic_vector( 31 downto 0 ):=(others=>'0');		 

---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----
signal trd_host_data	: std_logic_array_16x64;	

---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
signal trd_host_cmd_data	: std_logic_array_16x16;

		---- ������ ���������� ��� ������ ������� ----
signal trd_host_cmd	    : std_logic_array_16xbl_cmd;

---- ������ ������� DATA �� ������ ������� ----
signal trd_data			: std_logic_array_16x64:=(others=>(others=>'0'));

---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
signal trd_cmd_data		: std_logic_array_16x16:=(others=>(others=>'1'));

---- ������� DMA �� ������ �������
signal trd_drq			: std_logic_array_16xbl_drq:=(others=>(others=>'0'));

---- ������� ����������� �� ������ ������� ----
signal trd_irq			: std_logic_array_16xbl_irq:=(others=>'0');

---- ����� FIFO �� ������ ������� ----
signal trd_reset_fifo	: std_logic_array_16xbl_reset_fifo:=(others=>'0');

---- ������� DMA �� ������� MAIN (����� �������������) ----
signal trd_main_drq		: std_logic_array_16xbl_drq:=(others=>(others=>'0'));

---- ������� ����������� �� ������� MAIN (����� �������������) ----
signal trd_main_irq		: std_logic_array_16xbl_irq:=(others=>'0');

---- �������� ���������� DMA ----
signal trd_main_sel_drq	: std_logic_array_16x6:=(others=>(others=>'0'));

signal	test_mode		: std_logic;

---- ������ ���������� ��� ������ ������� ----
signal trd_trd_cmd	    : std_logic_array_16xbl_cmd;

---- ����� FIFO ----
signal trd_flag_rd	    : std_logic_array_16xbl_fifo_flag;


signal	di_mode1		: std_logic_vector( 15 downto 0 );
signal	di_data			: std_logic_vector( 63 downto 0 );
signal	di_data_we		: std_logic;
signal	di_flag_wr		: bl_fifo_flag;
signal	di_start		: std_logic;	  
signal	di_fifo_rst		: std_logic;
signal	di_clk			: std_logic;

signal	do_mode1		: std_logic_vector( 15 downto 0 );
signal	do_data			: std_logic_vector( 63 downto 0 );
signal	do_data_cs		: std_logic;
signal	do_flag_rd		: bl_fifo_flag;		 
signal	do_start		: std_logic;
signal	do_fifo_rst		: std_logic;
signal	do_clk			: std_logic;

signal	clk200			: std_logic;
signal	freq0			: std_logic;
signal	freq1			: std_logic;
signal	freq2			: std_logic;

signal	led_h1			: std_logic;
signal	led_h2			: std_logic;
signal	led_h3			: std_logic;
signal	led_h4			: std_logic;

signal	led_h1_p		: std_logic;
signal	led_h2_p		: std_logic;
signal	led_h3_p		: std_logic;
signal	led_h4_p		: std_logic;


signal	tp1				: std_logic;
signal	tp2				: std_logic;
signal	tp3				: std_logic;	

signal	px				: std_logic_vector( 3 downto 1 );

signal	clk30k			: std_logic;

----------------- ��������� ----------------------------------------
constant rom_main:  bl_trd_rom:=
(  
	0=>ID_MAIN, 			-- ������������� �������
	1=>ID_MODE_MAIN,		-- ����������� �������
	2=>VER_MAIN,  			-- ������ �������
	3=>RES_MAIN,  			-- ������� �������
	4=>FIFO_MAIN, 			-- ������ FIFO, ������������ FIFO 256x64
	5=>FTYPE_MAIN, 			-- ��� FIFO
	6=>x"0100",  			-- ����������� �������
	7=>x"0001", 			-- ����� ����������
    8=>x"4953", 			-- ��������� ���� ADM
	9=>x"0200", 			-- ������ ADM
	10=>x"0100", 			-- ������ �������� ����
	11=>x"0000",			-- ����������� �������� ����
	12=>"0000000011000011", -- ������������ �������
	13=>x"0000",			-- ������� ����
	14=>x"0000",			-- �� ������������
	15=>x"0000",			-- �� ������������
	16=>x"5507",			-- ������������� �������� ������
	17=>x"0200",			-- ������ �������� ������
	18=>x"0000",			-- ������������� ���������
	19=>x"0000",			-- ������ ���������
	20=>x"0107",			-- ����� ������ ��������
	31 downto 21 => x"0000"	);	


constant rom_dio_in:  bl_trd_rom:=
(  
	0=>ID_DIO_IN,			-- ������������� ������� 
	1=>ID_MODE_DIO_IN,		-- ����������� �������
	2=>VER_DIO_IN,			-- ������ �������
	3=>RES_DIO_IN,			-- ������� �������
	4=>FIFO_DIO_IN,			-- ������ FIFO
	5=>FTYPE_DIO_IN, 		-- ��� FIFO
	6=>x"010D",				-- ����������� �������
	7=>x"0001", 			-- ����� ����������
	31 downto 8 => x"0000");-- ������
	
constant rom_dio_out:  bl_trd_rom:=
(  
	0=>ID_DIO_OUT,			-- ������������� ������� 
	1=>ID_MODE_DIO_OUT,		-- ����������� �������
	2=>VER_DIO_OUT,			-- ������ �������				 			 
	3=>RES_DIO_OUT,			-- ������� �������
	4=>FIFO_DIO_OUT,		-- ������ FIFO
	5=>FTYPE_DIO_OUT, 		-- ��� FIFO
	6=>x"0C01",				-- ����������� �������
	7=>x"0001", 			-- ����� ����������
	31 downto 8 => x"0000");-- ������		
		
		 
constant rom_test_ctrl:  bl_trd_rom:=
(  
	0=>ID_TEST,				-- ������������� ������� 
	1=>ID_MODE_TEST,		-- ����������� �������
	2=>VER_TEST,			-- ������ �������
	3=>RES_TEST,			-- ������� �������
	4=>FIFO_TEST,			-- ������ FIFO
	5=>FTYPE_TEST, 			-- ��� FIFO
	6=>x"0000",				-- ����������� �������
	7=>x"0001", 			-- ����� ����������
	31 downto 8 => x"0000");-- ������		


constant trd_rom	: std_logic_array_16xbl_trd_rom	:=
(
	0 => rom_main,
	1 => rom_test_ctrl,
	2 => rom_empty,
	3 => rom_empty,
	4 => rom_empty,
	5 => rom_empty,
	6 => rom_dio_in,
	7 => rom_dio_out,
	others=> rom_empty 	);

begin
	
xled0:	obuf_s_16 port map( gpio_led0, '1' );	
xled1:	obuf_s_16 port map( gpio_led1, led_h1_p );
xled2:	obuf_s_16 port map( gpio_led2, led_h2_p );
xled3:	obuf_s_16 port map( gpio_led3, led_h3_p );
xled4:	obuf_s_16 port map( gpio_led4, led_h4_p );

led_h1_p  <= not led_h1;
led_h2_p  <= not led_h2;
led_h3_p  <= not led_h3;
led_h4_p  <= not led_h4;


tp1 <= not tp1 when rising_edge( clk );
tp2 <= px(2);
tp3 <= clk30k;

--btp1: obuf_f_16 port map( btp(1), tp1 );
--btp2: obuf_f_16 port map( btp(2), tp2 );
--btp3: obuf_f_16 port map( btp(3), tp3 );
--



amb: cl_ml605
	generic map(		

		CLKOUT6_DIVIDE 	=> 4,		-- 4 - ������� ��������� ���� 250 ���
	
		---- ��������� ������ ----
		trd_rom			=> trd_rom,
		---- ���������� ������ �� �������� DATA ----
		trd_in			=> "0000000001000001",
		---- ���������� ������ �� �������� STATUS ----
		trd_st			=> "0000000011000011",

		is_simulation	=> is_simulation	-- 0 - ������, 1 - ������������� ADM
	)
	port map(
	---- PCI-Express ----
		txp				=> pci_exp_txp,
		txn				=> pci_exp_txn,

		rxp				=> pci_exp_rxp,
		rxn				=> pci_exp_rxn,
		
		mgt100_p		=> sys_clk_p, 	-- �������� ������� 100 MHz �� PCI_Express
		mgt100_n		=> sys_clk_n,
		
		
		bperst			=> sys_reset_n,	-- 0 - �����						   
		
		p				=> px,		 

		led_h1			=> led_h1,	-- 0 - �������� ��������� H1
		led_h2			=> led_h2,	-- 0 - �������� ��������� H2 
		led_h3			=> led_h3,	-- 0 - �������� ��������� H3 
		led_h4			=> led_h4,	-- 0 - �������� ��������� H4
		
		---- ���������� ���� ----
		clk_out			=> clk,  		-- �������� �������
		reset_out		=> reset_main,	-- 0 - �����
		test_mode		=> test_mode,	-- 1 - �������� �����
		clk30k			=> clk30k,		-- �������� ������� 30 ���
		clk200_out		=> clk200,		-- �������� ������� 200 ���

		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	=> trd_host_adr( 15 downto 0 ),
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_data	=> trd_host_data,

		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_cmd_data=>trd_host_cmd_data,
				
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	=> trd_host_cmd,
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		=> trd_data,
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	=> trd_cmd_data,
		
		---- ������� DMA �� ������ ������� ----
		trd_drq			=> trd_drq,
		
		---- ������� DMA �� ������� MAIN (����� �������������) ----
		trd_main_drq	=> trd_main_drq,

		---- �������� ���������� DMA ----
		trd_main_sel_drq=> trd_main_sel_drq,

		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	=> trd_reset_fifo,
		
		---- ������� ����������� �� ������� MAIN (����� �������������) ----
		trd_main_irq	=> trd_main_irq
		
	);
	


main: trd_main_v8 
	port map 
	( 
	
		-- GLOBAL
		reset			=> reset_main,
		clk				=> clk,
		
		-- T0		 
		adr_in			=> trd_host_adr( 6 downto 0 ),
		data_in			=> trd_host_data(0),
		cmd_data_in 	=> trd_host_cmd_data(0),
		
		cmd				=> trd_host_cmd(0),
		
		data_out		=> trd_data(0),
		cmd_data_out	=> trd_cmd_data(0),
		
		bx_drq			=> trd_drq(0),			-- ���������� DMA
		
		test_mode		=> test_mode,
		test_mode_init	=> '1',
		
		b1_irq 			=> trd_irq(1),  
		b2_irq 			=> trd_irq(2),  
		b3_irq 			=> trd_irq(3),  
		b4_irq 			=> trd_irq(4),  
		b5_irq 			=> trd_irq(5),  
		b6_irq 			=> trd_irq(6),  
		b7_irq 			=> trd_irq(7),  

			   	
		b1_drq 			=> trd_drq(1),
		b2_drq 			=> trd_drq(2),
		b3_drq 			=> trd_drq(3),
		b4_drq 			=> trd_drq(4),
		b5_drq 			=> trd_drq(5),
		b6_drq 			=> trd_drq(6),
		b7_drq 			=> trd_drq(7),

		
		int1 			=> trd_main_irq(1),
		
		drq0 			=> trd_main_drq(0),
		drq1 			=> trd_main_drq(1),
		drq2 			=> trd_main_drq(2),
		drq3 			=> trd_main_drq(3),
		
		reset_out 		=> reset,
	   	
		fifo_rst_out	=> trd_reset_fifo(0),
		
		-- �������������
		b_clk 			=> (others=>'0'),
		
		b_start 		=> (others=>'0'),
		
		-- SYNX
		sn_rdy0 		=> '0',
		sn_rdy1 		=> '0',
		sn_start_en 	=> '0',
		sn_sync0 		=> '0'
		
		);
		
		
		


dio_in: trd_admdio64_in_v6  
	port map(		
		-- GLOBAL
		reset				=> reset,		-- 0 - �����
		clk					=> clk,			-- �������� �������
		
		-- ���������� ��������
		cmd_data_in 		=> trd_host_cmd_data(6),
		cmd					=> trd_host_cmd(6),
		
		data_out2			=> trd_data(6),
		cmd_data_out2		=> trd_cmd_data(6),
		
		
		bx_irq				=> trd_irq(6),  		-- 1 - ���������� �� �������
		bx_drq				=> trd_drq(6),			-- ���������� DMA
		
		mode1				=> di_mode1,			-- ������� MODE1

		fifo_rst			=> di_fifo_rst, 				-- 0 - ����� FIFO (�����)
		
		start				=> di_start,			--  1 - ���������� ������ (MODE0[5])
		
		-- ������ FIFO					
		data_in             => di_data,			-- ������ ��� ������ � FIFO
		data_wr             => di_data_we,		-- 1 - ����� ������
		flag_wr				=> di_flag_wr,		-- ����� FIFO, ��������� � clk_wr
		clk_wr 				=> di_clk	 	-- �������� ������� ������ � FIFO
	);		
	
trd_reset_fifo(6) <= di_fifo_rst;



dio_out: trd_admdio64_out_v4 
	port map(		
	
		-- GLOBAL
		reset				=> reset,		-- 0 - �����
		clk					=> clk,			-- �������� �������
		
		-- ���������� ��������
		data_in				=> trd_host_data(7),
		cmd_data_in 		=> trd_host_cmd_data(7),
		
		cmd					=> trd_host_cmd(7),
		
		cmd_data_out2		=> trd_cmd_data(7),
		
		
		bx_irq				=> trd_irq(7),  		-- 1 - ���������� �� �������
		bx_drq				=> trd_drq(7),			-- ���������� DMA
		
		mode1				=> do_mode1,	-- ������� MODE1
		
		fifo_rst			=> do_fifo_rst,		 	-- 0 - ����� FIFO
		start				=> do_start,			--  1 - ���������� ������ (MODE0[5])
		
		-- ������ �� FIFO
		data_out			=> do_data,			-- ���� ������ FIFO
		data_cs         	=> do_data_cs,		-- 0 - ������ ������
		flag_rd         	=> do_flag_rd,		-- ����� FIFO
		clk_rd          	=> do_clk	   						-- �������� ������� ������ ������
		
	   );		   
		
trd_reset_fifo(7) <= do_fifo_rst;	  

freq0 <= clk;
freq1 <= '0';	
freq2 <= '0';
						

test_ctrl: trd_test_ctrl_m1 
	generic map(
		SystemFreq 	=> 2000  	-- �������� ��������� �������� �������
	)
	port map(		
		-- GLOBAL
		reset			=> reset,		-- 0 - �����
		clk				=> clk,			-- �������� �������
		
		-- ���������� ��������
		cmd_data_in 	=> trd_host_cmd_data(1),
		
		cmd				=> trd_host_cmd(1),
		
		cmd_data_out2	=> trd_cmd_data(1),
		
		
		bx_irq			=> trd_irq(1),  		-- 1 - ���������� �� �������
		bx_drq			=> trd_drq(1),			-- ���������� DMA
		
		---- DIO_IN ----
		di_clk			=> di_clk,			-- �������� ������� ������ � FIFO
		di_data			=> di_data,			-- ������	 out
		di_data_we		=> di_data_we,		-- 1 - ������ ������
		di_flag_wr		=> di_flag_wr,		-- ����� FIFO
		di_fifo_rst		=> di_fifo_rst,		-- 0 - ����� FIFO
		di_mode1		=> di_mode1,		-- ������� MODE1
		di_start		=> di_start,		-- 1 - ���������� ������ (MODE0[5])
		
		---- DIO_OUT ----
		do_clk			=> do_clk,		 	-- �������� ������� ������ �� FIFO
		do_data			=> do_data,			-- ������  in
		do_data_cs		=> do_data_cs,		-- 0 - ������ ������
		do_flag_rd		=> do_flag_rd,		-- ����� FIFO
		do_fifo_rst		=> do_fifo_rst,		-- 0 - ����� FIFO
		do_mode1		=> do_mode1,		-- ������� MODE1
		do_start		=> do_start,		-- 1 - ���������� ������ (MODE0[5])
		
		clk_sys			=> clk200,		-- ������� �������� �������
		clk_check0		=> freq0,		-- ���������� �������, ���� 0
		clk_check1		=> freq1,		-- ���������� �������, ���� 0
		clk_check2		=> freq2		-- ���������� �������, ���� 0
		
	    );
		

end ml605_lx240t_core;
