class WorksController < ApplicationController
  def new
  end

  def edit
  end

  def show
    @work = Work.find(params[:id]).decorate
  end

  def index
    @search = WorkSearch.new(search_params)
    @works = @search.search_results
  end

  def search_params
    basics = {
      filtered: true,
      page: params[:page] || 1,
      current_user: current_user
    }
    return basics if params[:query].blank?

    params.require(:query).permit(
      WorkSearch.permitted_params
    ).merge(basics)
  end
end
