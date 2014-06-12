module Kernel
  # Requires any ruby files in a given path.
  #
  # @param path [String] Path to require all ruby files from.
  # @param options [Hash] Options Hash.
  # @option options :relative_to [String] Path relative to where `path` exists.
  #
  # @example require_all "compile_stages", relative_to: __FILE__
  def require_all(path, options = {})
    if rt = options[:relative_to]
      path = "#{File.dirname(rt)}/#{path}"
    end
    Dir.glob("#{path}/*.rb").each do |f|
      require f
    end
  end
end