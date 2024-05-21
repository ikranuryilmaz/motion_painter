----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2024 16:46:24
-- Design Name: 
-- Module Name: send_config - Behavioral
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

entity send_config is
    Port ( clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           scl : inout STD_LOGIC;
           sda : inout STD_LOGIC);
end send_config;

architecture Behavioral of send_config is
    component i2c_master is
        GENERIC(
            input_clk : INTEGER := 24_000_000; --input clock speed from user logic in Hz
            bus_clk   : INTEGER := 100_000   --speed the i2c bus (scl) will run at in Hz
        );
        PORT(
            clk       : IN     STD_LOGIC;                    --system clock
            reset_n   : IN     STD_LOGIC;                    --active low reset
            ena       : IN     STD_LOGIC;                    --latch in command
            addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
            rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
            data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
            busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
            data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
            ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
            sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
            scl       : INOUT  STD_LOGIC                     --serial clock output of i2c bus
        );                   
    end component;
    signal i2c_ena,i2c_rw,i2c_busy, busy_prev : STD_LOGIC :='0';
    signal i2c_addr : STD_LOGIC_VECTOR(6 downto 0) := (others=>'0');
    signal i2c_data_wr : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
    signal busy_cnt,delay_ctr : integer := 0;
    signal reset_sync,reset_sync2 : STD_LOGIC := '0';
    signal slave_addr : STD_LOGIC_VECTOR(6 downto 0) := "0100001";
begin
    i2c_module: i2c_master
    port map(
        clk => clk,
        reset_n => reset_sync2,
        ena => i2c_ena,
        addr => i2c_addr,
        rw => i2c_rw,
        data_wr => i2c_data_wr,
        busy =>i2c_busy,
        sda => sda,
        scl => scl
    );
    process(clk)
    begin
        if rising_edge(clk) then
            i2c_rw<='0';i2c_addr <= slave_addr;
            if reset='1' then
                delay_ctr <= delay_ctr+1;
                if delay_ctr = 10_000_000 then
                    delay_ctr<=0;
                    reset_sync<='1';
                    reset_sync2<='1';
                end if;
            else
                delay_ctr<=0;
                reset_sync<='0';
                reset_sync2<='0';            
            end if;

            busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
            if reset_sync='1' then
                IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                   busy_cnt <= busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                END IF;
				CASE busy_cnt IS                             
					WHEN 0 => i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 1 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 1_000_000 then
							busy_cnt <= busy_cnt+1;
							delay_ctr<=0;
						end if;

					WHEN 2 => i2c_ena <= '1'; i2c_data_wr <= x"12";
					WHEN 3 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 4 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 7_500_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 5 => i2c_ena <= '1'; i2c_data_wr <= x"11";
					WHEN 6 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 7 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 8 => i2c_ena <= '1'; i2c_data_wr <= x"3A";
					WHEN 9 =>i2c_ena <= '1'; i2c_data_wr <= x"04";
					WHEN 10 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 11 => i2c_ena <= '1'; i2c_data_wr <= x"12";
					WHEN 12 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 13 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 14 => i2c_ena <= '1'; i2c_data_wr <= x"17";
					WHEN 15 =>i2c_ena <= '1'; i2c_data_wr <= x"13";
					WHEN 16 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 17 => i2c_ena <= '1'; i2c_data_wr <= x"18";
					WHEN 18 =>i2c_ena <= '1'; i2c_data_wr <= x"01";
					WHEN 19 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 20 => i2c_ena <= '1'; i2c_data_wr <= x"32";
					WHEN 21 =>i2c_ena <= '1'; i2c_data_wr <= x"B6";
					WHEN 22 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 23 => i2c_ena <= '1'; i2c_data_wr <= x"19";
					WHEN 24 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 25 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 26 => i2c_ena <= '1'; i2c_data_wr <= x"1A";
					WHEN 27 =>i2c_ena <= '1'; i2c_data_wr <= x"7A";
					WHEN 28 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 29 => i2c_ena <= '1'; i2c_data_wr <= x"03";
					WHEN 30 =>i2c_ena <= '1'; i2c_data_wr <= x"0A";
					WHEN 31 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 32 => i2c_ena <= '1'; i2c_data_wr <= x"0C";
					WHEN 33 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 34 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 35 => i2c_ena <= '1'; i2c_data_wr <= x"3E";
					WHEN 36 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 37 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 38 => i2c_ena <= '1'; i2c_data_wr <= x"70";
					WHEN 39 =>i2c_ena <= '1'; i2c_data_wr <= x"3A";
					WHEN 40 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 41 => i2c_ena <= '1'; i2c_data_wr <= x"71";
					WHEN 42 =>i2c_ena <= '1'; i2c_data_wr <= x"35";
					WHEN 43 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 44 => i2c_ena <= '1'; i2c_data_wr <= x"72";
					WHEN 45 =>i2c_ena <= '1'; i2c_data_wr <= x"11";
					WHEN 46 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 47 => i2c_ena <= '1'; i2c_data_wr <= x"73";
					WHEN 48 =>i2c_ena <= '1'; i2c_data_wr <= x"F0";
					WHEN 49 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 50 => i2c_ena <= '1'; i2c_data_wr <= x"A2";
					WHEN 51 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 52 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 53 => i2c_ena <= '1'; i2c_data_wr <= x"15";
					WHEN 54 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 55 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 56 => i2c_ena <= '1'; i2c_data_wr <= x"7a";
					WHEN 57 =>i2c_ena <= '1'; i2c_data_wr <= x"20";
					WHEN 58 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 59 => i2c_ena <= '1'; i2c_data_wr <= x"7b";
					WHEN 60 =>i2c_ena <= '1'; i2c_data_wr <= x"10";
					WHEN 61 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 62 => i2c_ena <= '1'; i2c_data_wr <= x"7c";
					WHEN 63 =>i2c_ena <= '1'; i2c_data_wr <= x"1e";
					WHEN 64 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 65 => i2c_ena <= '1'; i2c_data_wr <= x"7d";
					WHEN 66 =>i2c_ena <= '1'; i2c_data_wr <= x"35";
					WHEN 67 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 68 => i2c_ena <= '1'; i2c_data_wr <= x"7e";
					WHEN 69 =>i2c_ena <= '1'; i2c_data_wr <= x"5a";
					WHEN 70 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 71 => i2c_ena <= '1'; i2c_data_wr <= x"7f";
					WHEN 72 =>i2c_ena <= '1'; i2c_data_wr <= x"69";
					WHEN 73 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 74 => i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 75 =>i2c_ena <= '1'; i2c_data_wr <= x"76";
					WHEN 76 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 77 => i2c_ena <= '1'; i2c_data_wr <= x"81";
					WHEN 78 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 79 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 80 => i2c_ena <= '1'; i2c_data_wr <= x"82";
					WHEN 81 =>i2c_ena <= '1'; i2c_data_wr <= x"88";
					WHEN 82 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 83 => i2c_ena <= '1'; i2c_data_wr <= x"83";
					WHEN 84 =>i2c_ena <= '1'; i2c_data_wr <= x"8f";
					WHEN 85 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 86 => i2c_ena <= '1'; i2c_data_wr <= x"84";
					WHEN 87 =>i2c_ena <= '1'; i2c_data_wr <= x"96";
					WHEN 88 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 89 => i2c_ena <= '1'; i2c_data_wr <= x"85";
					WHEN 90 =>i2c_ena <= '1'; i2c_data_wr <= x"a3";
					WHEN 91 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 92 => i2c_ena <= '1'; i2c_data_wr <= x"86";
					WHEN 93 =>i2c_ena <= '1'; i2c_data_wr <= x"af";
					WHEN 94 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 95 => i2c_ena <= '1'; i2c_data_wr <= x"87";
					WHEN 96 =>i2c_ena <= '1'; i2c_data_wr <= x"c4";
					WHEN 97 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 98 => i2c_ena <= '1'; i2c_data_wr <= x"88";
					WHEN 99 =>i2c_ena <= '1'; i2c_data_wr <= x"d7";
					WHEN 100 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 101 => i2c_ena <= '1'; i2c_data_wr <= x"89";
					WHEN 102 =>i2c_ena <= '1'; i2c_data_wr <= x"e8";
					WHEN 103 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 104 => i2c_ena <= '1'; i2c_data_wr <= x"13";
					WHEN 105 =>i2c_ena <= '1'; i2c_data_wr <= x"E0";
					WHEN 106 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 107 => i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 108 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 109 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 110 => i2c_ena <= '1'; i2c_data_wr <= x"10";
					WHEN 111 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 112 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 113 => i2c_ena <= '1'; i2c_data_wr <= x"0d";
					WHEN 114 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 115 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 116 => i2c_ena <= '1'; i2c_data_wr <= x"14";
					WHEN 117 =>i2c_ena <= '1'; i2c_data_wr <= x"18";
					WHEN 118 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 119 => i2c_ena <= '1'; i2c_data_wr <= x"a5";
					WHEN 120 =>i2c_ena <= '1'; i2c_data_wr <= x"05";
					WHEN 121 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 122 => i2c_ena <= '1'; i2c_data_wr <= x"ab";
					WHEN 123 =>i2c_ena <= '1'; i2c_data_wr <= x"07";
					WHEN 124 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 125 => i2c_ena <= '1'; i2c_data_wr <= x"24";
					WHEN 126 =>i2c_ena <= '1'; i2c_data_wr <= x"95";
					WHEN 127 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 128 => i2c_ena <= '1'; i2c_data_wr <= x"25";
					WHEN 129 =>i2c_ena <= '1'; i2c_data_wr <= x"33";
					WHEN 130 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 131 => i2c_ena <= '1'; i2c_data_wr <= x"26";
					WHEN 132 =>i2c_ena <= '1'; i2c_data_wr <= x"E3";
					WHEN 133 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 134 => i2c_ena <= '1'; i2c_data_wr <= x"9f";
					WHEN 135 =>i2c_ena <= '1'; i2c_data_wr <= x"78";
					WHEN 136 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 137 => i2c_ena <= '1'; i2c_data_wr <= x"a0";
					WHEN 138 =>i2c_ena <= '1'; i2c_data_wr <= x"68";
					WHEN 139 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 140 => i2c_ena <= '1'; i2c_data_wr <= x"a1";
					WHEN 141 =>i2c_ena <= '1'; i2c_data_wr <= x"03";
					WHEN 142 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 143 => i2c_ena <= '1'; i2c_data_wr <= x"a6";
					WHEN 144 =>i2c_ena <= '1'; i2c_data_wr <= x"d8";
					WHEN 145 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 146 => i2c_ena <= '1'; i2c_data_wr <= x"a7";
					WHEN 147 =>i2c_ena <= '1'; i2c_data_wr <= x"d8";
					WHEN 148 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 149 => i2c_ena <= '1'; i2c_data_wr <= x"a8";
					WHEN 150 =>i2c_ena <= '1'; i2c_data_wr <= x"f0";
					WHEN 151 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 152 => i2c_ena <= '1'; i2c_data_wr <= x"a9";
					WHEN 153 =>i2c_ena <= '1'; i2c_data_wr <= x"90";
					WHEN 154 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 155 => i2c_ena <= '1'; i2c_data_wr <= x"aa";
					WHEN 156 =>i2c_ena <= '1'; i2c_data_wr <= x"94";
					WHEN 157 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 158 => i2c_ena <= '1'; i2c_data_wr <= x"13";
					WHEN 159 =>i2c_ena <= '1'; i2c_data_wr <= x"e5";
					WHEN 160 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 161 => i2c_ena <= '1'; i2c_data_wr <= x"0e";
					WHEN 162 =>i2c_ena <= '1'; i2c_data_wr <= x"61";
					WHEN 163 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 164 => i2c_ena <= '1'; i2c_data_wr <= x"0f";
					WHEN 165 =>i2c_ena <= '1'; i2c_data_wr <= x"4b";
					WHEN 166 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 167 => i2c_ena <= '1'; i2c_data_wr <= x"16";
					WHEN 168 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 169 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 170 => i2c_ena <= '1'; i2c_data_wr <= x"1e";
					WHEN 171 =>i2c_ena <= '1'; i2c_data_wr <= x"27";
					WHEN 172 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 173 => i2c_ena <= '1'; i2c_data_wr <= x"21";
					WHEN 174 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 175 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 176 => i2c_ena <= '1'; i2c_data_wr <= x"22";
					WHEN 177 =>i2c_ena <= '1'; i2c_data_wr <= x"91";
					WHEN 178 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 179 => i2c_ena <= '1'; i2c_data_wr <= x"29";
					WHEN 180 =>i2c_ena <= '1'; i2c_data_wr <= x"07";
					WHEN 181 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 182 => i2c_ena <= '1'; i2c_data_wr <= x"33";
					WHEN 183 =>i2c_ena <= '1'; i2c_data_wr <= x"0b";
					WHEN 184 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 185 => i2c_ena <= '1'; i2c_data_wr <= x"35";
					WHEN 186 =>i2c_ena <= '1'; i2c_data_wr <= x"0b";
					WHEN 187 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 188 => i2c_ena <= '1'; i2c_data_wr <= x"37";
					WHEN 189 =>i2c_ena <= '1'; i2c_data_wr <= x"1d";
					WHEN 190 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 191 => i2c_ena <= '1'; i2c_data_wr <= x"38";
					WHEN 192 =>i2c_ena <= '1'; i2c_data_wr <= x"71";
					WHEN 193 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 194 => i2c_ena <= '1'; i2c_data_wr <= x"39";
					WHEN 195 =>i2c_ena <= '1'; i2c_data_wr <= x"2a";
					WHEN 196 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 197 => i2c_ena <= '1'; i2c_data_wr <= x"3c";
					WHEN 198 =>i2c_ena <= '1'; i2c_data_wr <= x"78";
					WHEN 199 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 200 => i2c_ena <= '1'; i2c_data_wr <= x"4d";
					WHEN 201 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 202 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 203 => i2c_ena <= '1'; i2c_data_wr <= x"4e";
					WHEN 204 =>i2c_ena <= '1'; i2c_data_wr <= x"20";
					WHEN 205 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 206 => i2c_ena <= '1'; i2c_data_wr <= x"69";
					WHEN 207 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 208 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 209 => i2c_ena <= '1'; i2c_data_wr <= x"6b";
					WHEN 210 =>i2c_ena <= '1'; i2c_data_wr <= x"4a";
					WHEN 211 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 212 => i2c_ena <= '1'; i2c_data_wr <= x"74";
					WHEN 213 =>i2c_ena <= '1'; i2c_data_wr <= x"10";
					WHEN 214 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 215 => i2c_ena <= '1'; i2c_data_wr <= x"8d";
					WHEN 216 =>i2c_ena <= '1'; i2c_data_wr <= x"4f";
					WHEN 217 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 218 => i2c_ena <= '1'; i2c_data_wr <= x"8e";
					WHEN 219 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 220 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 221 => i2c_ena <= '1'; i2c_data_wr <= x"8f";
					WHEN 222 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 223 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 224 => i2c_ena <= '1'; i2c_data_wr <= x"90";
					WHEN 225 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 226 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 227 => i2c_ena <= '1'; i2c_data_wr <= x"91";
					WHEN 228 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 229 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 230 => i2c_ena <= '1'; i2c_data_wr <= x"96";
					WHEN 231 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 232 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 233 => i2c_ena <= '1'; i2c_data_wr <= x"9a";
					WHEN 234 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 235 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 236 => i2c_ena <= '1'; i2c_data_wr <= x"b0";
					WHEN 237 =>i2c_ena <= '1'; i2c_data_wr <= x"84";
					WHEN 238 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 239 => i2c_ena <= '1'; i2c_data_wr <= x"b1";
					WHEN 240 =>i2c_ena <= '1'; i2c_data_wr <= x"0c";
					WHEN 241 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 242 => i2c_ena <= '1'; i2c_data_wr <= x"b2";
					WHEN 243 =>i2c_ena <= '1'; i2c_data_wr <= x"0e";
					WHEN 244 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 245 => i2c_ena <= '1'; i2c_data_wr <= x"b3";
					WHEN 246 =>i2c_ena <= '1'; i2c_data_wr <= x"82";
					WHEN 247 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 248 => i2c_ena <= '1'; i2c_data_wr <= x"b8";
					WHEN 249 =>i2c_ena <= '1'; i2c_data_wr <= x"0a";
					WHEN 250 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 251 => i2c_ena <= '1'; i2c_data_wr <= x"43";
					WHEN 252 =>i2c_ena <= '1'; i2c_data_wr <= x"0a";
					WHEN 253 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 254 => i2c_ena <= '1'; i2c_data_wr <= x"44";
					WHEN 255 =>i2c_ena <= '1'; i2c_data_wr <= x"f0";
					WHEN 256 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 257 => i2c_ena <= '1'; i2c_data_wr <= x"45";
					WHEN 258 =>i2c_ena <= '1'; i2c_data_wr <= x"34";
					WHEN 259 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 260 => i2c_ena <= '1'; i2c_data_wr <= x"46";
					WHEN 261 =>i2c_ena <= '1'; i2c_data_wr <= x"58";
					WHEN 262 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 263 => i2c_ena <= '1'; i2c_data_wr <= x"47";
					WHEN 264 =>i2c_ena <= '1'; i2c_data_wr <= x"28";
					WHEN 265 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 266 => i2c_ena <= '1'; i2c_data_wr <= x"48";
					WHEN 267 =>i2c_ena <= '1'; i2c_data_wr <= x"3a";
					WHEN 268 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 269 => i2c_ena <= '1'; i2c_data_wr <= x"59";
					WHEN 270 =>i2c_ena <= '1'; i2c_data_wr <= x"88";
					WHEN 271 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 272 => i2c_ena <= '1'; i2c_data_wr <= x"5a";
					WHEN 273 =>i2c_ena <= '1'; i2c_data_wr <= x"88";
					WHEN 274 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 275 => i2c_ena <= '1'; i2c_data_wr <= x"5b";
					WHEN 276 =>i2c_ena <= '1'; i2c_data_wr <= x"44";
					WHEN 277 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 278 => i2c_ena <= '1'; i2c_data_wr <= x"5c";
					WHEN 279 =>i2c_ena <= '1'; i2c_data_wr <= x"67";
					WHEN 280 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 281 => i2c_ena <= '1'; i2c_data_wr <= x"5d";
					WHEN 282 =>i2c_ena <= '1'; i2c_data_wr <= x"49";
					WHEN 283 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 284 => i2c_ena <= '1'; i2c_data_wr <= x"5e";
					WHEN 285 =>i2c_ena <= '1'; i2c_data_wr <= x"0e";
					WHEN 286 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 287 => i2c_ena <= '1'; i2c_data_wr <= x"6c";
					WHEN 288 =>i2c_ena <= '1'; i2c_data_wr <= x"0a";
					WHEN 289 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 290 => i2c_ena <= '1'; i2c_data_wr <= x"6d";
					WHEN 291 =>i2c_ena <= '1'; i2c_data_wr <= x"55";
					WHEN 292 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 293 => i2c_ena <= '1'; i2c_data_wr <= x"6e";
					WHEN 294 =>i2c_ena <= '1'; i2c_data_wr <= x"11";
					WHEN 295 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 296 => i2c_ena <= '1'; i2c_data_wr <= x"6f";
					WHEN 297 =>i2c_ena <= '1'; i2c_data_wr <= x"9f";
					WHEN 298 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 299 => i2c_ena <= '1'; i2c_data_wr <= x"6a";
					WHEN 300 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 301 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 302 => i2c_ena <= '1'; i2c_data_wr <= x"01";
					WHEN 303 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 304 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 305 => i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 306 =>i2c_ena <= '1'; i2c_data_wr <= x"60";
					WHEN 307 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 308 => i2c_ena <= '1'; i2c_data_wr <= x"13";
					WHEN 309 =>i2c_ena <= '1'; i2c_data_wr <= x"e7";
					WHEN 310 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 311 => i2c_ena <= '1'; i2c_data_wr <= x"4f";
					WHEN 312 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 313 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 314 => i2c_ena <= '1'; i2c_data_wr <= x"50";
					WHEN 315 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 316 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 317 => i2c_ena <= '1'; i2c_data_wr <= x"51";
					WHEN 318 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 319 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 320 => i2c_ena <= '1'; i2c_data_wr <= x"52";
					WHEN 321 =>i2c_ena <= '1'; i2c_data_wr <= x"22";
					WHEN 322 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 323 => i2c_ena <= '1'; i2c_data_wr <= x"53";
					WHEN 324 =>i2c_ena <= '1'; i2c_data_wr <= x"5e";
					WHEN 325 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 326 => i2c_ena <= '1'; i2c_data_wr <= x"54";
					WHEN 327 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 328 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 329 => i2c_ena <= '1'; i2c_data_wr <= x"58";
					WHEN 330 =>i2c_ena <= '1'; i2c_data_wr <= x"9e";
					WHEN 331 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 332 => i2c_ena <= '1'; i2c_data_wr <= x"41";
					WHEN 333 =>i2c_ena <= '1'; i2c_data_wr <= x"08";
					WHEN 334 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 335 => i2c_ena <= '1'; i2c_data_wr <= x"3f";
					WHEN 336 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 337 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 338 => i2c_ena <= '1'; i2c_data_wr <= x"75";
					WHEN 339 =>i2c_ena <= '1'; i2c_data_wr <= x"05";
					WHEN 340 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 341 => i2c_ena <= '1'; i2c_data_wr <= x"76";
					WHEN 342 =>i2c_ena <= '1'; i2c_data_wr <= x"e1";
					WHEN 343 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 344 => i2c_ena <= '1'; i2c_data_wr <= x"4c";
					WHEN 345 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 346 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 347 => i2c_ena <= '1'; i2c_data_wr <= x"77";
					WHEN 348 =>i2c_ena <= '1'; i2c_data_wr <= x"01";
					WHEN 349 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 350 => i2c_ena <= '1'; i2c_data_wr <= x"3d";
					WHEN 351 =>i2c_ena <= '1'; i2c_data_wr <= x"c3";
					WHEN 352 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 353 => i2c_ena <= '1'; i2c_data_wr <= x"4b";
					WHEN 354 =>i2c_ena <= '1'; i2c_data_wr <= x"09";
					WHEN 355 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 356 => i2c_ena <= '1'; i2c_data_wr <= x"c9";
					WHEN 357 =>i2c_ena <= '1'; i2c_data_wr <= x"60";
					WHEN 358 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 359 => i2c_ena <= '1'; i2c_data_wr <= x"41";
					WHEN 360 =>i2c_ena <= '1'; i2c_data_wr <= x"38";
					WHEN 361 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 362 => i2c_ena <= '1'; i2c_data_wr <= x"56";
					WHEN 363 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 364 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 365 => i2c_ena <= '1'; i2c_data_wr <= x"34";
					WHEN 366 =>i2c_ena <= '1'; i2c_data_wr <= x"11";
					WHEN 367 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 368 => i2c_ena <= '1'; i2c_data_wr <= x"3b";
					WHEN 369 =>i2c_ena <= '1'; i2c_data_wr <= x"12";
					WHEN 370 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 371 => i2c_ena <= '1'; i2c_data_wr <= x"a4";
					WHEN 372 =>i2c_ena <= '1'; i2c_data_wr <= x"88";
					WHEN 373 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 374 => i2c_ena <= '1'; i2c_data_wr <= x"96";
					WHEN 375 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 376 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 377 => i2c_ena <= '1'; i2c_data_wr <= x"97";
					WHEN 378 =>i2c_ena <= '1'; i2c_data_wr <= x"30";
					WHEN 379 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 380 => i2c_ena <= '1'; i2c_data_wr <= x"98";
					WHEN 381 =>i2c_ena <= '1'; i2c_data_wr <= x"20";
					WHEN 382 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 383 => i2c_ena <= '1'; i2c_data_wr <= x"99";
					WHEN 384 =>i2c_ena <= '1'; i2c_data_wr <= x"30";
					WHEN 385 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 386 => i2c_ena <= '1'; i2c_data_wr <= x"9a";
					WHEN 387 =>i2c_ena <= '1'; i2c_data_wr <= x"84";
					WHEN 388 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 389 => i2c_ena <= '1'; i2c_data_wr <= x"9b";
					WHEN 390 =>i2c_ena <= '1'; i2c_data_wr <= x"29";
					WHEN 391 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 392 => i2c_ena <= '1'; i2c_data_wr <= x"9c";
					WHEN 393 =>i2c_ena <= '1'; i2c_data_wr <= x"03";
					WHEN 394 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 395 => i2c_ena <= '1'; i2c_data_wr <= x"9d";
					WHEN 396 =>i2c_ena <= '1'; i2c_data_wr <= x"4c";
					WHEN 397 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 398 => i2c_ena <= '1'; i2c_data_wr <= x"9e";
					WHEN 399 =>i2c_ena <= '1'; i2c_data_wr <= x"3f";
					WHEN 400 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 401 => i2c_ena <= '1'; i2c_data_wr <= x"78";
					WHEN 402 =>i2c_ena <= '1'; i2c_data_wr <= x"04";
					WHEN 403 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 404 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 405 =>i2c_ena <= '1'; i2c_data_wr <= x"01";
					WHEN 406 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 407 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 408 =>i2c_ena <= '1'; i2c_data_wr <= x"f0";
					WHEN 409 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 410 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 411 =>i2c_ena <= '1'; i2c_data_wr <= x"0f";
					WHEN 412 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 413 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 414 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 415 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 416 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 417 =>i2c_ena <= '1'; i2c_data_wr <= x"10";
					WHEN 418 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 419 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 420 =>i2c_ena <= '1'; i2c_data_wr <= x"7e";
					WHEN 421 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 422 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 423 =>i2c_ena <= '1'; i2c_data_wr <= x"0a";
					WHEN 424 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 425 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 426 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 427 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 428 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 429 =>i2c_ena <= '1'; i2c_data_wr <= x"0b";
					WHEN 430 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 431 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 432 =>i2c_ena <= '1'; i2c_data_wr <= x"01";
					WHEN 433 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 434 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 435 =>i2c_ena <= '1'; i2c_data_wr <= x"0c";
					WHEN 436 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 437 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 438 =>i2c_ena <= '1'; i2c_data_wr <= x"0f";
					WHEN 439 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 440 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 441 =>i2c_ena <= '1'; i2c_data_wr <= x"0d";
					WHEN 442 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 443 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 444 =>i2c_ena <= '1'; i2c_data_wr <= x"20";
					WHEN 445 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 446 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 447 =>i2c_ena <= '1'; i2c_data_wr <= x"09";
					WHEN 448 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 449 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 450 =>i2c_ena <= '1'; i2c_data_wr <= x"80";
					WHEN 451 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 452 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 453 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 454 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 455 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 456 =>i2c_ena <= '1'; i2c_data_wr <= x"c0";
					WHEN 457 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 458 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 459 =>i2c_ena <= '1'; i2c_data_wr <= x"03";
					WHEN 460 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 461 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 462 =>i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 463 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 464 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 465 =>i2c_ena <= '1'; i2c_data_wr <= x"05";
					WHEN 466 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 467 => i2c_ena <= '1'; i2c_data_wr <= x"c8";
					WHEN 468 =>i2c_ena <= '1'; i2c_data_wr <= x"30";
					WHEN 469 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 470 => i2c_ena <= '1'; i2c_data_wr <= x"79";
					WHEN 471 =>i2c_ena <= '1'; i2c_data_wr <= x"26";
					WHEN 472 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 473 => i2c_ena <= '1'; i2c_data_wr <= x"12";
					WHEN 474 =>i2c_ena <= '1'; i2c_data_wr <= x"04";
					WHEN 475 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 476 => i2c_ena <= '1'; i2c_data_wr <= x"8C";
					WHEN 477 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 478 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 479 => i2c_ena <= '1'; i2c_data_wr <= x"04";
					WHEN 480 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 481 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 482 => i2c_ena <= '1'; i2c_data_wr <= x"40";
					WHEN 483 =>i2c_ena <= '1'; i2c_data_wr <= x"10";
					WHEN 484 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 485 => i2c_ena <= '1'; i2c_data_wr <= x"14";
					WHEN 486 =>i2c_ena <= '1'; i2c_data_wr <= x"38";
					WHEN 487 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 488 => i2c_ena <= '1'; i2c_data_wr <= x"4F";
					WHEN 489 =>i2c_ena <= '1'; i2c_data_wr <= x"B3";
					WHEN 490 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 491 => i2c_ena <= '1'; i2c_data_wr <= x"50";
					WHEN 492 =>i2c_ena <= '1'; i2c_data_wr <= x"B3";
					WHEN 493 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 494 => i2c_ena <= '1'; i2c_data_wr <= x"51";
					WHEN 495 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 496 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 497 => i2c_ena <= '1'; i2c_data_wr <= x"52";
					WHEN 498 =>i2c_ena <= '1'; i2c_data_wr <= x"3D";
					WHEN 499 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 500 => i2c_ena <= '1'; i2c_data_wr <= x"53";
					WHEN 501 =>i2c_ena <= '1'; i2c_data_wr <= x"A7";
					WHEN 502 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 503 => i2c_ena <= '1'; i2c_data_wr <= x"54";
					WHEN 504 =>i2c_ena <= '1'; i2c_data_wr <= x"E4";
					WHEN 505 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 506 => i2c_ena <= '1'; i2c_data_wr <= x"3D";
					WHEN 507 =>i2c_ena <= '1'; i2c_data_wr <= x"C0";
                    WHEN 508 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 509 => i2c_ena <= '1'; i2c_data_wr <= x"13";
					WHEN 510 =>i2c_ena <= '1'; i2c_data_wr <= x"00";
					WHEN 511 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN 512 => i2c_ena <= '1'; i2c_data_wr <= x"11";
					WHEN 513 =>i2c_ena <= '1'; i2c_data_wr <= x"02";
					WHEN 514 => i2c_ena <= '0'; delay_ctr <= delay_ctr+1;
						if delay_ctr = 250_000 then
							busy_cnt <= busy_cnt+1; delay_ctr<=0;
						end if;
					WHEN OTHERS => i2c_ena <= '0';
				END CASE;
            else
                i2c_ena <='0';
                busy_cnt <= 0;
            end if;
        end if;
    end process;
end Behavioral;
