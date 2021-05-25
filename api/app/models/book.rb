class Book < ApplicationRecord
    has_one_attached :book_archive
    has_one_attached :code_archive

    has_one_attached :epub
    has_one_attached :pdf
    has_one_attached :html

    def purge_files
        book_archive.purge
        code_archive.purge
        epub.purge
        pdf.purge
        html.purge
    end

    def as_json(options)
      self.attributes.merge({
        'book_archive' => self.book_archive.attributes,
        'code_archive' => self.code_archive.attributes,
        'pdf' => self.pdf.attributes,
        'epub' => self.epub.attributes,
        'html' => self.html.attributes
      })
    end
end
