library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity leddec16 is
 Port (dig : in STD_LOGIC_VECTOR (1 downto 0); -- which digit to currently display
data : in STD_LOGIC_VECTOR (15 downto 0); -- 16-bit (4-digit) data
anode: out STD_LOGIC_VECTOR (3 downto 0); -- which anode to turn on
 seg : out STD_LOGIC_VECTOR (6 downto 0)); -- segment code for current digit
end leddec16;
architecture Behavioral of leddec16 is
signal data4: STD_LOGIC_VECTOR (3 downto 0); -- binary value of current digit
begin
-- Select digit data to be displayed in this mpx period
data4 <= data(3 downto 0) when dig="00" else --digit 0
data(7 downto 4) when dig="01" else --digit 1
data(11 downto 8) when dig="10" else --digit 2
data(15 downto 12); --digit 3
-- Turn on segments corresponding to 4-bit data word
seg <= "0000001" when data4="0000" else --0
"1001111" when data4="0001" else --1
"0010010" when data4="0010" else --2
"0000110" when data4="0011" else --3
"1001100" when data4="0100" else --4
"0100100" when data4="0101" else --5
"0100000" when data4="0110" else --6
"0001111" when data4="0111" else --7
"0000000" when data4="1000" else --8
"0000100" when data4="1001" else --9
"0001000" when data4="1010" else --A
"1100000" when data4="1011" else --B
"0110001" when data4="1100" else --C
"1000010" when data4="1101" else --D
"0110000" when data4="1110" else --E
"0111000" when data4="1111" else --F
"1111111";
-- Turn on anode of 7-segment display addressed by 2-bit digit selector dig
anode <= "1110" when dig="00" and data /= x"0000" else -- digit 0
"1101" when dig="01" and data(15 downto 4) /= x"000" else -- digit 1
"1011" when dig="10" and data(15 downto 4) /=x"00" else -- digit 2
"0111" when dig="11" and data(15 downto 4) /=x"0" else -- digit 3
"1111";
end Behavioral; 