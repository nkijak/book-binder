require 'tmpdir'
require 'zlib'
require 'rubygems/package'
require 'asciidoctor'

module Binder
    def expand_archive(dir, archive)
        Zlib::GzipReader.open(archive) do |bz|
            Gem::Package::TarReader.new(bz) do |tar|
                tar.each do |entry|
                    if entry.file?
                        parent = "#{dir}/#{File.dirname(entry.full_name)}"
                        target = "#{dir}/#{entry.full_name}"
                        FileUtils.mkdir_p(parent)    
                        File.open(target, 'wb') { |f| f.write(entry.read) }
                    end
                    puts entry.header.mode, target
                    File.chmod(entry.header.mode, target) if entry.header.mode && target
                end
            end
        end
    end

    def render(book_zip, code_zip)
        Dir.mktmpdir do |temp_dir| 
            {book: book_zip, code: code_zip}.each do |prefix, archive|
                dir = "#{temp_dir}/#{prefix}" 
                puts dir, archive
                expand_archive dir, archive
            end
            Dir.mktmpdir do |output_dir|
                Asciidoctor.convert_file(
                    "#{temp_dir}/book/dist/raw.adoc",  #TODO how to find
                    to_file: true, 
                    safe: :unsafe,
                    to_dir: output_dir
                )
                yield output_dir
            end
        end
    end

    module_function(:render)
    module_function(:expand_archive)
end

Binder::render('tests/resources/book.tar.gz', 'tests/resources/code.tar.gz') do |outdir| 
    puts(outdir) 
end