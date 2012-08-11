---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_buft64.vhd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail	   : dsmv@insys.ru
--
-- Version  1.0
--
---------------------------------------------------------------------------------------------------
--
-- Description :  �������� ��� ���� Spartan-3
--				  ������������ �� ������ ������ �������,
--				  ��� ���� ����� ������ ������� ������ ���������� 
--				  �� ����� ����.
--
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;



entity ctrl_buft64 is
	port (
		t	: in std_logic;
		i	: in std_logic_vector( 63 downto 0 );
		o	: out std_logic_vector( 63 downto 0 )
	);
	
end ctrl_buft64;


architecture ctrl_buft64 of ctrl_buft64 is
begin

	o <= i;

end ctrl_buft64;
