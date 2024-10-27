# frozen_string_literal: true

class ForecastPeriod
  include ActiveModel::API
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attribute :number, :integer
  attribute :name, :immutable_string
  attribute :start_time, :time
  attribute :end_time, :time
  attribute :is_daytime, :boolean
  attribute :temperature, :integer
  attribute :temperature_unit, :immutable_string
  attribute :temperature_trend, :immutable_string
  attribute :probability_of_precipitation, :integer
  attribute :wind_speed, :immutable_string
  attribute :wind_direction, :immutable_string
  attribute :icon, :immutable_string
  attribute :short_forecast, :immutable_string
  attribute :detailed_forecast, :immutable_string

  validates :number, presence: true, numericality: { only_integer: true }
  validates :name, presence: true
  validates :temperature, presence: true, numericality: true
  validates :icon, presence: true

  def initialize(attributes = {})
    attributes.transform_keys! { _1.to_s.underscore }
    super(attributes)
  end

  # For some reason, ActiveModel::Types::Time doesn't parse the time strings correctly
  def start_time=(value)
    if value.blank?
      super(nil)
    elsif value.is_a?(Time) || value.is_a?(DateTime)
      super(value.to_time)
    else
      super Time.parse(value)
    end
  end

  # For some reason, ActiveModel::Types::Time doesn't parse the time strings correctly
  def end_time=(value)
    if value.blank?
      super(nil)
    elsif value.is_a?(Time) || value.is_a?(DateTime)
      super(value.to_time)
    else
      super Time.parse(value)
    end
  end

  def probability_of_precipitation=(value)
    value = 0.0 if value.blank?
    value = value.stringify_keys.fetch('value', 0).to_f if value.is_a?(Hash)
    super(value.to_f)
  end

  def icon=(url)
    return super(url) if url.blank?
    uri = Addressable::URI.parse(url)
    uri&.query_values = uri&.query_values&.tap { _1['size'] = 'large' }
    super(uri.to_s)
  end

  # TODO: figure out a way to consistently get the actual date the forecast is about
  def daytime? = is_daytime
  def precipitation? = probability_of_precipitation&.positive?
end
