# frozen_string_literal: true

class Api::V3::PseudsController < Api::V3::BaseController
  respond_to :json

  def index
    @pseuds = Search::PseudSearch.new(query_params).search_results
    respond_with @pseuds.to_json
  end

  def show
    @pseud = Search::PseudSearch.document(Pseud.find(params[:id]))
    respond_with @pseud.to_json
  end

  protected

  def query_params
    params.require(:query).permit(
      :q, :name, :fandom, :tag_ids, :collection_ids
    ).merge(current_user: current_user)
  end
end
