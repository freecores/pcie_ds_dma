-------------------------------------------------------------------------------
--
-- Title       : ctrl_ext_ram
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.2
--
-------------------------------------------------------------------------------
--
-- Description : ���� ������������ ������
--				 �� ������� ���� PLD_BUS - FIFO
--				 �� ������� ���� PCI_Express - ������
--
-------------------------------------------------------------------------------
--
--  Version 1.2  06.12.2011
--				 �������� local_adr_we ��� ctrl_ram_cmd 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  05.04.2010
--				 �������� �������� is_dsp48 - ���������� �������������
--				 ������ DSP48
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;	

library	work;
use work.core64_type_pkg.all;

package	ctrl_ext_ram_pkg is

component ctrl_ext_ram is
	generic(
		is_dsp48		: in integer:=1		-- 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(
	
		---- Global ----
		reset				: in std_logic;	-- 0 - �����
		clk					: in std_logic;		--! �������� ������� ���� - 250 ���
		aclk				: in std_logic;		--! �������� ������� ��������� ���� - 266 ���
		
		---- ctrl_main ----
		ram_change			: in std_logic;	-- 1 - ��������� ����� ������
		loc_adr_we			: in std_logic;	-- 1 - ������ ���������� ������
		data_in				: in std_logic_vector( 31 downto 0 ); -- ���� ������ ������
		dma_chn				: in std_logic;		-- ����� ������ DMA
		
		
		---- �������� ���������� ----
		dma0_ctrl			: in std_logic_vector( 7 downto 0 );	-- ������� DMA_CTRL, ����� 0
		dma1_ctrl			: in std_logic_vector( 7 downto 0 );	-- ������� DMA_CTRL, ����� 0
		
		
		dma0_transfer_rdy	: out std_logic;	-- 1 - ����� 0 ����� � ������
		dma1_transfer_rdy	: out std_logic;	-- 1 - ����� 1 ����� � ������
		
		
		---- PCI-Express ----
		dma_wr_en			: in std_logic;		-- 1 - ���������� ������ �� DMA
		dma_wr				: in std_logic;		-- 1 - ������ �� ���� wr_data
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- ������ DMA
		dma_wraddr 			: in std_logic_vector( 11 downto 0 );		
		
		dma_rddata			: out std_logic_vector( 63 downto 0 );	-- ������ FIFO
		dma_rdaddr			: in  std_logic_vector( 11 downto 0 );	-- ����� ������
		
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back	--! ����� �� ������
	
	);	
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;			 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library	work;
use work.core64_type_pkg.all;



use work.ctrl_ram_cmd_pkg.all;

entity ctrl_ext_ram is
	generic(
		is_dsp48			: in integer:=1		-- 1 - ������������ DSP48, 0 - �� ������������ DSP48
	);
	port(
	
		---- Global ----
		reset				: in std_logic;	-- 0 - �����
		clk					: in std_logic;		--! �������� ������� ���� - 250 ���
		aclk				: in std_logic;		--! �������� ������� ��������� ���� - 266 ���
		
		---- ctrl_main ----
		ram_change			: in std_logic;	-- 1 - ��������� ����� ������
		loc_adr_we			: in std_logic;	-- 1 - ������ ���������� ������
		data_in				: in std_logic_vector( 31 downto 0 ); -- ���� ������ ������
		dma_chn				: in std_logic;		-- ����� ������ DMA
		
		
		---- �������� ���������� ----
		dma0_ctrl			: in std_logic_vector( 7 downto 0 );	-- ������� DMA_CTRL, ����� 0
		dma1_ctrl			: in std_logic_vector( 7 downto 0 );	-- ������� DMA_CTRL, ����� 0
		
		
		dma0_transfer_rdy	: out std_logic;	-- 1 - ����� 0 ����� � ������
		dma1_transfer_rdy	: out std_logic;	-- 1 - ����� 1 ����� � ������
		
		
		---- PCI-Express ----
		dma_wr_en			: in std_logic;		-- 1 - ���������� ������ �� DMA
		dma_wr				: in std_logic;		-- 1 - ������ �� ���� wr_data
		dma_wrdata			: in std_logic_vector( 63 downto 0 );	-- ������ DMA
		dma_wraddr 			: in std_logic_vector( 11 downto 0 );		
		
		dma_rddata			: out std_logic_vector( 63 downto 0 );	-- ������ FIFO
		dma_rdaddr			: in  std_logic_vector( 11 downto 0 );	-- ����� ������
		
		---- DISP  ----
		ext_fifo_disp		: out type_ext_fifo_disp;		--! ������ �� ������ �� ���� EXT_FIFO 
		ext_fifo_disp_back	: in  type_ext_fifo_disp_back	--! ����� �� ������

	);
end ctrl_ext_ram;


architecture ctrl_ext_ram of ctrl_ext_ram is

--signal	reg_write		: std_logic;
--signal	reg_write_C1	: std_logic;
--signal	reg_write_C2	: std_logic;
--signal	reg_write_C4	: std_logic;
--signal	reg_write_C8	: std_logic;
--signal	reg_write_D0	: std_logic;
--signal	reg_write_E0	: std_logic;

signal	reg_ch0_ctrl	: std_logic_vector( 7 downto 0 );
signal	reg_ch1_ctrl	: std_logic_vector( 7 downto 0 );

signal	pf_chn			: std_logic;

signal	ram_adra		: std_logic_vector( 10 downto 0 );
signal	ram_adrb		: std_logic_vector( 10 downto 0 );			

signal	ram_we_a		: std_logic;
signal	ram_we_b		: std_logic;

signal	pf_repack_di	: std_logic_vector( 63 downto 0 );

signal	pf_adr			: std_logic_vector( 31 downto 0 );
signal	pf_ram_rd		: std_logic;  
signal	pf_ram_rd_z		: std_logic;

begin		  
	

reg_ch0_ctrl <= dma0_ctrl;
reg_ch1_ctrl <= dma1_ctrl;

gen_ram_adr: for ii in 0 to 31 generate
	
ram1:	ram16x1d 
		port map(
			we 	=> loc_adr_we,
			d 	=> data_in(ii),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			dpra0 => pf_chn,
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '0',
			dpo	  => pf_adr( ii )
		);

		
end generate;

--pf_adr( 7 downto 0 ) <= x"00";

ram_adra( 8 downto 0 ) <= dma_wraddr( 11 downto 3 ) when dma_wr_en='0' else
						  dma_rdaddr( 11 downto 3 );
						  
ram_adra( 10 ) <= dma_chn;

ram_we_a <= dma_wr and not dma_wr_en;  
ram_we_b <= ext_fifo_disp_back.data_we;


ext_fifo_disp.data_we <= pf_ram_rd  after 1 ns when rising_edge( aclk );
ext_fifo_disp.adr <= pf_adr;

pf_ram_rd_z <= pf_ram_rd after 1 ns when rising_edge( aclk );

gen_ram_data: for ii in 0 to 7 generate
	
ram: RAMB16_S9_S9 
  generic map(
    SIM_COLLISION_CHECK => "NONE"
    )

  port map(
    DOA   => dma_rddata( 7+ii*8 downto ii*8 ),
    DOB   => ext_fifo_disp.data( 7+ii*8 downto ii*8 ),

    ADDRA => ram_adra,
    ADDRB => ram_adrb,
    CLKA  => clk,
    CLKB  => aclk,
    DIA   => dma_wrdata( 7+ii*8 downto ii*8 ),
    DIB   => ext_fifo_disp_back.data( 7+ii*8 downto ii*8 ),
    DIPA  => (others=>'0'),
    DIPB  => (others=>'0'),

    ENA   => '1',
    ENB   => '1',
    SSRA  => '0',
    SSRB  => '0',
    WEA   => ram_we_a,
    WEB   => ram_we_b
    );
	
end generate;			 		 


cmd: ctrl_ram_cmd 
	generic map(
		is_dsp48		=> is_dsp48
	)
	port map(
		---- Global ----
		reset			=> reset,				-- 0 - �����
		clk				=> clk,					-- �������� ������� 250 ���
		aclk			=> aclk,				-- �������� ������� 266 ��� 
		
		---- Picoblaze ----
		dma_chn			=> dma_chn,				-- ����� ������ DMA	  
		reg_ch0_ctrl	=> reg_ch0_ctrl,		-- ������� ����������
		reg_ch1_ctrl	=> reg_ch1_ctrl,		-- ������� ����������
		reg_write_E0	=> ram_change,		-- 1 - ����� ����� ������
		dma0_transfer_rdy	=> dma0_transfer_rdy,	-- 1 - ���� ������ ����� � ������
		dma1_transfer_rdy	=> dma1_transfer_rdy,	-- 1 - ���� ������ ����� � ������
		loc_adr_we			=> loc_adr_we,			-- 1 - ������ ���������� ������
		
		---- PLB_BUS ----			  
		dmar0			=> ext_fifo_disp_back.dmar(0),		-- 1 - ������ DMA 0
		dmar1			=> ext_fifo_disp_back.dmar(1),		-- 1 - ������ DMA 1
		request_wr		=> ext_fifo_disp.request_wr,		-- 1 - ������ �� ������ � ������� 
		request_rd		=> ext_fifo_disp.request_rd,		-- 1 - ������ �� ������ �� �������� 
		allow_wr		=> ext_fifo_disp_back.allow_wr,		-- 1 - ���������� ������ 
		pb_complete		=> ext_fifo_disp_back.complete,		--! 1 - ���������� ������ �� ���� PLD_BUS
		
		
		pf_repack_we	=> ext_fifo_disp_back.data_we,		-- 1 - ������ � ������
		pf_ram_rd_out	=> pf_ram_rd,						-- 1 - ������ �� ������
		
		---- ������ ----	   
		ram_adra_a9		=> ram_adra(9),	-- ������ 9 ������ ������
		ram_adrb		=> ram_adrb
	
	);
	
pf_chn <= ram_adrb(10);

end ctrl_ext_ram;
