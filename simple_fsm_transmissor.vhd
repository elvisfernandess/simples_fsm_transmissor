-------------------------------------------------------------------
-- Name        : simple_fsm_transmissor.vhd
-- Author      : Elvis Fernandes
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Tarefa 12: Transmissor Serial 
-- Date        : 29/07/2024
-------------------------------------------------------------------
--Esta tarefa envolve a criação de um módulo em VHDL que recebe dados em paralelo de barramentos de 8 bits e os converte em formato serial para serem transmitidos por um pino de saída.
--Pinos de entrada e saída:
--clk - fclk = 100 kHz (usar uma PLL para redução).
--start: sinal que sinaliza o início da transmissão. A transmissão é iniciada quando start é nível lógico alto.
--reset: reinicializa circuitos síncronos.
--data: dado de 8 bits para ser transmitido em formato serial.
--addr: endereço de 8 bits que será transmitido em formato serial antes do dado.
--sdata: canal de saída da transmissão serial.
--Implementação e requisitos:
--Um exemplo de formato de saída pode ser visualizado na figura abaixo.
--Um bit em nível baixo deve ser enviado no início da transmissão (start bit).
--A linha permanece em nível lógico alto quando não há nenhuma transmissão.
--Use uma máquina de estados.
--Use simulação para o desenvolvimento.
--Comprovar o funcionamento da síntese com o osciloscópio.
--Código deve conter documentação.
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_fsm_transmissor is
    port (
        clk   : in  std_logic;
        start : in  std_logic;
        reset : in  std_logic;
        data  : in  std_logic_vector(7 downto 0);
        addr  : in  std_logic_vector(7 downto 0);
        sdata : out std_logic_vector(16 downto 0)
    );
end entity simple_fsm_transmissor;

architecture rtl of simple_fsm_transmissor is

    type state is (IDLE, TRANSMITTING);
    signal pr_state, nx_state : state;
	
	signal clk4        : std_logic;
    signal clk16       : std_logic;
    signal clk32       : std_logic;
    signal clk64       : std_logic;
    signal clk128      : std_logic;
    signal clk256      : std_logic;
    signal sel_pr      : std_logic_vector(2 downto 0) := "101";
    signal out_clk     : std_logic;

begin

	-------------Lower section---------------

	process(reset, clk) is
		begin
			if reset = '1' then
            pr_state <= IDLE;
			elsif (clk'event AND clk='0') then
            pr_state <= nx_state;
			end if;
	end process;
	
	-------------Uper section---------------
	process(start,addr,data,pr_state)
	begin
		case pr_state is 
			when IDLE =>
			sdata <="11111111111111111";
			if (start='0') then nx_state<=TRANSMITTING;
			else nx_state<=IDLE;
			end if;
			when TRANSMITTING =>
			sdata <='0' & addr & data;
			if(start='1') then nx_state<=IDLE;
			else nx_state <=TRANSMITTING;
			end if;
		end case;
	end process;
	
	-- Processo para a geração dos sinais de clock divididos
    process(clk, reset)
        variable cont4   : integer range 0 to 3; -- Ajustado para 3 para cobrir 4 estados
        variable cont16  : integer range 0 to 8;
        variable cont32  : integer range 0 to 16;
        variable cont64  : integer range 0 to 32;
        variable cont128 : integer range 0 to 64;
        variable cont256 : integer range 0 to 128;
    begin
        if reset = '1' then
            clk4    <= '0';
            clk16   <= '0';
            clk32   <= '0';
            clk64   <= '0';
            clk128  <= '0';
            clk256  <= '0';
            cont4   := 0;
            cont16  := 0;
            cont32  := 0;
            cont64  := 0;
            cont128 := 0;
            cont256 := 0;
        elsif rising_edge(clk) then
            cont4   := cont4 + 1;
            cont16  := cont16 + 1;
            cont32  := cont32 + 1;
            cont64  := cont64 + 1;
            cont128 := cont128 + 1;
            cont256 := cont256 + 1;

            if cont4 = 3 then
                clk4  <= not clk4;
                cont4 := 0;
            end if;

            if cont16 = 8 then
                clk16  <= not clk16;
                cont16 := 0;
            end if;

            if cont32 = 16 then
                clk32  <= not clk32;
                cont32 := 0;
            end if;

            if cont64 = 32 then
                clk64  <= not clk64;
                cont64 := 0;
            end if;

            if cont128 = 64 then
                clk128  <= not clk128;
                cont128 := 0;
            end if;

            if cont256 = 128 then
                clk256  <= not clk256;
                cont256 := 0;
            end if;
        end if;
    end process;
		
	-- Mux 8:1
    -- Seleciona o clk escolhido
    with sel_pr select out_clk <=
        clk and (not reset) when "000",
        clk4 when "001",
        clk16 when "010",
        clk32 when "011",
        clk64 when "100",
        clk128 when "101",
        clk256 when "110",
        '0' when others;
	
end architecture rtl;
