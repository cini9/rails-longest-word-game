require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @api_url = "https://wagon-dictionary.herokuapp.com/#{params[:word]}"
    @word_json = JSON.parse(open(@api_url).read)
    @result = { word: params[:word], grid: params[:grid] }

    if !in_grid?(params[:word], params[:grid])
      @result[:result] = 1
    elsif !@word_json['found']
      @result[:result] = 2
    else
      @result[:result] = 3
    end
    @result[:round_score] = calc_score(@result[:result], params[:word])
    session[:score] += calc_score(@result[:result], params[:word])
  end

  def reset
    session[:score] = 0
    redirect_to new_path
  end

  def in_grid?(word, grid)
    grid_array = grid.split(' ')
    word.split('').each do |letter|
      return false unless grid_array.include?(letter.upcase)

      grid_array.slice!(grid_array.index(letter.upcase))
    end
    true
  end

  def calc_score(result, word)
    return 0 if [1, 2].include?(result)

    word.length
  end
end
