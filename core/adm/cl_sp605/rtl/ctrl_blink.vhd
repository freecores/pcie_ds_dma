-------------------------------------------------------------------------------
--
-- Title       : ctrl_blink
-- Design      : ambpex5_v11_lx50t_ddr2
-- Author      : Dmitry Smekhov
-- Company     : NNS
--
-------------------------------------------------------------------------------
--
-- Description : ���������� ����������� ��������� ���� PCI-Express
--				  RESET=0 - ��������� �����
--				  pcie_link_up=1 - �� ������ ������������� PCI-Express - 
--								 - ��������� ����� ���������� ������
--				  pcie_link_up=0 - ����� ������� ������������� ������
--								   ���� PCI-Express
--								   
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package  ctrl_blink_pkg is

component ctrl_blink is			
	generic(
		is_simulation	: in integer:=0
	);
	port(
		clk				: in std_logic;	-- �������� ������� 250 
		reset			: in std_logic;	-- 0 - �����
		clk30k			: in std_logic;	-- �������� ������� 30 ���
		
		pcie_link_up	: in std_logic;	-- 0 - ��������� ������������� PCI-Express
		pcie_lstatus	: in std_logic_vector( 15 downto 0 );	-- �������� LSTATUS
		
		led_h1			: out std_logic	-- ���������
	);
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity ctrl_blink is			
	generic(
		is_simulation	: in integer:=0
	);
	port(
		clk				: in std_logic;	-- �������� ������� 250 
		reset			: in std_logic;	-- 0 - �����
		clk30k			: in std_logic;	-- �������� ������� 30 ���
		
		pcie_link_up	: in std_logic;	-- 0 - ��������� ������������� PCI-Express
		pcie_lstatus	: in std_logic_vector( 15 downto 0 );	-- �������� LSTATUS
		
		led_h1			: out std_logic	-- ���������
	);
end ctrl_blink;


architecture ctrl_blink of ctrl_blink is


signal	clk_blink			: std_logic;
signal	clk_z1, clk_z2		: std_logic;
signal	mask				: std_logic;
signal	cnt					: std_logic_vector( 3 downto 0 );
signal	cnt30k				: std_logic_vector( 13 downto 0 ):=(others=>'0');
signal	ncnt30k				: std_logic_vector( 13 downto 0 );

signal stp					: std_logic;

begin			 
gen_sim: if( is_simulation=1 ) generate
	
	clk_blink <= cnt30k(4) when stp='1' else cnt30k(3);	
	
end generate;

gen_syn: if( is_simulation=0 ) generate
	
	
	clk_blink <= cnt30k(13) when stp='1' else cnt30k(12);	
	
end generate;


	
clk_z1 <= clk_blink after 1 ns when rising_edge( clk );
clk_z2 <= clk_z1 after 1 ns when rising_edge( clk );

cnt30k(0) <= ncnt30k(0) when rising_edge( clk30k );

gen_30k: for i in 1 to 13 generate
	fd30k:	fd port map( q=>cnt30k(i), c=>cnt30k(i-1), d=>ncnt30k(i) );
end generate;

ncnt30k <= not cnt30k;


pr_state: process( clk ) begin
	
	if( rising_edge( clk ) ) then
		if( clk_z1='1' and clk_z2='0' ) then
			
			case( stp ) is
				when '0' => 
						if( pcie_link_up='0' ) then
							stp <= '1' after 1 ns;
						end if;
						mask <= '0' after 1 ns;
						cnt <= "0000" after 1 ns;
						
				when '1' => 
						if( pcie_link_up='1' ) then
							stp <= '0' after 1 ns;
						end if;
						if( cnt(3 downto 0 )="0000" ) then
							mask <= '0' after 1 ns;
						elsif( pcie_lstatus(6 downto 4)=cnt( 2 downto 0 ) ) then
							mask <= '1' after 1 ns;
						end if;
						
						cnt <= cnt + 1 after 1 ns;
						
				when others => null;
			end case;
							
			
			
		end if;
		
		if( reset='0' ) then
			mask <= '0' after 1 ns;
			stp <= '0' after 1 ns;
		end if;
	end if;
end process;

led_h1 <= reset and ( clk_blink or mask );

end ctrl_blink;
