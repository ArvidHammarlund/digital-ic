LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench_lab4 IS
END testbench_lab4;

ARCHITECTURE behavioral OF testbench_lab4 IS

    CONSTANT clk_period : TIME := 10 ns;

    -- Input
    SIGNAL clk                : STD_LOGIC := '0';
    SIGNAL resetn             : STD_LOGIC := '0';
    SIGNAL master_load_enable : STD_LOGIC := '0';
    SIGNAL extIn              : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL inValid            : STD_LOGIC := '0';
    SIGNAL outReady           : STD_LOGIC := '0';

    -- Test device
    SIGNAL pc2seg           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL imDataOut2seg    : STD_LOGIC_VECTOR(11 DOWNTO 0);  -- fixed to 12 bits
    SIGNAL dmDataOut2seg    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL aluOut2seg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL acc2seg          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL busOut2seg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL extOut           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL inReady, outValid : STD_LOGIC;

    -- Reference device
    SIGNAL ref_pc2seg           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_imDataOut2seg    : STD_LOGIC_VECTOR(11 DOWNTO 0);  -- fixed to 12 bits
    SIGNAL ref_dmDataOut2seg    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_aluOut2seg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_acc2seg          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_busOut2seg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_extOut           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ref_inReady, ref_outValid : STD_LOGIC;

    procedure check_output(
        constant name: in string;
        signal observed: in std_logic_vector;
        signal expected: in std_logic_vector
    ) is
    begin
        assert observed = expected
            report "Mismatch in " & name &
                "! Expected: " & to_hstring(expected) &
                " Got: " & to_hstring(observed)
            severity error;
    end procedure;

    procedure check_output(
        constant name: in string;
        signal observed: in std_logic;
        signal expected: in std_logic
    ) is
    begin
        assert observed = expected
            report "Mismatch in " & name &
                "! Expected: " & std_logic'image(expected) &
                " Got: " & std_logic'image(observed)
            severity error;
    end procedure;

BEGIN

    test_device: ENTITY work.EDA322_processor
        GENERIC MAP (
            dInitFile => "d_memory_lab4.mif",
            iInitFile => "i_memory_lab4.mif"
        )
        PORT MAP (
            clk => clk,
            resetn => resetn,
            master_load_enable => master_load_enable,
            extIn => extIn,
            inValid => inValid,
            outReady => outReady,
            pc2seg => pc2seg,
            imDataOut2seg => imDataOut2seg,
            dmDataOut2seg => dmDataOut2seg,
            aluOut2seg => aluOut2seg,
            acc2seg => acc2seg,
            busOut2seg => busOut2seg,
            extOut => extOut,
            inReady => inReady,
            outValid => outValid
        );

    reference: ENTITY work.reference_processor
        GENERIC MAP (
            dInitFile => "d_memory_lab4.mif",
            iInitFile => "i_memory_lab4.mif"
        )
        PORT MAP (
            clk => clk,
            resetn => resetn,
            master_load_enable => master_load_enable,
            extIn => extIn,
            inValid => inValid,
            outReady => outReady,
            pc2seg => ref_pc2seg,
            imDataOut2seg => ref_imDataOut2seg,
            dmDataOut2seg => ref_dmDataOut2seg,
            aluOut2seg => ref_aluOut2seg,
            acc2seg => ref_acc2seg,
            busOut2seg => ref_busOut2seg,
            extOut => ref_extOut,
            inReady => ref_inReady,
            outValid => ref_outValid
        );

    clk_process: PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period / 2;
        clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    driver_process: PROCESS
    BEGIN
        resetn <= '0';
        master_load_enable <= '1';
        WAIT FOR clk_period * 2;
        resetn <= '1';
        inValid <= '1';
        outReady <= '1';
        WAIT;
    END PROCESS;

    extIn_increment: PROCESS(clk)
    BEGIN
        IF rising_edge(clk) AND
        (master_load_enable = '1') AND
        (inValid = '1') AND
        (inReady = '1') THEN
            extIn <= std_logic_vector(unsigned(extIn) + 1);
        END IF;
    END PROCESS;

    verification_process: PROCESS(clk)
    BEGIN
        IF rising_edge(clk) AND (resetn = '1') THEN
            check_output("pc2seg", pc2seg, ref_pc2seg);
            check_output("imDataOut2seg", imDataOut2seg, ref_imDataOut2seg);
            check_output("dmDataOut2seg", dmDataOut2seg, ref_dmDataOut2seg);
            check_output("aluOut2seg", aluOut2seg, ref_aluOut2seg);
            check_output("acc2seg", acc2seg, ref_acc2seg);
            check_output("busOut2seg", busOut2seg, ref_busOut2seg);
            check_output("extOut", extOut, ref_extOut);
            check_output("inReady", inReady, ref_inReady);
            check_output("outValid", outValid, ref_outValid);
        END IF;
    END PROCESS;

END behavioral;