require 'tmpdir'
require 'zlib'
require 'rubygems/package'
require 'asciidoctor'

def render(book_zip, code_zip)
    Dir.mktmpdir do |book_dir| 
        puts book_dir
        Zlib::GzipReader.open(book_zip) do |bz|
            Gem::Package::TarReader.new(bz) do |tar|
                tar.each do |entry|
                    if entry.file?
                        parent = "#{book_dir}/#{File.dirname(entry.full_name)}"
                        target = "#{book_dir}/#{entry.full_name}"
                        puts "mkdir_p #{parent}"
                        FileUtils.mkdir_p(parent)    
                        File.open(target, 'wb') { |f| f.write(entry.read) }
                    end
                    File.chmod(entry.header.mode, target)
                end
            end
        end
        Dir.mktmpdir do |output_dir|
            Asciidoctor.convert_file(
                "#{book_dir}/dist/raw.adoc", 
                to_file: true, 
                safe: :unsafe,
                to_dir: output_dir
            )
            puts output_dir
        end
    end
end

render('tests/resources/book.tar.gz', 'tests/resources/code.tar.gz')