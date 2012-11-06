class DocumentToc < ActiveRecord::Base
  attr_accessible :document_file_id, :level, :parent_id, :title

  belongs_to :document_file

  belongs_to :parent, :class_name => "DocumentToc"
  has_many :childs, :class_name => "DocumentToc"
end
