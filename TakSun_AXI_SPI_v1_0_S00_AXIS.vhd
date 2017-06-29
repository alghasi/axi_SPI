library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TakSun_AXI_SPI_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here
        GN_N : positive := 32;                                             -- 32bit serial word length is default
        GN_CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
        GN_CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
        GN_PREFETCH : positive := 2;                                       -- prefetch lookahead cycles
        GN_SPI_2X_CLK_DIV : positive := 5;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
        CSPI_SCK : out std_logic;
        CSPI_SS : out std_logic;
        CSPI_SDO : out std_logic;
        CSPI_SDI : in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end TakSun_AXI_SPI_v1_0_S00_AXIS;

architecture arch_imp of TakSun_AXI_SPI_v1_0_S00_AXIS is
	-- function called clogb2 that returns an integer which has the 
	-- value of the ceiling of the log base 2.
	function clogb2 (bit_depth : integer) return integer is 
	variable depth  : integer := bit_depth;
	  begin
	    if (depth = 0) then
	      return(0);
	    else
	      for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	        if(depth <= 1) then 
	          return(clogb2);      
	        else
	          depth := depth / 2;
	        end if;
	      end loop;
	    end if;
	end;    

component spi_master is
    Generic (   
    N : positive := 32;                                             -- 32bit serial word length is default
    CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
    CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
    PREFETCH : positive := 2;                                       -- prefetch lookahead cycles
    SPI_2X_CLK_DIV : positive := 5);                                -- for a 100MHz sclk_i, yields a 10MHz SCK
Port (  
    sclk_i : in std_logic := 'X';                                   -- high-speed serial interface system clock
    pclk_i : in std_logic := 'X';                                   -- high-speed parallel interface system clock
    rst_i : in std_logic := 'X';                                    -- reset core
    ---- serial interface ----
    spi_ssel_o : out std_logic;                                     -- spi bus slave select line
    spi_sck_o : out std_logic;                                      -- spi bus sck
    spi_mosi_o : out std_logic;                                     -- spi bus mosi output
    spi_miso_i : in std_logic := 'X';                               -- spi bus spi_miso_i input
    ---- parallel interface ----
    di_req_o : out std_logic;                                       -- preload lookahead data request line
    di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel data in (clocked on rising spi_clk after last bit)
    wren_i : in std_logic := 'X';                                   -- user data write enable, starts transmission when interface is idle
    wr_ack_o : out std_logic;                                       -- write acknowledge
    do_valid_o : out std_logic;                                     -- do_o data valid signal, valid during one spi_clk rising edge.
    do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked on rising spi_clk after last bit)
    --- debug ports: can be removed or left unconnected for the application circuit ---
    sck_ena_o : out std_logic;                                      -- debug: internal sck enable signal
    sck_ena_ce_o : out std_logic;                                   -- debug: internal sck clock enable signal
    do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
    wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
    rx_bit_reg_o : out std_logic;                                   -- debug: internal rx bit
    state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
    core_clk_o : out std_logic;
    core_n_clk_o : out std_logic;
    core_ce_o : out std_logic;
    core_n_ce_o : out std_logic;
    sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
);                      
end component spi_master;
signal rst_blk : std_logic;
begin
spi_master_inst: spi_master
generic map
        (
        N => GN_N,                                             -- 32bit serial word length is default
        CPOL =>  GN_CPOL,                                       -- SPI mode selection (mode 0 default)
        CPHA =>  GN_CPHA,                                       -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH =>  GN_PREFETCH,                                     -- prefetch lookahead cycles
        SPI_2X_CLK_DIV =>  GN_SPI_2X_CLK_DIV)
port map(
    sclk_i   => S_AXIS_ACLK,                                 -- high-speed serial interface system clock
    pclk_i   => S_AXIS_ACLK,                               -- high-speed parallel interface system clock
    rst_i    => S_AXIS_ARESETN,                              -- reset core
---- serial interface ----
    spi_ssel_o =>CSPI_SS,                                   -- spi bus slave select line
    spi_sck_o  =>CSPI_SCK,                                  -- spi bus sck
    spi_mosi_o =>CSPI_SDO,                                 -- spi bus mosi output
    spi_miso_i =>CSPI_SDI,                             -- spi bus spi_miso_i input
---- parallel interface ----
    di_req_o =>S_AXIS_TREADY,                                     -- preload lookahead data request line
    di_i=>S_AXIS_TDATA,   -- parallel data in (clocked on rising spi_clk after last bit)
    wren_i =>S_AXIS_TVALID                                 -- user data write enable, starts transmission when interface is idle
  --  wr_ack_o                                     -- write acknowledge
   -- do_valid_o                                     -- do_o data valid signal, valid during one spi_clk rising edge.
    --do_o                    -- parallel output (clocked on rising spi_clk after last bit)
--- debug ports: can be removed or left unconnected for the application circuit ---
--    sck_ena_o                                   -- debug: internal sck enable signal
--    sck_ena_ce_o                                 -- debug: internal sck clock enable signal
--    do_transfer_o                                 -- debug: internal transfer driver
--    wren_o                                       -- debug: internal state of the wren_i pulse stretcher
--    rx_bit_reg_o                                   -- debug: internal rx bit
--    state_dbg_o               -- debug: internal state register
--    core_clk_o 
--    core_n_clk_o 
--    core_ce_o 
--    core_n_ce_o 
--    sh_reg_dbg_o           -- debug: internal shift register

);
        




	-- I/O Connections assignments

--	S_AXIS_TREADY	<= axis_tready;
	-- Control state machine implementation
--	process(S_AXIS_ACLK)
--	begin
--	  if (rising_edge (S_AXIS_ACLK)) then
--	    if(S_AXIS_ARESETN = '0') then
--	      -- Synchronous reset (active low)
	      
--	    else
--	          if (S_AXIS_TVALID = '1')then
--	         --   mst_exec_state <= WRITE_FIFO;
--	          else
--	         --   mst_exec_state <= IDLE;
--	          end if;
	      
--	    end if;  
--	  end if;
--	end process;
--	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
--	axis_tready <= '1' when ((mst_exec_state = WRITE_FIFO) and (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) else '0';

	-- Add user logic here

	-- User logic ends

end arch_imp;
