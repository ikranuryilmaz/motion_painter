----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2024 17:48:00
-- Design Name: 
-- Module Name: camera - Behavioral
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

entity camera is
    Port ( 
           pclk : in STD_LOGIC;
           vsync : in std_logic;
           href : in std_logic;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           addr: out STD_LOGIC_VECTOR (17 downto 0);
           writeenable : out std_logic_vector(0 downto 0);
           dataforbuffer : out std_logic_vector(8 downto 0)
           );
           
          
end camera;

architecture Behavioral of camera is
signal counter,drop :  std_logic:='0';
signal R,G,B : std_logic_vector (2 downto 0):= (others=>'0');
signal address : integer :=0;
signal check, rgb_ready : std_logic:='0';
begin
    addr<= std_logic_vector(to_unsigned(address, addr'length));
    process (pclk)
    begin
        if rising_edge(pclk) then
            writeenable<="0";
      
            check<=href;
            if( vsync='1') then
                address<=0;
                drop<='0';
            end if; 
            
            if((check='0') and (href='1')) then
                drop<= not drop;

            end if;
            
            if ((href='1') and (drop='0')) then
                counter<=not counter;
                if counter='0' then
                    R(0)<=data(5);
                    R(1)<=data(6);
                    R(2)<=data(7);
                    
                    G(0)<=data(0);
                    G(1)<=data(1);
                    G(2)<=data(2);
                else    
                    
                    B(0)<=data(2);
                    B(1)<=data(3);
                    B(2)<=data(4);
                    
                    rgb_ready<='1';                          
                end if;   
                                                         
            end if;
            if rgb_ready='1' then
                dataforbuffer ( 2 downto 0)<= R;
                dataforbuffer ( 5 downto 3)<= G;
                dataforbuffer ( 8 downto 6)<= B;
                writeenable<="1";
                rgb_ready<='0';
                address<=address+1;
            end if;
        end if;
        
    end process;

end Behavioral;
