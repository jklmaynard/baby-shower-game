module Api
  class QuestionsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :require_login

    def index
      questions = Question.all.map do |q|
        {
          id: q.id,
          body: q.body,
          question_type: q.question_type,
          answers: q.answers,
          position: q.position
        }
      end
      render json: questions
    end
  end
end
