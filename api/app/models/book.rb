class Book < ApplicationRecord
    has_one_attached :book_archive
    has_one_attached :code_archive

end
