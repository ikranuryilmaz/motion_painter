----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2024 02:03:57
-- Design Name: 
-- Module Name: vga - Behavioral
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

entity vga is
    Port ( clk_new : in STD_LOGIC;
           addr: out STD_LOGIC_VECTOR (17 downto 0);         
           data_in : in std_logic_vector(8 downto 0);
           vgaRed: out std_logic_vector(3 downto 0);
           vgaBlue: out std_logic_vector(3 downto 0);
           vgaGreen: out std_logic_vector(3 downto 0);
           vertical_sync : out STD_LOGIC;
           horizontal_sync : out STD_LOGIC);
end vga;



architecture Behavioral of vga is
signal s_horizontal : STD_LOGIC:='0';
signal s_vertical : STD_LOGIC:='0';
signal counterHorizontal: unsigned (31 downto 0):= (others=>'0');
signal counterVertical: unsigned (31 downto 0):= (others=>'0');
signal addresscounter: integer:=0;
signal repaint : std_logic:='0';

 
begin
vertical_sync<=s_vertical;
horizontal_sync<=s_horizontal;

addr<= std_logic_vector(to_unsigned(addresscounter, addr'length));
        
         process(clk_new)
         begin
         if rising_edge(clk_new) then
            counterHorizontal<=counterHorizontal+1;
            s_horizontal<='1';
            if counterHorizontal>656 and counterHorizontal<752+1  then
                s_horizontal<='0';              
            end if;
            if counterHorizontal=800-1 then
                counterHorizontal<=(others=>'0');
                counterVertical<=counterVertical+1;
                repaint <= not repaint;
                if ((repaint = '0') and (addresscounter>=640)) then
                    addresscounter<=addresscounter-642;
                end if;   
                         
            end if;
            s_vertical<='1';
            if counterVertical> 490 and counterVertical<492+1 then
                s_vertical<='0';     
            end if;
            if counterVertical=525 then
            counterVertical<=(others=>'0');
            addresscounter<=0;
            end if;
            
            if counterVertical>=0 and counterVertical<=480 and counterHorizontal>=0 and counterHorizontal<=640 then
                vgaRed<= data_in(2 downto 0)&"0";
                vgaGreen<=data_in(5 downto 3)&"0";
                vgaBlue<=data_in(8 downto 6)&"0";
                addresscounter<=addresscounter+1;
            else
                vgaRed<="0000";
                vgaBlue<="0000";
                vgaGreen<="0000";
            end if;
         
         end if;
         
         end process;
end Behavioral;
