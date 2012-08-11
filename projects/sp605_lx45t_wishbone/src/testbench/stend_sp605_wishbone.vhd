-------------------------------------------------------------------------------
--
-- Title       : stend_sp605_wishbone 
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
--
--  Version 1.1 (25.10.2011) Kuzmi4
--      Description: add "assert" for stop simulation after TEST finished.
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

library work;

use work.cmd_sim_pkg.all;		   
use work.block_pkg.all;
use work.sp605_lx45t_wishbone_pkg.all;
use work.xilinx_pcie_rport_m2_pkg.all;

use work.test_pkg.all;

use std.textio.all;
use std.textio;

entity stend_sp605_wishbone is
end stend_sp605_wishbone;


architecture stend_sp605_wishbone of stend_sp605_wishbone is

--component xilinx_pcie_2_0_rport_v6 is
--generic (
--          REF_CLK_FREQ   : integer;          -- 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
--          ALLOW_X8_GEN2  : boolean;
--          PL_FAST_TRAIN  : boolean;
--          LINK_CAP_MAX_LINK_SPEED : bit_vector;
--          DEVICE_ID : bit_vector;
--          LINK_CAP_MAX_LINK_WIDTH  : bit_vector;
--          LINK_CAP_MAX_LINK_WIDTH_int  : integer;
--          LINK_CTRL2_TARGET_LINK_SPEED  : bit_vector;
--          LTSSM_MAX_LINK_WIDTH  : bit_vector;
--          DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
--          USER_CLK_FREQ : integer;
--          VC0_TX_LASTPACKET : integer;
--          VC0_RX_RAM_LIMIT : bit_vector;
--          VC0_TOTAL_CREDITS_PD : integer;
--          VC0_TOTAL_CREDITS_CD : integer
--);
--port  (
--
--  sys_clk : in std_logic;
--  sys_reset_n : in std_logic;
--
--  pci_exp_rxn : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
--  pci_exp_rxp : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
--  pci_exp_txn : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
--  pci_exp_txp : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0)
--
--);
--end component;

signal	clk125			: std_logic:='0';
signal	clk125p			: std_logic;
signal	clk125n			: std_logic;

signal	clk100			: std_logic:='0';
signal	clk100p			: std_logic;
signal	clk100n			: std_logic;

signal	reset			: std_logic;

signal	txp				: std_logic_vector( 0 downto 0 ):=(others=>'0');
signal	txn				: std_logic_vector( 0 downto 0 ):=(others=>'1');
signal	rxp				: std_logic_vector( 0 downto 0 ):=(others=>'0');
signal	rxn				: std_logic_vector( 0 downto 0 ):=(others=>'1');

signal	rp_txp			: std_logic_vector( 0 downto 0 ):=(others=>'0');
signal	rp_txn			: std_logic_vector( 0 downto 0 ):=(others=>'1');
signal	rp_rxp			: std_logic_vector( 0 downto 0 ):=(others=>'0');
signal	rp_rxn			: std_logic_vector( 0 downto 0 ):=(others=>'1');

signal	tp				: std_logic_vector( 3 downto 1 );
signal	led1			: std_logic;
signal	led2			: std_logic;
signal	led3			: std_logic;		  
signal	led4			: std_logic;

signal	cmd				: bh_cmd; 	-- �������
signal  ret				: bh_ret; 	-- �����

--
-- Additional TEST signals:
--
signal  s_spy_fifo_clk              :   std_logic:='0';
signal  s_spy_fifo_wr_ena           :   std_logic:='0';
signal  s_spy_fifo_final            :   std_logic:='0';
signal  si_wb_outgoing_fifo_counter :   integer:=0;


begin
	
 dut: sp605_lx45t_wishbone 
	generic map(
		is_simulation	=> 2	-- 0 - ������, 1 - ������������� ADM, 2 - ������������� pcie_core  
	)
	port map(
		---- PCI-Express ----
		pci_exp_txp			=> txp,
		pci_exp_txn			=> txn,
		
		pci_exp_rxp			=> rxp,
		pci_exp_rxn			=> rxn,
		
		sys_clk_p			=> clk125p,   -- �������� ������� 125 MHz �� PCI_Express
		sys_clk_n			=> clk125n,
		
		sys_reset_n			=> reset,	-- 0 - �����						   
		
		
		---- ���������� ----
		gpio_led1			=> led1,
		gpio_led2			=> led2,
		gpio_led3			=> led3,
		gpio_led0			=> led4
	);	
	
	
rp : xilinx_pcie_rport_m2
generic map (
      REF_CLK_FREQ => 0,
      ALLOW_X8_GEN2 => FALSE,
      PL_FAST_TRAIN => TRUE,
      LINK_CAP_MAX_LINK_SPEED => X"1",
      DEVICE_ID => X"6011",
      LINK_CAP_MAX_LINK_WIDTH => X"01",
      LINK_CAP_MAX_LINK_WIDTH_int => 1,
      LINK_CTRL2_TARGET_LINK_SPEED => X"1",
      LTSSM_MAX_LINK_WIDTH => X"01",
      DEV_CAP_MAX_PAYLOAD_SUPPORTED => 2,
      VC0_TX_LASTPACKET => 29,
      VC0_RX_RAM_LIMIT => X"7FF",
      VC0_TOTAL_CREDITS_PD => (308),
      VC0_TOTAL_CREDITS_CD => (308),
      USER_CLK_FREQ => 1
)
port map (

		sys_clk => clk100,
		sys_reset_n => reset,
		
		pci_exp_txn => rp_txn,
		pci_exp_txp => rp_txp,
		pci_exp_rxn => rp_rxn,
		pci_exp_rxp => rp_rxp,
		  
		cmd			=> cmd, -- �������
		ret			=> ret	-- �����
  
);	


clk125 <= not clk125 after 4 ns;

clk125p <= clk125;
clk125n <= not clk125;

clk100 <= not clk100 after 5 ns;

clk100p <= clk100;
clk100n <= not clk100;

rxp(0) <= rp_txp(0);
rxn(0) <= rp_txn(0);

rp_rxp(0) <= txp(0);
rp_rxn(0) <= txn(0);	   

reset <= '0', '1' after 5002 ns;

pr_main: process 

variable	data	: std_logic_vector( 31 downto 0 );
variable 	str 	: LINE;		-- pointer to string

begin
    
    --test_init( "src\log\test.log" );
    test_init( "test.log" );
    
    wait for 180 us;	
    
    --test_dsc_incorrect( cmd, ret );
    test_read_4kb( cmd, ret );      -- was original
    --test_adm_read_8kb( cmd, ret );
    --test_adm_read_16kb( cmd, ret );
    --test_adm_write_16kb( cmd, ret );
    --test_block_main( cmd, ret );
    
    --test_num_1(cmd, ret);
    --test_num_2(cmd, ret);
    
    --test_wb_1(cmd, ret);
    --test_wb_2(cmd, ret);
    
    test_close;
    --
    -- Print Final Banner
    report "Init END OF TEST" severity WARNING;
    assert false
    report "End of TEST; Ending simulation (not a Failure)"
    severity FAILURE;
    wait;
    
end process pr_main;

end stend_sp605_wishbone;
