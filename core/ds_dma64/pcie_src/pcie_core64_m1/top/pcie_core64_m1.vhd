-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m1
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems 
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  ���������� ���� PCI Express 
--
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

package	pcie_core64_m1_pkg is

--! ���������� PCI-Express 
component pcie_core64_m1 is
	generic (
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
		clk_out			: out std_logic;	--! �������� ������� 250 MHz		  
		reset_out		: out std_logic;	--! 0 - �����
		dcm_rstp		: out std_logic;	--! 1 - ����� DCM 266 ���

		---- BAR0 - ����� ���������� ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! ���� ������ - ����� 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! ���� ������ - ����
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! ����� �������� 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - ������ � �������� 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - ������ �� ��������� ����� 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! ����� ����� ��� ������ 
		bp_reg_we		: out std_logic;			--! 1 - ������ � ������� �� �������   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - ������ �� �������� �� ������� 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - ������ ���������� 

		---- BAR1 ----	
		aclk			: in std_logic;				--! �������� ������� ��������� ���� - 266 ���
		aclk_lock		: in std_logic;				--! 1 - ������ �������
		pb_master		: out type_pb_master;		--! ������ 
		pb_slave		: in  type_pb_slave			--! �����  
		
				
		
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;		

use work.core64_type_pkg.all;
use work.core64_rx_engine_pkg.all;
use work.core64_tx_engine_pkg.all;	
use work.core64_reg_access_pkg.all;
use work.core64_pb_disp_pkg.all;   
use work.block_pe_fifo_ext_pkg.all;		
use work.core64_interrupt_pkg.all;

--! ���������� PCI-Express 
entity pcie_core64_m1 is
	generic (
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
		clk_out			: out std_logic;	--! �������� ������� 250 MHz		  
		reset_out		: out std_logic;	--! 0 - �����
		dcm_rstp		: out std_logic;	--! 1 - ����� DCM 266 ���

		---- BAR0 - ����� ���������� ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! ���� ������ - ����� 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! ���� ������ - ����
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! ����� �������� 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - ������ � �������� 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - ������ �� ��������� ����� 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! ����� ����� ��� ������ 
		bp_reg_we		: out std_logic;			--! 1 - ������ � ������� �� �������   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - ������ �� �������� �� ������� 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - ������ ���������� 

		---- BAR1 ----	
		aclk			: in std_logic;				--! �������� ������� ��������� ���� - 266 ���
		aclk_lock		: in std_logic;				--! 1 - ������ �������
		pb_master		: out type_pb_master;		--! ������ 
		pb_slave		: in  type_pb_slave			--! �����  
		
		
	);
end pcie_core64_m1;


architecture pcie_core64_m1 of pcie_core64_m1 is


component ctrl_pcie_x8
  port (
    pci_exp_rxn : in std_logic_vector((8 - 1) downto 0);
    pci_exp_rxp : in std_logic_vector((8 - 1) downto 0);
    pci_exp_txn : out std_logic_vector((8 - 1) downto 0);
    pci_exp_txp : out std_logic_vector((8 - 1) downto 0);

    sys_clk : in STD_LOGIC;
    sys_reset_n : in STD_LOGIC;

  refclkout         : out std_logic;


    trn_clk : out STD_LOGIC; 
    trn_reset_n : out STD_LOGIC; 
    trn_lnk_up_n : out STD_LOGIC; 

    trn_td : in STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_trem_n: in STD_LOGIC_VECTOR (7 downto 0);
    trn_tsof_n : in STD_LOGIC;
    trn_teof_n : in STD_LOGIC;
    trn_tsrc_dsc_n : in STD_LOGIC;
    trn_tsrc_rdy_n : in STD_LOGIC;
    trn_tdst_dsc_n : out STD_LOGIC;
    trn_tdst_rdy_n : out STD_LOGIC;
    trn_terrfwd_n : in STD_LOGIC ;
    trn_tbuf_av : out STD_LOGIC_VECTOR (( 4 -1 ) downto 0 );

    trn_rd : out STD_LOGIC_VECTOR((64 - 1) downto 0);
    trn_rrem_n: out STD_LOGIC_VECTOR (7 downto 0);
    trn_rsof_n : out STD_LOGIC;
    trn_reof_n : out STD_LOGIC; 
    trn_rsrc_dsc_n : out STD_LOGIC; 
    trn_rsrc_rdy_n : out STD_LOGIC; 
    trn_rbar_hit_n : out STD_LOGIC_VECTOR ( 6 downto 0 );
    trn_rdst_rdy_n : in STD_LOGIC; 
    trn_rerrfwd_n : out STD_LOGIC; 
    trn_rnp_ok_n : in STD_LOGIC; 
    trn_rfc_npd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_nph_av : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    trn_rfc_pd_av : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    trn_rfc_ph_av : out STD_LOGIC_VECTOR ( 7 downto 0 );
    trn_rcpl_streaming_n      : in STD_LOGIC;

    cfg_do : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_rd_wr_done_n : out STD_LOGIC; 
    cfg_di : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    cfg_byte_en_n : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    cfg_dwaddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    cfg_wr_en_n : in STD_LOGIC;
    cfg_rd_en_n : in STD_LOGIC; 

    cfg_err_cor_n : in STD_LOGIC; 
    cfg_err_cpl_abort_n : in STD_LOGIC; 
    cfg_err_cpl_timeout_n : in STD_LOGIC; 
    cfg_err_cpl_unexpect_n : in STD_LOGIC; 
    cfg_err_ecrc_n : in STD_LOGIC; 
    cfg_err_posted_n : in STD_LOGIC; 
    cfg_err_tlp_cpl_header : in STD_LOGIC_VECTOR ( 47 downto 0 ); 
    cfg_err_ur_n : in STD_LOGIC;
    cfg_err_cpl_rdy_n : out STD_LOGIC;
    cfg_err_locked_n : in STD_LOGIC; 
    cfg_interrupt_n : in STD_LOGIC;
    cfg_interrupt_rdy_n : out STD_LOGIC;
    cfg_pm_wake_n : in STD_LOGIC;
    cfg_pcie_link_state_n : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
    cfg_to_turnoff_n : out STD_LOGIC;
    cfg_interrupt_assert_n : in  STD_LOGIC;
    cfg_interrupt_di : in  STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_do : out STD_LOGIC_VECTOR(7 downto 0);
    cfg_interrupt_mmenable : out STD_LOGIC_VECTOR(2 downto 0);
    cfg_interrupt_msienable: out STD_LOGIC;

    cfg_trn_pending_n : in STD_LOGIC;
    cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
    cfg_device_number : out STD_LOGIC_VECTOR ( 4 downto 0 );
    cfg_function_number : out STD_LOGIC_VECTOR ( 2 downto 0 );
    cfg_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_command : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_lcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
    cfg_dsn: in STD_LOGIC_VECTOR (63 downto 0 );

    fast_train_simulation_only : in STD_LOGIC

  );

end component;


--signal     sys_clk_c : std_logic;

--signal     sys_reset_n_c : std_logic;
signal     trn_clk_c : std_logic;
signal     trn_reset_n_c : std_logic;
signal     trn_lnk_up_n_c : std_logic;
signal     cfg_trn_pending_n_c : std_logic;
signal     trn_tsof_n_c : std_logic;
signal     trn_teof_n_c : std_logic;
signal     trn_tsrc_rdy_n_c : std_logic;
signal     trn_tdst_rdy_n_c : std_logic;
signal     trn_tsrc_dsc_n_c : std_logic;
signal     trn_terrfwd_n_c : std_logic;
signal     trn_tdst_dsc_n_c : std_logic;
signal     trn_td_c : std_logic_vector((64 - 1) downto 0);
signal     trn_trem_n_c : std_logic_vector(7 downto 0);
signal     trn_tbuf_av_c : std_logic_vector(( 4 -1 )  downto 0);
signal     trn_rsof_n_c : std_logic;
signal     trn_reof_n_c : std_logic;
signal     trn_rsrc_rdy_n_c : std_logic;
signal     trn_rsrc_dsc_n_c : std_logic;
signal     trn_rdst_rdy_n_c : std_logic;
signal     trn_rerrfwd_n_c : std_logic;
signal     trn_rnp_ok_n_c : std_logic;

signal     trn_rd_c : std_logic_vector((64 - 1) downto 0);
signal     trn_rrem_n_c : std_logic_vector(7 downto 0);
signal     trn_rbar_hit_n_c : std_logic_vector(6 downto 0);
signal     trn_rfc_nph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_npd_av_c : std_logic_vector(11 downto 0);
signal     trn_rfc_ph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_pd_av_c : std_logic_vector(11 downto 0);
signal     trn_rcpl_streaming_n_c      : std_logic;

signal     cfg_do_c : std_logic_vector(31 downto 0);
signal     cfg_di_c : std_logic_vector(31 downto 0);
signal     cfg_dwaddr_c : std_logic_vector(9 downto 0) ;
signal     cfg_byte_en_n_c : std_logic_vector(3 downto 0);
signal     cfg_err_tlp_cpl_header_c : std_logic_vector(47 downto 0);
signal     cfg_wr_en_n_c : std_logic;
signal     cfg_rd_en_n_c : std_logic;
signal     cfg_rd_wr_done_n_c : std_logic;
signal     cfg_err_cor_n_c : std_logic;
signal     cfg_err_ur_n_c : std_logic;
signal     cfg_err_ecrc_n_c : std_logic;
signal     cfg_err_cpl_timeout_n_c : std_logic;
signal     cfg_err_cpl_abort_n_c : std_logic;
signal     cfg_err_cpl_unexpect_n_c : std_logic;
signal     cfg_err_posted_n_c : std_logic;

signal     cfg_err_cpl_rdy_n_c : std_logic;  
signal     cfg_interrupt_n_c : std_logic;
signal     cfg_interrupt_rdy_n_c : std_logic;

signal     cfg_interrupt_assert_n_c : std_logic;
signal     cfg_interrupt_di_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_do_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_mmenable_c : std_logic_vector(2 downto 0);
signal     cfg_interrupt_msienable_c: std_logic;

signal     cfg_turnoff_ok_n_c : std_logic;
signal     cfg_to_turnoff_n_c : std_logic;
signal     cfg_pm_wake_n_c : std_logic;
signal     cfg_pcie_link_state_n_c : std_logic_vector(2 downto 0);
signal     cfg_bus_number_c : std_logic_vector(7 downto 0);
signal     cfg_device_number_c : std_logic_vector(4 downto 0);
signal     cfg_function_number_c : std_logic_vector(2 downto 0);
signal     cfg_status_c : std_logic_vector(15 downto 0);
signal     cfg_command_c : std_logic_vector(15 downto 0);
signal     cfg_dstatus_c : std_logic_vector(15 downto 0);
signal     cfg_dcommand_c : std_logic_vector(15 downto 0);
signal     cfg_lstatus_c : std_logic_vector(15 downto 0);
signal     cfg_lcommand_c : std_logic_vector(15 downto 0);
--signal     unsigned_fast_simulation: unsigned(0 downto 0);
signal     vector_fast_simulation: std_logic_vector(0 downto 0):=(0=>'1');

signal	refclkout				: std_logic;


signal clk					: std_logic;
signal rstp					: std_logic;
signal trn_rx				: type_trn_rx;			--! ���� ������
signal trn_rx_back			: type_trn_rx_back;		--! ���������� � ����� ������

signal reg_access			: type_reg_access;		--! ������ �� ������ � ��������� 
		
signal rx_tx_engine			: type_rx_tx_engine;	--! ����� RX->TX 
signal tx_rx_engine			: type_tx_rx_engine;	--! ����� TX->RX 
		
signal rx_ext_fifo			: type_rx_ext_fifo;		--! ����� RX->EXT_FIFO 
signal tx_ext_fifo			: type_tx_ext_fifo;
signal	tx_ext_fifo_back	: type_tx_ext_fifo_back;
signal	reg_access_back		: type_reg_access_back;
signal	completer_id		: std_logic_vector( 15 downto 0 );

signal	trn_tx				: type_trn_tx;
signal	trn_tx_back			: type_trn_tx_back;

signal	reg_disp			: type_reg_disp;
signal	reg_disp_back		: type_reg_disp_back;

signal	reg_ext_fifo		: type_reg_ext_fifo;
signal	reg_ext_fifo_back	: type_reg_ext_fifo_back;

signal	ext_fifo_disp		: type_ext_fifo_disp;		--! ������ �� ������ �� ���� EXT_FIFO 
signal	ext_fifo_disp_back	: type_ext_fifo_disp_back;	--! ����� �� ������

signal	pb_rstp				: std_logic;

signal	irq					: std_logic;

attribute buffer_type 	: string;
attribute clock_buffer 	: string;
--attribute clock_buffer of signal_name: signal is "{bufgdll|ibufg|bufgp|ibuf|none}";	
attribute buffer_type  of clk_out: signal is "none";	
attribute buffer_type  of clk: signal is "none";	
													    
attribute clock_buffer of clk_out	: signal is "none";	
attribute clock_buffer of clk		: signal is "none";	

begin

gen_sim: if( is_simulation/=0 ) generate
	vector_fast_simulation <= (others=>'1');
end generate;

gen_syn: if( is_simulation=0 ) generate
	vector_fast_simulation <= (others=>'0');
end generate;
	
	
clk_out <= clk;
reset_out <= not pb_rstp after 1 ns when rising_edge( clk );

 ep : ctrl_pcie_x8 port map  (

--
-- PCI Express Fabric Interface
--

  pci_exp_txp => txp,             -- O (7/3/0:0)
  pci_exp_txn => txn,             -- O (7/3/0:0)
  pci_exp_rxp => rxp,             -- O (7/3/0:0)
  pci_exp_rxn => rxn,             -- O (7/3/0:0)


--
-- System ( SYS ) Interface
--
  sys_clk => mgt250,                     -- I

  sys_reset_n => perst,                  -- I

  refclkout => refclkout,                -- O

--
-- Transaction ( TRN ) Interface
--

  trn_clk => clk		,                 -- O
  trn_reset_n => trn_reset_n_c,           -- O
  trn_lnk_up_n => trn_lnk_up_n_c,         -- O

-- Tx Local-Link

  trn_td => trn_tx.trn_td,                     -- I (63/31:0)
  trn_trem_n => trn_tx.trn_trem_n,
  trn_tsof_n => trn_tx.trn_tsof_n,             -- I
  trn_teof_n => trn_tx.trn_teof_n,             -- I
  trn_tsrc_rdy_n => trn_tx.trn_tsrc_rdy_n,     -- I
  trn_tsrc_dsc_n => trn_tx.trn_tsrc_dsc_n,     -- I
  trn_terrfwd_n => trn_tx.trn_terrfwd_n,       -- I

  trn_tbuf_av => trn_tx_back.trn_tbuf_av( 3 downto 0 ),           -- O (4/3:0)
  trn_tdst_rdy_n => trn_tx_back.trn_tdst_rdy_n,     -- O
  trn_tdst_dsc_n => trn_tx_back.trn_tdst_dsc_n,     -- O

-- Rx Local-Link

  trn_rd => trn_rx.trn_rd,                     -- O (63/31:0)
  trn_rrem_n => trn_rx.trn_rrem_n,
  trn_rsof_n => trn_rx.trn_rsof_n,             -- O
  trn_reof_n => trn_rx.trn_reof_n,             -- O
  trn_rsrc_rdy_n => trn_rx.trn_rsrc_rdy_n,     -- O
  trn_rsrc_dsc_n => trn_rx.trn_rsrc_dsc_n,     -- O
  trn_rdst_rdy_n => trn_rx_back.trn_rdst_rdy_n,     -- I
  trn_rerrfwd_n => trn_rx.trn_rerrfwd_n,       -- O
  trn_rnp_ok_n => trn_rx_back.trn_rnp_ok_n,         -- I
  trn_rbar_hit_n => trn_rx.trn_rbar_hit_n,     -- O (6:0)
  trn_rfc_nph_av => trn_rx.trn_rfc_nph_av,     -- O (11:0)
  trn_rfc_npd_av => trn_rx.trn_rfc_npd_av,     -- O (7:0)
  trn_rfc_ph_av => trn_rx.trn_rfc_ph_av,       -- O (11:0)
  trn_rfc_pd_av => trn_rx.trn_rfc_pd_av,       -- O (7:0)
  trn_rcpl_streaming_n => trn_rx_back.trn_rcpl_streaming_n,

--
-- Host ( CFG ) Interface
--

  cfg_do => cfg_do_c,                                    -- O (31:0)
  cfg_rd_wr_done_n => cfg_rd_wr_done_n_c,                -- O
  cfg_di => cfg_di_c,                                    -- I (31:0)
  cfg_byte_en_n => cfg_byte_en_n_c,                      -- I (3:0)
  cfg_dwaddr => cfg_dwaddr_c,                            -- I (9:0)
  cfg_wr_en_n => cfg_wr_en_n_c,                          -- I
  cfg_rd_en_n => cfg_rd_en_n_c,                          -- I
  cfg_err_cor_n => cfg_err_cor_n_c,                      -- I
  cfg_err_ur_n => cfg_err_ur_n_c,                        -- I
  cfg_err_ecrc_n => cfg_err_ecrc_n_c,                    -- I
  cfg_err_cpl_timeout_n => cfg_err_cpl_timeout_n_c,      -- I
  cfg_err_cpl_abort_n => cfg_err_cpl_abort_n_c,          -- I
  cfg_err_cpl_unexpect_n => cfg_err_cpl_unexpect_n_c,    -- I
  cfg_err_posted_n => cfg_err_posted_n_c,                -- I
  cfg_err_cpl_rdy_n => cfg_err_cpl_rdy_n_c,              -- O
  cfg_err_locked_n => '1',                -- I
  cfg_err_tlp_cpl_header => cfg_err_tlp_cpl_header_c,    -- I (47:0)
  cfg_interrupt_n => cfg_interrupt_n_c,                  -- I
  cfg_interrupt_rdy_n => cfg_interrupt_rdy_n_c,          -- O

  cfg_interrupt_assert_n => cfg_interrupt_assert_n_c,    -- I
  cfg_interrupt_di       => cfg_interrupt_di_c,          -- I [7:0]
  cfg_interrupt_do       => cfg_interrupt_do_c,          -- O [7:0]
  cfg_interrupt_mmenable => cfg_interrupt_mmenable_c,    -- O [2:0]
  cfg_interrupt_msienable=> cfg_interrupt_msienable_c,   -- O
  cfg_to_turnoff_n => cfg_to_turnoff_n_c,                -- O
  cfg_pm_wake_n => cfg_pm_wake_n_c,                      -- I
  cfg_pcie_link_state_n => cfg_pcie_link_state_n_c,      -- O (2:0)
  cfg_trn_pending_n => cfg_trn_pending_n_c,              -- I
  cfg_bus_number => cfg_bus_number_c,                    -- O (7:0)
  cfg_device_number => cfg_device_number_c,              -- O (4:0)
  cfg_function_number => cfg_function_number_c,          -- O (2:0)
  cfg_status => cfg_status_c,                            -- O (15:0)
  cfg_command => cfg_command_c,                          -- O (15:0)
  cfg_dstatus => cfg_dstatus_c,                          -- O (15:0)
  cfg_dcommand => trn_tx_back.cfg_dcommand,              -- O (15:0)
  cfg_lstatus => cfg_lstatus_c,                          -- O (15:0)
  cfg_lcommand => cfg_lcommand_c,                        -- O (15:0)
  cfg_dsn => (others => '0'),

 fast_train_simulation_only => vector_fast_simulation(0)

);

pcie_link_up <= trn_lnk_up_n_c;
pcie_lstatus <= cfg_lstatus_c;

rstp <=  not trn_reset_n_c  after 1 ns when rising_edge( clk );
dcm_rstp <= not trn_reset_n_c;

pb_rstp <= rstp or ( not aclk_lock ) after 1 ns when rising_edge( clk );

  trn_rnp_ok_n_c              <= '0';
  trn_rcpl_streaming_n_c      <= '1'; 
  trn_terrfwd_n_c             <= '1';

  cfg_err_cor_n_c             <= '1';
  cfg_err_ur_n_c              <= '1';
  cfg_err_ecrc_n_c            <= '1';
  cfg_err_cpl_timeout_n_c     <= '1';
  cfg_err_cpl_abort_n_c       <= '1';
  cfg_err_cpl_unexpect_n_c    <= '1';
  cfg_err_posted_n_c          <= '0';

  cfg_interrupt_di_c <= X"00";

  cfg_pm_wake_n_c             <= '1';
  cfg_trn_pending_n_c         <= '1';
  cfg_dwaddr_c                <= (others => '0');
  cfg_err_tlp_cpl_header_c    <= (others => '0');
  cfg_di_c                    <= (others => '0');
  cfg_byte_en_n_c             <= X"F"; -- 4-bit bus
  cfg_wr_en_n_c               <= '1';
  cfg_rd_en_n_c               <= '1';
--  cfg_completer_id_c          <= (cfg_bus_number &
--                                cfg_device_number &
--                                cfg_function_number);
--  cfg_bus_mstr_enable_c       <= cfg_command(2);



rx: core64_rx_engine 
	port map(
	
		--- General ---
		rstp			=> rstp,			--! 1 - ����� 
		clk				=> clk,				--! �������� ������� ���� - 250 MHz 
		
		trn_rx			=> trn_rx,			--! ���� ������
		trn_rx_back		=> trn_rx_back,		--! ���������� � ����� ������
						                
		reg_access		=> reg_access,		--! ������ �� ������ � ��������� 
						                
		rx_tx_engine	=> rx_tx_engine,	--! ����� RX->TX 
		tx_rx_engine	=> tx_rx_engine,	--! ����� TX->RX 
						                
		rx_ext_fifo		=> rx_ext_fifo		--! ����� RX->EXT_FIFO 
		
		
		
	);
	

tx: core64_tx_engine 
	port map(
	
		--- General ---
		rstp			=> rstp,			--! 1 - ����� 
		clk				=> clk,				--! �������� ������� ���� - 250 MHz 
		
		trn_tx			=> trn_tx,			--! �������� ������
		trn_tx_back		=> trn_tx_back,		--! ���������� � �������� ������
						                
		completer_id	=> completer_id,	--! ������������� ���������� 
						                
		reg_access_back	=> reg_access_back,	--! ������ �� ������ � ��������� 
						                
		rx_tx_engine	=> rx_tx_engine,	--! ����� RX->TX 
		tx_rx_engine	=> tx_rx_engine,	--! ����� TX->RX 
						                
		tx_ext_fifo		=> tx_ext_fifo,		--! ����� TX->EXT_FIFO 
		tx_ext_fifo_back=> tx_ext_fifo_back --! ����� TX->EXT_FIFO 
			
	);
	
  completer_id     <= (cfg_bus_number_c &
                       cfg_device_number_c &
                       cfg_function_number_c );	
					   
					   
 reg: core64_reg_access 
	port map(
		--- General ---
		rstp				=> rstp,	--! 1 - ����� 
		clk					=> clk,		--! �������� ������� ���� - 250 MHz 
		
		--- RX_ENGINE ---- 
		reg_access			=> reg_access,	--! ������ �� ������ � ��������� 
		
		--- TX_ENGINE ----
		reg_access_back		=> reg_access_back,	--! ����� �� ������ 
		
		---- PB_DISP ----
		reg_disp			=> reg_disp,		--! ������ �� ������ � ��������� �� BAR1 
		reg_disp_back		=> reg_disp_back,	--! ����� �� ������ 
		
		---- BLOCK EXT_FIFO ----
		reg_ext_fifo		=> reg_ext_fifo,		--! ������ �� ������ � ������ ���������� EXT_FIFO 
		reg_ext_fifo_back	=> reg_ext_fifo_back,	--! ����� �� ������ 
		
		---- BAR0 - ����� ���������� ----
		bp_host_data		=> bp_host_data,	--! ���� ������ - ����� 
		bp_data				=> bp_data,			--! ���� ������ - ����
		bp_adr				=> bp_adr,			--! ����� �������� 
		bp_we				=> bp_we,			--! 1 - ������ � �������� 
		bp_rd				=> bp_rd,			--! 1 - ������ �� ��������� ����� 
		bp_sel				=> bp_sel,			--! ����� ����� ��� ������ 
		bp_reg_we			=> bp_reg_we,		--! 1 - ������ � ������� �� �������   0x100000 - 0x1FFFFF 
		bp_reg_rd			=> bp_reg_rd,		--! 1 - ������ �� �������� �� ������� 0x100000 - 0x1FFFFF 
		bp_irq				=> bp_irq			--! 1 - ������ ���������� 
	);					   

	
 disp: core64_pb_disp 
	port map(
		--- General ---
		rstp				=> pb_rstp,		--! 1 - ����� 
		clk					=> clk,			--! �������� ������� ���� - 250 MHz 
		
		---- PB_DISP ----
		reg_disp			=> reg_disp,		--! ������ �� ������ � ��������� �� BAR1 
		reg_disp_back		=> reg_disp_back,	--! ����� �� ������ 
		
		---- EXT_FIFO ----
		ext_fifo_disp		=> ext_fifo_disp,		--! ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	=> ext_fifo_disp_back,	--! ����� �� ������
		
		---- BAR1 ----	
		aclk				=> aclk,				--! �������� ������� ��������� ���� - 266 ���
		pb_master			=> pb_master,			--! ������ 
		pb_slave			=> pb_slave				--! �����  

	);	
	


fifo: block_pe_fifo_ext 
	port map(
	
		---- Global ----	 
		rstp				 => pb_rstp,				 
		clk					 => clk,					 
		aclk				 => aclk,				 
							                      
		---- TX_ENGINE ----	 
		tx_ext_fifo			 => tx_ext_fifo,			 
		tx_ext_fifo_back	 => tx_ext_fifo_back,	 
							                      
		---- RX_ENGINE ----	 
		rx_ext_fifo			 => rx_ext_fifo,
							                      
		---- REG ----		 
		reg_ext_fifo		 => reg_ext_fifo,		 
		reg_ext_fifo_back	 => reg_ext_fifo_back, 
							 	                 
		---- DISP  ----		 
		ext_fifo_disp		 => ext_fifo_disp,
		ext_fifo_disp_back	 => ext_fifo_disp_back,
		
		irq					 => irq,				-- 1 - ������ ����������
		
		test				=> px
	);
		
	
 

 int: core64_interrupt 
	port map(
	
		rstp					=> pb_rstp,					-- 1 - �����
		clk						=> clk,						-- �������� ������� ���� 250 ���
		
		irq						=> irq,						-- 1 - ������ ����������
		
		cfg_command10			=> cfg_command_c(10),		-- 1 - ���������� ��������� 
		cfg_interrupt			=> cfg_interrupt_n_c, 		-- 0 - ��������� ��������� ����������
		cfg_interrupt_assert	=> cfg_interrupt_assert_n_c,-- 0 - ������������ ����������, 1 - ������� ���������� 
		cfg_interrupt_rdy		=> cfg_interrupt_rdy_n_c	-- 0 - ������������� ��������� ���������� 
	
	);
	
--	cfg_interrupt_n_c <= '1';
--	cfg_interrupt_assert_n_c <= '1';
	
end pcie_core64_m1;
