# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render text: 'Hello World!'
  end
end