library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_move is
    Port (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        left : IN STD_LOGIC;
        right : IN STD_LOGIC;
        down : IN STD_LOGIC;
        serve : IN STD_LOGIC; -- initiates serve
        red: OUT STD_LOGIC;
        green: OUT STD_LOGIC;
        blue: OUT STD_LOGIC
        );
end block_move;

architecture Behavioral of block_move is
    -- Currently Using a block to test movement
    CONSTANT bsize : INTEGER := 8;
    
    -- Distance the block moves each frame
    CONSTANT b_speed: STD_LOGIC_VECTOR (9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (1, 10);
    SIGNAL b_on : STD_LOGIC; -- Indicates whether block is at current pixel position
    SIGNAL start : STD_LOGIC := '0';
    
    -- Current block positoin - Set to the top of the screen
    SIGNAL b_x : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 10);
    SIGNAL b_y : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 10);
    
    -- Current block motion
    SIGNAL b_x_motion, b_y_motion : STD_LOGIC_VECTOR(9 DOWNTO 0) := b_speed;

begin
    red <= b_on;
    green <= Not b_on;
    blue <= not b_on;
    
    blockdraw: PROCESS (b_x, b_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : std_logic_vector (9 downto 0);
    BEGIN    
        if pixel_col <= b_x then
            vx := b_x - pixel_col;
        else
            vx := pixel_col - b_x;
        end if;
        
        if pixel_row <= b_y then
            vy := b_y - pixel_row;
        else
            vy := pixel_row - b_y;
        end if;
        
        if vx >= 150 and vx <= 250 and vy >= 100 and vy <= 150 then -- test if radial distance is < bsize
            b_on <= start;
        else
            b_on <= '0';
        end if;
        
    END PROCESS;
    
    blockfall: PROCESS
VARIABLE temp : STD_LOGIC_VECTOR (10 DOWNTO 0);
            BEGIN
                WAIT UNTIL rising_edge(v_sync);
                IF left = '1' AND start = '0' THEN -- test for new serve
                    start <= '1';
                   -- b_y_motion <= (NOT b_speed) + 1; -- set vspeed to (- b_speed) pixels
                --ELSIF b_y <= bsize THEN -- bounce off top wall
                    --b_y_motion <= b_speed; -- set vspeed to (+ b_speed) pixels
                --ELSIF b_y + bsize >= 480 THEN -- if b meets bottom wall
                  --  b_y_motion <= (NOT b_speed) + 1; -- set vspeed to (- b_speed) pixels
                    --start <= '0'; -- and make b disappear
                END IF;
                if serve = '1' then
                    b_y_motion <= b_speed + 1;
                end if; 
                END PROCESS;

end Behavioral;
