-- Quartus Prime VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mixer is

	generic
	(
		DATA_WIDTH : natural := 16
	);

	port
	(
		clk		 	 	  		: in std_logic;
		reset_n	 		  		: in std_logic;
		-- Inputs
		Audio_Mic_Left   		: in  std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Valid_Mic_Left   		: in std_logic;
		Ready_Mic_Left		   : out  std_logic;
		
				-- Inputs
		Audio_Mic_Right  		: in  std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Valid_Mic_Right  		: in std_logic;
		Ready_Mic_Right  		: out  std_logic;
		
		Audio_SD_Left			: in  std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Write_SD_Left	  		: in std_logic;
		WaitRequest_SD_Left  : out  std_logic;
		
				
		Audio_SD_Right	      : in  std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Write_SD_Right		   : in std_logic;
		WaitRequest_SD_Right : out  std_logic;
		-- Outputs
		Audio_Mix_Left   	   : out std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Valid_Mix_Left    	: out  std_logic;
		Ready_Mix_Left   	   : in  std_logic;
		
		-- Outputs
		Audio_Mix_Right   	: out std_logic_vector((DATA_WIDTH - 1) DOWNTO 0);
		Valid_Mix_Right   	: out  std_logic;
		Ready_Mix_Right   	: in  std_logic;		
		
		-- AS_Signals
		AS_Add 		  	   	: in std_logic;
		AS_Wr				   	: in std_logic;
		AS_WrData	 	   	: in std_logic_vector(31 DOWNTO 0);
		AS_Rd						: in std_logic;
		AS_RdData				: out std_logic_vector(31 DOWNTO 0)

	);

end entity;

architecture rtl of Mixer is

	-- Mixer state machine definition
	type state_mixer is (Waiting, Weight_Data, Mix_Data);
	signal Mixer_state : state_mixer;
	-- Declare registers for intermediate values
	signal SD_reg_Left 		: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal Mic_reg_Left		: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal SD_reg_Right 		: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal Mic_reg_Right		: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal Left_Signal		: signed(DATA_WIDTH + 9  downto 0);
	signal Right_Signal		: signed(DATA_WIDTH + 9 downto 0);

	-- FIFO signals
	signal empty 				: std_logic;
	signal empty_SD_Left 	: std_logic;
	signal empty_Mic_Left 	: std_logic;
	signal empty_SD_Right 	: std_logic;
	signal empty_Mic_Right 	: std_logic;
	signal full_SD_Left	 	: std_logic;
	signal full_Mic_Left 	: std_logic;
	signal full_SD_Right	 	: std_logic;
	signal full_Mic_Right 	: std_logic;
	signal rdreq_Left			: std_logic;
	signal rdreq_Right		: std_logic;
	
		-- AS signals
	signal weight				: std_logic_vector(4 DOWNTO 0);
	signal Volume		      : std_logic_vector(4 DOWNTO 0);


component FIFO_Mixer
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1)  DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1)  DOWNTO 0)
	);
	
END component;


begin
	-- Slave registers programming
AvalonSlaveWr: process(clk, reset_n)
	begin
	if reset_n = '0' then
		weight  <= "00101";
		Volume  <= "00101";
	elsif rising_edge(clk) then
		if AS_Wr = '1' then
			case AS_Add is
				when '0' =>	    weight     <= AS_WrData(4 DOWNTO 0);
				when '1' => 	 Volume	 	<= AS_WrData(4 DOWNTO 0);
				when others => null;
			end case;
		end if;
	end if;
end process AvalonSlaveWr;

-- Slave Rd Access
AvalonSlaveRd: process(clk, reset_n)
	begin
	if reset_n = '0' then
		 AS_RdData  <= (others =>'0');
	elsif rising_edge(clk) then
		if AS_Rd = '1' then
			case AS_Add is
				when '0' => AS_RdData(4 DOWNTO 0) <= weight;
				when '1' => AS_RdData(4 DOWNTO 0) <= Volume;
				when others => null;
			end case;
		end if;
	end if;
	end process AvalonSlaveRd;

FIFO_Mixer_SD_Right: FIFO_Mixer 
	port map (
		clock		=>    clk,
		data		=>	 	Audio_SD_Right,
		rdreq		=>		rdreq_Right,
		wrreq		=>		Write_SD_Right,
		q			=>		SD_reg_Right,
		empty		=>		empty_SD_Right,
		full		=>	   full_SD_Right
		);	
		
FIFO_Mixer_SD_Left: FIFO_Mixer 
	port map (
		clock		=>    clk,
		data		=>	 	Audio_SD_Right,
		rdreq		=>		rdreq_Left,
		wrreq		=>		Write_SD_Left,
		q			=>		SD_reg_Left,
		empty		=>		empty_SD_Left,
		full		=>	   full_SD_Left
		);	

FIFO_Mixer_Mic_Right: FIFO_Mixer 
	port map (
		clock		=>    clk,
		data		=>	 	Audio_Mic_Right,
		rdreq		=>		rdreq_Right,
		wrreq		=>		Valid_Mic_Right,
		q			=>		Mic_reg_Right,
		empty		=>		empty_Mic_Right,
		full		=>	   full_Mic_Right
		);	
FIFO_Mixer_Mic_Left: FIFO_Mixer 
	port map (
		clock		=>    clk,
		data		=>	 	Audio_Mic_Left,
		rdreq		=>		rdreq_Left,
		wrreq		=>		Valid_Mic_Left,
		q			=>		Mic_reg_Left,
		empty		=>		empty_Mic_Left,
		full		=>	   full_Mic_Left
		);	
		
state_machine :	process (reset_n,clk)
	begin
		if reset_n = '0' then
		   Valid_Mix_Left <= '0';
			Valid_Mix_Right <= '0';		
			Mixer_state <= Waiting;
		elsif (rising_edge(clk)) then
			
			case Mixer_state is
					
				when Waiting =>
					Valid_Mix_Left <= '0';
					Valid_Mix_Right <= '0';
					if (empty = '0') and (Ready_Mix_Right = '1' and Ready_Mix_Left = '1') then
						Mixer_State <= Weight_Data;
						-- Read FIFOs
						rdreq_Left  <= '1';
						rdreq_Right <= '1';
					end if;

					when Weight_Data =>
					-- Weight signals
					Left_Signal  <= signed(Volume)*((10 - signed(weight))*signed(Mic_reg_Left)  + signed(weight)*signed(SD_reg_Left))/160;
					Right_Signal <= signed(Volume)*((10 - signed(weight))*signed(Mic_reg_Right) + signed(weight)*signed(SD_reg_Right))/160;
										
					-- Stop reading FIFOs
					rdreq_Right <= '0';
					rdreq_Left <= '0';
					-- Go to mixer
					Mixer_State <= Mix_Data;

				when Mix_Data =>
					Audio_Mix_Left <= std_logic_vector(Left_Signal(DATA_WIDTH-1 DOWNTO 0));
					Audio_Mix_Right <= std_logic_vector(Right_Signal(DATA_WIDTH-1 DOWNTO 0));
					Valid_Mix_Left <= '1';
					Valid_Mix_Right <= '1';
					Mixer_State <= Waiting;

				when others => null;
				
			end case;			
		end if;
	end process;

	WaitRequest_SD_Right <= full_SD_Right;
	WaitRequest_SD_Left  <= full_SD_Left;
	Ready_Mic_Right		<= not(full_Mic_Right);
	Ready_Mic_Left 		<= not(full_Mic_Left);
	
	empty <= empty_Mic_Right and empty_Mic_Left and empty_SD_Left and empty_SD_Right;

end rtl;

