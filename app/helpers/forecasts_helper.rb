# Based on https://getbootstrap.com/docs/5.3/examples/carousel/
module ForecastsHelper
  CAROUSEL_BUTTON_LABELS = { prev: 'Previous', next: 'Next' }.freeze
  FIXED_DATE_LABELS = { 0 => 'Today', 1 => 'Tomorrow' }.freeze
  def forecast_carousel_indicator(label, idx, target:)
    label = FIXED_DATE_LABELS.fetch(idx, label)
    content_tag :button, label, type: "button", 'data-bs-target': target, 'data-bs-slide-to': idx,
                class: [idx.zero? && "active"].compact_blank.join(' '),
                'aria-current': idx.zero?, 'aria-label': label
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
        icon = content_tag :span, '',
                    class: "carousel-control-#{action}-icon", 'aria-hidden': true
        hidden_label = content_tag :span, label, class: 'visually-hidden'
        icon + hidden_label
      end
    end
  end

  def carousel_buttons(target:)
    carousel_button(:prev, target:) + carousel_button(:next, target:)
  end

  def cache_status_badge(is_hit)
    text = is_hit ? 'Hit' : 'Miss'
    color_class = is_hit ? 'text-bg-info' : 'text-bg-warning'
    content_tag :span, class: %W[badge rounded-pill align-text-top #{color_class}] do
      content_tag :small, "Cache #{text}"
    end
  end
end
