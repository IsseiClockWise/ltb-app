require 'line/bot'

class TodosController < ApplicationController
  before_action :set_todo, only: %i[ show edit update destroy ]

  # GET /todos or /todos.json
  def index
    @todos = Todo.all
  end

  # GET /todos/1 or /todos/1.json
  def show
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # GET /todos/1/edit
  def edit
  end

  # POST /todos or /todos.json
  def create
    @todo = Todo.new(todo_params)
  
    if @todo.save
      send_line_notification("ToDoが追加されました。タイトル: #{@todo.title}, 内容: #{@todo.content}")
      redirect_to @todo, notice: 'ToDoが作成されました。'
    else
      render :new
    end
  end  

  # PATCH/PUT /todos/1 or /todos/1.json
  def update
    if @todo.update(todo_params)
      send_line_notification("ToDoの情報が更新されました。タイトル: #{@todo.title}, 内容: #{@todo.content}")
      redirect_to todo_url(@todo), notice: "ToDoの情報が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todos/1 or /todos/1.json
  def destroy
    send_line_notification("ToDoが削除されました。タイトル: #{@todo.title}, 内容: #{@todo.content}")
    @todo.destroy

    redirect_to todos_url, notice: "ToDoが削除されました。"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:title, :content)
    end

    def send_line_notification(message)
      client = Line::Bot::Client.new { |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_TOKEN']
      }

      message = {
        type: 'text',
        text: message
      }
      response = client.push_message(ENV['USER_LINE_ID'], message)
      p response
    end
end
