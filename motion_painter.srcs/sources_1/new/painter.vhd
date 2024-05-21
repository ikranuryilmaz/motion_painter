----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2024 22:44:16
-- Design Name: 
-- Module Name: painter - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity painter is
    Port ( clk : in STD_LOGIC;
    threshold : in std_logic_vector(2 downto 0);
    negthreshold: in std_logic_vector( 2 downto 0);
    colour : in std_logic_vector(2 downto 0);
    reset : in std_logic;
    data_in : in std_logic_vector( 8 downto 0);
    dataforpaint : out std_logic_vector(0 downto 0);
    wrepaint : out std_logic_vector(0 downto 0)
           );
    
end painter;

architecture Behavioral of painter is

begin
process(clk)
begin
    if rising_edge(clk) then
    wrepaint<="0";
        if colour="001" then --RED
            if (unsigned(data_in(2 downto 0)) >= unsigned(threshold) and unsigned(data_in(5 downto 3))<=unsigned(negthreshold) and unsigned(data_in(8 downto 6 ))<=unsigned(negthreshold) ) then
                wrepaint<="1";
                dataforpaint<="1";
            end if;
            
        end if;
        
        if colour="010" then --GREEN
            if (unsigned(data_in(5 downto 3)) >= unsigned(threshold) and unsigned(data_in(2 downto 0))<=unsigned(negthreshold) and unsigned(data_in(8 downto 6))<=unsigned(negthreshold) )then
                wrepaint<="1";
                dataforpaint<="1";
            end if;
        
        
        end if;
        
        if colour="100" then --BLUE
            if (unsigned(data_in(8 downto 6)) >= unsigned(threshold) and unsigned(data_in(5 downto 3))<=unsigned(negthreshold) and unsigned(data_in(2 downto 0))<=unsigned(negthreshold) )then
                wrepaint<="1";
                dataforpaint<="1";
            
            end if;
        
        end if;
        
        if reset='1' then
            wrepaint<="1";
            dataforpaint<="0";         
        end if;
    
    end if;
end process;


end Behavioral;
