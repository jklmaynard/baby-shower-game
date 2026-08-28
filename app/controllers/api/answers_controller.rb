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
        correct_texts.any? { |t| fuzzy_blank_match?(norm_input, normalize_blank(t)) }
      end

      answer.assign_attributes(answer_text: answer_text, is_correct: is_correct)

      if answer.save
        render json: { success: true, is_correct: is_correct, answer: answer_text }
      else
        render json: { success: false, errors: answer.errors.full_messages }, status: :unprocessable_entity
      end
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

    private

    def fuzzy_blank_match?(norm_input, norm_correct)
      return true if norm_correct == norm_input
      return true if norm_correct.include?(norm_input)
      return true if norm_input.include?(norm_correct)

      threshold = fuzzy_edit_threshold(norm_correct)
      return false if threshold.zero?

      damerau_levenshtein(norm_input, norm_correct) <= threshold
    end

    def fuzzy_edit_threshold(str)
      case str.length
      when 0..3 then 0
      when 4..5 then 1
      when 6..8 then 2
      else           3
      end
    end

    def damerau_levenshtein(a, b)
      return b.length if a.empty?
      return a.length if b.empty?

      rows = a.length + 1
      cols = b.length + 1
      dp = Array.new(rows) { |i| Array.new(cols) { |j| i.zero? ? j : (j.zero? ? i : 0) } }

      (1...rows).each do |i|
        (1...cols).each do |j|
          cost = a[i - 1] == b[j - 1] ? 0 : 1
          dp[i][j] = [
            dp[i - 1][j] + 1,
            dp[i][j - 1] + 1,
            dp[i - 1][j - 1] + cost
          ].min
          if i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]
            dp[i][j] = [ dp[i][j], dp[i - 2][j - 2] + cost ].min
          end
        end
      end

      dp[rows - 1][cols - 1]
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
  end
end
