library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tetris is
    Port (clk_50MHz : IN STD_LOGIC; -- system clock
		VGA_red : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- VGA outputs
		VGA_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		VGA_blue : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		VGA_hsync : OUT STD_LOGIC;
		VGA_vsync : OUT STD_LOGIC;
		ADC_CS : OUT STD_LOGIC; -- ADC signals
		ADC_SCLK : OUT STD_LOGIC;
		ADC_SDATA1 : IN STD_LOGIC;
		ADC_SDATA2 : IN STD_LOGIC;
		dig : in STD_LOGIC_VECTOR (1 downto 0); -- which digit to currently display
        data : in STD_LOGIC_VECTOR (15 downto 0); -- 16-bit (4-digit) data
        anode: out STD_LOGIC_VECTOR (3 downto 0); -- which anode to turn on
        seg : out STD_LOGIC_VECTOR (6 downto 0); -- segment code for current digit
	    btn0 : IN STD_LOGIC; -- button to initiate serve
	    btn1 : IN STD_LOGIC; -- button to move right
	    btn2 : IN STD_LOGIC; -- button to move left
	    btn3 : IN STD_LOGIC --  button to move down
        );
end tetris;

architecture Behavioral of tetris is

    SIGNAL ck_25 : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
	-- internal signals to connect modules
	SIGNAL S_red, S_green, S_blue : STD_LOGIC;
	SIGNAL S_vsync : STD_LOGIC;
	SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL batpos : STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL serial_clk, sample_clk : STD_LOGIC;
	SIGNAL adout : STD_LOGIC_VECTOR (11 DOWNTO 0);
	SIGNAL count : STD_LOGIC_VECTOR (9 DOWNTO 0); -- counter to generate ADC clocks
	COMPONENT block_move IS
		PORT (
			v_sync : IN STD_LOGIC;
			pixel_row : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			pixel_col : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			serve : IN STD_LOGIC;
			left : IN STD_LOGIC;
			right : IN STD_LOGIC;
			down : IN STD_LOGIC;
			red : OUT STD_LOGIC;
			green : OUT STD_LOGIC;
			blue : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT vga_sync IS
		PORT (
			clock_25MHz : IN STD_LOGIC;
			red : IN STD_LOGIC;
			green : IN STD_LOGIC;
			blue : IN STD_LOGIC;
			red_out : OUT STD_LOGIC;
			green_out : OUT STD_LOGIC;
			blue_out : OUT STD_LOGIC;
			hsync : OUT STD_LOGIC;
			vsync : OUT STD_LOGIC;
			pixel_row : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			pixel_col : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END COMPONENT;
	
	
begin

	-- Process to generate clock signals
	ckp : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_50MHz);
		ck_25 <= NOT ck_25; -- 25MHz clock for VGA modules
	END PROCESS;
	serial_clk <= NOT count(4); -- 1.5 MHz serial clock for ADC
	ADC_SCLK <= serial_clk;
	sample_clk <= count(9); -- sampling clock is low for 16 SCLKs
	ADC_CS <= sample_clk;

	-- set least significant bits of VGA video to '0'
	VGA_red(1 DOWNTO 0) <= "00";
	VGA_green(1 DOWNTO 0) <= "00";
	VGA_blue(0) <= '0';
		add_block : block_move
		PORT MAP(
			v_sync => S_vsync, 
			pixel_row => S_pixel_row, 
			pixel_col => S_pixel_col, 
 
			serve => btn0,
			left => btn2,
			right => btn1, 
			down => btn3, 			
			red => S_red, 
			green => S_green, 
			blue => S_blue
		);
		vga_driver : vga_sync
		PORT MAP(--instantiate vga_sync component
			clock_25MHz => ck_25, 
			red => S_red, 
			green => S_green, 
			blue => S_blue, 
			red_out => VGA_red(2), 
			green_out => VGA_green(2), 
			blue_out => VGA_blue(1), 
			pixel_row => S_pixel_row, 
			pixel_col => S_pixel_col, 
			hsync => VGA_hsync, 
			vsync => S_vsync
		);
		VGA_vsync <= S_vsync; --connect output vsync

end Behavioral;
