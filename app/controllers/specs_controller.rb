class SpecsController < ApplicationController
    respond_to :html, :doc, :pdf

    def specs
        @navs = []

        @page_name = "Specs"
        @url_options = {}

        if params["serie"].nil?
            render :list_series
        else
            @serie = SpecSerie.find_by_index(params["serie"].to_i)

            @navs.push({ :name => @page_name, :link => specs_res_url(@url_options) })
            @page_name = "#{@serie.index} Series"
            @url_options[:serie] = params["serie"]

            if params["spec"].nil?
                render :list_specs
            else
                spec_desc = Document.parse_no(params["spec"])
                @spec = Document.find_by_desc(spec_desc)

                if @spec.nil?
                    render :status => :not_found
                    return
                end

                @navs.push({ :name => @page_name, :link => specs_res_url(@url_options) })
                @page_name = @spec.name
                @url_options[:spec] = params["spec"]
                
                if params["version"].nil?
                    render :list_versions
                else
                    version_desc = DocumentVersion.parse_version(params["version"])
                    @version = @spec.document_versions.where(version_desc).first

                    @navs.push({ :name => @page_name, :link => specs_res_url(@url_options) })
                    @page_name = @version.version
                    @url_options[:version] = params["version"]

                    if params["format"].nil?
                        @content_partial = "version_layout"

                        @doc_pdf = @version.get_file(:pdf)
                        if @doc_pdf.document_tocs.count == 0
                            @version.analyze_pdf
                        end

                        if @version.has_format? :html
                            @doc_html = DocumentPdfHtml.new @version.get_file(:html).local_path
                        elsif !@doc_pdf.nil?
                            @version.retreive_format(:html)
                            @doc_html = DocumentPdfHtml.new @version.get_file(:html).local_path
                        end

                        render :version
                    else
                        respond_to do |format|
                            format.any(:html, :pdf, :doc) {
                                file_format = params["format"].to_sym

                                if @version.has_format?(file_format) or @version.retreive_format(file_format)
                                    send_file @version.get_file(file_format).local_path, :disposition => 'inline'
                                else
                                    redirect_to Rails.application.routes.url_helpers.specs_res_url( {
                                        :serie => params["serie"],
                                        :spec => params["spec"],
                                        :version => params["version"]
                                        } )
                                end
                            }
                        end
                    end
                end
            end
        end
    end
end
