class BooksController < ApplicationController
  include ActionController::MimeResponds

  before_action :set_book, only: [:show, :update, :destroy, :bind]

  # GET /books
  def index
    @books = Book.all

    render json: @books
  end

  # GET /books/1
  def show
    respond_to do |format|
      format.json { render json: @book }
      #FIXME this is kind of janky but works for zero-scale/now
      format.html { render body: @book.html.download}
      format.any(:pdf, :epub) do 
        redirect_to rails_blob_path(@book.send(request.format.to_sym), disposition: 'attachment')
      end
    end
  end


  # POST /books/1/bind
  def bind(*args)
    puts args
    unless @book.nil?
      RenderBookJob.perform_later @book
      render :nothing => true, status: :no_content
    else
      render :nothing => true, status: :not_found
    end 
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      RenderBookJob.perform_later @book
      render json: @book, status: :created, location: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      RenderBookJob.perform_later @book
      render json: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.purge_files
    @book.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :book_archive, :code_archive)
    end
end
