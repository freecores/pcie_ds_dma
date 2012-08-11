 -------------------------------------------------------------------------------
--
-- Title       : cl_ambpex5_m5
-- Author      : Dmitry	Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 	���� ����������� ������ ��� ������ AMBPEX5
--					����������� 5 - ������������ pcie_core64_m2
--
-------------------------------------------------------------------------------
--
--  Version 1.0  02.07.2011
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.adm2_pkg.all;


package	cl_ambpex5_m5_pkg is	  
	
constant rom_empty: bl_trd_rom:=(others=>x"0000");	

component cl_ambpex5_m5 is  
	generic (				
	
		 ---- ��������� PLL ----
		 --- CLKOUT0 - 266 ��� ---
		 --- CLKOUT1 - 200 ��� ---
	     BANDWIDTH 				: string := "OPTIMIZED";
	     CLKFBOUT_MULT 			: integer := 16;
	     CLKFBOUT_PHASE 		: real := 0.0;
	     CLKIN_PERIOD 			: real := 0.000;
	     CLKOUT0_DIVIDE 		: integer := 3;
	     CLKOUT0_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT0_PHASE 			: real := 0.0;
	     CLKOUT1_DIVIDE 		: integer := 4;
	     CLKOUT1_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT1_PHASE 			: real := 0.0;
	     CLKOUT2_DIVIDE 		: integer := 1;
	     CLKOUT2_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT2_PHASE 			: real := 0.0;
	     CLKOUT3_DIVIDE 		: integer := 1;
	     CLKOUT3_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT3_PHASE 			: real := 0.0;
	     CLKOUT4_DIVIDE 		: integer := 1;
	     CLKOUT4_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT4_PHASE 			: real := 0.0;
	     CLKOUT5_DIVIDE 		: integer := 1;
	     CLKOUT5_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT5_PHASE 			: real := 0.0;
	     CLK_FEEDBACK 			: string := "CLKFBOUT";
	     COMPENSATION 			: string := "SYSTEM_SYNCHRONOUS";
	     DIVCLK_DIVIDE 			: integer := 5;
	     REF_JITTER 			: real := 0.100;
	     RESET_ON_LOSS_OF_LOCK 	: boolean := FALSE;
	
	
		---- ��������� ������ ----
		trd_rom			: in std_logic_array_16xbl_trd_rom:=(others=>(others=>(others=>'0')));
		---- ���������� ������ �� �������� DATA ----
		trd_in			: in std_logic_vector( 15 downto 0 ):=x"0000";
		---- ���������� ������ �� �������� STATUS ----
		trd_st			: in std_logic_vector( 15 downto 0 ):=x"0000";
	
		is_simulation	: integer:=0	-- 0 - ������, 1 - ������������� ADM
	);
	port (
		---- PCI-Express ----
		txp				: out std_logic_vector( 7 downto 0 );
		txn				: out std_logic_vector( 7 downto 0 );
		
		rxp				: in  std_logic_vector( 7 downto 0 );
		rxn				: in  std_logic_vector( 7 downto 0 );
		
		mgt251_p		: in  std_logic; -- �������� ������� 250 MHz �� PCI_Express
		mgt251_n		: in  std_logic;
		
		
		bperst			: in  std_logic;	-- 0 - �����						   
		
		p				: out std_logic_vector( 3 downto 1 );
		
		led_h1			: out std_logic;	-- 0 - �������� ��������� H1
		led_h2			: out std_logic;	-- 0 - �������� ��������� H2
		led_h3			: out std_logic;	-- 0 - �������� ��������� H3
		led_h4			: out std_logic;	-- 0 - �������� ��������� H4

		
		---- ���������� ���� ----
		clk_out			: out std_logic;	-- �������� �������
		reset_out		: out std_logic;	-- 0 - �����
		test_mode		: in std_logic;		-- 1 - �������� �����
		clk30k			: out std_logic;	-- �������� ������� 30 ���

		clk200_out		: out std_logic;	-- �������� ������� 200 ���
		clk2_pll		: out std_logic;	-- ����� PLL CLKOUT2 
		clk3_pll		: out std_logic;	-- ����� PLL CLKOUT3 
		clk4_pll		: out std_logic;	-- ����� PLL CLKOUT4 
		clk5_pll		: out std_logic;	-- ����� PLL CLKOUT5 
		clk_lock_out	: out std_logic;	-- 1 - ������� ����������� 
		  
		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	: out std_logic_vector( 15 downto 0 );
		
		---- ���� ������, ����� ������� ������������� ������ � ������� DATA ----		
		trd_host_data	: out std_logic_array_16x64;			  
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_cmd_data	: out std_logic_array_16x16;
		
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	: out std_logic_array_16xbl_cmd;
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		: in  std_logic_array_16x64:=(others=>(others=>'0'));
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	: in  std_logic_array_16x16:=(others=>(others=>'0'));
		
		---- ������� DMA �� ������ ������� ----
		trd_drq			: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));
		
		---- ������� DMA �� ������� MAIN (����� �������������) ----
		trd_main_drq	: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));

		---- �������� ���������� DMA ----
		trd_main_sel_drq: in  std_logic_array_16x6:=(others=>(others=>'0'));

		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	: in  std_logic_array_16xbl_reset_fifo:=(others=>'0');
		
		---- ������� ����������� �� ������� MAIN (����� �������������) ----
		trd_main_irq	: in std_logic_array_16xbl_irq:=(others=>'0')
		

	);

end component;

end package;



library ieee;
use ieee.std_logic_1164.all;	 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.adm2_pkg.all;

use work.pb_adm_ctrl_m2_pkg.all; 
use work.ctrl_blink_pkg.all;



entity cl_ambpex5_m5 is  
	generic (				
	
		 ---- ��������� PLL ----
		 --- CLKOUT0 - 266 ��� ---
		 --- CLKOUT1 - 200 ��� ---
	     BANDWIDTH 				: string := "OPTIMIZED";
	     CLKFBOUT_MULT 			: integer := 16;
	     CLKFBOUT_PHASE 		: real := 0.0;
	     CLKIN_PERIOD 			: real := 0.000;
	     CLKOUT0_DIVIDE 		: integer := 3;
	     CLKOUT0_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT0_PHASE 			: real := 0.0;
	     CLKOUT1_DIVIDE 		: integer := 4;
	     CLKOUT1_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT1_PHASE 			: real := 0.0;
	     CLKOUT2_DIVIDE 		: integer := 1;
	     CLKOUT2_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT2_PHASE 			: real := 0.0;
	     CLKOUT3_DIVIDE 		: integer := 1;
	     CLKOUT3_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT3_PHASE 			: real := 0.0;
	     CLKOUT4_DIVIDE 		: integer := 1;
	     CLKOUT4_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT4_PHASE 			: real := 0.0;
	     CLKOUT5_DIVIDE 		: integer := 1;
	     CLKOUT5_DUTY_CYCLE 	: real := 0.5;
	     CLKOUT5_PHASE 			: real := 0.0;
	     CLK_FEEDBACK 			: string := "CLKFBOUT";
	     COMPENSATION 			: string := "SYSTEM_SYNCHRONOUS";
	     DIVCLK_DIVIDE 			: integer := 5;
	     REF_JITTER 			: real := 0.100;
	     RESET_ON_LOSS_OF_LOCK 	: boolean := FALSE;
	
	
		---- ��������� ������ ----
		trd_rom			: in std_logic_array_16xbl_trd_rom:=(others=>(others=>(others=>'0')));
		---- ���������� ������ �� �������� DATA ----
		trd_in			: in std_logic_vector( 15 downto 0 ):=x"0000";
		---- ���������� ������ �� �������� STATUS ----
		trd_st			: in std_logic_vector( 15 downto 0 ):=x"0000";
	
		is_simulation	: integer:=0	-- 0 - ������, 1 - ������������� ADM
	);
	port (
		---- PCI-Express ----
		txp				: out std_logic_vector( 7 downto 0 );
		txn				: out std_logic_vector( 7 downto 0 );
		
		rxp				: in  std_logic_vector( 7 downto 0 );
		rxn				: in  std_logic_vector( 7 downto 0 );
		
		mgt251_p		: in  std_logic; -- �������� ������� 250 MHz �� PCI_Express
		mgt251_n		: in  std_logic;
		
		
		bperst			: in  std_logic;	-- 0 - �����						   
		
		p				: out std_logic_vector( 3 downto 1 );
		
		led_h1			: out std_logic;	-- 0 - �������� ��������� H1
		led_h2			: out std_logic;	-- 0 - �������� ��������� H2
		led_h3			: out std_logic;	-- 0 - �������� ��������� H3
		led_h4			: out std_logic;	-- 0 - �������� ��������� H4

		
		---- ���������� ���� ----
		clk_out			: out std_logic;	-- �������� �������
		reset_out		: out std_logic;	-- 0 - �����
		test_mode		: in std_logic;		-- 1 - �������� �����
		clk30k			: out std_logic;	-- �������� ������� 30 ���

		clk200_out		: out std_logic;	-- �������� ������� 200 ���
		clk2_pll		: out std_logic;	-- ����� PLL CLKOUT2 
		clk3_pll		: out std_logic;	-- ����� PLL CLKOUT3 
		clk4_pll		: out std_logic;	-- ����� PLL CLKOUT4 
		clk5_pll		: out std_logic;	-- ����� PLL CLKOUT5 
		clk_lock_out	: out std_logic;	-- 1 - ������� ����������� 
		  
		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	: out std_logic_vector( 15 downto 0 );
		
		---- ���� ������, ����� ������� ������������� ������ � ������� DATA ----		
		trd_host_data	: out std_logic_array_16x64;			  
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_cmd_data	: out std_logic_array_16x16;
		
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	: out std_logic_array_16xbl_cmd;
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		: in  std_logic_array_16x64:=(others=>(others=>'0'));
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	: in  std_logic_array_16x16:=(others=>(others=>'0'));
		
		---- ������� DMA �� ������ ������� ----
		trd_drq			: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));
		
		---- ������� DMA �� ������� MAIN (����� �������������) ----
		trd_main_drq	: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));

		---- �������� ���������� DMA ----
		trd_main_sel_drq: in  std_logic_array_16x6:=(others=>(others=>'0'));

		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	: in  std_logic_array_16xbl_reset_fifo:=(others=>'0');
		
		---- ������� ����������� �� ������� MAIN (����� �������������) ----
		trd_main_irq	: in std_logic_array_16xbl_irq:=(others=>'0')
		

	);

		
	
end cl_ambpex5_m5;


architecture cl_ambpex5_m5 of cl_ambpex5_m5 is

---------------------------------------------------------------------------

component cl_adm_simulation is			 
	
	generic(
			---- ��������� ������ ----
			trd_rom			: in std_logic_array_16xbl_trd_rom:=(others=>(others=>(others=>'0')));
			---- ���������� ������ �� �������� DATA ----
			trd_in			: in std_logic_vector( 15 downto 0 ):=x"0000";
			---- ���������� ������ �� �������� STATUS ----
			trd_st			: in std_logic_vector( 15 downto 0 ):=x"0000";
			
			PERIOD_CLK		: in time:= 10 ns;	-- ������ ��������� �������
			RESET_PAUSE		: in time:= 102 ns	-- ����� ������ ������� RESET
			
	);
	
	port(	
	
		
		---- ���������� ���� ----
		clk_out			: out std_logic;
		reset_out		: out std_logic;
		test_mode		: in std_logic;		-- 1 - �������� �����

		
		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	: out std_logic_vector( 15 downto 0 );
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_data	: out std_logic_vector( 63 downto 0 );
		
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	: out std_logic_array_16xbl_cmd;
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		: in  std_logic_array_16x64:=(others=>(others=>'0'));
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	: in  std_logic_array_16x16:=(others=>(others=>'0'));
		
		---- ������� DMA �� ������� MAIN (����� �������������) ----
		trd_main_drq	: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));

		---- �������� ���������� DMA ----
		trd_main_sel_drq: in  std_logic_array_16x6:=(others=>(others=>'0'));

		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	: in  std_logic_array_16xbl_reset_fifo:=(others=>'0');
		
		---- ������� ����������� �� ������� MAIN (����� �������������) ----
		trd_main_irq	: in std_logic_array_16xbl_irq:=(others=>'0')
		
	
	);	
	
end component;


component pcie_core64_m2 is
	generic (
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������������� ������
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ������
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ����
		
		is_simulation	: integer:=0	--! 0 - ������, 1 - ������������� 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 7 downto 0 );
		txn				: out std_logic_vector( 7 downto 0 );
		
		rxp				: in  std_logic_vector( 7 downto 0 );
		rxn				: in  std_logic_vector( 7 downto 0 );
		
		mgt250			: in  std_logic; -- �������� ������� 250 MHz �� PCI_Express
		
		perst			: in  std_logic;	-- 0 - �����						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! ����������� ����� 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- ������� LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - ��������� ������������� PCI-Express
		
		
		---- ��������� ���� ----			  
		clk250_out		: out std_logic;		--! �������� ������� 250 MHz		  
		reset_out		: out std_logic;		--! 0 - �����
		dcm_rstp		: out std_logic;		--! 1 - ����� DCM 266 ���
		clk				: in std_logic;			--! �������� ������� ��������� ���� - 266 ���
		clk_lock		: in std_logic;			--! 1 - ������ �������
		
		---- BAR1 ----
		lc_adr			: out std_logic_vector( 31 downto 0 );	--! ���� ������
		lc_host_data	: out std_logic_vector( 63 downto 0 );	--! ���� ������ - �����
		lc_data			: in  std_logic_vector( 63 downto 0 );	--! ���� ������ - ����
		lc_wr			: out std_logic;	--! 1 - ������
		lc_rd			: out std_logic;	--! 1 - ������, ������ ������ ���� �� ������ ���� ����� rd 
		lc_dma_req		: in  std_logic_vector( 1 downto 0 );	--! 1 - ������ DMA
		lc_irq			: in  std_logic		--! 1 - ������ ���������� 
		
				
		
	);
end component;


signal	mgt250			: std_logic;
signal	perst			: std_logic;

signal	lc_adr			: std_logic_vector( 31 downto 0 );
signal	lc_host_data	: std_logic_vector( 63 downto 0 );
signal	lc_data			: std_logic_vector( 63 downto 0 );
signal	lc_wr			: std_logic;
signal	lc_rd			: std_logic;
signal	lc_dma_req		: std_logic_vector( 1 downto 0 );
signal	lc_irq			: std_logic;

signal	irq1			: std_logic;	-- 1 - ���������� � HOST
signal	dmar0			: std_logic;	-- 1 - ������ DMA 0
signal	dmar1			: std_logic;	-- 1 - ������ DMA 1
signal	dmar2			: std_logic;	-- 1 - ������ DMA 2
signal	dmar3			: std_logic;	-- 1 - ������ DMA 3		  

signal	trdi_host_data	: std_logic_vector( 63 downto 0 );

signal	dcm_rstp		: std_logic;
signal	clk_lock		: std_logic; 
signal	clk250			: std_logic;   	 
signal	clk200			: std_logic;
signal	clk200x			: std_logic;
signal	clk266x			: std_logic;
signal	clkfb			: std_logic;

signal	clk30i			: std_logic;
signal	cnt30k0			: std_logic;
signal	cnt30k1			: std_logic;
signal	cnt30k2			: std_logic;
signal	cnt30i0			: std_logic;
signal	cnt30i1			: std_logic;
signal	cnt30i2			: std_logic;
signal	cnt30ce0		: std_logic;
signal	cnt30ce1		: std_logic;
signal	cnt30ce2		: std_logic;
signal	cnt30start		: std_logic;
signal	cnt30start1		: std_logic;

---- ������ ���������� ��� ������ ������� ----
signal trdi_host_cmd	    : std_logic_array_16xbl_cmd;	  

signal	clk				: std_logic:='0';
signal	reset			: std_logic;

signal	pcie_link_up	: std_logic;
signal	pcie_lstatus	: std_logic_vector( 15 downto 0 );

signal	px				: std_logic_vector( 7 downto 0 );

signal	trd4_host_data	: std_logic_vector( 63 downto 0 );

attribute	period	: string;
attribute	period of clk:signal is "250 MHz";

attribute buffer_type 	: string;
attribute clock_buffer 	: string;
--attribute clock_buffer of signal_name: signal is "{bufgdll|ibufg|bufgp|ibuf|none}";	
attribute buffer_type  of clk_out: signal is "none";	
attribute buffer_type  of clk: signal is "none";	
													    
attribute clock_buffer of clk_out		: signal is "none";	
attribute clock_buffer of clk			: signal is "none";	
attribute clock_buffer of clk200_out	: signal is "none";	

attribute syn_keep	: boolean; 				 
attribute syn_keep of trd_host_data : signal is true;
attribute syn_keep of trd_host_cmd_data: signal is true;

begin				
	
	--
------- component PLL_BASE -----
--xpll: PLL_BASE
--  generic map(
--     BANDWIDTH 					=> BANDWIDTH, 				     
--     CLKFBOUT_MULT 				=> CLKFBOUT_MULT, 			     
--     CLKFBOUT_PHASE 			=> CLKFBOUT_PHASE, 		     
--     CLKIN_PERIOD 				=> CLKIN_PERIOD, 			     
--     CLKOUT0_DIVIDE 			=> CLKOUT0_DIVIDE, 		     
--     CLKOUT0_DUTY_CYCLE 		=> CLKOUT0_DUTY_CYCLE, 	     
--     CLKOUT0_PHASE 				=> CLKOUT0_PHASE, 			     
--     CLKOUT1_DIVIDE 			=> CLKOUT1_DIVIDE, 		     
--     CLKOUT1_DUTY_CYCLE 		=> CLKOUT1_DUTY_CYCLE, 	     
--     CLKOUT1_PHASE 				=> CLKOUT1_PHASE, 			     
--     CLKOUT2_DIVIDE 			=> CLKOUT2_DIVIDE, 		     
--     CLKOUT2_DUTY_CYCLE 		=> CLKOUT2_DUTY_CYCLE, 	     
--     CLKOUT2_PHASE 				=> CLKOUT2_PHASE, 			     
--     CLKOUT3_DIVIDE 			=> CLKOUT3_DIVIDE, 		     
--     CLKOUT3_DUTY_CYCLE 		=> CLKOUT3_DUTY_CYCLE, 	     
--     CLKOUT3_PHASE 				=> CLKOUT3_PHASE, 			     
--     CLKOUT4_DIVIDE 			=> CLKOUT4_DIVIDE, 		     
--     CLKOUT4_DUTY_CYCLE 		=> CLKOUT4_DUTY_CYCLE, 	     
--     CLKOUT4_PHASE 				=> CLKOUT4_PHASE, 			     
--     CLKOUT5_DIVIDE 			=> CLKOUT5_DIVIDE, 		     
--     CLKOUT5_DUTY_CYCLE 		=> CLKOUT5_DUTY_CYCLE, 	     
--     CLKOUT5_PHASE 				=> CLKOUT5_PHASE, 			     
--     CLK_FEEDBACK 				=> CLK_FEEDBACK, 			     
--     COMPENSATION 				=> COMPENSATION, 			     
--     DIVCLK_DIVIDE 				=> DIVCLK_DIVIDE, 			     
--     REF_JITTER 				=> REF_JITTER,			     
--     RESET_ON_LOSS_OF_LOCK 		=> RESET_ON_LOSS_OF_LOCK 	     
--  )
--  port map(
--     CLKFBOUT 	=> clkfb,
--     CLKOUT0 	=> clk266x,
--     CLKOUT1 	=> clk200x,
--     CLKOUT2 	=> clk2_pll,
--     CLKOUT3 	=> clk3_pll,
--     CLKOUT4 	=> clk4_pll,
--     CLKOUT5 	=> clk5_pll,
----     LOCKED 	=> clk_lock,
--     CLKFBIN 	=> clkfb,
--     CLKIN 		=> clk250,
--     RST 		=> dcm_rstp
--  );

clk_lock <= '1';
clk <= clk250;

xclk200: bufg port map( clk200, clk200x );
--xclk266: bufg port map( clk, clk266x );
clk200_out <= clk200;
clk_lock_out <= clk_lock;


	
gen_syn: if( is_simulation=0 or  is_simulation=2 ) generate

	
clk_out <= clk;
reset_out <= reset after 1 ns when rising_edge( clk );	   
clk30k <= clk30i;


xmgtclk : IBUFDS  port map (O => mgt250, I => mgt251_p, IB => mgt251_n );	   
xmperst: ibuf port map( perst, bperst );


pcie: pcie_core64_m2   
generic map(
		is_simulation	=> is_simulation	-- 0 - ������, 1 - ������������� 
	)
	
	port map(
	
		---- PCI-Express ----
		txp				=> txp,
		txn				=> txn,
		
		rxp				=> rxp,
		rxn				=> rxn,
		
		mgt250			=> mgt250,
		
		perst			=> perst,
		
		px				=> px,
		
		pcie_lstatus	=> pcie_lstatus,	 -- ������� LSTATUS
		pcie_link_up	=> pcie_link_up,	 -- 0 - ��������� ������������� PCI-Express
		
		---- ��������� ���� ----			  
		clk250_out		=> clk250,			-- �������� ������� 250 MHz		  
		reset_out		=> reset,			-- 0 - �����
		dcm_rstp		=> dcm_rstp,		-- 1 - ����� DCM 266 ��� 
		clk				=> clk,				-- �������� ������� ��������� ���� - 266 ���
		clk_lock		=> clk_lock,		-- 1 - ������ �������
		
		lc_adr			=> lc_adr,			-- ���� ������
		lc_host_data	=> lc_host_data,	-- ���� ������ - �����
		lc_data			=> lc_data,			-- ���� ������ - ����
		lc_wr			=> lc_wr,			-- 1 - ������
		lc_rd			=> lc_rd,			-- 1 - ������, ������ ������ ���� �� �������� ���� ����� rd
		lc_dma_req		=> lc_dma_req,		-- 1 - ������ DMA
		lc_irq			=> lc_irq			-- 1 - ������ ���������� 
		
	);		
	
	

p(1) <= px(0); -- int_req_fl
p(2) <= px(1); -- int_req_main
p(3) <= px(2); -- int_ack


blink:	ctrl_blink 
	generic map(
		is_simulation	=> is_simulation
	)
	port map(
		clk				=> clk250,		-- �������� ������� 250 
		reset			=> reset,	-- 0 - �����
		clk30k			=> clk30i,	-- �������� ������� 30 ���
		
		pcie_link_up	=> pcie_link_up,	-- 0 - ��������� ������������� PCI-Express
		pcie_lstatus	=> pcie_lstatus,	-- �������� LSTATUS
		
		led_h1			=> led_h1		-- ���������
	);

	
led_h2 <= reset and not dmar1;
led_h3 <= reset and not dmar0;
led_h4 <= reset and not px(0);

	
ad:	pb_adm_ctrl_m2 
	generic map (					 
		---- ���������� ������ �� �������� DATA ----
		trd1_in		=> conv_integer( trd_in(1) ),
		trd2_in		=> conv_integer( trd_in(2) ),
		trd3_in		=> conv_integer( trd_in(3) ),
		trd4_in		=> conv_integer( trd_in(4) ),
		trd5_in		=> conv_integer( trd_in(5) ),
		trd6_in		=> conv_integer( trd_in(6) ),
		trd7_in		=> conv_integer( trd_in(7) ),

		---- ���������� ������ �� �������� STATUS ----
		trd1_st		=> conv_integer( trd_st(1) ),
		trd2_st		=> conv_integer( trd_st(2) ),
		trd3_st		=> conv_integer( trd_st(3) ),
		trd4_st		=> conv_integer( trd_st(4) ),
		trd5_st		=> conv_integer( trd_st(5) ),
		trd6_st		=> conv_integer( trd_st(6) ),
		trd7_st		=> conv_integer( trd_st(7) ),
		
		---- ��������� ������� ----
		rom0		=> trd_rom(0),
		rom1		=> trd_rom(1),
		rom2		=> trd_rom(2),
		rom3		=> trd_rom(3),
		rom4		=> trd_rom(4),
		rom5		=> trd_rom(5),
		rom6		=> trd_rom(6),
		rom7		=> trd_rom(7)
		
	)

	port map(			 
		---- GLOBAL ----
		reset			=> reset,			-- 0 - �����
		clk				=> clk,				-- �������� �������
		
		---- PLD_BUS ----
		lc_adr			=> lc_adr( 17 downto 11 ),	-- ���� ������
		lc_host_data	=> lc_host_data,	-- ���� ������, ����
		lc_data			=> lc_data,			-- ���� ������, �����
		lc_wr			=> lc_wr,			-- 1 - ������
		lc_rd			=> lc_rd,			-- 1 - ������
		

		test_mode		=> test_mode,			-- 1 - �������� �����

		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	=> trd_host_adr( 6 downto 0 ),
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_data	=> trdi_host_data,
		
		---- ���� ������, ����� ������� ������������� ������ � ������� DATA ������� 4 ----		
		trd4_host_data	=> trd4_host_data,
		
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	=> trdi_host_cmd,
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		=> trd_data,
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	=> trd_cmd_data,	 
		
		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	=> trd_reset_fifo,

		---- ������� DMA �� ������ ������� ----
		trd_drq			=> trd_drq,
		
		---- ��������� ���������� � DRQ ----
		int1			=> trd_main_irq(1),
		            	
		drq0			=> trd_main_drq(0),
		drq1			=> trd_main_drq(1),
		drq2			=> trd_main_drq(2),
		drq3			=> trd_main_drq(3),
		
		---- ����� DRQ � IRQ ----
		irq1			=> irq1,
		dmar0			=> dmar0,
		dmar1			=> dmar1,
		dmar2			=> dmar2,
		dmar3			=> dmar3
		
	);
	
	


lc_dma_req <= dmar1 & dmar0;
lc_irq <= irq1;

end generate;	

gen_simulation: if( is_simulation=1 ) generate
	
clk_out <= clk;

ctrl: cl_adm_simulation			 
	
	generic map(
			---- ��������� ������ ----
			trd_rom			=> trd_rom,
			---- ���������� ������ �� �������� DATA ----
			trd_in			=> trd_in,
			---- ���������� ������ �� �������� STATUS ----
			trd_st			=> trd_st,
			
			PERIOD_CLK		=> 4 ns,	-- ������ ��������� �������
			RESET_PAUSE		=> 102 ns	-- ����� ������ ������� RESET
			
	)
	
	port map(	
	
		
		---- ���������� ���� ----
		clk_out			=> clk,
		reset_out		=> reset_out,
		test_mode		=> test_mode,		-- 1 - �������� �����

		
		---- ���� ������ ��� ����������� � ���� ���������� ������������ ������� MAIN ----		
		trd_host_adr	=> trd_host_adr,
		
		---- ���� ������, ����� ������� ������������� ������ � �������� ������� ----		
		trd_host_data	=> trdi_host_data,
		
		---- ������ ���������� ��� ������ ������� ----		
		trd_host_cmd	=> trdi_host_cmd,
		
		---- ������ ������� DATA �� ������ ������� ----
		trd_data		=> trd_data,
		
		---- ������ ��������� STATUS, CMD_ADR, CMD_DATA �� ������ ������� ----
		trd_cmd_data	=> trd_cmd_data,
		
		---- ������� DMA �� ������� MAIN (����� �������������) ----
		trd_main_drq	=> trd_main_drq,

		---- �������� ���������� DMA ----
		trd_main_sel_drq=> trd_main_sel_drq,

		---- ����� FIFO �� ������ ������� ----
		trd_reset_fifo	=> trd_reset_fifo,
		
		---- ������� ����������� �� ������� MAIN (����� �������������) ----
		trd_main_irq	=> trd_main_irq
		
	
	);	
	
	
--trd_host_data <= trdi_host_data;	
trd4_host_data <= trdi_host_data;	


end generate;

---- ������������ �������� ���������� -----

gen_cmd: for ii in 0 to 7 generate

trd_host_cmd(ii).data_cs <= trdi_host_cmd(ii).data_cs;
trd_host_cmd(ii).data_oe <= '0';
trd_host_cmd(ii).cmd_data_cs <= trdi_host_cmd(ii).cmd_data_cs;
trd_host_cmd(ii).status_cs <= trdi_host_cmd(ii).status_cs;

trd_host_cmd(ii).data_we 		<= trdi_host_cmd(ii).data_we after 0.4 ns when rising_edge( clk );
trd_host_cmd(ii).cmd_data_we 	<= trdi_host_cmd(ii).cmd_data_we after 0.4 ns when rising_edge( clk );
trd_host_cmd(ii).cmd_adr_we 	<= trdi_host_cmd(ii).cmd_adr_we after 0.4 ns when rising_edge( clk );

trd_host_cmd(ii).adr 			<= trdi_host_cmd(ii).adr;

gen_data: if( ii/=4 ) generate
		--trd_host_data(ii) <= trdi_host_data after 0.4 ns when rising_edge( clk );
		
		gen_bus: for jj in 0 to 63 generate
		attribute syn_keep of xfd : label is true;
		begin
			xfd:  fd port map( q=>trd_host_data(ii)(jj), c=>clk, d=>trdi_host_data(jj) );
		end generate;
	
	end generate;
	
	gen_data_t4: if( ii=4 ) generate
		--trd_host_data(ii) <= trd4_host_data after 0.4 ns when rising_edge( clk );
		
		gen_bus: for jj in 0 to 63 generate
		attribute syn_keep of xfd : label is true;
		begin
			xfd: fd port map( q=>trd_host_data(ii)(jj), c=>clk, d=>trd4_host_data(jj) );
		end generate;
		
	end generate;

trd_host_cmd_data(ii) <= trdi_host_data( 15 downto 0 ) after 0.4 ns when rising_edge( clk );

end generate;


---- ������������ ������� 30 ��� ----

cnt30start  <= dcm_rstp after 1 ns when rising_edge( clk250 );
cnt30start1 <= cnt30start after 1 ns when rising_edge( clk250 );

cnt30i0 <= ((cnt30start xor cnt30start1) or cnt30k0) and not cnt30start;
cnt30i1 <= ((cnt30start xor cnt30start1) or cnt30k1 )and not cnt30start;
cnt30i2 <=  not cnt30k2 and not cnt30start;
cnt30ce1 <= (cnt30start xor cnt30start1) or cnt30k0 or cnt30start;
cnt30ce2 <=  (cnt30k1 and cnt30ce1) or cnt30start;

xcnt0: srlc32e port map( q31=>cnt30k0, clk=>clk250, d=>cnt30i0, a=>"11111",   ce=>'1' );
xcnt1: srlc32e port map( q31=>cnt30k1, clk=>clk250, d=>cnt30i1, a=>"11111",   ce=>cnt30ce1 );
xcnt2: srlc32e port map( q=>cnt30k2, clk=>clk250,   d=>cnt30i2,   a=>"01001", ce=>cnt30ce2 );

clk30i <= cnt30k2;

end cl_ambpex5_m5;						



