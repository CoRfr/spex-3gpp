class SpecScope < ActiveRecord::Base
  has_many :spec_series, :class_name => 'SpecSerie'
end
