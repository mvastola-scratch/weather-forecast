# Based on https://getbootstrap.com/docs/5.3/examples/carousel/
module ForecastsHelper
  CAROUSEL_BUTTON_LABELS = { prev: 'Previous', next: 'Next' }
  def forecast_carousel_indicator(date, idx, target:)
    content_tag :button, 'A', type: "button", 'data-bs-target': target, 'data-bs-slide-to': idx,
                class: [idx.zero? && "active"].compact_blank.join(' '),
                'aria-current': idx.zero?, 'aria-label': date.to_s
  end

  def placeholder_image(height: '100%', width: '100%', fill: "var(--bs-secondary-color)", **args)
    content_tag :svg, class: 'bd-placeholder-img', width:, height:, xmlns:"http://www.w3.org/2000/svg",
                'aria-hidden': "true", preserveAspectRatio: "xMidYMid slice", focusable: false, **args do
      tag :rect, width: '100%', height: '100%', fill:
    end
  end

  def forecast_carousel_item(idx, &block)
    classes = ['forcast-carousel-item', 'carousel-item', idx.zero? && 'active'].compact_blank
    content_tag :div, class: classes.join(' ') do
      # placeholder_image +
        content_tag(:div, class: 'container') { capture(&block) }
    end
  end

  def carousel_button(action, target:)
    label = CAROUSEL_BUTTON_LABELS.fetch(action.to_sym)
    content_tag :div, class: 'carousel-button' do
      content_tag :button, class: "carousel-control-#{action}", 'data-bs-target': target,
                  'data-bs-slide': action do
        content_tag :span, '',
                    class: "carousel-control-#{action}-icon", 'aria-hidden': true
        content_tag :span, label, class: 'visually-hidden'
      end
    end
  end

  def carousel_buttons(target:)
    capture do
      carousel_button(:prev, target:)
      carousel_button(:next, target:)
    end
  end
end
