---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_start_v2
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
--
-- Version     : 1.6	    
--			  
---------------------------------------------------------------------------------------------------
--
-- �������	:	rtl_s2e		- ���������� ��� Spartan-2E
--				rtl_v2		- ���������� ��� Virtex-II
--
---------------------------------------------------------------------------------------------------
--
-- Description :  ����� �������� ������� � ������� ������
--												
--				����������� 2. �� ������������ �������� CNT0, CNT1, CNT2
--
---------------------------------------------------------------------------------------------------
--					
-- Version 1.6  28.11.2006
--				���������� ������������ �������� start_a_tr_clr � start_a_tr (�� �������� � ctrl_start_v4)
--              (�������)
--
-- Version 1.5  16.02.2006
--				���������� ������������ ������� ������ � ����������� ������
--				� ������������� ����� ����������� ������
--					
--
-- Version 1.4  28.04.2004
--				���������� ������������ ������� ������ � ����������� ������
--				� ������������� ����� �������� ������.
--				��������� �������� ������ ctrl_start_v2_pkg.
--
-- Version 1.3  19.01.2004
--				���������� ������������ �������� ������� � ������ ADM_MSYNC
--					
-- Version 1.2  25.12.2003
--				���������� ������������ ������� ������ � ������ Slave						  
--					
-- Version 1.1  22.12.2003
--				���������� ����� ������������ ����������� ������
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;	   
use ieee.std_logic_unsigned.all;


package	ctrl_start_v2_pkg is

component ctrl_start_v2 is		
	port( 					
	
		reset: in std_logic;						-- 0 - �����
		mode0: in std_logic_vector( 15 downto 0 ); 	-- ������� MODE0
		stmode: in std_logic_vector( 15 downto 0 );	-- ������� STMODE
		fmode:	in std_logic_vector(  5 downto 0 ); -- ������� FMODE
		fdiv:	in std_logic_vector( 15 downto 0 ); -- ������� FDIV
		fdiv_we: in std_logic;						-- 1 - ������ � ������� FDIV
		
		b_clk:  in std_logic_vector( 15 downto 0 ); -- ����� �������� �������
		b_start: in std_logic_vector( 15 downto 0 ); -- ����� ������� START
		
		bx_clk: out std_logic; 		-- ����� �������� ������� 
		bx_start: out std_logic;	-- ����� ������� start ���������� � bx_clk
		bx_start_a: out std_logic;	-- ����������� ����� ������� start 
		bx_start_sync: out std_logic; -- ������� �������������
		
		goe0: out std_logic;	  	-- ��������� ���������� 60MHz
		goe1: out std_logic			-- ��������� ���������� 50MHz
		
	);
	
end component;

end package ctrl_start_v2_pkg;


library IEEE;
use IEEE.STD_LOGIC_1164.all;	   
use ieee.std_logic_unsigned.all;



entity ctrl_start_v2 is		
	port( 					
	
		reset: in std_logic;						-- 0 - �����
		mode0: in std_logic_vector( 15 downto 0 ); 	-- ������� MODE0
		stmode: in std_logic_vector( 15 downto 0 );	-- ������� STMODE
		fmode:	in std_logic_vector(  5 downto 0 ); -- ������� FMODE
		fdiv:	in std_logic_vector( 15 downto 0 ); -- ������� FDIV
		fdiv_we: in std_logic;						-- 1 - ������ � ������� FDIV
		
		b_clk:  in std_logic_vector( 15 downto 0 ); -- ����� �������� �������
		b_start: in std_logic_vector( 15 downto 0 ); -- ����� ������� START
		
		bx_clk: out std_logic; 		-- ����� �������� ������� 
		bx_start: out std_logic;	-- ����� ������� start ���������� � bx_clk
		bx_start_a: out std_logic;	-- ����������� ����� ������� start 
		bx_start_sync: out std_logic; -- ������� �������������
		
		goe0: out std_logic;	  	-- ��������� ���������� 60MHz
		goe1: out std_logic			-- ��������� ���������� 50MHz
		
	);
	
end ctrl_start_v2;


architecture ctrl_start_v2 of ctrl_start_v2 is



signal clki: std_logic; 		-- ��������� ������� ������
signal clko_cnt: std_logic;		-- ������ � ������ ��������
signal clko: std_logic; 		-- �������������� ������   

signal clk_cnt: std_logic_vector( 15 downto 0 ); -- ������� �������� �������
signal clk_cnt_z, clk_cnt_z1 : 	std_logic; 	-- 1 - clk_cnt=0
signal clk_cnt_half: std_logic;	-- 1 - clk_cnt = fdiv/2
signal clk_div1: std_logic;		-- 1 - fdiv=1
signal xcnt0:	std_logic_vector( 15 downto 0 ); -- ������� ��������� ��������
signal xcnt1:	std_logic_vector( 15 downto 0 ); -- ������� ����������� ����
signal xcnt2:	std_logic_vector( 15 downto 0 ); -- ������� ������������ ����

signal xcnt0_z: std_logic;		-- 1 - xcnt0=x"0000"
signal xcnt1_z: std_logic;		-- 1 - xcnt1=x"0000"
signal xcnt2_z: std_logic;		-- 1 - xcnt2=x"0000"

signal start_a: std_logic;		-- 0 - ����������� �����
signal start_a_tr, start_a_tr1: std_logic; 	-- 0 - ����������� ���������� �����
signal start_a_tr_clr:	std_logic;
signal start_i, start_i1: std_logic;		-- 0 - ��������� �������� ������
signal stop_i, stop_i1: std_logic;			-- 0 - ��������� �������� ��������
signal start_s, start_si: std_logic;		-- 0 - ���������� �����
signal start_cnt0: std_logic;				-- 1 - ���������� �� ����� ������ �������� 0
signal start_cnt12: std_logic;				-- 1 - ���������� �� ����� ������ ��������� 1 � 2
signal xcnt1_start: std_logic;				-- 1 - ���������� ������ �������� xcnt1
signal xcnt2_start: std_logic;				-- 1 - ���������� ������ �������� xcnt2	  
signal adcen: std_logic;					-- 1 - ����������� �����
signal start_o: std_logic;					-- �������������� ������ ����������� ������
signal clk_clr: std_logic;					-- 1 - ����� �������� �������� �������
signal clk_clr_cl0:  std_logic;				-- 1 - ����� clk_clr
signal clk_clr_block: std_logic;			-- 1 - ���������� ������
signal start_prog: std_logic;
signal prog_start: std_logic;				-- 1 - ������ ����������� �����

begin
	
adcen <= mode0(5);	


pr_clk: process( b_clk, fmode ) is
begin
	case fmode( 3 downto 0 ) is
		when "0000" => clki <= b_clk(0);
		when "0001" => clki <= b_clk(1);
		when "0010" => clki <= b_clk(2);
		when "0011" => clki <= b_clk(3);
		when "0100" => clki <= b_clk(4);
		when "0101" => clki <= b_clk(5);
		when "0110" => clki <= b_clk(6);
		when "0111" => clki <= b_clk(7);
		when "1000" => clki <= b_clk(8);
		when "1001" => clki <= b_clk(9);
		when "1010" => clki <= b_clk(10);
		when "1011" => clki <= b_clk(11);
		when "1100" => clki <= b_clk(12);
		when "1101" => clki <= b_clk(13);
		when "1110" => clki <= b_clk(14);
		when "1111" => clki <= b_clk(15);
		when others => null;
	end case;
end process;	

goe0<='1' when fmode( 3 downto 0 )="0001" else '0';
goe1<='1' when fmode( 3 downto 0 )="0010" else '0';


pr_cnt_clk: process( reset, start_a, fdiv_we, fmode, clki ) is 
begin
	if( reset='0' or ( clk_clr='1' and fmode(5)='1' ) or fdiv_we='1' ) then
		--clk_cnt<=(others=>'0');
		clk_cnt<=x"0001";
	elsif( rising_edge( clki ) ) then
		if( clk_cnt_z='1' ) then
			clk_cnt<=fdiv;
		else
			clk_cnt<=clk_cnt-1;
		end if;
	end if;
end process;

clk_div1<='1' when fdiv=x"0001" else '0';
clk_cnt_z<='1' when clk_cnt=x"0001" else '0';
clk_cnt_half<='1' when clk_cnt( 14 downto 0 )=fdiv( 15 downto 1 ) else '0';
	
pr_clk_cnt_z1: 	process( clki ) begin
	if( rising_edge( clki ) ) then
		clk_cnt_z1<=clk_cnt_z;
	end if;
end process;				  			   
		
pr_clko_cnt: process( clki, clk_cnt, clk_div1, clk_cnt_half ) is
begin
	if( clk_div1='1' ) then
		clko_cnt<=clki;
	elsif( rising_edge( clki ) ) then
		if( clk_cnt_z1='1' ) then clko_cnt<='0'; 
		elsif( clk_cnt_half='1' ) then clko_cnt<='1';
		end if;
	end if;
end process;	

pr_clko: process( mode0, b_clk, clko_cnt ) is
begin
	if( mode0(4)='0' ) then
		clko<=b_clk(4);
	elsif( mode0(6)='1' ) then
		clko<=b_clk(7);
	else
		clko<=clko_cnt;
	end if;
end process;

bx_clk<=clko;

-- �����

pr_starto: process( mode0, b_start, start_s ) is
begin
	if( mode0(4)='0' ) then -- SLAVE
		start_o<=b_start(4) or not mode0(5);
	else
		start_o<=start_s;
	end if;
end process;

bx_start<=start_o;

pr_start_i: process( stmode, b_start, start_prog ) is
begin
	case stmode( 3 downto 0 ) is
		when "0000" => start_i <= start_prog;
		when "0001" => start_i <= b_start(1);
		when "0010" => start_i <= b_start(2);
		when "0011" => start_i <= b_start(3);
		when "0100" => start_i <= b_start(4);
		when "0101" => start_i <= b_start(5);
		when "0110" => start_i <= b_start(6);
		when "0111" => start_i <= b_start(7);
		when "1000" => start_i <= b_start(8);
		when "1001" => start_i <= b_start(9);
		when "1010" => start_i <= b_start(10);
		when "1011" => start_i <= b_start(11);
		when "1100" => start_i <= b_start(12);
		when "1101" => start_i <= b_start(13);
		when "1110" => start_i <= b_start(14);
		when "1111" => start_i <= b_start(15);
		when others => null;
	end case;
end process;	
start_prog<=( not mode0(5) ) xor stmode(6) when rising_edge(b_clk(0) );
--start_i1<= ( start_i xor stmode(6) ) or ( not mode0(5) );
start_i1<= ( start_i xor stmode(6) );

pr_stop_i: process( stmode, b_start, mode0(5) ) is
begin
	case stmode( 11 downto 8 ) is
		when "0000" => stop_i <= ( not mode0(5) ) xor stmode(14);
		when "0001" => stop_i <= b_start(1);
		when "0010" => stop_i <= b_start(2);
		when "0011" => stop_i <= b_start(3);
		when "0100" => stop_i <= b_start(4);
		when "0101" => stop_i <= b_start(5);
		when "0110" => stop_i <= b_start(6);
		when "0111" => stop_i <= b_start(7);
		when "1000" => stop_i <= b_start(8);
		when "1001" => stop_i <= b_start(9);
		when "1010" => stop_i <= b_start(10);
		when "1011" => stop_i <= b_start(11);
		when "1100" => stop_i <= b_start(12);
		when "1101" => stop_i <= b_start(13);
		when "1110" => stop_i <= b_start(14);
		when "1111" => stop_i <= b_start(15);
		when others => null;
	end case;
end process;	

stop_i1<= stop_i xor stmode(14);

pr_start_a_tr: process( mode0, start_a_tr_clr, start_i1 ) 
begin						  
	if( mode0(5)='0' or start_a_tr_clr='1' ) then
		start_a_tr<='1';
	elsif( prog_start='1' and mode0(5)='1' ) then
		start_a_tr<='0';
	elsif( falling_edge( start_i1 ) ) then
		start_a_tr<='0';
	end if;				
end process;


pr_start_a_tr1: process( b_clk ) begin
	if( rising_edge( b_clk(0) ) ) then
		start_a_tr1<=start_a_tr;
	end if;
end process;

pr_start_a_tr_clr: process( mode0, prog_start, start_a_tr1, stop_i1 ) begin
	if( start_a_tr1='1' or mode0(5)='0' or prog_start='1' ) then
		start_a_tr_clr<='0';
	elsif( rising_edge( stop_i1 ) ) then
		start_a_tr_clr<='1';
	end if;
end process;


--start_a<=start_a_tr when stmode(7)='1' else start_i1;
start_a<=start_a_tr when stmode(7)='1' else start_i1  or ( not mode0(5) );
bx_start_a<=start_a;
		
pr_start_si: process( clko ) begin
	if( rising_edge( clko ) ) then
		start_si<=start_a;
	end if;
end process;

start_s<=start_si;

			

pr_clk_clr: process( reset, clk_clr_cl0, start_a ) begin
	if( reset='0' or clk_clr_cl0='1' ) then
		clk_clr<='0';
	elsif( falling_edge( start_a ) ) then
		clk_clr<='1';
	end if;
end process;	 

bx_start_sync <= clk_clr;

pr_clk_cl0: process( reset, b_clk(0) ) begin
	if( reset='0' ) then
		clk_clr_cl0<='0';
	elsif( rising_edge( b_clk(0) ) ) then
	 	if( clk_clr='1' and clk_clr_block='0' ) then
			 clk_clr_cl0<='1';		   
		else
			clk_clr_cl0<='0';
		end if;
	end if;
end process;


pr_clk_clr_block: process( reset, b_clk(0) ) 
begin
	if( reset='0' ) then
		clk_clr_block<='0';
	elsif( rising_edge( b_clk(0) ) ) then
		if( clk_cnt_half='1' and clk_clr_block='0' ) then
			clk_clr_block<='1';
		else
			clk_clr_block<='0';
		end if;
	end if;
end process;


end ctrl_start_v2;
