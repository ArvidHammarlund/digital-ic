LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY testbench_lab4 IS
END testbench_lab4;

ARCHITECTURE behavioral OF testbench_lab4 IS

    CONSTANT clk_period : TIME := 10 ns;

    -- Input
    SIGNAL clk                : STD_LOGIC := '0'; 
    SIGNAL resetn             : STD_LOGIC := '0'; 
    SIGNAL master_load_enable : STD_LOGIC := '0'; 
    SIGNAL extIn              : STD_LOGIC_VECTOR(7 downto 0) 
        := (others => '0'); 
    SIGNAL inValid            : STD_LOGIC := '0'; 
    SIGNAL outReady           : STD_LOGIC := '0'; 

    -- Test device
    SIGNAL pc2seg, imDataOut2seg, dmDataOut2seg, aluOut2seg, acc2seg, busOut2seg, extOut: STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL inReady, outValid : STD_LOGIC; 

    -- Reference device (REF)
    SIGNAL ref_pc2seg, ref_imDataOut2seg, ref_dmDataOut2seg, ref_aluOut2seg, ref_acc2seg, ref_busOut2seg, ref_extOut : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL ref_inReady, ref_outValid : STD_LOGIC; 

    procedure check_output(
        constant name: in string;
        signal observed: in std_logic_vector;
        signal expected: in std_logic_vector
    ) is
        begin
            ASSERT observed = expected 
                REPORT "Mismatch in " 
                    & name 
                    & "! Expected: " 
                    & to_hstring(expected) 
                    & " Got: " 
                    & to_hstring(observed)
                SEVERITY ERROR;
    end procedure;

BEGIN

    test_device: entity work.EDA322_processor 
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

    reference: entity work.reference_processor
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
        clk <= '0'; WAIT FOR clk_period/2;
        clk <= '1'; WAIT FOR clk_period/2;
    END PROCESS;

    driver_process: PROCESS
    BEGIN
        resetn <= '0';
        master_load_enable <= '1';
        WAIT FOR clk_period * 2;
        resetn <= '1'; 
        inValid  <= '1'; 
        outReady <= '1';
        WAIT; 
    END PROCESS;

    extIn_increment: PROCESS(clk)
    BEGIN
        IF rising_edge(clk 
            and (master_load_enable = '1')
            and (inValid = '1') 
            and (inReady = '1')
        ) THEN
            extIn <= std_logic_vector(unsigned(extIn) + 1); 
        END IF;
    END PROCESS;

    verification_process: PROCESS(clk)
    BEGIN
        IF rising_edge(clk) AND (resetn = '1') THEN 
            check_output("pc2seg", pc2seg, ref_pc2seg);
            check_output("imDataOut2seg", imDataOut2seg,            ref_imDataOut2seg);
            check_output("dmDataOut2seg", dmDataOut2seg, 
                ref_dmDataOut2seg);
            check_output("aluOut2seg", aluOut2seg, ref_aluOut2seg);
            check_output("acc2seg", acc2seg, ref_acc2seg);
            check_output("busOut2seg", busOut2seg, ref_busOut2seg);
            check_output("extOut", extOut, ref_extOut);
            check_output("inReady", inReady, ref_inReady);
            check_output("outValid", outValid, ref_outValid);
    END IF;
    END PROCESS;

END behavioral;