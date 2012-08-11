-------------------------------------------------------------------------------
--
-- Title       : core64_type_pkg
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1
--
-------------------------------------------------------------------------------
--
-- Description : ����������� ����� ��� ������� DS_DMA64 
--
-------------------------------------------------------------------------------
--
--  Version 1.1  28.09.2011 Dmitry Smekhov
--				 �������� complete � ���  type_pb_slave 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! ����������� ����� ��� ������� DS_DMA64 
package core64_type_pkg is

--! �������� ������ � ���� PCIE 
type type_trn_tx is record
	
    trn_td 			: std_logic_vector((64 - 1) downto 0);
    trn_trem_n		: std_logic_vector (7 downto 0);
    trn_tsof_n 		: std_logic;
    trn_teof_n 		: std_logic;
    trn_tsrc_dsc_n 	: std_logic;
    trn_tsrc_rdy_n 	: std_logic;
    trn_terrfwd_n 	: std_logic ;
	
end record;

--! ���������� � �������� ������ � ���� PCIE 
type type_trn_tx_back is record
	
    trn_tdst_dsc_n 	: std_logic;
    trn_tdst_rdy_n 	: std_logic;
    trn_tbuf_av 	: std_logic_vector ( 5 downto 0 );
	cfg_dcommand	: std_logic_vector( 15 downto 0 );			-- ������� Device Control Register
	
end record;

--! ���� ������ �� ���� PCIE 
type type_trn_rx is record

    trn_rd 			: std_logic_vector((64 - 1) downto 0);
    trn_rrem_n		: std_logic_vector (7 downto 0);
    trn_rsof_n 		: std_logic;
    trn_reof_n 		: std_logic; 
    trn_rsrc_dsc_n 	: std_logic; 
    trn_rsrc_rdy_n 	: std_logic; 
    trn_rbar_hit_n 	: std_logic_vector ( 6 downto 0 );
    trn_rerrfwd_n 	: std_logic; 
    trn_rfc_npd_av 	: std_logic_vector ( 11 downto 0 ); 
    trn_rfc_nph_av 	: std_logic_vector ( 7 downto 0 ); 
    trn_rfc_pd_av 	: std_logic_vector ( 11 downto 0 ); 
    trn_rfc_ph_av 	: std_logic_vector ( 7 downto 0 );
	
end record;


--! ���������� � ����� ������ �� ���� PCIE 
type type_trn_rx_back is record
	
    trn_rdst_rdy_n 			: std_logic; 
    trn_rnp_ok_n 			: std_logic; 
    trn_rcpl_streaming_n    : std_logic;
	
end record;

--! �������� ������ � ���� PCIE. ��������� AXI
type type_axi_tx is record
	
--    trn_td 			: std_logic_vector((64 - 1) downto 0);
--    trn_trem_n		: std_logic_vector (7 downto 0);
--    trn_tsof_n 		: std_logic;
--    trn_teof_n 		: std_logic;
--    trn_tsrc_dsc_n 	: std_logic;
--    trn_tsrc_rdy_n 	: std_logic;
--    trn_terrfwd_n 	: std_logic ;		   
	
	s_axis_tx_tdata   : std_logic_vector(63 downto 0);
	s_axis_tx_tstrb   : std_logic_vector(7 downto 0);
	s_axis_tx_tuser   : std_logic_vector(3 downto 0);
	s_axis_tx_tlast   : std_logic;
	s_axis_tx_tvalid  : std_logic;
    tx_cfg_gnt        : std_logic;
    fc_sel        	  : std_logic_vector(2 downto 0);
		
	
end record;

--! ���������� � �������� ������ � ���� PCIE. ��������� AXI
type type_axi_tx_back is record
	
    tx_cfg_req       : std_logic;
    tx_err_drop      : std_logic;
	s_axis_tx_tready : std_logic;
--    trn_tdst_dsc_n 	: std_logic;
--    trn_tdst_rdy_n 	: std_logic;
    trn_tbuf_av 	: std_logic_vector ( 5 downto 0 );
	cfg_dcommand	: std_logic_vector( 15 downto 0 );			-- ������� Device Control Register
	
      fc_cpld       : std_logic_vector(11 downto 0);
      fc_cplh       : std_logic_vector(7 downto 0);
      fc_npd        : std_logic_vector(11 downto 0);
      fc_nph        : std_logic_vector(7 downto 0);
      fc_pd         : std_logic_vector(11 downto 0);
      fc_ph         : std_logic_vector(7 downto 0);
	
end record;


--! ���� ������ �� ���� PCIE. ��������� AXI 
type type_axi_rx is record

--    trn_rd 			: std_logic_vector((64 - 1) downto 0);
--    trn_rrem_n		: std_logic_vector (7 downto 0);
--    trn_rsof_n 		: std_logic;
--    trn_reof_n 		: std_logic; 
--    trn_rsrc_dsc_n 	: std_logic; 
--    trn_rsrc_rdy_n 	: std_logic; 
--    trn_rbar_hit_n 	: std_logic_vector ( 6 downto 0 );
--    trn_rerrfwd_n 	: std_logic; 
--    trn_rfc_npd_av 	: std_logic_vector ( 11 downto 0 ); 
--    trn_rfc_nph_av 	: std_logic_vector ( 7 downto 0 ); 
--    trn_rfc_pd_av 	: std_logic_vector ( 11 downto 0 ); 
--    trn_rfc_ph_av 	: std_logic_vector ( 7 downto 0 );		 

      m_axis_rx_tdata     : std_logic_vector(63 downto 0);
      m_axis_rx_tstrb     : std_logic_vector(7 downto 0);
      m_axis_rx_tlast     : std_logic;
      m_axis_rx_tvalid    : std_logic;
      m_axis_rx_tuser     : std_logic_vector(21 downto 0);

	
end record;


--! ���������� � ����� ������ �� ���� PCIE. ��������� AXI 
type type_axi_rx_back is record
	
--    trn_rdst_rdy_n 			: std_logic; 
--    trn_rnp_ok_n 			: std_logic; 
--    trn_rcpl_streaming_n    : std_logic;

      m_axis_rx_tready     : std_logic;
      rx_np_ok             : std_logic;

end record;

--! ������ � ��������� 
type type_reg_access is record
	
	adr						: std_logic_vector( 31 downto 0 );	--! ����� ��������
	data					: std_logic_vector( 31 downto 0 );	--! ������ ��� ������ � �������
	req_wr					: std_logic_vector( 1 downto 0 );	--! 1 - ���������� ������ � �������
	req_rd					: std_logic_vector( 1 downto 0 ); 	--! 1 - ���������� ������ �� ��������
	
end record;

--! ������ � ��������� - �������� ����� 
type type_reg_access_back is record
	
	data					: std_logic_vector( 31 downto 0 );	--! ������ ��� ������ � �������
	data_we					: std_logic;	--! 1 - ����� ������ 
	complete				: std_logic;	--! 1 - �������� ��������� 
	
end record;

--! RX->TX
type type_rx_tx_engine	is record
	
	request_reg_wr			: std_logic;	--! 1 - ������ �� ������ � ������� 
	request_reg_rd			: std_logic;	--! 1 - ������ �� ������ �� �������� 
	request_tag				: std_logic_vector( 7 downto 0 );	--! ������������� �������
	request_tc				: std_logic_vector( 2 downto 0 );	--! Traffic class
	request_attr			: std_logic_vector( 3 downto 0 );	--! ��������
	request_id				: std_logic_vector( 15 downto 0 );  --! ID ���������� ������� 
	
	complete_we				: std_logic;	--! 1 - ������ ������ �� ������ 
	lower_adr				: std_logic_vector( 6 downto 2 );	--! ������� ������� ������
	byte_count				: std_logic_vector( 2 downto 0 );	--! ����� ���� � ������� 
	
end record;

--! TX->RX
type type_tx_rx_engine	is record
	
	complete_reg			: std_logic;	--! 1 - ���������� ������� � �������� 
	
end record;

--! RX->EXT_FIFO 
type type_rx_ext_fifo is record
	
	adr						: std_logic_vector( 8 downto 0 );	--! ����� 
	data					: std_logic_vector( 63 downto 0 );	--! ������
	data_we					: std_logic;	--! 1 - ������ ������ 
	
end record;

--! TX->EXT_FIFO 
type type_tx_ext_fifo is record
	
	adr						: std_logic_vector( 8 downto 0 );	--! ����� 
	
	complete_ok				: std_logic;	--! 1 - �������� ���������� �������� 
	complete_error			: std_logic;	--! 1 - �������� ��������� � �������
	
end record;

--! TX->EXT_FIFO_BACK
type type_tx_ext_fifo_back is record
	
	data					: std_logic_vector( 63 downto 0 );	--! ������
	
	req_wr					: std_logic;	--! 1 - ���������� ������ ����� 4 ��
	req_rd					: std_logic;	--! 1 - ���������� ������
	rd_size					: std_logic;	--! 0 - 512 ����, 1 - 4 ��
	pci_adr					: std_logic_vector( 39 downto 8 );	--! ����� �� ���� PCI 
	
end record;

--! REG->DISP 
type type_reg_disp is record
	
	adr						: std_logic_vector( 31 downto 0 );	--! ����� 
	data					: std_logic_vector( 31 downto 0 );	--! ������ 
	request_reg_wr			: std_logic;	--! 1 - ������ �� ������ � ������� 
	request_reg_rd			: std_logic;	--! 1 - ������ �� ������ �� �������� 
	
end record;


--! REG->DISP BACK 
type type_reg_disp_back is record
	
	data					: std_logic_vector( 31 downto 0 );	--! ������ 
	data_we					: std_logic;	--! 1 - ����� ������ ������ 
	complete				: std_logic;	--! 1 - �������� ��������� 
	
end record;


--! REG->EXT_FIFO 
type type_reg_ext_fifo is record
	
	adr						: std_logic_vector( 6 downto 0 );	--! ����� 
	data					: std_logic_vector( 31 downto 0 );	--! ������ 
	data_we					: std_logic;	--! 1 - ������ � �������� 
	
end record;

--! REG->EXT_FIFO BACK 
type type_reg_ext_fifo_back is record
	
	data					: std_logic_vector( 31 downto 0 );	--! ������ 
	
end record;


--! PB_DATA_MASTER  
type type_pb_master is record
	
	stb0					: std_logic;	--! 1 - ����� ������� � ������ 
	stb1					: std_logic;	--! 1 - ����� ������	
	cmd						: std_logic_vector( 2 downto 0 );	--! �������	 
	adr						: std_logic_vector( 31 downto 0 ); 	--! �����
	data					: std_logic_vector( 63 downto 0 );	--! ������ 
	
end record;

--! PB_DATA_SLAVE 
type type_pb_slave is record
	
	stb0					: std_logic;	--! 1 - ����� ������� � ������ 
	stb1					: std_logic;	--! 1 - ����� ������	
	data					: std_logic_vector( 63 downto 0 );	--! ������ 
	dmar					: std_logic_vector( 1 downto 0 );	--! 1 - ������ DMA 
	irq						: std_logic;	--! 1 - ������ ���������� 
	complete				: std_logic;	--! 1 - ���������� �������� �� ���� 
	ready					: std_logic;	--! 1 - ���������� � ����� ������ 
	
end record;

--! EXT_FIFO -> DISP
type type_ext_fifo_disp is record
	
	adr						: std_logic_vector( 31 downto 0 );	--! ����� 
	data					: std_logic_vector( 63 downto 0 );	--! ������ 
	data_we					: std_logic;	--! 1 - ������ 
	request_wr				: std_logic;	--! 1 - ������ �� ������ � ������� 
	request_rd				: std_logic;	--! 1 - ������ �� ������ �� �������� 
	
end record;

--! EXT_FIFO -> DISP BACK 
type type_ext_fifo_disp_back is record
	
	data					: std_logic_vector( 63 downto 0 );	--! ������ 
	data_we				    : std_logic;	--! 1 - ������
	dmar					: std_logic_vector( 1 downto 0 );	--! 1 - ������ DMA 
	allow_wr				: std_logic;	--! 1 - ���������� ������ 
	irq						: std_logic;	--! 1 - ������ ���������� 
	complete				: std_logic;	--! 1 - ���������� ��������
	
end record;


end package;