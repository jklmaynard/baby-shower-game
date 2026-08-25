namespace :questions do
  desc "Import questions from a JSON file. Usage: rails questions:import FILE=path/to/questions.json"
  task import: :environment do
    file_path = ENV["FILE"] || Rails.root.join("db/questions_import.json")

    unless File.exist?(file_path)
      puts "ERROR: File not found: #{file_path}"
      puts "Usage: rails questions:import FILE=path/to/questions.json"
      puts ""
      puts "Expected JSON format:"
      puts '[{"question":"...", "type":"multiple|blank", "answer":[{"text":"...", "is_correct":true}]}]'
      exit 1
    end

    raw = JSON.parse(File.read(file_path))
    imported = 0
    skipped  = 0

    raw.each_with_index do |item, i|
      body    = item["question"].to_s.strip
      qtype   = item["type"].to_s.strip
      answers = item["answer"] || []

      if body.blank?
        puts "  Skipping entry #{i + 1}: missing question text"
        skipped += 1
        next
      end

      unless %w[multiple blank].include?(qtype)
        puts "  Skipping entry #{i + 1}: invalid type '#{qtype}' (must be multiple or blank)"
        skipped += 1
        next
      end

      next_pos = (Question.maximum(:position) || 0) + 1

      q = Question.find_or_initialize_by(body: body)
      q.question_type = qtype
      q.position    ||= next_pos
      q.answers       = answers.map { |a| { "text" => a["text"].to_s, "is_correct" => !!a["is_correct"] } }

      if q.save
        imported += 1
        puts "  [#{imported}] Saved: #{body.truncate(60)}"
      else
        puts "  Skipping entry #{i + 1}: #{q.errors.full_messages.join(', ')}"
        skipped += 1
      end
    end

    puts ""
    puts "Done. Imported: #{imported}, Skipped: #{skipped}. Total questions: #{Question.count}"
  end

  desc "List all questions"
  task list: :environment do
    Question.each do |q|
      puts "[#{q.id}] (#{q.question_type}) #{q.body}"
    end
  end
end
