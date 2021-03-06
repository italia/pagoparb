# frozen_string_literal: true

module Soap; end
module Soap::Webservice; end

class Soap::Webservice::Request
  class << self
    def header_attributes; {} end

    def body_attributes; {} end
  end

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
    validate_header_attrs!
    validate_body_attrs!
  end

  def validate_header_attrs!
    return if required_header.empty?
    if !required_header.empty? && attributes.empty?
      raise "Required attributes are missing: #{required_header}"
    end

    if !(required_header - attributes.keys).empty?
      raise "Attribute #{required_header - attributes.keys} must be present"
    end
  end

  def validate_body_attrs!
    return if required_body.empty?
    if !required_body.empty? && attributes.empty?
      raise "Required attributes are missing: #{required_body}"
    end

    if !(required_body - attributes.keys).empty?
      raise "Attribute #{required_body - attributes.keys} must be present"
    end
  end

  def body_params
    return {} if self.class.body_attributes.nil?
    self.class.body_attributes.each.with_object({}) do |attr, attrs|
      name = Soap.to_snakecase(attr[:name]).to_sym
      value = attributes[name]
      attrs[name] = value if value
    end
  end

  def header_params
    return {} if self.class.header_attributes.nil?
    self.class.header_attributes.each.with_object({}) do |attr, attrs|
      name = Soap.to_snakecase(attr[:name]).to_sym
      value = attributes[name]
      attrs[name] = value if value
    end
  end

  def to_message
    {
      soap_header: header_params,
      message: body_params
    }
  end

  def to_xml
    Gyoku.xml(
      to_message,
      key_converter: lambda { |key| Soap.to_camelcase(key) }
    )
  end

  private

  def list_header_attrs
    return {} if self.class.header_attributes.nil?
    self.class.header_attributes.each.with_object(
      required: [],
      optional: []
    ) do |attr, attrs|
      name = Soap.to_snakecase(attr[:name]).to_sym
      if attr[:attributes].empty?
        attrs[:required] << name
      else
        attrs[:optional] << name
      end
    end
  end

  def list_body_attrs
    return {} if self.class.body_attributes.nil?
    self.class.body_attributes.each.with_object(
      required: [],
      optional: []
    ) do |attr, attrs|
      name = Soap.to_snakecase(attr[:name]).to_sym
      if attr[:attributes].empty?
        attrs[:required] << name
      else
        attrs[:optional] << name
      end
    end
  end

  def required_header
    list_header_attrs[:required] || []
  end

  def required_body
    list_body_attrs[:required] || []
  end

  def required_attrs
    required_header + required_body
  end
end
