class DocumentFile < ActiveRecord::Base
    attr_accessible :format, :sha1, :size

    belongs_to :document_version

    has_many :document_tocs

    def self.get_filename(doc_version, format)
        name  = "%02d%02d" % [doc_version.document.spec_serie.index, doc_version.document.spec_number]
        name += "-#{doc_version.document.spec_part}" if !doc_version.document.spec_part.nil?
        name += "-#{doc_version.version(:letters)}"
        name += ".#{format}"
    end

    def self.get_local_path(doc_version, format)
        Rails.root.join(
            'specs',
            doc_version.document.spec_serie.index.to_s,
            doc_version.document.name.gsub('.','_'),
            self.get_filename(doc_version, format))
    end

    def local_path
        DocumentFile.get_local_path(document_version, format)
    end

    PREFIX = %W(To Go Mo Ko o).freeze

    def size_h
      s = size.to_f
      i = PREFIX.length - 1
      while s > 512 && i > 0
        i -= 1
        s /= 1024
      end
      ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + PREFIX[i]
    end

    def analyze
        sha1 = Digest::SHA1.new

        File.open(local_path) do |file|
            buffer = ''

            while not file.eof
                file.read(512, buffer)
                sha1.update(buffer)
            end

            self.size = file.size
            self.sha1 = sha1.to_s
        end

        case format
            when :pdf then analyze_pdf
        end
    end


    def analyze_pdf

        if format != "pdf"
          return false
        end

        doc = Poppler::Document.new(local_path.to_s)
        indexer = Poppler::IndexIter.new(doc)

        # Clean
        document_tocs.delete_all

        # Update page count
        self.nb_pages ||= doc.n_pages
        save

        puts "This is the number of pages #{doc.n_pages}".cyan

        pdf_walk_index(indexer)

        true
    end

    def content
        File.read( local_path )
    end

private

    def pdf_walk_index(indexer, parent = nil, depth = 0)

        indexer.each do |i|

            toc_entry = document_tocs.create
            toc_entry.title = i.action.title
            toc_entry.page = i.action.dest.page_num
            toc_entry.parent = parent
            toc_entry.level = depth
            toc_entry.save

            child = i.child

            pdf_walk_index(child, toc_entry, depth + 1) if child.nil? == false and depth < 1
        end
    end
end
