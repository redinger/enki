class CommentsController < ApplicationController
  include UrlHelper
  OPEN_ID_ERRORS = { 
    :missing  => "Sorry, the OpenID server couldn't be found", 
    :canceled => "OpenID verification was canceled",
    :failed   => "Sorry, the OpenID verification failed" }

  before_filter :find_post, :except => [:new]

  def index
    if request.post? || using_open_id?
      create
    else
      redirect_to(post_path(@post))
    end
  end

  def new
    @comment = Comment.build_for_preview(params[:comment])

    respond_to do |format|
      format.js do
        render :partial => 'comment.html.erb'
      end
    end
  end

  def create
    @comment = Comment.new((session[:pending_comment] || params[:comment] || {}).reject {|key, value| !Comment.protected_attribute?(key) })
    @comment.post = @post
    @comment.env = request.env
    session[:pending_comment] = nil

    unless @comment.requires_openid_authentication?
      @comment.blank_openid_fields
    else
      session[:pending_comment] = params[:comment]
      return if authenticate_with_open_id(@comment.author, :optional => [:nickname, :fullname, :email]) do |result, identity_url, registration|
        if result.status == :successful
          @comment.post = @post

          @comment.author_url   = @comment.author
          @comment.author       = (registration["fullname"] || registration["nickname"] || @comment.author_url).to_s
          @comment.author_email = (registration["email"] || @comment.author_url).to_s

          @comment.openid_error = ""
          session[:pending_comment] = nil
        else
          @comment.openid_error = OPEN_ID_ERRORS[ result.status ]
        end
      end
    end

    if session[:pending_comment].nil? && @comment.save
      if @comment.spam
        flash[:notice] = 'Your comment has been marked for review'
      else
        flash[:notice] = 'Comment created'
      end
      redirect_to post_path(@post)
    else
      render :template => 'posts/show'
    end
  end

  protected

  def find_post
    @post = Post.find_by_permalink(*[:year, :month, :day, :slug].collect {|x| params[x] })
  end
end
