---------------------------------------------------------------------------------------------------
--
-- Title       : trd_pkg.vhd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
--	
-- Version	   : 1.0
---------------------------------------------------------------------------------------------------
--
-- Description : ����� ������� ��� ������� � �������� ����� ���� PCI Express 
--
---------------------------------------------------------------------------------------------------
--					
--  Version 1.0  02.07.2011
--				  ������ �� trd_simulation_pkg.vhd v1.0
--
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;		
use ieee.std_logic_arith.all;  
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;

library work;
use work.cmd_sim_pkg.all;

use std.textio.all;
use std.textio;

package trd_pkg is
	
		
constant MODE0		: integer:=0;
constant IRQ_MASK	: integer:=1;
constant IRQ_INV	: integer:=2;
constant FMODE		: integer:=3;
constant FDIV		: integer:=4;
constant STMODE		: integer:=5;
constant CNT0		: integer:=6;
constant CNT1		: integer:=7;
constant CNT2		: integer:=8;
constant MODE1		:  integer:=9;
constant MODE2		:  integer:=10;
constant MODE3		:  integer:=11;
constant MODE4		:  integer:=12;
constant SYNX		:  integer:=13;
constant THDAC		:  integer:=14;
constant MUX		:  integer:=15;

constant ID			:  integer:=16#100#;
constant VER		:  integer:=16#102#;
constant TRES		:  integer:=16#103#;

constant REG200		:  integer:=16#200#;
constant REG201		:  integer:=16#201#;


constant TRDIND_MODE0		: integer:=0;
constant TRDIND_IRQ_MASK	: integer:=1;
constant TRDIND_IRQ_INV		: integer:=2;
constant TRDIND_FMODE		: integer:=3;
constant TRDIND_FDIV		: integer:=4;
constant TRDIND_STMODE		: integer:=5;
constant TRDIND_CNT0		: integer:=6;
constant TRDIND_CNT1		: integer:=7;
constant TRDIND_CNT2		: integer:=8;
constant TRDIND_MODE1		:  integer:=9;
constant TRDIND_MODE2		:  integer:=10;
constant TRDIND_MODE3		:  integer:=11;
constant TRDIND_SFLAG		:  integer:=12;
constant TRDIND_SYNX		:  integer:=13;
constant TRDIND_THDAC		:  integer:=14;
constant TRDIND_MUX			:  integer:=15;

constant TRDIND_SFLAG_PAE	:  integer:=12;
constant TRDIND_SFLAG_PAF	:  integer:=13;


constant TRDIND_CHAN1		:  integer:=16#10#;
constant TRDIND_CHAN2		:  integer:=16#11#;
constant TRDIND_FORMAT		:  integer:=16#12#;
constant TRDIND_FSRC		:  integer:=16#13#;
constant TRDIND_FDVR		:  integer:=16#14#;
constant TRDIND_GAIN		:  integer:=16#15#;
constant TRDIND_INP			:  integer:=16#16#;
constant TRDIND_CONTROL1	:  integer:=16#17#;

constant TRDIND_ID			:  integer:=16#100#;
constant TRDIND_IDMOD		:  integer:=16#101#;
constant TRDIND_VER			:  integer:=16#102#;
constant TRDIND_TRES		:  integer:=16#103#;

constant TRDIND_REG200		:  integer:=16#200#;
constant TRDIND_REG201		:  integer:=16#201#;

constant TRDIND_FLAGCLR		:  integer:=16#200#;
constant TRDIND_ADC_OR		:  integer:=16#208#;
constant TRDIND_PRT_STATUS	:  integer:=16#209#;
constant TRDIND_PRT_CNTL	:  integer:=16#20A#;
constant TRDIND_PRT_CNTH	:  integer:=16#20B#;
constant TRDIND_TL_ADR		:  integer:=16#20C#;
constant TRDIND_TL_DATA		:  integer:=16#20E#;
constant TRDIND_TL_MODE		:  integer:=16#20E#;





---- ������������ ����� �������� ������ ----		
procedure trd_test_mode (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		mode:			in  integer -- 1 - �������� �����
									-- 0 - ������� �����
		);
		
---- ������ � ��������� ������� ��� �������� ���������� ----		
procedure trd_cmd (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			in std_logic_vector( 15 downto 0 ) -- ������
		);

---- ������ � ��������� ������� � ��������� ���������� ----		
procedure trd_wait_cmd (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			in std_logic_vector( 15 downto 0 ) -- ������
		);	
		
---- ������ �� ���������� �������� � ��������� ���������� ----		
procedure trd_wait_cmd_in (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		);	

---- ������ �� ���������� �������� ��� �������� ���������� ----		
procedure trd_cmd_in (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		);
		
---- ������ 64-� ���������� ����� � ������� DATA ----		
procedure trd_data_out64 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			in std_logic_vector( 63 downto 0 ) -- ������
		);
		
---- ������ 64-� ���������� ����� �� �������� DATA ----		
procedure trd_data_in64 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 63 downto 0 ) -- ������
		);
		
---- ������ 32-� ���������� ����� � ������� DATA ----		
procedure trd_data_out32 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			in std_logic_vector( 31 downto 0 ) -- ������
		);
		
---- ������ 32-� ���������� ����� �� �������� DATA ----		
procedure trd_data_in32 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 31 downto 0 ) -- ������
		);
		
		
---- ������ ������� 32-� ��������� ����� � ������� DATA ----		
procedure trd_data_array_out32 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: in mem32( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
);

---- ������ ������� 32-� ��������� ����� �� �������� DATA ----
procedure trd_data_array_in32 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: out mem32( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
);

---- ������ ������� 64-� ��������� ����� � ������� DATA ----
procedure trd_data_array_out64 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: in mem64( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
);

---- ������ ������� 64-� ��������� ����� �� �������� DATA ----
procedure trd_data_array_in64 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: out mem64( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
);		

---- ������ �������� STATUS ----
procedure trd_status (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		);
		
		
		

end package	trd_pkg;

package body trd_pkg is
	

procedure trd_test_mode (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		mode:			in  integer -- 1 - �������� �����
									-- 0 - ������� �����
		) is 
begin								
	if( mode=1 ) then
	 trd_data_out32( cmd, ret, 0, x"00000002" );
	else
	 trd_data_out32( cmd, ret, 0, x"00000001" );
	end if;
end trd_test_mode;

procedure trd_cmd (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			in std_logic_vector( 15 downto 0 ) -- ������
		) is 
variable v: std_logic_vector( 31 downto 0 );		 
begin										
	v:=conv_std_logic_vector( reg, 32 );
	data_write(  cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+4096*4096, 32), v ); 
	v( 31 downto 16 ):=(others=>'0');
	v( 15 downto 0 ):=data;
	data_write( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+3*4096, 32), v ); 
end;

procedure trd_wait_cmd (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			in std_logic_vector( 15 downto 0 ) -- ������
		) is 
variable v: std_logic_vector( 31 downto 0 );
variable b: std_logic;
begin										
	v:=conv_std_logic_vector( reg, 32 );
	data_write(  cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+2*4096, 32), v );   
	lp1: loop
		data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+0, 32), v ); 
		b:=v(0);
		if(b='1')then 
			exit lp1;
		end if;
	end loop;
	
	v( 31 downto 16 ):=(others=>'0');
	v( 15 downto 0 ):=data;
	data_write( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+3*4096, 32), v ); 
end;

procedure trd_cmd_in (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		) is 
variable v: std_logic_vector( 31 downto 0 );		 
begin										
	v:=conv_std_logic_vector( reg, 32 );
	data_write(  cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+2*4096, 32), v ); 
	data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+3*4096, 32), v ); 
	data:=v( 15 downto 0 );
end;


procedure trd_wait_cmd_in (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		reg:			in integer; -- ����� ��������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		) is 
variable v: std_logic_vector( 31 downto 0 );		 
variable b: std_logic;
begin										
	v:=conv_std_logic_vector( reg, 32 );
	data_write(  cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+2*4096, 32), v ); 
	
	lp1: loop
		data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+0, 32), v ); 
		b:=v(0);
		if(b='1')then 
			exit lp1;
		end if;
	end loop;
	
	data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+3*4096, 32), v ); 
	data:=v( 15 downto 0 );
end;

procedure trd_data_out64 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			in std_logic_vector( 63 downto 0 ) -- ������
		)  is 
begin										
	data_write64( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32), data ); 
end;

procedure trd_data_in64 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 63 downto 0 ) -- ������
		) is 
begin
	data_read64( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32), data ); 
end;
		
procedure trd_data_out32 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			in std_logic_vector( 31 downto 0 ) -- ������
		) is 
begin
	data_write( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32), data ); 
	
end;

procedure trd_data_in32 (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 31 downto 0 ) -- ������
		) is 
begin
	data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32), data ); 
	
end;


procedure trd_data_array_out32 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: in mem32( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
) is 
 variable adr	: mem32( mem_size-1 downto 0 ); -- �����
begin												   
	for i in 0 to mem_size-1  loop
		adr(i):=x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32);
	end loop;
	array_write( cmd, ret, adr, data, n ); 
	
end;

procedure trd_data_array_in32 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: out mem32( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
) is 
 variable adr	: mem32( mem_size-1 downto 0 ); -- �����
begin												   
	for i in 0 to mem_size-1  loop
		adr(i):=x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32);
	end loop;
	array_read( cmd, ret, adr, data, n ); 
	
end;

procedure trd_data_array_out64 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: in mem64( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
) is 
 variable adr	: mem32( mem_size-1 downto 0 ); -- �����
begin												   
	for i in 0 to mem_size-1  loop
		adr(i):=x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32);
	end loop;
	array_write64( cmd, ret, adr, data, n ); 
	
end;

procedure trd_data_array_in64 (
		signal  cmd	: out bh_cmd; 						-- ������� ��� ADSP
		signal  ret	: in  bh_ret; 						-- ����� ADSP
		trd			: in integer; 						-- ����� �������
		data		: out mem64( mem_size-1 downto 0 ); 	-- ������
		n			: in integer						-- ������ ����� ������
) is 
 variable adr	: mem32( mem_size-1 downto 0 ); -- �����
begin												   
	for i in 0 to mem_size-1  loop
		adr(i):=x"20000000"+conv_std_logic_vector(trd*4096*4+4096, 32);
	end loop;
	array_read64( cmd, ret, adr, data, n ); 
	
end;

		
procedure trd_status (
		signal  cmd:	out bh_cmd; -- ������� ��� ADSP
		signal  ret:	in  bh_ret; -- ����� ADSP
		trd:			in integer; -- ����� �������
		data:			out std_logic_vector( 15 downto 0 ) -- ������
		) is 
 variable v: std_logic_vector( 31 downto 0 );
begin
	data_read( cmd, ret, x"20000000"+conv_std_logic_vector(trd*4096*4+0, 32), v ); 
	data:=v( 15 downto 0 );
	
end;
		

		

end package	body trd_pkg;

