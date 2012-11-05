class SpecScope < ActiveRecord::Base
  attr_accessible :scope

  has_many :spec_series, :class_name => 'SpecSerie'
end
