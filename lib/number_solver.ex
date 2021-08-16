defmodule NumberSolver do
  @moduledoc """
  * Determines whether a given set of numbers can solve for the specified number by performing basic arithmetic operations (+, -, *, /) using all the given numbers.
  * Finds a solution if the the given set of numbers are solvable.
  * Division is considered valid a valid operation only when the remainder/modulus is zero.
  """

  defmodule Calculation do
    defstruct history: nil, numbers: [], value: 0

    @type t :: %__MODULE__{history: tuple(), value: integer(), numbers: list()}

    @spec new(integer) :: t()
    def new(number) when is_integer(number) do
      __struct__(numbers: [number], history: nil, value: number)
    end
  end

  alias NumberSolver.Calculation

  @type operator :: :* | :+ | :- | :/

  @spec run([integer], integer) :: :soluton_not_found | NumberSolver.Calculation.t()
  def run(numbers, target) do
    numbers
    |> Enum.map(&Calculation.new/1)
    |> loop_algorithm(target, 0)
  end

  @spec loop_algorithm([Calculation.t()], integer, non_neg_integer) ::
          :soluton_not_found | NumberSolver.Calculation.t()
  def loop_algorithm(calcs, target, epoch) do
    if epoch == 1000 do
      :soluton_not_found
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
      calculation = hd(calcs)

      case calculation.value do
        ^target -> calculation
        _ -> nil
      end
    else
      [operand1 | [operand2 | rest]] = Enum.shuffle(calcs)

      [
        do_math(:+, operand1, operand2),
        do_math(:-, operand1, operand2),
        do_math(:*, operand1, operand2),
        do_math(:/, operand1, operand2)
      ]
      |> Enum.filter(&is_struct/1)
      |> Enum.map(&search_for_solution(rest ++ [&1], target))
      |> Enum.filter(& &1)
      |> case do
        [result | _] -> result
        _ -> nil
      end
    end
  end

  @spec do_math(operator, Calculation.t(), Calculation.t()) :: Calculation.t() | {:error, any}
  def do_math(:+, %Calculation{} = operand1, %Calculation{} = operand2) do
    new_value = operand1.value + operand2.value
    new_history = {operand1.history || operand1.value, operand2.history || operand2.value, :+}

    operand1
    |> struct!(numbers: Enum.sort(operand1.numbers ++ operand2.numbers))
    |> struct!(value: new_value)
    |> struct!(history: new_history)
  end

  def do_math(:-, %Calculation{} = operand1, %Calculation{} = operand2) do
    new_value = operand1.value - operand2.value
    new_history = {operand1.history || operand1.value, operand2.history || operand2.value, :-}

    operand1
    |> struct!(numbers: Enum.sort(operand1.numbers ++ operand2.numbers))
    |> struct!(value: new_value)
    |> struct!(history: new_history)
  end

  def do_math(:*, %Calculation{} = operand1, %Calculation{} = operand2) do
    new_value = operand1.value * operand2.value
    new_history = {operand1.history || operand1.value, operand2.history || operand2.value, :*}

    operand1
    |> struct!(numbers: Enum.sort(operand1.numbers ++ operand2.numbers))
    |> struct!(value: new_value)
    |> struct!(history: new_history)
  end

  def do_math(:/, %Calculation{} = operand1, %Calculation{} = operand2) do
    if valid_division?(operand1.value, operand2.value) do
      new_value = div(operand1.value, operand2.value)
      new_history = {operand1.history || operand1.value, operand2.history || operand2.value, :/}

      operand1
      |> struct!(numbers: Enum.sort(operand1.numbers ++ operand2.numbers))
      |> struct!(value: new_value)
      |> struct!(history: new_history)
    else
      {:error, :invalid_division}
    end
  end

  @spec valid_division?(integer, integer) :: boolean
  def valid_division?(value1, value2) when is_integer(value1) and is_integer(value2) do
    cond do
      value2 == 0 -> false
      rem(value1, value2) != 0 -> false
      true -> true
    end
  end
end
