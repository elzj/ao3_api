# frozen_string_literal: true

class Api::V3::BookmarksController < Api::V3::BaseController
  before_action :authenticate_user!, only: [:create]

  def index
    @bookmarks = Search::BookmarkSearch.new(query_params)
                                       .search_results(load: false)
    render json: @bookmarks.to_json
  end

  def show
    @bookmark = Search::BookmarkSearch.document(
      Bookmark.visible_to(current_user).find(params[:id])
    )
    render json: @bookmark.to_json
  end

  def create
    bookmark = Bookmark.new(bookmark_params)
    if bookmark.save_for_user(current_user)
      render json: { id: bookmark.id }, status: :created
    else
      render json: { errors: bookmark.errors }, status: :unprocessable_entity
    end
  end

  protected

  def query_params
    params.require(:query).permit(
      Search::BookmarkSearch.permitted_params
    ).merge(current_user: current_user)
  end

  def bookmark_params
    params.require(:bookmark).permit(
      :bookmarker_notes, :bookmarkable_id, :bookmarkable_type,
      :rec, :private, :tags, :pseud_id
    )
  end
end
