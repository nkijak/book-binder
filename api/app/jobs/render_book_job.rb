class RenderBookJob < ApplicationJob
  queue_as :default

  def perform(book)
    
  end
end
