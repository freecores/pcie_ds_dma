-------------------------------------------------------------------------------
--
-- Title       : ctrl_dma_ext_cmd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : ���� ������������ ������� ��� ����������� DMA PLDA
--				  
--		���� ��������� ��������� ��������� ��� ��������� ���������� ������
--										   
--		���� �������� ���������:
--			0: 1 - ���������� ������
--			1: 1 - ������ ��� ������ 
--			2: 1 - ������ ����� 0
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library	work;
use work.core64_type_pkg.all;

package ctrl_dma_ext_cmd_pkg is
	
component ctrl_dma_ext_cmd is	   	  
	generic(
		is_dsp48		: in integer:=1		-- 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(						  
		---- Global ----
		rstp				: in std_logic;		--! 1 - �����
		clk					: in std_logic;		--! �������� ������� 250 ���
		
		---- CTRL_MAIN ----
		dma_reg0			: in std_logic_vector( 2 downto 0 );	--! ������� �����������
																	--! 0:  1 - ������ ������
																	--! 1:  1 - ���� 4 kB, 0 - 512 ����
																	--! 2:  1 - ���������� ������, 0 - ������ ������ �� �����������
		
		dma_change_adr		: in std_logic	;	--! 1 - ��������� ������ � �������
		dma_cmd_status		: out std_logic_vector( 2 downto 0 );	--! ��������� DMA
																--! 0: 1 - ���������� ������
																--! 1: 1 - ������ ��� ������
																--! 2: 1 - ������ ����� ����� 0
		dma_chn				: in std_logic;							--! ����� ������ DMA
		
		---- CTRL_EXT_DESCRIPTOR ----			 
		dsc_adr_h			: in std_logic_vector( 7 downto 0 );    --! �����, ���� 4
		dsc_adr				: in std_logic_vector( 23 downto 0 );	--! �����, ����� 3..1
		dsc_size			: in std_logic_vector( 23 downto 0 );	--! ������, ����� 3..1
		

		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! ����� TX->EXT_FIFO 
		tx_req_wr			: out std_logic;				--! 1 - ���������� ������ ����� 4 ��
		tx_req_rd			: out std_logic;				--! 1 - ���������� ������
		tx_rd_size			: out std_logic;				--! 0 - 512 ����, 1 - 4 ��
		tx_pci_adr			: out std_logic_vector( 39 downto 8 );	--! ����� �� ���� PCI 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! ����� RX->EXT_FIFO 
		
		---- ����������� ����� ----
		test				: out std_logic_vector( 3 downto 0 )
	);
		
	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;		

library	work;
use work.core64_type_pkg.all;
use work.ctrl_dma_adr_pkg.all;


entity ctrl_dma_ext_cmd is	   
	generic(
		is_dsp48		: in integer:=1		-- 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(
		---- Global ----
		rstp				: in std_logic;		--! 1 - �����
		clk					: in std_logic;		--! �������� ������� 250 ���
		
		---- CTRL_MAIN ----
		dma_reg0			: in std_logic_vector( 2 downto 0 );	--! ������� �����������
																	--! 0:  1 - ������ ������
																	--! 1:  1 - ���� 4 kB, 0 - 512 ����
																	--! 2:  1 - ���������� ������, 0 - ������ ������ �� �����������
		dma_change_adr		: in std_logic	;	--! 1 - ��������� ������ � �������
		dma_cmd_status		: out std_logic_vector( 2 downto 0 );	--! ��������� DMA
																--! 0: 1 - ���������� ������
																--! 1: 1 - ������ ��� ������
																--! 2: 1 - ������ ����� ����� 0
		dma_chn				: in std_logic;							--! ����� ������ DMA
		
		---- CTRL_EXT_DESCRIPTOR ----			 
		dsc_adr_h			: in std_logic_vector( 7 downto 0 );    --! �����, ���� 4
		dsc_adr				: in std_logic_vector( 23 downto 0 );	--! �����, ����� 3..1
		dsc_size			: in std_logic_vector( 23 downto 0 );	--! ������, ����� 3..1
		

		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! ����� TX->EXT_FIFO 
		tx_req_wr			: out std_logic;				--! 1 - ���������� ������ ����� 4 ��
		tx_req_rd			: out std_logic;				--! 1 - ���������� ������
		tx_rd_size			: out std_logic;				--! 0 - 512 ����, 1 - 4 ��
		tx_pci_adr			: out std_logic_vector( 39 downto 8 );	--! ����� �� ���� PCI 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! ����� RX->EXT_FIFO 
		
		---- ����������� ����� ----
		test				: out std_logic_vector( 3 downto 0 )
	);
		
	
end ctrl_dma_ext_cmd;


architecture ctrl_dma_ext_cmd of ctrl_dma_ext_cmd is	

type stp_type is ( s0, s1, s2, s3 );

signal	stp		: stp_type;


signal	status	: std_logic_vector( 3 downto 0 );	  

signal	dma_rw	: std_logic;	  

signal	cnt_pause	: std_logic_vector( 5 downto 0 );

signal	dma_cmd_rdy		: std_logic;
signal	dma_cmd_error	: std_logic;
signal	dma_cmd_start	: std_logic;		 

signal	pci_adr			: std_logic_vector( 39 downto 0 );
signal	pci_size_z		: std_logic;

signal	size4k			: std_logic;


begin					
	
	
dma_cmd_start <= dma_reg0(0);

dma_adr: ctrl_dma_adr 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		clk				=> clk,			-- �������� �������
		
		---- ������ � PICOBLAZE ----
		dma_chn			=> dma_chn,				-- ����� ������ DMA	  
		reg0			=> dma_reg0,			-- ������� DMA_CTRL
		reg41_wr		=> dma_change_adr,	 	-- 1 - ������ � ������� 41
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr			=> dsc_adr,				-- �����, ����� 3..1
		dsc_adr_h		=> dsc_adr_h,		    -- �����, ���� 4
		dsc_size		=> dsc_size,			-- ������, ����� 3..1

		---- ����� ----
		pci_adr			=> pci_adr,				-- ������� ����� 
		pci_size_z		=> pci_size_z,			-- 1 - ������ ����� 0
		pci_rw			=> dma_rw				-- 0 - ������, 1 - ������	

	);


size4k <= dma_reg0(1);

tx_pci_adr <= pci_adr( 39 downto 8 );
tx_rd_size <= size4k;

dma_cmd_status(0) <= dma_cmd_rdy;
dma_cmd_status(1) <= dma_cmd_error;		 
dma_cmd_status(2) <= pci_size_z;

pr_state: process( clk ) begin
	if( rising_edge( clk ) ) then

		case( stp ) is
			when s0 =>
				if( dma_cmd_start='1' ) then
					stp <= s1 after 1 ns;
				end if;		
				
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;
				dma_cmd_rdy <= '0' after 1 ns;
				dma_cmd_error <= '0' after 1 ns;
				
			when s1 =>
			
				tx_req_rd <= (not dma_rw) or (not size4k) after 1 ns;
				tx_req_wr <= dma_rw and size4k after 1 ns;
				
				if( tx_ext_fifo.complete_ok='1' ) then 
					stp <= s2 after 1 ns;			   
				elsif( tx_ext_fifo.complete_error='1' ) then
					stp <= s3 after 1 ns;			   
				end if;
				
				dma_cmd_error <= tx_ext_fifo.complete_error after 1 ns;
				
			when s2 =>
				
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;
				
				dma_cmd_rdy <= '1' after 1 ns;
				if( dma_cmd_start='0' ) then
					stp <= s0 after 1 ns;
				end if;		 
				
			when s3 =>
				tx_req_rd <= '0' after 1 ns;
				tx_req_wr <= '0' after 1 ns;   
				if( tx_ext_fifo.complete_error='0' ) then
					stp <= s0 after 1 ns;
				end if;
				
			
		end case;
									
		
		if( rstp='1' ) then
			stp <= s0 after 1 ns;
		end if;
				
	end if;
end process;





end ctrl_dma_ext_cmd;
