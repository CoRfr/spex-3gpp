class SpecsController < ApplicationController
    respond_to :html, :doc, :pdf

    def specs
        if params["serie"].nil?
            render :list_series
        else
            @serie = SpecSerie.find_by_index(params["serie"].to_i)

            if params["spec"].nil?
                render :list_specs
            else
                spec_desc = Document.parse_no(params["spec"])
                @spec = Document.find_by_desc(spec_desc)

                if @spec.nil?
                    render :status => :not_found
                    return
                end

                if params["version"].nil?
                    render :list_versions
                else
                    version_desc = DocumentVersion.parse_version(params["version"])
                    @version = @spec.document_versions.where(version_desc).first

                    if params["format"].nil?
                        @content_partial = "version_layout"
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
