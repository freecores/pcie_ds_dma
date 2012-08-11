-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m7
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  ���������� PCI Express
--				  ����������� 7 - Spartan-6 PCI Express v1.1 x1
--				  ���� LC_BUS 64 �������
--				  ���� PE_MAIN 
--
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

package	pcie_core64_m7_pkg is

--! ���������� PCI-Express 
component pcie_core64_m7 is
	generic (
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������������� ������
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ������
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ����
		
		is_simulation	: integer:=0	--! 0 - ������, 1 - ������������� 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 0 downto 0 );
		txn				: out std_logic_vector( 0 downto 0 );
		
		rxp				: in  std_logic_vector( 0 downto 0 );
		rxn				: in  std_logic_vector( 0 downto 0 );
		
		mgt125			: in  std_logic; -- �������� ������� 125 MHz �� PCI_Express
		
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

end package;



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;
use work.pcie_core64_m6_pkg.all;
use work.core64_pb_transaction_pkg.all;
use work.block_pe_main_pkg.all;

--! ���������� PCI-Express 
entity pcie_core64_m7 is
	generic (				 
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������������� ������
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ������
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ����
	
		is_simulation	: integer:=0	--! 0 - ������, 1 - ������������� 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 0 downto 0 );
		txn				: out std_logic_vector( 0 downto 0 );
		
		rxp				: in  std_logic_vector( 0 downto 0 );
		rxn				: in  std_logic_vector( 0 downto 0 );
		
		mgt125			: in  std_logic; -- �������� ������� 125 MHz �� PCI_Express
		
		perst			: in  std_logic;	-- 0 - �����						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! ����������� ����� 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- ������� LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - ��������� ������������� PCI-Express
		
		
		---- ��������� ���� ----			  
		clk250_out		: out std_logic;	--! �������� ������� 250 MHz		  
		reset_out		: out std_logic;	--! 0 - �����
		dcm_rstp		: out std_logic;		--! 1 - ����� DCM 266 ���
		clk				: in std_logic;			--! �������� ������� ��������� ���� - 266 ���
		clk_lock		: in std_logic;			--! 1 - ������ �������

		---- BAR1 ----
		lc_adr			: out std_logic_vector( 31 downto 0 );	--! ���� ������
		lc_host_data	: out std_logic_vector( 63 downto 0 );	--! ���� ������ - �����
		lc_data			: in  std_logic_vector( 63 downto 0 );	--! ���� ������ - ����
		lc_wr			: out std_logic;	--! 1 - ������
		lc_rd			: out std_logic;	--! 1 - ������, ������ ������ ���� �� �������� ���� ����� rd
		lc_dma_req		: in  std_logic_vector( 1 downto 0 );	--! 1 - ������ DMA
		lc_irq			: in  std_logic		--! 1 - ������ ���������� 
		
				
		
	);
end pcie_core64_m7;


architecture pcie_core64_m7 of pcie_core64_m7 is

---- BAR0 - ����� ���������� ----
signal	bp_host_data	: std_logic_vector( 31 downto 0 );	--! ���� ������ - ����� 
signal	bp_data			: std_logic_vector( 31 downto 0 );  --! ���� ������ - ����
signal	bp_adr			: std_logic_vector( 19 downto 0 );	--! ����� �������� ������ ����� 
signal	bp_we			: std_logic_vector( 3 downto 0 ); 	--! 1 - ������ � �������� 
signal	bp_rd			: std_logic_vector( 3 downto 0 );   --! 1 - ������ �� ��������� ����� 
signal	bp_sel			: std_logic_vector( 1 downto 0 );	--! ����� ����� ��� ������ 
signal	bp_reg_we		: std_logic;			--! 1 - ������ � ������� �� �������   0x100000 - 0x1FFFFF 
signal	bp_reg_rd		: std_logic; 			--! 1 - ������ �� �������� �� ������� 0x100000 - 0x1FFFFF 
signal	bp_irq			: std_logic;						--! 1 - ������ ���������� 

signal	clk250			: std_logic;
signal	reset			: std_logic;

signal	pb_master		: type_pb_master;		--! ������ 
signal	pb_slave		: type_pb_slave;		--! �����  

signal	pb_reset		: std_logic;
signal	brd_mode		: std_logic_vector( 15 downto 0 );

signal	bp0_data		: std_logic_vector( 31 downto 0 );

begin
	
	
core: pcie_core64_m6 
	generic map(
		is_simulation	=> is_simulation		--! 0 - ������, 1 - ������������� 
	)		  
	port map(
	
		---- PCI-Express ----
		txp				  => txp,				
		txn				  => txn,				
						                  
		rxp				  => rxp,				
		rxn				  => rxn,				
						                  
		mgt125			  => mgt125,			
						                  
		perst			  => perst,			
						                  
		px				  => px,				
						                  
		pcie_lstatus	  => pcie_lstatus,	
		pcie_link_up	  => pcie_link_up,	
		
		
		---- ��������� ���� ----			  
		clk_out			 => clk250,
		reset_out		 => reset,
		dcm_rstp		 => dcm_rstp, 

		---- BAR1 ----
		aclk			=> clk,
		aclk_lock		=> clk_lock,
		pb_master		=> pb_master,		
		pb_slave		=> pb_slave,		

						                 
		---- BAR0 - ����� ���������� ----
		bp_host_data	=> bp_host_data,	
		bp_data			=> bp_data,			
		bp_adr			=> bp_adr,			
		bp_we			=> bp_we,			
		bp_rd			=> bp_rd,
		bp_sel			=> bp_sel,			
		bp_reg_we		=> bp_reg_we,		
		bp_reg_rd		=> bp_reg_rd,		
		bp_irq			=> bp_irq
						                
		
	);	

reset_out <= reset;
clk250_out   <= clk250;

bp_data <= bp0_data when bp_sel="00" else (others=>'0');

tz: core64_pb_transaction 
	port map(
		reset				=> reset,		--! 0 - �����
		clk					=> clk,			--! �������� ������� ��������� ���� - 266 ��� 
		
		---- BAR1 ----	
		pb_master			=> pb_master,			--! ������ 
		pb_slave			=> pb_slave,			--! �����  
		
		---- ��������� ���� -----		
		lc_adr				=> lc_adr,				
		lc_host_data		=> lc_host_data,	
		lc_data				=> lc_data,			
		lc_wr				=> lc_wr,			
		lc_rd				=> lc_rd,			
		lc_dma_req			=> lc_dma_req,		
		lc_irq				=> lc_irq		
	);
				
	
main: block_pe_main 
	generic map(
		Device_ID		=> Device_ID,	 		-- ������������� ������
		Revision		=> Revision,		 	-- ������ ������
		PLD_VER			=> PLD_VER,				-- ������ ����
		BLOCK_CNT		=> x"0008"  			-- ����� ������ ���������� 
		
	)	
	port map(
	
		---- Global ----
		reset_hr1		=> reset,		-- 0 - �����
		clk				=> clk250,		-- �������� ������� DSP
		pb_reset		=> pb_reset,	-- 0 - ����� ������� ����
		
		---- HOST ----
		bl_adr			=> bp_adr( 4 downto 0 ),		-- �����
		bl_data_in		=> bp_host_data,				-- ������
		bl_data_out		=> bp0_data,					-- ������
		bl_data_we		=> bp_we(0),					-- 1 - ������ ������   
		
		---- ���������� ----
		brd_mode		=> brd_mode						-- ������� BRD_MODE

	);		
		
end pcie_core64_m7;
