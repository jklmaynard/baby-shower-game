module Api
  class AnswersController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :require_login

    def create
      question = Question.find(params[:question_id])
      answer = current_player.player_answers.find_or_initialize_by(question: question)

      answer_text = params[:answer_text].to_s.strip
      correct_texts = question.correct_answer_texts
      is_correct = if question.multiple?
        correct_texts.map(&:downcase).include?(answer_text.downcase)
      elsif question.date?
        normalize_date(answer_text) == normalize_date(correct_texts.first.to_s)
      else
        norm_input = normalize_blank(answer_text)
        correct_texts.any? do |t|
          norm_correct = normalize_blank(t)
          norm_correct == norm_input ||
            norm_correct.include?(norm_input) ||
            norm_input.include?(norm_correct)
        end
      end

      answer.assign_attributes(answer_text: answer_text, is_correct: is_correct)

      if answer.save
        render json: { success: true, is_correct: is_correct, answer: answer_text }
      else
        render json: { success: false, errors: answer.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def normalize_blank(str)
      str.to_s.strip.downcase.gsub(/\A(a|an|the)\s+/, "").strip
    end

    def normalize_date(str)
      return nil if str.blank?
      Date.parse(str.include?("/") ? str.gsub(%r{(\d+)/(\d+)/(\d+)}, '\3-\1-\2') : str)
    rescue Date::Error
      nil
    end

    def index
      question = Question.find(params[:question_id])
      answers = question.player_answers.group(:answer_text).count

      render json: {
        question_id: question.id,
        question: question.body,
        results: answers.map { |text, count| { answer: text, count: count } }
                        .sort_by { |r| -r[:count] }
      }
    end
  end
end
