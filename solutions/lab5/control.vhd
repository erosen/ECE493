-- User-Encoded State Machine
library ieee;
use ieee.std_logic_1164.all;

entity control is
        port(   CLOCK_50 : in std_LOGIC;
					 KEY  : in std_logic_vector(3 downto 0);
					 SW : in std_LOGIC_VECTOR(17 downto 0);
                LEDR          : out std_logic_vector(17 downto 0);
                LEDG : out std_logic_vector(8 downto 0);
                HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(0 to 6);
					 SRAM_ADDR : OUT STD_LOGIC_VECTOR (19 downto 0);
					SRAM_DQ : INOUT STD_LOGIC_VECTOR (15 downto 0);
					SRAM_OE_N, 
					SRAM_WE_N, 
					SRAM_CE_N, 
					SRAM_LB_N, 
					SRAM_UB_N : BUFFER STD_LOGIC);
end control;

architecture rtl of control is
       
		 COMPONENT hexdisplay
                PORT (C        : IN        STD_LOGIC_VECTOR(4 DOWNTO 0);
                      H        : OUT        STD_LOGIC_VECTOR(0 TO 6));
        END COMPONENT;
        
		   COMPONENT ALU
					port(A, B : IN STD_LOGIC_VECTOR(7 downto 0);
						OPCODE : IN STD_LOGIC_VECTOR(2 downto 0);
						ALU_out : OUT STD_LOGIC_VECTOR(7 downto 0));
			END COMPONENT;
			
			-- altera sram IP initiation
		COMPONENT altera_UP_sram
			PORT (
				-- Inputs
				clk				:IN		STD_LOGIC;
				reset				:IN		STD_LOGIC;
				address			:IN		STD_LOGIC_VECTOR(19 DOWNTO  0);
				byteenable		:IN		STD_LOGIC_VECTOR( 1 DOWNTO  0);	
				read				:IN		STD_LOGIC;
				write				:IN		STD_LOGIC;
				writedata		:IN		STD_LOGIC_VECTOR(15 DOWNTO  0);	

				-- Bi-Directional
				SRAM_DQ			:INOUT	STD_LOGIC_VECTOR(15 DOWNTO  0);	-- SRAM Data bus 16 Bits

				-- Outputs
				readdata			:BUFFER	STD_LOGIC_VECTOR(15 DOWNTO  0);	
				readdatavalid	:BUFFER	STD_LOGIC;

				SRAM_ADDR		:BUFFER	STD_LOGIC_VECTOR(19 DOWNTO  0);	-- SRAM Address bus 18 Bits

				SRAM_LB_N		:BUFFER	STD_LOGIC;								-- SRAM Low-byte Data Mask 
				SRAM_UB_N		:BUFFER	STD_LOGIC;								-- SRAM High-byte Data Mask 
				SRAM_CE_N		:BUFFER	STD_LOGIC;								-- SRAM Chip chipselect
				SRAM_OE_N		:BUFFER	STD_LOGIC;								-- SRAM Output chipselect
				SRAM_WE_N		:BUFFER	STD_LOGIC								-- SRAM Write chipselect

			);
		END COMPONENT;
			
        -- Build an enumerated type for the state machine
        type proc_state is (FETCH, DECODE, EXECUTE, MEMORY_WRITE);
        
        -- Registers to hold the current state and the next state
        signal present_state, next_state           : proc_state;
        -- Attribute to declare a specific encoding for the states
        attribute syn_encoding                                  : string;
        attribute syn_encoding of proc_state : type is "00 01 10 11";
        
		  
        SIGNAL Clock, reset : STD_LOGIC;
		  SIGNAL IR : STD_LOGIC_VECTOR(17 downto 0);
		  SIGNAL OPCODE: STD_LOGIC_VECTOR(2 downto 0);
		  SIGNAL DADDR : STD_LOGIC_VECTOR(4 downto 0);
		  SIGNAL ALU_result, ALU_out : STD_LOGIC_VECTOR(7 downto 0);
		  SIGNAL ALUvalA, ALUvalB : STD_LOGIC_VECTOR(7 downto 0); 
		  SIGNAL control_read, control_write : STD_lOGIC := '0';
		  
		  SIGNAL control_address : STD_LOGIC_VECTOR(19 downto 0);
		  SIGNAL byteenable : STD_LOGIC_VECTOR(1 downto 0) := "01"; -- turn on low bits
	     SIGNAL readdata : STD_LOGIC_VECTOR (15 downto 0);
		  SIGNAL control_data : STD_LOGIC_VECTOR (15 downto 0) := (OTHERS => '0');
		  SIGNAL readdatavalid : STD_LOGIC;
		  
		  type addresses is array (0 to 1) of STD_LOGIC_VECTOR(4 downto 0);
		  type data_values is array (0 to 1) of STD_LOGIC_VECTOR(7 downto 0);
		  
		  SIGNAL SADDR : addresses;
		  SIGNAL SourceVal : data_values;
  
        SIGNAL displayb0, displayb1, displayb2, displayb3, displayb4,
                displayb5, displayb6, displayb7 : STD_LOGIC_VECTOR(4 downto 0);
        
begin
        
        Clock <= KEY(0);
		  reset <= KEY(1);
		 
        
        -- Move to the next state
        process(Clock)
        begin
        
                if (reset = '0') then
					 
                        present_state <= FETCH;
								
                elsif (Clock='0') then
                        
								present_state <= next_state;
                end if;
        end process;

      
        process (present_state)
        begin
                case present_state is
                       
							  when FETCH =>
									-- TAKE IN THE INSTRUCTION FROM THE SWITCHES
									IR <= SW(17 DOWNTO 0);
									
									-- SET FLASH MEMORY TO NOT USED
                           control_read <= '0';
									control_write <= '0';
									ALU_result <= (OTHERS => '0');
									control_address(19 downto 5) <= (OTHERS => '0');
									
									-- PROCEED
                           next_state <= DECODE;
										
                        when DECODE =>
                           -- BREAK DOWN IR INTO ITS COMPONENTS    
									OPCODE <= IR(17 downto 15);
									DADDR <= IR(14 downto 10);
									SADDR(0) <= IR(9 downto 5);
									SADDR(1)<= IR (4 downto 0); 
									
									
									-- TELL FLASH MEMROY WE WANT TO READ
									control_read <= '1';
									
									-- SPECIAL CASE WHERE SOURCE ADDRESS 2 IS SHIFT AMOUNT
									IF OPCODE = "111" THEN
										-- TELL THE FLASH CHIP WHICH ADRESS TO LOOKUP
										control_address(4 downto 0) <= SADDR(0);
										
										-- SET THE VALUE STORED IN THAT CELL
										SourceVal(0)(7 downto 0) <= readdata(7 downto 0) after 100ms;	
										SourceVal(1)(7 downto 0) <= "000" & SADDR(1);
										
									ELSE
										-- DO THE SAME THING AS BEFORE EXCEPT RECIEVE THE SECOND VALUE
										FOR i in 0 to 1 loop 
											control_address(4 downto 0) <= SADDR(i);
											SourceVal(i)(7 downto 0) <= readdata(7 downto 0) after 100ms;
										end loop;
									END IF;
									
									-- PROCEED
									next_state <= EXECUTE;
										  
                        when EXECUTE =>
								
									-- TURN READ OFF
									control_read <= '0';
									
									-- SET VALUE FROM FLASH CHIP TO ALU INPUTS
									ALUvalA <= SourceVal(0);
									ALUValB <= SourceVal(1);
									
									-- TAKE THE RESULT AND PUT IT IN A REGISTER
									ALU_result <= ALU_out;
									
									-- PROCEED TO MEMORY_WRITE
									next_state <= MEMORY_WRITE;
									
								when MEMORY_WRITE =>
								
									-- SET WRITE ON
									control_write <= '1';
									
									-- TAKE IN THE DESTINATION ADDRESS
									control_address(4 downto 0) <= DADDR;
									
									control_data(7 downto 0) <= ALU_result;
									-- write the value from the alu to DADDR
									next_state <= FETCH;
                end case;
        end process;
        
        display0: hexdisplay PORT MAP (displayb0, HEX0);
        display1: hexdisplay PORT MAP (displayb1, HEX1);
        display2: hexdisplay PORT MAP (displayb2, HEX2);
        display3: hexdisplay PORT MAP (displayb3, HEX3);
        display4: hexdisplay PORT MAP (displayb4, HEX4);
        display5: hexdisplay PORT MAP (displayb5, HEX5);
        display6: hexdisplay PORT MAP (displayb6, HEX6);
        display7: hexdisplay PORT MAP (displayb7, HEX7);
		  
		  MEM : altera_UP_sram PORT MAP (
							clk => CLOCK_50, -- Set the clock to the system clock
							reset	=> NOT KEY(1), -- Active high reset
							address => control_address, 
							byteenable => byteenable, -- We only want a single byte so the high bits are disabled
							read => control_read, -- flag for read
							write	=> control_write, -- flag for write
							writedata => control_data,	--the data we want to write
							SRAM_DQ => SRAM_DQ,	-- INOUT from the SRAM	
							
							readdata	=> readdata, --Data recieved from the SRAM
							readdatavalid => readdatavalid,

							SRAM_ADDR => SRAM_ADDR,
							SRAM_LB_N => SRAM_LB_N,
							SRAM_UB_N => SRAM_UB_N,
							SRAM_CE_N => SRAM_CE_N,
							SRAM_OE_N => SRAM_OE_N, 
							SRAM_WE_N => SRAM_WE_N
				);
        Arith : ALU PORT MAP (ALUvalA, ALUValB, OPCODE, ALU_out);
end rtl;

-- ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
        port(A, B : IN STD_LOGIC_VECTOR(7 downto 0);
				 OPCODE : IN STD_LOGIC_VECTOR(2 downto 0);
				 ALU_out : OUT STD_LOGIC_VECTOR(7 downto 0));
end ALU;

architecture Structure of ALU is
BEGIN

	PROCESS(OPCODE)
	BEGIN
		CASE OPCODE is
			when "000" => ALU_out <= A AND B;
			when "001" => ALU_out <= A OR B;
			when "010" => ALU_out <= A NAND B;
			when "011" => ALU_out <= A NOR B;
			when "100" => ALU_out <= A XOR B;
			when "101" => ALU_out <= STD_LOGIC_VECTOR(signed(A) + signed(B));
			when "110" => ALU_out <= STD_LOGIC_VECTOR(signed(A) - signed(B));
			when "111" => ALU_out <= STD_LOGIC_VECTOR(SHIFT_RIGHT(signed(A), to_integer(signed(B))));
			when others => ALU_out <= "00000000";
		END CASE;
	END PROCESS;
	
END STRUCTURE;

-- PROGRAM COUNTER
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
        port(increment_flag : IN STD_LOGIC;
				  OLD_COUNT : IN STD_LOGIC_VECTOR(3 downto 0);
				  CURRENT_PC : OUT STD_LOGIC_VECTOR(3 downto 0));
end PC;

architecture Structure of PC is
BEGIN

		CURRENT_PC <= STD_LOGIC_VECTOR(signed(OLD_COUNT) + 1) when increment_flag = '1' else OLD_COUNT;

END STRUCTURE;
-- 7 seg display
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hexdisplay IS
        PORT (C        : IN        STD_LOGIC_VECTOR(4 DOWNTO 0);
              H        : OUT        STD_LOGIC_VECTOR(0 TO 6));
END hexdisplay;

ARCHITECTURE Structure OF hexdisplay IS
BEGIN
        PROCESS (C)
        BEGIN
                CASE C IS
                        WHEN "00000" => H <= "0000001";
                        WHEN "00001" => H <= "1001111";
                        WHEN "00010" => H <= "0010010";  
                        WHEN "00011" => H <= "0000110";
                        WHEN "00100" => H <= "1001100"; 
                        WHEN "00101" => H <= "0100100"; 
                        WHEN "00110" => H <= "0100000"; 
                        WHEN "00111" => H <= "0001111"; 
                        WHEN "01000" => H <= "0000000"; 
                        WHEN "01001" => H <= "0000100"; 
                        WHEN "01010" => H <= "0001000"; 
                        WHEN "01011" => H <= "1100000"; 
                        WHEN "01100" => H <= "1110010"; 
                        WHEN "01101" => H <= "1000010"; 
                        WHEN "01110" => H <= "0110000"; 
                        WHEN "01111" => H <= "0111000"; 
                        WHEN "10000" => H <= "1111110";
                        WHEN "10001" => H <= "1111111";
                        WHEN OTHERS => H <= "ZZZZZZZ";
                END CASE;
        END PROCESS;
END Structure;