-------------------------------------------------------------------------------
--
-- Title       : plda_block_pkg
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : ������� ������� � ������ ����������
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cmd_sim_pkg.all;


package block_pkg is
	
---- ������ � ������� ����� ���������� ----
procedure block_write(  signal cmd	: out bh_cmd; 	-- ������� ��� ����������
						signal ret	: in  bh_ret;	-- ����� ����������
						nb	: in  integer;	-- ����� �����
						nr	: in  integer;	-- ����� ��������
						data	: in std_logic_vector( 31 downto 0 ) -- ��������
);

---- ������ �� �������� ����� ���������� ----
procedure block_read(   signal cmd	: out bh_cmd; 	-- ������� ��� ����������
						signal ret	: in  bh_ret;	-- ����� ����������
						nb	: in  integer;	-- ����� �����
						nr	: in  integer;	-- ����� ��������
						data	: out std_logic_vector( 31 downto 0 ) -- ��������
);

	
end block_pkg;	

package body block_pkg is
	
---- ������ � ������� ����� ���������� ----
procedure block_write(  signal cmd	: out bh_cmd; 	-- ������� ��� ����������
						signal ret	: in  bh_ret;	-- ����� ����������
						nb	: in  integer;	-- ����� �����
						nr	: in  integer;	-- ����� ��������
						data	: in std_logic_vector( 31 downto 0 ) -- ��������
) is

variable	adr		: std_logic_vector( 31 downto 0 );
begin		 
	
	adr:=x"10000000";
	adr:=adr+nb*32*8+nr*8;
	data_write( cmd, ret, adr, data );
	
end block_write;	

---- ������ �� �������� ����� ���������� ----
procedure block_read(   signal cmd	: out bh_cmd; 	-- ������� ��� ����������
						signal ret	: in  bh_ret;	-- ����� ����������
						nb	: in  integer;	-- ����� �����
						nr	: in  integer;	-- ����� ��������
						data	: out std_logic_vector( 31 downto 0 ) -- ��������
) is
variable	adr		: std_logic_vector( 31 downto 0 );
begin

	adr:=x"10000000";
	adr:=adr+nb*32*8+nr*8;
	data_read( cmd, ret, adr, data );
	
end block_read;	

	
end block_pkg;	

