# frozen_string_literal: true

class Forecast
  FORECASTED_DAYS = 3

  include ActiveModel::API
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attribute :zip, :integer
  attribute :cache_hit, :boolean

  attribute :geometry, :immutable_string
  attribute :units, :immutable_string
  attribute :forecast_generator, :immutable_string
  attribute :generated_at, :time
  attribute :update_time, :time
  attribute :valid_times, :immutable_string
  attribute :elevation # This seems to always return in meters a https://codes.wmo.int/common/unit/_m type
  attribute :periods, :forecast_periods

  validates :zip, presence: true, numericality: { only_integer: true }
  validates :cache_hit, inclusion: { in: [true, false] }
  validates :generated_at, :update_time, presence: true
  validates :periods, presence: true, length: { minimum: 1 }

  def initialize(attributes = {})
    attributes.transform_keys! { _1.to_s.underscore }
    attributes.delete('@context')
    super(attributes)
  end

  # For some reason, ActiveModel::Types::Time doesn't parse the time strings correctly
  def generated_at=(value)
    if value.blank?
      super(nil)
    elsif value.is_a?(Time) || value.is_a?(DateTime)
      super(value.to_time)
    else
      super Time.parse(value)
    end
  end

  # For some reason, ActiveModel::Types::Time doesn't parse the time strings correctly
  def update_time=(value)
    if value.blank?
      super(nil)
    elsif value.is_a?(Time) || value.is_a?(DateTime)
      super(value.to_time)
    else
      super Time.parse(value)
    end
  end


  def read_attribute_for_serialization(attr_name)
    attr_name == 'periods' ? super&.map(&:serializable_hash) : super
  end

  def zip_location = @zip_location ||= ZipCodeLookup.fetch(zip)

  def cache_hit? = cache_hit
  def valid?(context = nil)
    super && periods&.all? { _1.valid?(context) }
  end

  def by_date = @by_date ||= periods.slice_before(&:daytime?).first(FORECASTED_DAYS)
end

