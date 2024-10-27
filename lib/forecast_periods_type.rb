# frozen_string_literal: true

  # ActiveModel type to encapsulate an instance of ::ForecastPeriod
  class ForecastPeriodsType < ActiveModel::Type::Value
    def type = :forecast_period

    def cast_value(value)
      Array.wrap(value).map do |v|
        next nil if v.blank?
        next v if v.is_a?(::ForecastPeriod)
        ForecastPeriod.new(**v)
      end.compact
    end
  end
