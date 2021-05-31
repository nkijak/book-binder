require "test_helper"

class RenderBookJobTest < ActiveJob::TestCase
  test "job attaches book" do
    book = Book.first
    assert_not book.epub.attached?
    assert_not book.pdf.attached?
    RenderBookJob.perform_now(book)
    assert book.epub.attached?
    assert book.pdf.attached?
  end
end
