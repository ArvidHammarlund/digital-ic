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

        case curr_state is
            when FE =>
                imRead  <= '1'; 
                pcLd    <= '1'; 
                dmWrite <= '0';
                dmRead  <= '0';
            when DE1 =>
                if (opcode(3) = '1' or opcode = O_CMP) then 
                    dmRead <= '1';
                    busSel <= B_IMEM; 
                end if;
            when DE2 =>
                if (opcode = O_LBI and master_load_enable = '1') then
                    dmRead <= '1';
                    busSel <= B_DMEM;
                else
                    dmRead <= '0';
                end if;
            when EX =>
                case opcode is
                    when O_ADD | O_SUB | O_AND | O_XOR | O_CMP =>
                        busSel <= B_DMEM; 
                        case opcode is
                            when O_ADD =>
                                aluOp <= A_ADD;
                            when O_SUB =>
                                aluOp <= A_SUB;
                            when O_AND =>
                                aluOp <= A_AND;
                            when others =>
                                aluOp <= A_XOR;
                            end case;
                        flagLd <= '1';
                        if (opcode /= O_CMP) then
                            accLd <= '1';
                        else
                            accLd <= '0';
                        end if;
                    when O_MOV =>
                        busSel <= B_IMEM;
                        accSel <= '1';
                        accLd  <= '1';
                    when O_JE | O_JNZ | O_J =>
                        pcSel <= '1';
                        if (opcode = O_J or (opcode = O_JE and e_flag = '1') or (opcode = O_JNZ and z_flag = '0')) then
                            pcSel <= '1';
                            if (master_load_enable = '1') then
                                pcLd  <= '1';
                            end if;
                        end if;
                    when O_IN =>
                        inReady <= '1';
                        if (inValid = '1') then
                            busSel <= B_EXT; accSel <= '1'; accLd <= '1';
                        end if;
                    when O_OUT =>
                        outValid <= '1';
                    when others => null;
                end case;
                dmRead <= '0';
            when ME =>
                if (opcode = O_SB or opcode = O_SBI) then
                    if (master_load_enable = '1') then
                        dmWrite <= '1'; 
                    end if;
                    busSel  <= B_DMEM; 
                end if;
                dmRead <= '0';
            when others => null;
        end case;
    end process;
END behavioral;