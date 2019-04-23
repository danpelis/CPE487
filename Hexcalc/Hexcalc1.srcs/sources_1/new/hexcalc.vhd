library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity hexcalc is
Port ( 
bt_sub: in STD_LOGIC; 
clk_50MHz : in STD_LOGIC; -- system clock (50 MHz)
SEG7_anode : out STD_LOGIC_VECTOR (3 downto 0); -- anodes of four 7-seg displays
SEG7_seg : out STD_LOGIC_VECTOR (6 downto 0); -- common segments of 7-seg displays
bt_clr: in STD_LOGIC; -- calculator "clear" button
bt_plus: in STD_LOGIC; -- calculator "+" button
bt_eq: in STD_LOGIC; -- calculator "-" button
KB_col: out STD_LOGIC_VECTOR (4 downto 1); -- keypad column pins
KB_row: in STD_LOGIC_VECTOR (4 downto 1 )); -- keypad row pins
end hexcalc;
architecture Behavioral of hexcalc is
component keypad is
 Port ( samp_ck : in STD_LOGIC;
 col : out STD_LOGIC_VECTOR (4 downto 1);
 row : in STD_LOGIC_VECTOR (4 downto 1);
 value : out STD_LOGIC_VECTOR (3 downto 0);
 hit : out STD_LOGIC);
end component;
component leddec16 is
 Port ( dig : in STD_LOGIC_VECTOR (1 downto 0);
 data : in STD_LOGIC_VECTOR (15 downto 0);
 anode: out STD_LOGIC_VECTOR (3 downto 0);
 seg : out STD_LOGIC_VECTOR (6 downto 0));
end component;
signal cnt: std_logic_vector(20 downto 0); -- counter to generate timing signals
signal kp_clk, kp_hit, sm_clk: std_logic;
signal kp_value: std_logic_vector (3 downto 0);
signal nx_acc, acc: std_logic_vector (15 downto 0); -- accumulated sum

signal nx_operand, operand: std_logic_vector (15 downto 0); -- operand
signal display: std_logic_vector (15 downto 0); -- value to be displayed
signal led_mpx: STD_LOGIC_VECTOR (1 downto 0); -- 7-seg multiplexing clock
signal Plus_or_Sub: STD_LOGIC;
type state is (ENTER_ACC, ACC_RELEASE, START_OP, OP_RELEASE,
ENTER_OP, SHOW_RESULT); -- state machine states
signal pr_state, nx_state: state; -- present and next states
begin
ck_proc: process(clk_50MHz)
begin
if rising_edge( clk_50MHz) then -- on rising edge of clock
cnt <= cnt+1; -- increment counter
end if;
end process;
kp_clk <= cnt(15); -- keypad interrogation clock
sm_clk <= cnt(20); -- state machine clock
led_mpx <= cnt(18 downto 17); -- 7-seg multiplexing clock
kp1: keypad port map (samp_ck => kp_clk, col => KB_col,
row => KB_row, value => kp_value, hit => kp_hit);
led1: leddec16 port map (dig => led_mpx, data => display,
anode => SEG7_anode, seg => SEG7_seg);
sm_ck_pr: process (bt_clr, sm_clk) -- state machine clock process
begin
if bt_clr = '1' then -- reset to known state
acc <= X"0000";
operand <= X"0000";
pr_state <= ENTER_ACC;
elsif rising_edge (sm_clk) then -- on rising clock edge
pr_state <= nx_state; -- update present state
acc <= nx_acc; -- update accumulator
operand <= nx_operand; -- update operand
end if;
end process;
-- state maching combinatorial process
-- determines output of state machine and next state
sm_comb_pr: process (kp_hit, kp_value, bt_plus, bt_sub, bt_eq, acc, operand, pr_state)
begin
nx_acc <= acc; -- default values of nx_acc, nx_operand & display
nx_operand <= operand;
display <= acc;
case pr_state is -- depending on present state...
when ENTER_ACC => -- waiting for next digit in 1st operand entry
if kp_hit = '1' then
nx_acc <= acc(11 downto 0) & kp_value;

nx_state <= ACC_RELEASE;
elsif bt_plus = '1' then
nx_state <= START_OP;
Plus_or_Sub <= '1';
elsif bt_sub = '1' then
nx_state <= START_OP;
Plus_or_Sub <= '0';
else nx_state <= ENTER_ACC;
end if;
when ACC_RELEASE => -- waiting for button to be released
if kp_hit = '0' then
nx_state <= ENTER_ACC;
else nx_state <= ACC_RELEASE;
end if;
when START_OP => -- ready to start entering 2nd operand
if kp_hit = '1' then
nx_operand <= X"000" & kp_value;
nx_state <= OP_RELEASE;
display <= operand;
else nx_state <= START_OP;
end if;
when OP_RELEASE => -- waiting for button ot be released
display <= operand;
if kp_hit = '0' then
nx_state <= ENTER_OP;
else nx_state <= OP_RELEASE;
end if;
when ENTER_OP => -- waiting for next digit in 2nd operand
display <= operand;
if (bt_eq = '1' AND Plus_or_Sub = '1') then
nx_acc <= acc + operand;
nx_state <=SHOW_RESULT;
elsif (bt_eq = '1' AND Plus_or_Sub = '0') then
nx_acc <= acc - operand;
nx_state <=SHOW_RESULT;
elsif kp_hit = '1' then
nx_operand <= operand(11 downto 0) & kp_value;
nx_state <= OP_RELEASE;
else nx_state <= ENTER_OP;
end if;
when SHOW_RESULT => -- display result of addition
if kp_hit = '1' then
nx_acc <= X"000" & kp_value;
nx_state <= ACC_RELEASE;
else nx_state <= SHOW_RESULT;
end if;
end case;
end process;
end Behavioral;