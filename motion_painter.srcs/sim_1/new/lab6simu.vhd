----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2024 03:07:57
-- Design Name: 
-- Module Name: lab6simu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab6simu is
--  Port ( );
end lab6simu;

architecture Behavioral of lab6simu is
component vga
    Port ( clk : in STD_LOGIC;
               vertical_sync : out STD_LOGIC;
               horizontal_sync : out STD_LOGIC);
    end component;

signal clk_ne : std_logic:='0';
signal vertical_new : std_logic:='0';
signal horizontal_new : std_logic:='0';

begin
clk_ne<=not clk_ne after 5ns;

vga0 : vga
           port map ( 
           clk => clk_ne,
           vertical_sync  =>  vertical_new ,
           horizontal_sync  =>  horizontal_new 
         );
         
         


end Behavioral;
