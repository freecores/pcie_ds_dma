--------------------------------------------------------------------------------------------------
--
-- Title       : block_pe_fifo_ext
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.3
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--		���� ���������� FIFO ��� �������� � ����� PCI-Express
--		
--		����������� 2 - ������ ����� �����������������	
--					  - ��� ������� DS_DMA64 
--
--		��������:
--				0x08 - DMA_MODE
--							��� 0:   CG_MODE   		1 - ������ � ������ �����������������
--							��� 1:   DEMAND_MODE	1 - ������ � ������ �� ��������
--							��� 2:   DIRECT			1 - �������� ADM->HOST, 0 - �������� HOST->ADM
--				
--							��� 5:   DMA_INT_ENABLE  1 - ���������� ������������ ���������� �� ����� EOT
--
--				0x09 - DMA_CTRL
--							��� 0:   DMA_START		 - 1 - ���������� ������ DMA
--							��� 1:   DMA_STOP		 - 1 - ���������� ��������
--
--							��� 3:   PAUSE	 		 - 1 - ������������ ������
--							��� 4:   RESET_FIFO		 - 1 - ����� ����������� FIFO ������ DMA
--				
--				0x0A - BLOCK_CNT - ����� ������ ��� ������
--
--
--				0x10 - STATUS
--							���� 3..0:  DMA_STATUS
--							���  4:	    DMA_EOT 		- 1 - ���������� DMA
--							���  5:  	DMA_SG_EOT		- 1 - ���������� DMA � ������ SG	
--							���  6:     DMA_INT_ERROR 	- 1 - ������� ��������� ���������� �� DMA_EOT
--							���  7:     INT_REQ			- 1 - ������ DMA
--							���  8:     DSC_CORRECT  	- 1 - ���� ������������ ����������
--
--							���� 15..12:  SIG			- ��������� 0xA
--					   
--				0x11 - FLAG_CLR
--							���  4:      DMA_EOT 	- 1 - ����� ���� DMA_EOT � �������� STATUS
--
--				0x14 - PCI_ADRL
--				0x15 - PCI_ADRH
--				
--				0x17 - LOCAL_ADR
--					
--
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.3		14.12.2011
--					���������� ����������� ����� ������������ ����� ������� ����� 
--					����� ������������
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;   

library	work;
use work.core64_type_pkg.all;

package block_pe_fifo_ext_pkg is
	
component block_pe_fifo_ext is				
	generic(
		is_dsp48			: in integer:=1			--! 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(
	
		---- Global ----
		rstp				: in std_logic;		--! 1 - �����
		clk					: in std_logic;		--! �������� ������� ���� - 250 ���
		aclk				: in std_logic;		--! �������� ������� ��������� ���� - 266 ���
		
		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! ����� TX->EXT_FIFO 
		tx_ext_fifo_back	: out type_tx_ext_fifo_back;	--! ����� TX->EXT_FIFO 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! ����� RX->EXT_FIFO 
		
		---- REG ----
		reg_ext_fifo		: in  type_reg_ext_fifo;		--! ������ �� ������ � ������ ���������� EXT_FIFO 
		reg_ext_fifo_back	: out type_reg_ext_fifo_back;	--! ����� �� ������ 
			
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back;	--! ����� �� ������
		
		irq					: out std_logic;				--! 1 - ������ ����������
		
		test				: out std_logic_vector( 7 downto 0 )
		
		
							   
	);	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library	work;
use work.ctrl_dma_ext_cmd_pkg.all;		  
use work.ctrl_ext_descriptor_pkg.all;  
use work.ctrl_ext_ram_pkg.all;		
use work.ctrl_main_pkg.all;

library unisim;
use unisim.vcomponents.all;

use work.core64_type_pkg.all;

entity block_pe_fifo_ext is	
	generic(
		is_dsp48			: in integer:=1			--! 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(
	
		---- Global ----
		rstp				: in std_logic;		--! 1 - �����
		clk					: in std_logic;		--! �������� ������� ���� - 250 ���
		aclk				: in std_logic;		--! �������� ������� ��������� ���� - 266 ���
		
		---- TX_ENGINE ----
		tx_ext_fifo			: in type_tx_ext_fifo;			--! ����� TX->EXT_FIFO 
		tx_ext_fifo_back	: out type_tx_ext_fifo_back;	--! ����� TX->EXT_FIFO 
		
		---- RX_ENGINE ----
		rx_ext_fifo			: in type_rx_ext_fifo;			--! ����� RX->EXT_FIFO 
		
		---- REG ----
		reg_ext_fifo		: in  type_reg_ext_fifo;		--! ������ �� ������ � ������ ���������� EXT_FIFO 
		reg_ext_fifo_back	: out type_reg_ext_fifo_back;	--! ����� �� ������ 
			
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back;	--! ����� �� ������

		irq					: out std_logic;				--! 1 - ������ ����������
		
		test				: out std_logic_vector( 7 downto 0 )
		
	);		
end block_pe_fifo_ext;


architecture block_pe_fifo_ext of block_pe_fifo_ext is					   



signal	ram_adra	: std_logic_vector( 8 downto 0 );
signal	ram_adrb	: std_logic_vector( 8 downto 0 );
signal	ram_di_a	: std_logic_vector( 31 downto 0 );
signal	ram_do_a	: std_logic_vector( 31 downto 0 );
signal	ram_we_a	: std_logic;
signal	ram_do_b	: std_logic_vector( 31 downto 0 );
signal	reg_dma0_status	: std_logic_vector( 15 downto 0 );
signal	reg_dma1_status	: std_logic_vector( 15 downto 0 );

------------------------------------------------------------------------------------
--
-- declaration of KCPSM3
--
  component kcpsm3
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component p_fifo
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM
--
signal     address : std_logic_vector(9 downto 0);
signal instruction : std_logic_vector(17 downto 0);
signal 	port_id		: std_logic_vector( 7 downto 0 );
signal	write_strobe	: std_logic;
signal	read_strobe		: std_logic;
signal	interrupt		: std_logic;
signal	interrupt_ack	: std_logic;
signal	kc_reset		: std_logic;
signal	in_port			: std_logic_vector( 7 downto 0 );
signal	out_port		: std_logic_vector( 7 downto 0 );

signal	reg4_do			: std_logic_vector( 7 downto 0 );
signal	reg8_do			: std_logic_vector( 7 downto 0 );
signal	ram0_wr			: std_logic;
signal	ram1_wr			: std_logic;
signal	ram_adr			: std_logic_vector( 10 downto 0 );

signal	reg_dma_chn		: std_logic_vector( 1 downto 0 );
signal	reg_status		: std_logic_vector( 7 downto 0 );
signal	reg_dma_status	: std_logic_vector( 3 downto 0 );
signal	reg_descriptor_status	: std_logic_vector( 1 downto 0 );		 
signal	dsc_adr_h		: std_logic_vector( 7 downto 0 );    -- �����, ���� 4
signal	dsc_adr			: std_logic_vector( 23 downto 0 );
signal	dsc_size		: std_logic_vector( 23 downto 0 ); 

signal	dma0_rs0		: std_logic_vector( 7 downto 0 );
signal	dma1_rs0		: std_logic_vector( 7 downto 0 );		   
signal	dma0_rs0x		: std_logic_vector( 7 downto 0 );
signal	dma1_rs0x		: std_logic_vector( 7 downto 0 );		   
signal	dma_rs0			: std_logic_vector( 7 downto 0 );
signal	reg_test		: std_logic_vector( 7 downto 0 );

signal	dx				: std_logic_vector( 7 downto 0 );	
signal	ram_transfer_rdy	: std_logic;

signal	dma0_transfer_rdy	: std_logic;
signal	dma1_transfer_rdy	: std_logic;
signal	dma0_eot_clr		: std_logic;
signal	dma1_eot_clr		: std_logic;
signal	dma0_ctrl			: std_logic_vector( 7 downto 0 );
signal	dma1_ctrl			: std_logic_vector( 7 downto 0 );
signal	ram_change			: std_logic;	-- 1 - ��������� ����� ������
signal	reg_dma0_ctrl		: std_logic_vector( 7 downto 0 );
signal	reg_dma1_ctrl		: std_logic_vector( 7 downto 0 );
signal	reg_dma0_mode		: std_logic_vector( 7 downto 0 );
signal	reg_dma1_mode		: std_logic_vector( 7 downto 0 );
		
		---- ctrl_ext_descriptor ----
signal	dsc_correct			: std_logic;		-- 1 - �������� ���������� ����������
signal	dsc_cmd				: std_logic_vector( 7 downto 0 );	-- ��������� ����� �����������
signal	dsc_change_adr		: std_logic;	-- 1 - ����� ������ �����������
signal	dsc_change_mode		: std_logic;	-- ����� ��������� ������:
												-- 0: - ����������
		                                      	-- 1: - ������� � �������� �����������
signal	dsc_load_en			: std_logic;	-- 1 - ���������� ������ �����������
		
		---- ctrl_dma_ext_cmd ----						 
signal	dma_reg0			: std_logic_vector( 2 downto 0 );	-- ������� �����������
signal	dma_change_adr		: std_logic	;	-- 1 - ��������� ������ � �������
signal	dma_cmd_status		: std_logic_vector( 2 downto 0 );	-- ��������� DMA
signal	dma_chn				: std_logic;

signal	pci_adr_we			: std_logic;			 
signal	pci_adr_h_we		: std_logic;	-- 1 - ������ ������� �������� ������
signal	loc_adr_we			: std_logic;

signal	ack_cnt				: std_logic_vector( 4 downto 0 );

signal	reset				: std_logic;

signal	dma_wraddr			: std_logic_vector( 11 downto 0 );
signal	dma_rdaddr			: std_logic_vector( 11 downto 0 );	 
signal 	dma_wrdata			: std_logic_vector( 63 downto 0 );

signal	req_rd				: std_logic;
signal	req_wr				: std_logic;
signal	dsc_check_start		: std_logic;	-- 1 - �������� �����������
signal	dsc_check_ready		: std_logic;	-- 1 - �������� ���������
--
------------------------------------------------------------------------------------


begin	

reset <= not rstp after 1 ns when rising_edge( clk );


--test( 7 downto 4 ) <= (others=>'-');  

test(4) <= req_rd after 1 ns when rising_edge( clk );
test(5) <= req_wr after 1 ns when rising_edge( clk );
test(6) <= dsc_load_en;	 
test(7) <= dsc_change_adr;

ram_adrb( 8 downto 7 ) <= (others=>'0');
ram_adrb( 6 downto 0 ) <= reg_ext_fifo.adr;
	
dma_wraddr( 11 downto 0 ) <= rx_ext_fifo.adr & "000";
dma_rdaddr( 11 downto 0 ) <= tx_ext_fifo.adr & "000";
dma_wrdata <= rx_ext_fifo.data;

ram0_wr <= rx_ext_fifo.data_we ;	 
ram1_wr <= rx_ext_fifo.data_we and dma_reg0(1);

ram: RAMB16_S36_S36 
  generic map(
    SIM_COLLISION_CHECK => "NONE",
  	INIT_00	 =>  x"000000000000000000000000" & x"00000002" & x"00000000" & x"00003400" & x"00000103" & x"00001018",
	INIT_04	 =>  x"000000000000000000000000" & x"00000002" & x"00000001" & x"00003400" & x"00000103" & x"00001018"
    )

  port map(
    DOA   => ram_do_a,
    DOB   => ram_do_b, --: out std_logic_vector(15 downto 0);
	
    ADDRA => ram_adra,
    ADDRB => ram_adrb,
    CLKA  => clk,
    CLKB  => clk,
    DIA   => ram_di_a,
    DIB   => reg_ext_fifo.data,
    ENA   => '1',
    ENB   => '1',
    DIPA  => (others=>'0'),
    DIPB  => (others=>'0'),		 
    SSRA  => '0',
    SSRB  => '0',
    WEA   => ram_we_a,
    WEB   => reg_ext_fifo.data_we
	
	
    --ADDRA : in std_logic_vector(10 downto 0);
    --ADDRB : in std_logic_vector(9 downto 0);
 
    );
	
	
reg_ext_fifo_back.data( 15 downto 0 )	<=	reg_dma0_status when  ram_adrb="0010000" else
											reg_dma1_status when  ram_adrb="0110000" else
											ram_do_b( 15 downto 0 );
 
reg_ext_fifo_back.data( 31 downto 16 ) <= ram_do_b( 31 downto 16 );


test(0) <= reg_dma0_status(4) after 1 ns when rising_edge( clk );
test(1) <= dma0_transfer_rdy after 1 ns when rising_edge( clk );	  
test(2) <= dma_cmd_status(0) after 1 ns when rising_edge( clk );
test(3) <= dma0_eot_clr after 1 ns when rising_edge( clk );



pr_dma_ctrl: process( clk ) begin
	if( rising_edge( clk ) ) then
		dma0_eot_clr <= '0' after 1 ns;
		dma1_eot_clr <= '0' after 1 ns;
		if( rstp='1' ) then
			reg_dma0_ctrl <= x"00" after 1 ns;
			reg_dma1_ctrl <= x"00" after 1 ns;
			reg_dma0_mode <= x"00" after 1 ns;
			reg_dma1_mode <= x"00" after 1 ns;
		elsif( reg_ext_fifo.data_we='1' ) then  
			case( reg_ext_fifo.adr ) is
				when "0001000" => reg_dma0_mode <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0001001" => reg_dma0_ctrl <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0010001" => dma0_eot_clr  <= reg_ext_fifo.data(4) after 1 ns;
				when "0101000" => reg_dma1_mode <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0101001" => reg_dma1_ctrl <= reg_ext_fifo.data( 7 downto 0 ) after 1 ns;
				when "0110001" => dma1_eot_clr  <= reg_ext_fifo.data(4) after 1 ns;
				when others => null;
			end case;
		end if;
	end if;
end process;

dma0_ctrl(0) <= reg_dma0_ctrl(0); -- DMA_START	 
dma0_ctrl(1) <= reg_dma0_mode(1); -- DEMAND_MODE
dma0_ctrl(2) <= reg_dma0_mode(2); -- DIRECT
dma0_ctrl(3) <= reg_dma0_ctrl(3); -- PAUSE
dma0_ctrl(4) <= reg_dma0_ctrl(4); -- RESET_FIFO
dma0_ctrl(5) <= reg_dma0_mode(5); -- DMA_INT_ENABLE
dma0_ctrl(6) <= '0';
dma0_ctrl(7) <= '0';


dma1_ctrl(0) <= reg_dma1_ctrl(0); -- DMA_START	 
dma1_ctrl(1) <= reg_dma1_mode(1); -- DEMAND_MODE
dma1_ctrl(2) <= reg_dma1_mode(2); -- DIRECT
dma1_ctrl(3) <= reg_dma1_ctrl(3); -- PAUSE
dma1_ctrl(4) <= reg_dma1_ctrl(4); -- RESET_FIFO
dma1_ctrl(5) <= reg_dma1_mode(5); -- DMA_INT_ENABLE
dma1_ctrl(6) <= '0';
dma1_ctrl(7) <= '0';



main: ctrl_main 
	port map(
		---- Global ----
		reset				=> reset,	-- 0 - �����
		clk					=> clk,		-- �������� �������

		---- �������� ���������� ----
		dma0_ctrl			=> dma0_ctrl,		-- ������� DMA_CTRL, ����� 0
		dma1_ctrl			=> dma1_ctrl,		-- ������� DMA_CTRL, ����� 0
		
		---- ctrl_ext_ram ----
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - ����� 0 ����� � ������
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - ����� 1 ����� � ������
		
		---- ���������� DMA ----
		dma_chn				=> dma_chn,			-- ����� ������ DMA ��� �������� ������
		ram_do				=> ram_di_a( 7 downto 0 ),		-- ������ ��� ������ � ������� STATUS
		ram_adr				=> ram_adra,		-- ����� ��� ������ � ������� STATUS
		ram_we				=> ram_we_a,		-- 1 - ������ � ������
		dma0_eot_clr		=> dma0_eot_clr,	-- 1 - ����� ����� DMA0_EOT
		dma1_eot_clr		=> dma1_eot_clr,	-- 1 - ����� ����� DMA1_EOT
		
		reg_dma0_status		=> reg_dma0_status,	-- ������� STATUS ������ 0
		reg_dma1_status		=> reg_dma1_status,	-- ������� STATUS ������ 1
		
		---- ctrl_ext_ram	----
		ram_change			=> ram_change,		-- 1 - ��������� ����� ������
		loc_adr_we			=> loc_adr_we,		-- 1 - ������ ���������� ������
		
		---- ctrl_ext_descriptor ----
		pci_adr_we			=> pci_adr_we,		-- 1 - ������ ������
		pci_adr_h_we		=> pci_adr_h_we,	-- 1 - ������ ������� �������� ������
		dsc_correct			=> dsc_correct,		-- 1 - �������� ���������� ����������
		dsc_cmd				=> dsc_cmd,			-- ��������� ����� �����������
		dsc_change_adr		=> dsc_change_adr,	-- 1 - ����� ������ �����������
		dsc_change_mode		=> dsc_change_mode,	-- ����� ��������� ������:
												-- 0: - ����������
		                                      	-- 1: - ������� � �������� �����������
		dsc_load_en			=> dsc_load_en,		-- 1 - ���������� ������ �����������
		dsc_check_start		=> dsc_check_start,	-- 1 - �������� �����������
		dsc_check_ready		=> dsc_check_ready,	-- 1 - �������� ���������
		
		---- ctrl_dma_ext_cmd ----						 
		dma_reg0			=> dma_reg0,		-- ������� �����������
		dma_change_adr		=> dma_change_adr,	-- 1 - ��������� ������ � �������
		dma_status			=> dma_cmd_status		-- ��������� DMA
																	-- 0: 1 - ���������� ������
																	-- 1: 1 - ������ ��� ������
																	-- 2: 1 - ������ ����� ����� 0
	);		

	
cmd: ctrl_dma_ext_cmd 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(						  
		---- Global ----
		rstp			=> rstp,			-- 1 - �����
		clk				=> clk,				-- �������� �������
		
		---- CTRL_MAIN ----
		dma_reg0		=> dma_reg0,		-- ������� �����������
		dma_change_adr	=> dma_change_adr,	-- 1 - ��������� ������ � �������
		dma_cmd_status	=> dma_cmd_status,	-- ��������� DMA
																-- 0: 1 - ���������� ������
																-- 1: 1 - ������ ��� ������
																-- 2: 1 - ������ ����� ����� 0
		dma_chn			=> dma_chn,		-- ����� ������ DMA
		
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr_h		=> dsc_adr_h,	    -- �����, ���� 4
		dsc_adr			=> dsc_adr,				-- �����, ����� 3..1
		dsc_size		=> dsc_size,			-- ������, ����� 3..1
		
		
		---- TX_ENGINE ----
		tx_ext_fifo			=> tx_ext_fifo,		
		tx_req_wr			=> req_wr,	
		tx_req_rd			=> req_rd,	
		tx_rd_size			=> tx_ext_fifo_back.rd_size,	
		tx_pci_adr			=> tx_ext_fifo_back.pci_adr,	
		
		---- RX_ENGINE ----
		rx_ext_fifo			=> rx_ext_fifo
		
		---- ����������� ����� ----
		--test			: out std_logic_vector( 3 downto 0 )
	);
	
tx_ext_fifo_back.req_wr <= req_wr;	 
tx_ext_fifo_back.req_rd <= req_rd;

dsc: ctrl_ext_descriptor 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		reset			=> reset,	-- 0 - �����
		clk				=> clk,		-- �������� �������
		
		---- ������ ������ ----
		data_in				=> ram_do_a,	 -- ���� ������ ������
		pci_adr_we			=> pci_adr_we,		-- 1 - ������ ������
		pci_adr_h_we		=> pci_adr_h_we,	-- 1 - ������ ������� �������� ������
		
		---- ctrl_main ----
		dma_chn				=> dma_chn,			-- ����� ������ DMA
		dsc_correct			=> dsc_correct,		-- 1 - �������� ���������� ����������
		dsc_cmd				=> dsc_cmd,			-- ��������� ����� �����������
		dsc_change_adr		=> dsc_change_adr,	-- 1 - ����� ������ �����������
		dsc_change_mode		=> dsc_change_mode,	-- ����� ��������� ������:
												-- 0: - ����������
		                                      	-- 1: - ������� � �������� �����������
		dsc_load_en			=> dsc_load_en,		-- 1 - ���������� ������ �����������
		dsc_check_start		=> dsc_check_start,	-- 1 - �������� �����������
		dsc_check_ready		=> dsc_check_ready,	-- 1 - �������� ���������

		
		---- ctrl_dma_ext_cmd ---
		ram0_wr			=> ram0_wr,			-- 1 - ������ � ������ ������������
		dma_wraddr		=> dma_wraddr( 11 downto 0 ),	-- ����� ������
		dma_wrdata		=> dma_wrdata,		-- ������ DMA
		dsc_adr_h		=> dsc_adr_h,	    -- �����, ���� 4
		dsc_adr			=> dsc_adr,			-- �����, ����� 3..1
		dsc_size		=> dsc_size			-- ������, ����� 3..1
		
--		---- ����������� ����� ----
--		test			: out std_logic_vector( 3 downto 0 )

	
	);	
	

	
ram_data: ctrl_ext_ram 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
	
		---- Global ----
		reset			=> reset,	-- 0 - �����
		clk				=> clk,		-- �������� �������	250 ��� 
		aclk			=> aclk,	-- �������� ������� 266 ���
		
		
		---- ctrl_main ----
		ram_change		=> ram_change,		-- 1 - ��������� ����� ������
		loc_adr_we		=> loc_adr_we,		-- 1 - ������ ���������� ������
		data_in			=> ram_do_a,		-- ���� ������ ������
		dma_chn			=> dma_chn,			-- ����� ������ DMA
		
		
		---- �������� ���������� ----
		dma0_ctrl		=> dma0_ctrl,		-- ������� DMA_CTRL, ����� 0
		dma1_ctrl		=> dma1_ctrl,		-- ������� DMA_CTRL, ����� 0
		
		
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - ����� 0 ����� � ������
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - ����� 1 ����� � ������
		
		
		---- PCI-Express ----
		dma_wr_en		=> dsc_size(0),		-- 1 - ������, 0 - ������
		dma_wr			=> ram1_wr,			-- 1 - ������ �� ���� wr_data
		dma_wrdata		=> dma_wrdata,		-- ������ DMA
		dma_wraddr 		=> dma_wraddr,
		
		dma_rddata		=> tx_ext_fifo_back.data,	-- ������ FIFO
		dma_rdaddr		=> dma_rdaddr,				-- ����� ������
		
		---- DISP  ----
		ext_fifo_disp		=> ext_fifo_disp,		-- ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	=> ext_fifo_disp_back	-- ����� �� ������
		
	);		
	


irq <= reg_dma0_status(7) or reg_dma1_status(7) or ext_fifo_disp_back.irq after 1 ns when rising_edge( clk );

end block_pe_fifo_ext;
