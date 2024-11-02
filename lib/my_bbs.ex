defmodule MyBBS do
  def view do
    quote do
      @behaviour BBS.View

      import BBS.Format
      import BBS.View
    end
  end

  def component do
    quote do
      use BBS.Component

      import BBS.Format
      import BBS.View
    end
  end

  defmacro __using__(thing) do
    apply(__MODULE__, thing, [])
  end
end
