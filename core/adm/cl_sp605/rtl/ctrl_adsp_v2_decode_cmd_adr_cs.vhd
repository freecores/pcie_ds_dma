---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_adsp_v2_decode_cmd_adr_cs
-- Author      : Dmitry Smekhov, Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.1
---------------------------------------------------------------------------------------------------
--
-- Description :  ������ ������������� ������� ������ �������� CMD_ADR ��� Virtex2
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.1 17.06.2005
--				������� �������� RLOC � ���������� FMAP
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use ieee.std_logic_arith.all;

-- synopsys translate_off
library ieee;
use ieee.vital_timing.all;	
-- synopsys translate_on

library unisim;
use unisim.VCOMPONENTS.all;


entity ctrl_adsp_v2_decode_cmd_adr_cs is
	port (
		reset		: in std_logic;			-- 0 - �����
		clk			: in std_logic;			-- �������� �������
		adr			: in std_logic_vector( 4 downto 0 );	-- ���� ������
		rd			: in std_logic;							-- 0 - ������ ������
		data_cs		: out std_logic							-- 0 - ������ ������
	);
end ctrl_adsp_v2_decode_cmd_adr_cs;


architecture ctrl_adsp_v2_decode_cmd_adr_cs of ctrl_adsp_v2_decode_cmd_adr_cs is

signal cs1	: std_logic;	-- 0 - ������ ������

--attribute rloc	: string;
--attribute rloc	of xcs1	: label is "X0Y0";
--attribute rloc	of xd	: label is "X0Y0";

begin
	
	
	
cs1 <='0' when 	adr( 1 downto 0 )="10" 
				else '1'  after 1 ns;

--xcs1: fmap port map( o=>cs1, i1=>'0', i2=>'0', i3=>adr(0), i4=>adr(1) );
xd:	  fd   port map( q=>data_cs, c=>clk, d=>cs1 );


end ctrl_adsp_v2_decode_cmd_adr_cs;
