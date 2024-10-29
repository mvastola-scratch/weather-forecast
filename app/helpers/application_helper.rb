module ApplicationHelper
  FLASH_CLASSES = {
    notice: "alert alert-info",
    success: "alert alert-success",
    error: "alert alert-danger",
    alert: "alert alert-warning",
  } .freeze

  def flash_class(level)
    FLASH_CLASSES.fetch(level.to_sym)
  end

  def nav_item(target, text = nil, disabled: false, is_current: nil, **link_attribs, &block)
    link_attribs.stringify_keys!
    is_current = current_page?(target) if is_current.nil?
    link_classes = [ link_attribs.delete("class")&.split(/\s+/), "nav-link", is_current && "active" ].compact_blank.to_set
    if is_current
      link_attribs["aria-current"] = "page"
      link_classes << "active"
    end
    if disabled
      link_attribs["aria-disabled"] = true
      link_classes << "disabled"
    end
    text ||= capture(&block)

    content_tag :li, class: "nav-item" do
      link_to text, target, class: link_classes.to_a.join(" "), **link_attribs
    end
  end
end
