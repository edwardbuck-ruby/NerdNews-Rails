# encoding: utf-8

class CommentsController < ApplicationController
  load_and_authorize_resource
  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
    @story = Story.find(params[:story_id])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new(parent_id: params[:parent_id])
    @story = Story.find(params[:story_id])

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
    @story = Story.find(params[:story_id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @story = Story.find(params[:story_id])
    @comment = @story.comments.build(params[:comment])
    @comment.user = current_user ? current_user : nil
    @comment.parent_id = params[:comment][:parent_id].empty? ? nil : Comment.find(params[:comment][:parent_id])
    @comment.add_user_requests_data = request
    @comments = @story.comments.arrange(order: :created_at)

    respond_to do |format|
      if @comment.save

        record_activity %Q(دیدگاهی جدید برای خبر #{view_context.link_to @story.title.truncate(40), story_path(@story, :anchor => "comment_#{@comment.id}")} ایجاد کرد)

        UserMailer.delay.comment_reply(@comment.id) unless @comment.parent.nil?
        rate_user(current_user, 1) if current_user.present?
        format.html { redirect_to @story, notice: t('controllers.comments.create.flash.success') }
      else
        format.html { render template: "stories/show" }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])
    @story = Story.find(params[:story_id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        record_activity %Q(دیدگاه در خبر #{view_context.link_to @story.title.truncate(40), story_path(@story, :anchor => "comment_#{@comment.id}")} را ویرایش کرد)

        format.html { redirect_to story_path(@comment.story),
          notice: t('controllers.comments.update.flash.success') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    record_activity %Q(دیدگاه در خبر #{view_context.link_to @story.title.truncate(40), story_path(@story, :anchor => "comment_#{@comment.id}")} را حذف کرد)

    respond_to do |format|
      format.html { redirect_to story_path(@comment.story) }
    end
  end
end
