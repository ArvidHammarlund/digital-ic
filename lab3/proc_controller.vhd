LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.chacc_pkg.all;

ENTITY proc_controller IS
    port (
        -- Synchronizes every sequential circuit (the processor's clock)
        clk: in std_logic;
        -- Initializes the components when active (RESETn=0)
        resetn: in std_logic;
        -- used to control manual clock toggling/debugging
        master_load_enable: in std_logic;
        -- Four MSBs of current instruction
        opcode: in std_logic_vector(3 downto 0);
        -- Used for conditional jump instructions
        e_flag: in std_logic;
        -- sed for conditional jump instructions
        z_flag: in std_logic;
        -- External input; used by IN instruction
        inValid: in std_logic;
        -- External input; used by OUT instruction
        outReady: in std_logic;

        -- One-hot select signal for the Bus
        busSel: out std_logic_vector(3 downto 0);
        -- Select signal for pc mux
        pcSel: out std_logic;
        -- Enables PC register
        pcLd: out std_logic;
        -- Enables the read function of the Instruction Memory
        imRead: out std_logic;
        -- Enables the read function of the Data Memory
        dmRead: out std_logic;
        -- Enables the write function of the Data Memory
        dmWrite: out std_logic;
        -- Control signal that determines the ALU operation
        aluOp: out std_logic_vector(1 downto 0);
        -- Enables E and Z registers
        flagLd: out std_logic;
        -- Select signal for ACC mux
        accSel: out std_logic;
        -- Enables ACC register
        accLd: out std_logic;
        -- Signals when the processor is ready for input
        inReady: out std_logic;
        -- Indicates that data on extOut is vali    d
        outValid: out std_logic
    );
END proc_controller;

ARCHITECTURE behavioral OF proc_controller IS
    type state_type is (FE, DE1, DE2, EX, ME);
    signal curr_state: state_type;
    signal next_state: state_type;			
BEGIN

    state_register: PROCESS(clk, resetn) 
    BEGIN
        IF (resetn = '0') THEN 
            curr_state <= FE; 
        ELSIF (rising_edge(clk) AND (master_load_enable = '1')) THEN
            curr_state <= next_state; 
        END IF;
    END PROCESS;

    next_state_logic: PROCESS(curr_state, opcode, inValid, outReady)
    BEGIN
        next_state <= FE; 
        CASE curr_state IS
            WHEN FE =>
                next_state <= DE1; 
            WHEN DE1 =>
                CASE opcode IS
                    WHEN O_NOOP => 
                        next_state <= FE; 
                    WHEN O_LBI  => 
                        next_state <= DE2; 
                    WHEN O_SB | O_SBI => 
                        next_state <= ME; 
                    WHEN O_IN | O_OUT => 
                        next_state <= EX; 
                    WHEN OTHERS => 
                        next_state <= EX; 
                END CASE;
            WHEN DE2 =>
                next_state <= EX; 
            WHEN EX =>
                IF (opcode = O_IN AND inValid = '0') THEN
                    next_state <= EX; 
                ELSIF (opcode = O_OUT AND outReady = '0') THEN
                    next_state <= EX; 
                ELSE
                    next_state <= FE; 
                END IF;
            WHEN ME =>
                next_state <= FE; 
            WHEN OTHERS =>
                next_state <= FE;
        END CASE;
    END PROCESS;

    output_logic: PROCESS(curr_state, opcode, e_flag, z_flag, inValid, outReady, master_load_enable)
    begin
        busSel  <= "0000"; pcSel   <= '0'; pcLd     <= '0';
        imRead  <= '0';    dmRead  <= '0'; dmWrite  <= '0';
        aluOp   <= A_XOR;  flagLd  <= '0'; accSel   <= '0';
        accLd   <= '0';    inReady <= '0'; outValid <= '0';

        if (opcode = O_NOOP) then
            busSel <= "0000";
        end if;

        if (opcode = O_OUT) then
            busSel <= "0000";
        end if;

        if (opcode != O_SB and opcode != O_SBI) then
            dmWrite <= '0';
        end if;

        if (opcode != O_OUT) then
            outValid <= '0';
        end if;

        if (opcode != O_IN) then
            inReady <= '0';
        end if;

        case opcode is 
            when O_MOV | O_J | O_JE | O_JNZ | O_SB | O_IN | O_OUT | O_NOOP =>
                dmRead <= '0';
            when OTHERS => NULL;
            end case;

        case opcode is
            when O_CMP | O_XOR | O_AND | O_ADD | O_SUB  =>
                NULL;
            when OTHERS => 
                flagLd <= '0';
        end case;

        case opcode is 
            -- in, move, xor, and, add, sub
            when O_IN | O_MOV | O_XOR | O_AND | O_ADD | O_SUB | O_LB | O_LBI =>
                NULL;
            when OTHERS =>
                accLd <= '0';
        end case;


        case curr_state is
            when FE =>
                pcSell <= "0";
                imRead <= "1";
                pcLd   <= "1";
            when DE1 =>
                if (
                    opcode = O_CMP or opcode = O_XOR or opcode = O_AND or opcode = O_ADD or opcode = O_SUB or opcode = O_LB or opcode = O_SB or opcode = O_LBI or opcode = O_SBI
                ) then
                    busSel <= "0001";
                    dmRead <= "1";
            when DE2 =>
                if (opcode = O_LBI) then
                    busSel <= "0010";
                    dmRead <= "1";
                end if;
            when EX =>
                if (opcode = O_IN) then
                    busSel <= "1000";
                    accSel <= "1";
                    if (inValid = '1') then
                        accLd <= "1";
                    end if; 
                    inReady <= '1';
                end if;

                if (opcode = O_OUT) then
                    outValid <= "1";
                end if;

                if (opcode = O_MOV) then 
                    busSel <= "0001";
                    accSel <= "1";
                    accLd <= "1";
                end if;

                if (opcode = O_J) then
                    busSel <= "0100";
                    pcSel <= "1";
                    pcLd <= "1";
                end if;

                if (opcode = O_JE) then
                    busSel <= "0001";
                    pcSel <= "1";
                    if (e_flag = '1') then
                        pcLd <= "1";
                    end if;
                end if;

                if (opcode = O_JNZ) then
                    busSel <= "0001";
                    pcSel <= "1";
                    if (z_flag = '0') then
                        pcLd <= "1";
                    end if;
                end if;

                if (opcode = O_CMP) then
                    busSel <= "0010";
                    flagLd <= "1";
                end if;

                if (opcode = O_XOR) then
                    busSel <= "0010";
                    aluOp <= "00";
                    accSel <= "0";
                    flagLd <= "1";
                    accLd <= "1";
                end if;

                if (opcode = O_AND) then
                    busSel <= "0010";
                    aluOp <= "01";
                    accSel <= "0";
                    flagLd <= "1";
                    accLd <= "1";
                end if;

                if (opcode = O_ADD) then
                    busSel <= "0010";
                    aluOp <= "10";
                    accSel <= "0";
                    flagLd <= "1";
                    accLd <= "1";
                end if;

                if (opcode = O_SUB) then
                    busSel <= "0010";
                    aluOp <= "11";
                    accSel <= "0";
                    flagLd <= "1";
                    accLd <= "1";
                end if;

                if (opcode = O_LB) then
                    busSel <= "0010";
                    accSel <= "1";
                    accLd <= "1";
                end if;
    
                if (opcode = L_BI) then
                    busSel <= "0010";
                    accSel <= "1";
                    accLd <= "1";
                end if;
               
            when ME =>
                if (opcode = O_SB) then
                    busSel <= "0001";
                    dmWrite <= "1";
                end if;
                if (opcode = O_SBI) then
                    busSel <= "0010";
                    dmWrite <= "1";
                end if;

            when OTHERS => NULL;
        end case;

        IF master_load_enable = '0' THEN
            imRead <= '0';
            dmRead <= '0';
            dmWrite <= '0';
            pcLd <= '0';
            flagLd <= '0';
            accLd <= '0';
            inReady <= '0';
            outValid <= '0';
        END IF;

    end process;

END behavioral;