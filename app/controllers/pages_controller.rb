class PagesController < ApplicationController
  def index #views/index.html.erbを表示させるというアクション
    @users = User.all
    @listings = Listing.where(active: true).all
  end

  def search
    @listings = Listing.where(active: true).all
  end
  
end
