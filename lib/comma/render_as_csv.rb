if defined?(ActionController::Renderers) && ActionController::Renderers.respond_to?(:add)
  ActionController::Renderers.add :csv do |obj, options|
    filename = options[:filename] || 'data'
    send_data obj.to_comma, :type => Mime::CSV, :disposition => "attachment; filename=#{filename}.csv"
  end
else
  module RenderAsCSV
    def self.included(base)
      base.alias_method_chain :render, :csv
    end

    def render_with_csv(options = nil, extra_options = {}, &block)
      return render_without_csv(options, extra_options, &block) unless options.is_a?(Hash) and options[:csv].present?

      content  = options.delete(:csv)
      style    = options.delete(:style) || :default
      filename = options.delete(:filename)

      headers.merge!(
        'Content-Transfer-Encoding' => 'binary',
        'Content-Type'              => 'text/csv; charset=utf-8'
      )
      filename_header_value = "attachment"
      filename_header_value += "; filename=\"#{filename}\"" if filename.present?
      headers.merge!('Content-Disposition' => filename_header_value)

      @performed_render = false

      render_stream :status => 200,
                    :content => Array(content),
                    :style => style
    end

    protected

    def render_stream(options)
      status  = options[:status]
      content = options[:content]
      style   = options[:style]

      #rails 2 specific
      render :status => status, :text => Proc.new { |response, output|
        output.write FasterCSV.generate_line(content.first.to_comma_headers(style))
        content.each { |line| output.write FasterCSV.generate_line(line.to_comma(style)) }
      }

    end
  end
  #credit : http://ramblingsonrails.com/download-a-large-amount-of-data-in-csv-from-rails
end