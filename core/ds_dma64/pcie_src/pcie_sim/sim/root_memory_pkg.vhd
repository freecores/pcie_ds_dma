-------------------------------------------------------------------------------
--
-- Title       : root_memory_pkg
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;	  
use ieee.std_logic_unsigned.all;	 
use ieee.std_logic_textio.all;

use std.textio.all;
use std.textio;


package	root_memory_pkg is		  

type type_root_mem32 is array (natural range<>) of integer;	

shared variable root_mem_0x10	: type_root_mem32( 16383 downto 0 );  	-- ������ 0x100000 - 0x10FFFF;
shared variable root_mem_0x80	: type_root_mem32( 16383 downto 0 );	-- ������ 0x800000 - 0x80FFFF;

--! ������ ������ COMPLETION � 32-� ��������� ������ 
shared variable	memory_request_completion_size	:integer:=16;

--! ��� ������ ������� � ������ 
type type_memory_request_item is record
	
	tag				: std_logic_vector( 7 downto 0 );  		--! ������������� ������� 
	adr_low			: std_logic_vector( 31 downto 0 ); 		--! ������� ������� ������ 
	adr_high		: std_logic_vector( 31 downto 0 ); 		--! ������� ������� ������
	size			: integer;                         		--! ������ 
	requester_id	: std_logic_vector( 15 downto 0 ); 		--! ������������� ����������� �������
	
end record;	



signal			mem64r_request			: std_logic:='0';	--! ������� ������� 


--! ������ ������� � �������
procedure	memory_request_write
	(
		req_item		: in type_memory_request_item	--! ������
	);
	
--! ���������� ������� �� ������� 	
procedure	memory_request_read
	(						 
		req_ready		: out integer;						--! 1 - ���� ������
		req_item		: out type_memory_request_item		--! ������ 
	);
	
	
--! ������ ������ � ������ 
procedure	memory_write
	(						 
		adr_high		: in std_logic_vector( 31 downto 0 );	--! 1 - ������� ������� ������
		adr_low			: in std_logic_vector( 31 downto 0 );	--! 1 - ������� ������� ������
		data			: std_logic_vector( 31 downto 0 )		--! ������ ��� ������ � ������
	);
	
		

end package;	

package body root_memory_pkg is
	
	
constant	memory_request_size			: integer:=64;	--! ������ ������� ��������
--! ���� ������� �������� �� ������ 
type type_memory_request_array is array( memory_request_size-1 downto 0 ) of type_memory_request_item;
	
-- ������� �������� 
shared variable	memory_request_array	: type_memory_request_array;	--! ������ ������� 
shared variable memory_request_index_wr	: integer:=-1;					--! ������ ������ � ������ �������� 
shared variable memory_request_index_rd	: integer:=-1;					--! ������ ������ �� ������ ��������
	
	
--! ������� � ���������� �������� 	
function next_index( index : in integer ) return integer is

	variable	ret		: integer;

begin
	
	ret := index + 1;
	if( ret=memory_request_size ) then
		ret:=0;
	end if;
	
	return ret;
	
end next_index;
	
--! ������ ������� � �������
procedure	memory_request_write
	(
		req_item		: in type_memory_request_item	--! ������
	) is
	
variable	n	: integer;

begin

	n:=next_index( memory_request_index_wr );
	
	memory_request_array( n ) := req_item;
	
	memory_request_index_wr:=n;
	
	
end memory_request_write;
	
--! ���������� ������� �� ������� 	
procedure	memory_request_read
	(						 
		req_ready		: out integer;						--! 1 - ���� ������
		req_item		: out type_memory_request_item		--! ������ 
	) is

variable	n		: integer;	
variable	ret		: type_memory_request_array;

begin			   
	
	if( memory_request_index_wr=memory_request_index_rd ) then
		req_ready := 0;
	else
		n:=next_index( memory_request_index_rd );
		req_item:=memory_request_array( n );
		req_ready := 1;
		memory_request_index_rd :=n;
	end if;
	
end memory_request_read;	
		

--! ������ ������ � ������ 
procedure	memory_write
	(						 
		adr_high		: in std_logic_vector( 31 downto 0 );	--! 1 - ������� ������� ������
		adr_low			: in std_logic_vector( 31 downto 0 );	--! 1 - ������� ������� ������
		data			: std_logic_vector( 31 downto 0 )		--! ������ ��� ������ � ������
	) is
	
variable	adr_h		: integer;
variable	adr_l		: integer;
variable	datai		: integer;
variable	index		: integer;
variable 	str 	: LINE;		-- pointer to string
begin

	adr_h :=  conv_integer( adr_high );
	adr_l := conv_integer( adr_low );

	if( adr_h=0 ) then
		if( adr_l>=16#100000# and adr_l<=16#10FFFF# ) then
			index:=adr_l-16#100000#;
			index:=index/4;
			root_mem_0x10(index):= conv_integer( data );
			
		write( str, string'("adr_l: " )); hwrite( str, adr_low ); write( str, string'(" index: " )); write( str, index ); write( str, string'(" : " ));  hwrite( str, data ); writeline( output, str );

		elsif( adr_l>=16#800000# and adr_l<=16#80FFFF# ) then
			index:=adr_l-16#800000#;
			index:=index/4;
			root_mem_0x80(index):= conv_integer( data );
		end if;		
	end if;

	
end memory_write;
	

end package body;	