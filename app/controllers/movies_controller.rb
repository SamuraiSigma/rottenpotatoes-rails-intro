class MoviesController < ApplicationController

  attr_accessor :checked_ratings

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    restore_session = {}

    # Restore session? just a test
    if params[:sorted_by].nil? && !session[:sorted_by].nil?
      params[:sorted_by] = session[:sorted_by]
    end

    if params[:ratings].nil? && !session[:ratings].nil?
      params[:ratings] = session[:ratings]
    end

    # Get chosen ratings and convert to array
    @ratings_hash = params[:ratings]
    @checked_ratings = (@ratings_hash.nil? ? [] : @ratings_hash.keys)

    # Filter movies by ratings
    @movies = @movies.where(:rating => @checked_ratings)

    # Sort, if necessary
    order_by = ['title', 'release_date']
    option = params[:sorted_by]
    @all_ratings = Movie.all_ratings
    @movies = @movies.order(option + " ASC") if order_by.include?(option)

    # Session
    session[:ratings] = @ratings_hash
    session[:sorted_by] = option
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
