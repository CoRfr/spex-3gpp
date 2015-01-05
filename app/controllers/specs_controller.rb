class SpecsController < ApplicationController
    respond_to :html, :doc, :pdf

    def specs
        @navs = []

        @page_name = "Specs"
        @url_options = {}
        @title = "X"

        begin
            if params["serie"].nil?
                # Display series list
                render :list_series
            else
                @serie = SpecSerie.find_by_index(params["serie"].to_i)

                @navs.push({ :name => @page_name, :link => specs_res_url(@url_options) })
                @page_name = "#{@serie.index} Series"
                @title += " :: #{@page_name}"
                @url_options[:serie] = params["serie"]

                if params["spec"].nil?
                    # Display spec list
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
                    @title = "X :: #{@page_name}"
                    @url_options[:spec] = params["spec"]
                    
                    if params["version"].nil?
                        # Display version list
                        render :list_versions
                    else
                        version_desc = DocumentVersion.parse_version(params["version"])
                        @version = @spec.document_versions.where(version_desc).first

                        @navs.push({ :name => @page_name, :link => specs_res_url(@url_options) })
                        @page_name = @version.version
                        @title += " :: #{@page_name}"
                        @url_options[:version] = params["version"]

                        # Display version

                        if params["format"].nil?
                            @content_partial = "version_layout"
                            render :version
                        else
                            respond_to do |format|
                                format.any(:html, :pdf, :doc) {
                                    file_format = params["format"].to_sym
                                    ap @version
                                    if @version.has_format?(file_format) or @version.retrieve_format(file_format)
                                        send_file @version.get_file(file_format).local_path, :disposition => 'inline'
                                    else
                                        redirect_to specs_res_url( {
                                            :serie => params["serie"],
                                            :spec => params["spec"],
                                            :version => params["version"]
                                            }),
                                            :notice => "Unable to retrieve format #{file_format}"
                                    end
                                }
                            end
                        end
                    end
                end
            end
        rescue Exception => e
            @exception = e
        end
    end
end
