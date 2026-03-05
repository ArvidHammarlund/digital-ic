library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab2.mif";
             iInitFile : string := "i_memory_lab2.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        inValid            : in  std_logic;
        outReady           : in  std_logic;
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        extOut             : out std_logic_vector(7 downto 0);
        inReady            : out std_logic;
        outValid           : out std_logic
    );
end EDA322_processor;

architecture dataflow of EDA322_processor is

    signal pcIncrOut : std_logic_vector(7 downto 0);
    signal jumpAddr : std_logic_vector(7 downto 0);
    signal nextPC : std_logic_vector(7 downto 0);
    signal pcOut : std_logic_vector(7 downto 0);
    signal imDataOut : std_logic_vector(11 downto 0);
    signal dmDataOut : std_logic_vector(7 downto 0);
    signal aluOut : std_logic_vector(7 downto 0);
    signal accMuxOut : std_logic_vector(7 downto 0);
    signal accOut : std_logic_vector(7 downto 0);
    signal busOut : std_logic_vector(7 downto 0);
    signal pcSel : std_logic;
    signal pcLd : std_logic;
    signal busSel : std_logic_vector(3 downto 0);
    signal imRead : std_logic;
    signal dmRead : std_logic;
    signal dmWrite : std_logic;
    signal aluOp : std_logic_vector(1 downto 0);
    signal accSel : std_logic;
    signal accLd : std_logic;
    signal flagLd : std_logic;
    signal e_alu : std_logic;
    signal e_flag : std_logic;
    signal z_alu : std_logic;
    signal z_flag : std_logic;

 begin
    PC : entity work.reg
    generic map(width => 8)
    port map(
        clk   => clk,
        rstn  => resetn,
        en    => pcLd,
        d     => nextPC,
        q     => pcOut
    );

    pcIncrOut <= std_logic_vector(unsigned(pcOut) + 1);

    jumpAddr <= std_logic_vector(signed(pcOut) + signed(busOut));

    PC_mux : entity work.mux
    port map(
	s => pcSel,
	i0 => pcIncrOut,
	i1 => jumpAddr,
	o => nextPC
    );
    
    IM : entity work.memory
    generic map(
        DATA_WIDTH => 12,
        ADDR_WIDTH => 8,
        INIT_FILE  => iInitFile
    )
    port map(
        clk     => clk,
        readEn  => imRead,
        writeEn => '0',
        address => pcOut,
        dataIn  => (others => '0'),
        dataOut => imDataOut
    );

    DM : entity work.memory
    generic map(
        DATA_WIDTH => 8,
        ADDR_WIDTH => 8,
        INIT_FILE  => dInitFile
    )
    port map(
        clk     => clk,
        readEn  => dmRead,
        writeEn => dmWrite,
        address => busOut,
        dataIn  => accOut,
        dataOut => dmDataOut
    );

    ALU : entity work.alu
    generic map(
        width => 8
    )
    port map(
        alu_inA  => accOut,
        alu_inB  => busOut,
        alu_op   => aluOp,
        E        => e_alu,
        Z        => z_alu,
        alu_out  => aluOut
    );

    FLAG_E : entity work.reg
    generic map(width => 1)
    port map(
        clk => clk,
        rstn => resetn,
        en => flagLd,
        d(0) => e_alu,
        q(0) => e_flag
    );

    FLAG_Z : entity work.reg
    generic map(width => 1)
    port map(
        clk => clk,
        rstn => resetn,
        en => flagLd,
        d(0) => z_alu,
        q(0) => z_flag
    );

    ACC_mux : entity work.mux
    port map(
	s => accSel,
	i0 => aluOut,
	i1 => busOut,
	o => accMuxOut
    );

    ACC : entity work.reg
    generic map(width => 8)
    port map(
        clk   => clk,
        rstn  => resetn,
        en    => accLd,
        d     => accMuxOut,
        q     => accOut
    );

    PROC_BUS : entity work.proc_bus
    port map(
        busSel    => busSel,
        imDataOut => imDataOut(7 downto 0),
        dmDataOut => dmDataOut,
        accOut    => accOut,
        extIn     => extIn,
        busOut    => busOut
    );

    CONTROLLER : entity work.proc_controller
    port map(
        clk => clk,
        resetn => resetn,
        master_load_enable => master_load_enable,
        opcode => imDataOut(11 downto 8),
        e_flag => e_flag,
        z_flag => z_flag,
        inValid => inValid,
        outReady => outReady,
        busSel => busSel,
        pcSel => pcSel,
        pcLd => pcLd,
        imRead => imRead,
        dmRead => dmRead,
        dmWrite => dmWrite,
        aluOp => aluOp,
        flagLd => flagLd,
        accSel => accSel,
        accLd => accLd,
        inReady => inReady,
        outValid => outValid
    );

    pc2seg <= pcOut;
    imDataOut2seg <= imDataOut;
    dmDataOut2seg <= dmDataOut;
    aluOut2seg <= aluOut;
    busOut2seg <= busOut;
    acc2seg <= accOut;

end architecture dataflow;
