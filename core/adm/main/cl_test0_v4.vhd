---------------------------------------------------------------------------------------------------
--
-- Title       : cl_test0_v4
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1
--
---------------------------------------------------------------------------------------------------
--
-- Description : ������ ���������� ������������.
--               ����������� 4 - ���� ������ 64 �������, ���� ������ 7 ��������
--			     ���� ��������� ����� ��������� ��������
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.1	10.06.2010
--					�������� ����� ������������ ��������������� ������������������
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package cl_test0_v4_pkg is

component cl_test0_v4 is
	port( 
		reset			: in std_logic;			-- 0 - ����� �����, ������� � ����� �� test_mode_init
		reset_reg		: in std_logic;			-- 0 - ����� ���������� ��������
		clk				: in std_logic;			-- �������� �������
		reg_test_mode	: in std_logic:='0';	-- 1 - ������������ ��������������� ������������������
		
		adr_in			: in std_logic_vector( 6 downto 0 );	-- ���� ������
		data_in			: in std_logic_vector( 63 downto 0 );	-- ���� ������, ����
		data_en			: in std_logic;			-- 1 - ������ � �������
		data_cs			: in std_logic;			-- 0 - ������
		
		data_out		: out std_logic_vector( 63 downto 0 );	-- ���� ������, �����
		test_mode_init	: in std_logic;			-- ��������� ���������
		test_mode		: out std_logic			-- 1 - �������� �����
	);
		
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;

entity cl_test0_v4 is
	port( 
		reset			: in std_logic;			-- 0 - ����� �����, ������� � ����� �� test_mode_init
		reset_reg		: in std_logic;			-- 0 - ����� ���������� ��������
		clk				: in std_logic;			-- �������� �������
		reg_test_mode	: in std_logic:='0';	-- 1 - ������������ ��������������� ������������������
		
		adr_in			: in std_logic_vector( 6 downto 0 );	-- ���� ������
		data_in			: in std_logic_vector( 63 downto 0 );	-- ���� ������, ����
		data_en			: in std_logic;			-- 1 - ������ � �������
		data_cs			: in std_logic;			-- 0 - ������
		
		data_out		: out std_logic_vector( 63 downto 0 );	-- ���� ������, �����
		test_mode_init	: in std_logic;			-- ��������� ���������
		test_mode		: out std_logic			-- 1 - �������� �����
	);
		
end cl_test0_v4;


architecture cl_test0_v4 of cl_test0_v4 is

signal reg: std_logic_vector( 63 downto 0 );

signal reg_en2, reg_sen: std_logic;
signal tmode, tmode1: std_logic;    -- 1 - ����� ������������
signal reg_clr: std_logic; 			-- 1 - ����� ��������

begin




	
	
pr_tmode: process( reset, clk ) begin
	if( reset='0' ) then
		tmode<=test_mode_init;
	elsif( rising_edge( clk ) ) then
		if( tmode='1' ) then
			if( data_en='1' )  then
				tmode <= not data_in(0);
			end if;
		else
			if( data_en='1' )  then
				tmode<= data_in(1);
			end if;
		end if;					
	end if;
end process;


test_mode<=tmode;

pr_reg: process( reset, reset_reg, tmode, clk ) begin
	if( reset='0' or reset_reg='0' or reg_clr='1' ) then
		reg<=( 1=>reg_test_mode, others=>'0' );
	elsif( rising_edge( clk ) ) then
		if( data_en='1' ) then
			reg( 6 downto 0 )<=adr_in( 6 downto 0 ) after 1 ns;
			reg( 63 downto 7 )<=data_in( 63 downto 7 ) after 1 ns;
		elsif( reg_sen='1' ) then
			for i in 63 downto 1 loop
				reg( i )<=reg(i-1);
			end loop;			   
			if( reg_test_mode='0' ) then
				reg( 0 )<= not reg( 63 ) after 1 ns;
			else
				reg(0) <= reg(63) xor reg(62) xor reg(60) xor reg(59) after 1 ns;
			end if;
		end if;
	end if;	  
end process;
		
reg_sen<=data_cs;		 

pr_tmode1: process( clk ) begin
	if( rising_edge( clk ) ) then
		tmode1<=tmode;
	end if;
end process;

reg_clr<=tmode xor tmode1;

	
data_out<=reg;	
		
	 

end cl_test0_v4;
