library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TakSun_AXI_SPI_v1_0 is
	generic (
		-- Users to add parameters here
        GN_TOP_N : positive := 32;                                             -- 32bit serial word length is default
        GN_TOP_CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
        GN_TOP_CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
        GN_TOP_PREFETCH : positive := 2;                                       -- prefetch lookahead cycles
        GN_TOP_SPI_2X_CLK_DIV : positive := 5;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
        SPI_SCK : out std_logic;
        SPI_SS : out std_logic;
        SPI_SDO : out std_logic;
        SPI_SDI :in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic
	);
end TakSun_AXI_SPI_v1_0;

architecture arch_imp of TakSun_AXI_SPI_v1_0 is

	-- component declaration
	component TakSun_AXI_SPI_v1_0_S00_AXIS is
		generic (
        GN_N : positive := 32;                                             -- 32bit serial word length is default
        GN_CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
        GN_CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
        GN_PREFETCH : positive := 2;                                       -- prefetch lookahead cycles
        GN_SPI_2X_CLK_DIV : positive := 5;

		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
        CSPI_SCK : out std_logic;
        CSPI_SS : out std_logic;
        CSPI_SDO : out std_logic;
        CSPI_SDI :in std_logic;
		
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component TakSun_AXI_SPI_v1_0_S00_AXIS;

begin

-- Instantiation of Axi Bus Interface S00_AXIS
TakSun_AXI_SPI_v1_0_S00_AXIS_inst : TakSun_AXI_SPI_v1_0_S00_AXIS
	generic map (
	   GN_N =>GN_TOP_N,                                             -- 32bit serial word length is default
       GN_CPOL=> GN_TOP_CPOL ,                                        -- SPI mode selection (mode 0 default)
       GN_CPHA =>GN_TOP_CPHA,                                        -- CPOL = clock polarity, CPHA = clock phase.
       GN_PREFETCH=>GN_TOP_PREFETCH,                                       -- prefetch lookahead cycles
       GN_SPI_2X_CLK_DIV=> GN_TOP_SPI_2X_CLK_DIV,
	   C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
	    CSPI_SCK =>SPI_SCK,
        CSPI_SS =>SPI_SS,
        CSPI_SDO =>SPI_SDO,
        CSPI_SDI =>SPI_SDI,

		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
