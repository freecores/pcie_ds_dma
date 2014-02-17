-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m5
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1
--
-------------------------------------------------------------------------------
--
-- Description :  ���������� ���� PCI Express 
--				  ����������� 4 - Virtex 6 PCI Express 2.0 x4 
--
--				  �������� pcie_core64_m4, block_pe_main, core64_pb_transaction
--				  ��������� ���� LC_BUS 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  	17.02.2014
--					��������� ��������� Artix 7 - pcie_core64_m10
--
-------------------------------------------------------------------------------
--
--  Version 1.0  	15.08.2011
--					������ �� pcie_core64_m2 v1.0
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package	pcie_core64_m5_pkg is

--! ���������� PCI-Express 
component pcie_core64_m5 is
	generic ( 
		CORE_NAME		: in string:="pcie_core64_m4";
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������������� ������
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ������
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ����
		
		refclk			: integer:=100;		--! �������� ������� �������� ������� [���]
		is_simulation	: integer:=0	--! 0 - ������, 1 - ������������� 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; -- �������� ������� 250 MHz ��� 100 MHz �� PCI_Express
		
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
		lc_irq			: in  std_logic;	--! 1 - ������ ���������� 
		lc_rd_cfg		: in std_logic_vector( 3 downto 0 ):="0101"	--! ��������� �������� ������� ������ �� ������� lc_rd				
		
				
		
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;
--use work.pcie_core64_m4_pkg.all;
use work.core64_pb_transaction_pkg.all;
use work.block_pe_main_pkg.all;

--! ���������� PCI-Express 
entity pcie_core64_m5 is
	generic (				 
		CORE_NAME		: in string:="pcie_core64_m4";
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������������� ������
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ������
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- ������ ����
	
		refclk			: integer:=100;		--! �������� ������� �������� ������� [���]
		is_simulation	: integer:=0	--! 0 - ������, 1 - ������������� 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; -- �������� ������� 250 MHz ��� 100 MHz �� PCI_Express
		
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
		lc_irq			: in  std_logic;	--! 1 - ������ ���������� 
		lc_rd_cfg		: in std_logic_vector( 3 downto 0 ):="0101"	--! ��������� �������� ������� ������ �� ������� lc_rd				
		
				
		
	);
end pcie_core64_m5;


architecture pcie_core64_m5 of pcie_core64_m5 is

--! ���������� PCI-Express 
component pcie_core64_m4 is
	generic (  
		DEVICE_ID			: in bit_vector := X"5507";   	--! �������� �������� DeviceID 
		refclk				: in integer:=100;				--! �������� ������� �������� ������� [���]
		is_simulation		: in integer:=0;				--! 0 - ������, 1 - ������������� 
		interrupt_number	: in std_logic_vector( 1 downto 0 ):="00"	-- ����� INTx: 0 - INTA, 1 - INTB, 2 - INTC, 3 - INTD 
		
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; --! �������� ������� 250 MHz ��� 100 ��� �� PCI_Express
		
		perst			: in  std_logic;	--! 0 - �����						   
		
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

component pcie_core64_m10 is
	generic (  
		DEVICE_ID			: in std_logic_vector := x"5507";   	--! �������� �������� DeviceID 
		refclk				: in integer:=100;				--! �������� ������� �������� ������� [���]
		is_simulation		: in integer:=0;				--! 0 - ������, 1 - ������������� 
		interrupt_number	: in std_logic_vector( 1 downto 0 ):="00"	-- ����� INTx: 0 - INTA, 1 - INTB, 2 - INTC, 3 - INTD 
		
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 3 downto 0 );
		txn				: out std_logic_vector( 3 downto 0 );
		
		rxp				: in  std_logic_vector( 3 downto 0 );
		rxn				: in  std_logic_vector( 3 downto 0 );
		
		mgt250			: in  std_logic; --! �������� ������� 250 MHz ��� 100 ��� �� PCI_Express
		
		perst			: in  std_logic;	--! 0 - �����						   
		
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
	
gen_m4: if( CORE_NAME="pcie_core64_m4" ) generate
	
core: pcie_core64_m4 
	generic map(
		refclk			=> refclk,				--! �������� ������� �������� ������� [���]
		is_simulation	=> is_simulation		--! 0 - ������, 1 - ������������� 
	)		  
	port map(
	
		---- PCI-Express ----
		txp				  => txp,				
		txn				  => txn,				
						                  
		rxp				  => rxp,				
		rxn				  => rxn,				
						                  
		mgt250			  => mgt250,			
						                  
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
	
end generate;	

	
gen_m10: if( CORE_NAME="pcie_core64_m10" ) generate
	
core: pcie_core64_m10 
	generic map(
		DEVICE_ID			=> Device_ID,	   		--! �������� �������� DeviceID 
		refclk				=> refclk,				--! �������� ������� �������� ������� [���]
		is_simulation		=> is_simulation		--! 0 - ������, 1 - ������������� 
	)		  
	port map(
	
		---- PCI-Express ----
		txp				  => txp,				
		txn				  => txn,				
						                  
		rxp				  => rxp,				
		rxn				  => rxn,				
						                  
		mgt250			  => mgt250,			
						                  
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
	
end generate;

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
		lc_irq				=> lc_irq,		
		lc_rd_cfg			=> lc_rd_cfg	
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
		
end pcie_core64_m5;
