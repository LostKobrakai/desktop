defmodule Desktop.Image do
  @moduledoc """
  A module that creates images and icons using :wx
  """
  def new(app, path) when is_binary(path) do
    path = get_abs_path(app, path)
    {:ok, :wxImage.new(path)}
  end

  def new_icon(app, path) do
    case new(app, path) do
      {:ok, image} -> new_icon(image)
      error -> error
    end
  end

  def new_icon(image) do
    case :wx.getObjectType(image) do
      :wxImage ->
        bitmap = :wxBitmap.new(image)

        ret = new_icon(bitmap)
        destroy(bitmap)
        ret

      :wxBitmap ->
        icon = :wxIcon.new()

        case :wxIcon.copyFromBitmap(icon, image) do
          :ok ->
            {:ok, icon}

          error ->
            destroy(icon)
            error
        end

      :wxIcon ->
        image
    end
  end

  def destroy(image) do
    module = :wx.getObjectType(image)
    module.destroy(image)
  end

  defp get_abs_path(_, abs_path = "/" <> _) do
    abs_path
  end

  defp get_abs_path(app, name) when is_binary(name) do
    Application.app_dir(app, ["priv", name])
  end
end