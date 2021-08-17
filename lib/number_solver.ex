defmodule NumberSolver do
  @moduledoc """
  * Determines whether a given set of numbers can solve for the specified number by performing basic arithmetic operations (+, -, *, /) using all the given numbers.
  * Finds a solution if the the given set of numbers are solvable.
  * Division is considered valid a valid operation only when the remainder/modulus is zero.
  """

  defmodule Calculation do
    defstruct polish_notation: nil, value: 0

    @type t :: %__MODULE__{polish_notation: tuple(), value: integer()}
  end

  alias NumberSolver.Calculation

  @type operator :: :* | :+ | :- | :/
  @type polish_notation :: {operator, polish_notation | integer, polish_notation | integer}

  @max_epoch 1000

  @spec run([integer], integer) :: :solution_not_found | NumberSolver.Calculation.t()
  def run(numbers, target) do
    result =
      numbers
      |> Enum.map(&struct!(Calculation, value: &1))
      |> loop_algorithm(target, 0)

    case result do
      %Calculation{} ->
        IO.inspect(result.polish_notation)
        polish_notation_to_value(result.polish_notation)

      failure ->
        failure
    end
  end

  @spec loop_algorithm([Calculation.t()], integer, non_neg_integer) ::
          :solution_not_found | NumberSolver.Calculation.t()
  def loop_algorithm(calcs, target, epoch) do
    if epoch == @max_epoch do
      :solution_not_found
    else
      case search_for_solution(calcs, target) do
        nil -> loop_algorithm(calcs, target, epoch + 1)
        result -> result
      end
    end
  end

  @spec search_for_solution([Calculation.t()], integer) :: Calculation.t() | nil
  def search_for_solution(calcs, target) when is_list(calcs) and is_integer(target) do
    if length(calcs) == 1 do
      case result = hd(calcs) do
        %{value: ^target} -> result
        _ -> nil
      end
    else
      [operand1 | [operand2 | rest]] = Enum.shuffle(calcs)

      [:+, :-, :*, :/]
      |> Enum.map(&do_math(&1, operand1, operand2))
      |> Enum.filter(&is_struct/1)
      |> Enum.map(&search_for_solution(rest ++ [&1], target))
      |> Enum.filter(& &1)
      |> case do
        [result | _] -> result
        _not_found -> nil
      end
    end
  end

  @spec do_math(operator, Calculation.t(), Calculation.t()) :: Calculation.t() | {:error, any}
  def do_math(:+, %Calculation{} = operand1, %Calculation{} = operand2) do
    polish_notation1 = operand1.polish_notation || operand1.value
    polish_notation2 = operand2.polish_notation || operand2.value
    new_polish_notation = {:+, polish_notation1, polish_notation2}
    new_value = operand1.value + operand2.value

    struct!(operand1, value: new_value, polish_notation: new_polish_notation)
  end

  def do_math(:-, %Calculation{} = operand1, %Calculation{} = operand2) do
    polish_notation1 = operand1.polish_notation || operand1.value
    polish_notation2 = operand2.polish_notation || operand2.value
    new_polish_notation = {:-, polish_notation1, polish_notation2}
    new_value = operand1.value - operand2.value

    struct!(operand1, value: new_value, polish_notation: new_polish_notation)
  end

  def do_math(:*, %Calculation{} = operand1, %Calculation{} = operand2) do
    polish_notation1 = operand1.polish_notation || operand1.value
    polish_notation2 = operand2.polish_notation || operand2.value
    new_polish_notation = {:*, polish_notation1, polish_notation2}
    new_value = operand1.value * operand2.value

    struct!(operand1, value: new_value, polish_notation: new_polish_notation)
  end

  def do_math(:/, %Calculation{} = operand1, %Calculation{} = operand2) do
    if valid_division?(operand1.value, operand2.value) do
      polish_notation1 = operand1.polish_notation || operand1.value
      polish_notation2 = operand2.polish_notation || operand2.value
      new_polish_notation = {:/, polish_notation1, polish_notation2}
      new_value = div(operand1.value, operand2.value)

      struct!(operand1, value: new_value, polish_notation: new_polish_notation)
    else
      {:error, :invalid_division}
    end
  end

  @spec valid_division?(integer, integer) :: boolean
  def valid_division?(value1, value2) when is_integer(value1) and is_integer(value2) do
    value2 != 0 && rem(value1, value2) == 0
  end

  @spec operator_to_fun(operator) :: (integer, integer -> integer)
  def operator_to_fun(operator) do
    case operator do
      :/ -> fn o1, o2 -> Kernel.div(o1, o2) end
      _ -> fn o1, o2 -> apply(Kernel, operator, [o1, o2]) end
    end
  end

  @spec polish_notation_to_value(polish_notation() | integer) :: integer
  # Recursive case
  def polish_notation_to_value({operator, operand1, operand2}) do
    operand1 = polish_notation_to_value(operand1)
    operand2 = polish_notation_to_value(operand2)
    result = operator_to_fun(operator).(operand1, operand2)
    IO.puts("#{operand1} #{operator} #{operand2} = #{result}")
    result
  end

  # Base case
  def polish_notation_to_value(number) when is_integer(number), do: number
end
