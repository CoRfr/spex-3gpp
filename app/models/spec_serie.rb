class SpecSerie < ActiveRecord::Base
  belongs_to :spec_scope
  has_many :documents
end
