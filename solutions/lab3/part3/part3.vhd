-- User-Encoded State Machine
library ieee;
use ieee.std_logic_1164.all;

entity part1 is
	port(clk	  : in std_logic;
		reset	  : in std_logic;
		D0, D1	  : in std_logic;
		Z0, Z1	  : out std_logic;
		pres, nextstate : out std_logic_vector(0 to 2) );

end part1;

architecture Structure of part1 is
	-- Build an enumerated type for the state machine
	type count_state is (A, B, C, D, E);

	-- Registers to hold the current state and the next state
	signal present_state, next_state	: count_state;
	-- Attribute to declare a specific encoding for the states
	attribute syn_encoding	 : string;
	attribute syn_encoding of count_state : type is "compact";

begin
	-- Move to the next state
	process(clk, reset)
	begin

		if reset = '1' then
			present_state <= A;
		elsif (rising_edge(clk)) then
			present_state <= next_state;
		end if;
	end process;

	-- Determine what the next state will be, and set the output bits
	process (present_state, D0, D1)
	variable input : std_logic_vector(0 to 1);
	begin
		input := D1 & D0;
		case present_state is
			when A =>
				if (D0 = '0') then
					next_state <= A;
					Z0 <= '0';
					Z1 <= '0';
				elsif (D0 = '1') then
					next_state <= D;
					Z0 <= '1';
					Z1 <= '0';
				end if;
			when B =>
				if (input = "11") then
					next_state <= A;
					Z0 <= '1';
					Z1 <= '0';
				elsif (input = "01") then
					next_state <= E;
					Z0 <= '0';
					Z1 <= '0';
				elsif (input = "10") then
					next_state <= D;
					Z0 <= '1';
					Z1 <= '1';
				else
					next_state <= C;
					Z0 <= '0';
					Z1 <= '1';
				end if;
			when C =>
				if (D1 = '1') then
					next_state <= B;
					Z0 <= '0';
					Z1 <= '1';
				elsif (D1 = '0') then
					next_state <= E;
					Z0 <= '1';
					Z1 <= '0';
				end if;
			when D =>
				if (input = "01") then
					next_state <= A;
					Z0 <= '1';
					Z1 <= '0';
				elsif (input = "01") then
					next_state <= E;
					Z0 <= '0';
					Z1 <= '1';
				end if;
			when E =>
				if (input = "00") then
					next_state <= E;
					Z0 <= '1';
					Z1 <= '0';
				elsif (input = "10") then	
					next_state <= B;
					Z0 <= '1';
					Z1 <= '1';
				elsif (input = "11") then
					next_state <= D;
					Z0 <= '0';
					Z1 <= '0';
				end if;
		end case;
	end process;
	
		pres <= "000" when present_state = A else
             		"001" when present_state = B else
			"010" when present_state = C else
             		"011" when present_state = D else
             		"100";
             		
		nextstate <= "000" when present_state = A else
        		"001" when present_state = B else
			"010" when present_state = C else
             		"011" when present_state = D else
             		"100";


end Structure;
