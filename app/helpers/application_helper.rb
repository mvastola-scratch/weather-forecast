module ApplicationHelper
  FLASH_CLASSES = {
    notice: "alert alert-info",
    success: "alert alert-success",
    error: "alert alert-error",
    alert: "alert alert-error",
  } .freeze
  def flash_class(level)
    FLASH_CLASSES.fetch(level.to_sym)
  end
end
