----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2024 17:48:54
-- Design Name: 
-- Module Name: top_module - Behavioral
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

entity top_module is   
Port (
    clk_100MHz : in std_logic;
    pclk : in std_logic;
    data : in std_logic_vector(7 downto 0);
    vsynccam : in std_logic;
    href : in std_logic;
    colour: in std_logic_vector(2 downto 0);
    threshold : in std_logic_vector(2 downto 0);
    negthreshold : in std_logic_vector(2 downto 0);
    reset: in std_logic;
    vgaRed: out std_logic_vector(3 downto 0);
    vgaBlue: out std_logic_vector(3 downto 0);
    vgaGreen: out std_logic_vector(3 downto 0);
    vertical_sync : out STD_LOGIC;
    horizontal_sync : out STD_LOGIC;
    xclk : out std_logic;
    send_configuration : in std_logic;
    scl : inout std_logic;
    sda : inout std_logic

 );
end top_module;

architecture Behavioral of top_module is
component vga
port(
            clk_new : in STD_LOGIC;
            addr: out STD_LOGIC_VECTOR (17 downto 0);         
            data_in : in std_logic_vector(8 downto 0);
            vgaRed: out std_logic_vector(3 downto 0);
            vgaBlue: out std_logic_vector(3 downto 0);
            vgaGreen: out std_logic_vector(3 downto 0);
            vertical_sync : out STD_LOGIC;
            horizontal_sync : out STD_LOGIC
);
end component;

component camera
port(
           pclk : in STD_LOGIC;
           vsync : in std_logic;
           href : in std_logic;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           addr: out std_logic_vector(17 downto 0);
           writeenable : out std_logic_vector(0 downto 0);
           dataforbuffer : out std_logic_vector(8 downto 0)
           );
end component;

component painter
Port ( clk : in STD_LOGIC;
    threshold : in std_logic_vector(2 downto 0);
    negthreshold :in std_logic_vector(2 downto 0);
    colour : in std_logic_vector(2 downto 0);
    reset : in std_logic;
    data_in : in std_logic_vector( 8 downto 0);
    dataforpaint : out std_logic_vector(0 downto 0);
    wrepaint : out std_logic_vector(0 downto 0)
           );
end component;


component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_25MHz          : out    std_logic;
  clk_24MHz          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

COMPONENT PaintBuffer
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT FrameBuffer
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT send_config
    Port ( clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           scl : inout STD_LOGIC;
           sda : inout STD_LOGIC);
END COMPONENT;

signal clk_new, xclk_sig : std_logic:='0';
signal wea,painted,wrepaint,dataforpaint: std_logic_vector(0 downto 0):= (others=>'0');
signal addr,addrb,addrb_minus: std_logic_vector(17 downto 0):= (others=>'0');
signal dataforbuffer, doutb, final: std_logic_vector(8 downto 0):= (others=>'0');

begin

xclk <= xclk_sig;
clock_wizard : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_25MHz => clk_new,
   clk_24MHz => xclk_sig,
   -- Clock in ports
   clk_in1 => clk_100MHz
 );
 
 frameram : FrameBuffer
  PORT MAP (
    clka => pclk,
    wea => wea,
    addra => addr,
    dina => dataforbuffer,
    clkb => clk_new,
    addrb => addrb,
    doutb => doutb
  );
  
 mycam : camera
   PORT MAP(
   pclk =>  pclk ,
   vsync => vsynccam ,
   href =>  href ,
   data => data  ,
   addr =>  addr ,
   writeenable =>  wea,
   dataforbuffer =>  dataforbuffer
   );
   
   
final <= doutb or (painted&painted&painted&painted&painted&painted&painted&painted&painted);
thisvga : vga
    PORT MAP(
    clk_new =>  clk_new,
    addr => addrb,
    data_in => final,
    vgaRed =>  vgaRed,
    vgaBlue =>  vgaBlue,
    vgaGreen =>  vgaGreen ,
    vertical_sync =>  vertical_sync,
    horizontal_sync =>  horizontal_sync
    );
    
paintmachine : painter
    PORT MAP(
    clk =>pclk,
    negthreshold=>negthreshold,
    threshold=>threshold,
    colour=>colour,
    reset=>reset,
    data_in=>dataforbuffer,
    dataforpaint => dataforpaint,
    wrepaint=>wrepaint
   
    
    );
    
    addrb_minus<=std_logic_vector(unsigned(addrb)-1);
paintram : PaintBuffer
  PORT MAP (
    clka => pclk,
    wea => wrepaint,
    addra => addr,
    dina => dataforpaint,
    clkb => clk_new,
    addrb => addrb_minus,
    doutb => painted
  );
sendconfig: send_config
  PORT MAP (
    clk => xclk_sig,
    reset => send_configuration,
    scl => scl,
    sda => sda
  );

end Behavioral;
