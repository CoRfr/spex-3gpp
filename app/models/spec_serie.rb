class SpecSerie < ActiveRecord::Base
  attr_accessible :index, :spec_scope_id, :subject

  belongs_to :spec_scope
  has_many :documents
end
