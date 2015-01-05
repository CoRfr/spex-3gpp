class DocumentToc < ActiveRecord::Base
  belongs_to :document_file

  belongs_to :parent, :class_name => "DocumentToc"
  has_many :childs, :class_name => "DocumentToc"
end
