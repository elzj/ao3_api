# frozen_string_literal: true

class Api::V3::TagsController < Api::V3::BaseController
  def index
    tags = Search::TagSearch.new(query_params).search_results
    render json: tags.to_json
  end

  def show
    @tag = Search::TagSearch.document(Tag.find(params[:id]))
    render json: @tag.as_json
  end

  def autocomplete
    tags = Tag.autocomplete(search_param: params[:q])
    render json: tags.to_json
  end

  protected

  def query_params
    params.require(:query).permit(
      :name, :canonical, :tag_type
    ).merge(current_user: current_user)
  end
end
