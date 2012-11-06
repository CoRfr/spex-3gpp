class DocumentPdfHtml

    def initialize(path)
        @source_html = Nokogiri::HTML(open(path))
    end

    def html_content
        content  = js_content
        content += css_content
        content += body_content
    end

    def page_count
        if @page_count.nil?
            @page_count = @source_html.xpath('/div[@class="d" and position()=last()]').to_s
            puts "Page Count"
            puts @page_count.green
        end

        @page_count
    end

private
    def body_content
        @source_html.xpath('//*[@id="pdf-main"]').to_s
    end

    def css_content
        content  = @source_html.xpath('/html/head/style[1]').to_s
        content += @source_html.xpath('/html/head/style[2]').to_s
        content += @source_html.xpath('/html/head/style[3]').to_s
    end

    def js_content
        content  = @source_html.xpath('/html/head/script[2]').to_s
        content += @source_html.xpath('/html/head/script[3]').to_s
    end

end