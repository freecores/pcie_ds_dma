---------------------------------------------------------------------------------------------------
--
-- Title       : cmd_sim_pkg.vhd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
--	
-- Version	   : 1.1
---------------------------------------------------------------------------------------------------
--
-- Description :  ����������� ����� �������� �������������
--
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;

package	cmd_sim_pkg is		  

type mem32 is array (natural range<>) of std_logic_vector( 31 downto 0 );		 
type mem64 is array (natural range<>) of std_logic_vector( 63 downto 0 );		 
constant mem_size:integer:=32; -- ������ ������� ������

type bh_cmd is record 	
	cmd: 	integer;  
	adr:	mem32( mem_size-1 downto 0 );
	data: 	mem64( mem_size-1 downto 0 );
	p0:		integer;
	p1:		integer;
end record;			  

-- ������ �������
-- cmd:
--		1 - read
--		2 - write
--	  	20 - ������ ����� � ������
--		21 - ������ ����� �� ������
--		22 - ������ ������������ ������������������ �����
--		30 - ������ ������� �� ����� data0.dat
--		31 - ������ ������� � ������ � ���� data1.dat

--	p0[31..16] - ����� ����� ������
--  p0[0] - 1 - ���� 64 ����
--			0 - ���� 32 ����
--  mem - ������ ��� ������ ��� ������




type bh_ret is record
	ret:	integer;
	data:	mem64( mem_size-1 downto 0 );
end record;	
	
	
procedure data_write( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: in std_logic_vector( 31 downto 0 )	-- ������ ��� ������
	);
	
procedure data_read( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: out std_logic_vector( 31 downto 0 )	-- ����������� ������
	);

procedure data_write64( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: in std_logic_vector( 63 downto 0 )	-- ������ ��� ������
	);
	
procedure data_read64( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: out std_logic_vector( 63 downto 0 )	-- ����������� ������
	);
	

procedure array_write( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ������ ������
	data: in mem32( mem_size-1 downto 0 );	-- ������ ��� ������
	n:	  in integer						-- ������ ����� ������
	);
	
procedure array_read( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ������ ������
	data: out mem32( mem_size-1 downto 0 );	-- ����������� ������
	n:	  in integer							-- ������ ����� ������
	);

procedure array_write64( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ������ ������
	data: in mem64( mem_size-1 downto 0 );	-- ������ ��� ������
	n:	  in integer						-- ������ ����� ������
	);
	
procedure array_read64( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ������ ������
	data: out mem64( mem_size-1 downto 0 );	-- ����������� ������
	n:	  in integer						-- ������ ����� ������
	);
	
procedure int_mem_read(
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:	in std_logic_vector( 31 downto 0 ); -- ����� ������
	data:	out std_logic_vector( 31 downto 0 ) -- ������ �� ������
	);
	
procedure int_mem_write(
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr:	in std_logic_vector( 31 downto 0 ); -- ����� ������
	data:	in std_logic_vector( 31 downto 0 ) -- ������ ��� ������
	);
	

end package cmd_sim_pkg;



package body cmd_sim_pkg is	


procedure data_write( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: in std_logic_vector( 31 downto 0 )	-- ������ ��� ������
	) is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	
	vcmd.cmd:=2;
	vcmd.adr(0):=adr;
	vcmd.data(0)( 31 downto 0 ):=data;
	
	vp0:=(others=>'0');
	vp0(16):='1';
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end data_write;	
	
	
	
procedure data_read( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: out std_logic_vector( 31 downto 0 )	-- ����������� ������
	) is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	vcmd.cmd:=1;
	vcmd.adr(0):=adr;
	
	vp0:=(others=>'0');
	vp0(16):='1';
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	data:=ret.data(0)( 31 downto 0 );
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end data_read;

procedure data_write64( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: in std_logic_vector( 63 downto 0 )	-- ������ ��� ������
	) is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	vcmd.cmd:=2;
	vcmd.adr(0):=adr;
	vcmd.data(0):=data;
	
	vp0:=(others=>'0');
	vp0(0):='1';
	vp0(16):='1';
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end data_write64;
	
procedure data_read64( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr: in std_logic_vector( 31 downto 0 ); 	-- ����� ��������
	data: out std_logic_vector( 63 downto 0 )	-- ����������� ������
	)  is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	vcmd.cmd:=1;
	vcmd.adr(0):=adr;
	
	vp0:=(others=>'0');
	vp0(0):='1';
	vp0(16):='1';
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	data:=ret.data(0);
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end data_read64;
	

procedure array_write( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ����� ��������
	data: in mem32( mem_size-1 downto 0 );		-- ������ ��� ������
	n:	  in integer							-- ������ ����� ������
	) is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	
	vcmd.cmd:=2;	 
	for i in 0 to n loop
	  vcmd.adr(i):=adr(i);
	  vcmd.data(i)( 31 downto 0 ):=data(i);
	end loop;
	
	vp0:=(others=>'0');
	vp0(31 downto 16):=conv_std_logic_vector( n, 16 );
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end array_write;
	
procedure array_read( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ����� ��������
	data: out mem32( mem_size-1 downto 0 );	-- ����������� ������
	n: in integer			-- ������ �����
	)  is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	
	vcmd.cmd:=1;	 
	for i in 0 to n loop
	  vcmd.adr(i):=adr(i);
	end loop;
	
	vp0:=(others=>'0');
	vp0(31 downto 16):=conv_std_logic_vector( n, 16 );
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	
	for i in 0 to n loop
	  data(i):=ret.data(i)( 31 downto 0 );
	end loop;
	
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end array_read;

procedure array_write64( 
	signal	cmd: out bh_cmd; 	-- ������� ��� ����������
	signal	ret: in bh_ret; 	-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ����� ��������
	data: in mem64( mem_size-1 downto 0 );		-- ������ ��� ������
	n:	  in integer							-- ������ ����� ������
	)  is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	
	vcmd.cmd:=2;	 
	for i in 0 to n loop
	  vcmd.adr(i):=adr(i);
	  vcmd.data(i):=data(i);
	end loop;
	
	vp0:=(others=>'0');
	vp0(0):='1';
	vp0(31 downto 16):=conv_std_logic_vector( n, 16 );
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end array_write64;
	
procedure array_read64( 
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr:  in mem32( mem_size-1 downto 0 ); 	-- ����� ��������
	data: out mem64( mem_size-1 downto 0 );	-- ����������� ������
	n:	in integer			-- ������ �����
	)   is
 variable vcmd: bh_cmd;
 variable vp0: std_logic_vector( 31 downto 0 ); 
begin							
	
	
	vcmd.cmd:=1;	 
	for i in 0 to n loop
	  vcmd.adr(i):=adr(i);
	end loop;
	
	vp0:=(others=>'0');
	vp0(0):='1';
	vp0(31 downto 16):=conv_std_logic_vector( n, 16 );
	vcmd.p0:=conv_integer( unsigned( vp0 ) );
	cmd<=vcmd;	 
	wait until ret'event;
	
	for i in 0 to n loop
	  data(i):=ret.data(i);
	end loop;
	
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
end array_read64;
	
procedure int_mem_read(
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr:	in std_logic_vector( 31 downto 0 ); -- ����� ������
	data:	out std_logic_vector( 31 downto 0 ) -- ������ �� ������
	)  is
	
 variable vcmd: bh_cmd;
	
begin		  
	
	vcmd.cmd:=21;
	vcmd.adr(0):=adr;
	cmd<=vcmd;	 
	wait until ret'event;			
	wait for 1 ns;
	data:=ret.data(0)( 31 downto 0 );
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
	
end int_mem_read;
	
procedure int_mem_write(
	signal cmd: out bh_cmd; 	-- ������� ��� ����������
	signal ret: in bh_ret; 		-- ������������ �������� �� ����������
	adr:	in std_logic_vector( 31 downto 0 ); -- ����� ������
	data:	in std_logic_vector( 31 downto 0 ) -- ������ ��� ������
	) is
	
 variable vcmd: bh_cmd;
	
begin		  
	
	vcmd.cmd:=20;
	vcmd.adr(0):=adr;
	vcmd.data(0)( 31 downto 0 ):=data;
	cmd<=vcmd;	 
	wait until ret'event;
	wait for 1 ns;
	vcmd.cmd:=0;
	cmd<=vcmd;	
	wait for 10 ns;	
	
end int_mem_write;


	
end package body cmd_sim_pkg;		