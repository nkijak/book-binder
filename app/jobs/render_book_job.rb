require 'tmpdir'
require 'zlib'
require 'rubygems/package'
require 'asciidoctor'

class RenderBookJob < ApplicationJob
  queue_as :default

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
        [book_zip, code_zip]
          .compact
          .zip(['book', 'code'])
          .each do |archive, prefix|
              dir = "#{temp_dir}/#{prefix}" 
              puts dir, archive
              expand_archive dir, archive
          end
          Dir.mktmpdir do |output_dir|
              adoc = "#{temp_dir}/book/dist/raw.adoc"
              #TODO break up into separate jobs as to not stop processing  
              Asciidoctor.convert_file(
                  adoc,  #TODO how to find
                  to_file: true, 
                  safe: :unsafe,
                  to_dir: output_dir
              )
              Asciidoctor.convert_file(
                  adoc,  #TODO how to find
                  to_file: true, 
                  backend: 'pdf',
                  safe: :unsafe,
                  to_dir: output_dir
              )
              Asciidoctor.convert_file(
                  adoc,  #TODO how to find
                  to_file: true, 
                  backend: 'epub3',
                  safe: :unsafe,
                  to_dir: output_dir
              )
              logger.info "rendered to #{output_dir}"
              yield output_dir
          end
      end
  end

  ##
  # if +code_archive+ is available +open+ and yield in block as usual
  # otherwise execute the block anyway and pass +other+
  def either(code_archive, other, &block)
    if code_archive.attached?
      code_archive.open(block)
    else
      block.call(other)
    end
  end

  def perform(book)
    book.book_archive.open do |book_archive|
      logger.debug book_archive.path
      either(book.code_archive, nil) do |code_archive|
        render(book_archive, code_archive) do |outdir| 
          d = Dir.new(outdir)
          logger.debug d.entries
          pdfs = d.grep(/\.+pdf/)
          epubs = d.grep(/\.+epub/)
          htmls = d.grep(/\.+html/)
          logger.info "found #{pdfs.inspect},#{epubs.inspect}, and #{htmls.inspect}"
          book.pdf.attach(io: File.open(File.join(outdir, pdfs.first)), filename: pdfs.first) if pdfs.any?
          book.epub.attach(io: File.open(File.join(outdir, epubs.first)), filename: epubs.first) if epubs.any?
          book.html.attach(io: File.open(File.join(outdir, htmls.first)), filename: htmls.first) if htmls.any?
          book.save!
        end
      end
    end
  end
end
