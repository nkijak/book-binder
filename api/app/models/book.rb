class Book < ApplicationRecord
    has_one_attached :book_archive
    has_one_attached :code_archive

    has_one_attached :epub
    has_one_attached :pdf

    def purge_files
        book_archive.purge
        code_archive.purge
        epub.purge
        pdf.purge
    end
end
