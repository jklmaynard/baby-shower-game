questions_data = [
  {
    body: "What is Hannah's due date?",
    question_type: :date,
    position: 11,
    answers: [
      { text: "10/6/2026", is_correct: true }
    ]
  },
  {
    body: "What was the most popular toy the year Hannah was born?",
    question_type: :blank,
    position: 12,
    answers: [
      { text: "Trolls", is_correct: true }
    ]
  },
  {
    body: "What was the most popular toy the year Patrick was born?",
    question_type: :blank,
    position: 13,
    answers: [
      { text: "Teenage Mutant Ninja Turtles", is_correct: true },
      { text: "TMNT", is_correct: true }
    ]
  },
  {
    body: "What is the name used for a baby elephant?",
    question_type: :blank,
    position: 14,
    answers: [
      { text: "calf", is_correct: true }
    ]
  },
  {
    body: "What is a baby platypus called?",
    question_type: :blank,
    position: 15,
    answers: [
      { text: "puggle", is_correct: true }
    ]
  },
  {
    body: "What is the name of the soft spots on a newborn baby's head where the skull bones haven't yet fused?",
    question_type: :blank,
    position: 16,
    answers: [
      { text: "fontanelles", is_correct: true },
      { text: "fontanelle", is_correct: true }
    ]
  },
  {
    body: "What is the most common birth month?",
    question_type: :blank,
    position: 17,
    answers: [
      { text: "September", is_correct: true }
    ]
  },
  {
    body: "How many bones does a baby have at birth?",
    question_type: :blank,
    position: 18,
    answers: [
      { text: "300", is_correct: true }
    ]
  },
  {
    body: "What is a baby's first poop called?",
    question_type: :blank,
    position: 19,
    answers: [
      { text: "meconium", is_correct: true }
    ]
  },
  {
    body: "What body part are babies born without?",
    question_type: :blank,
    position: 20,
    answers: [
      { text: "kneecaps", is_correct: true },
      { text: "patella", is_correct: true }
    ]
  }
]

questions_data.each do |data|
  Question.find_or_create_by!(body: data[:body]) do |q|
    q.question_type = data[:question_type]
    q.position      = data[:position]
    q.answers       = data[:answers].map { |a| { "text" => a[:text], "is_correct" => a[:is_correct] } }
  end
end

puts "Seeded #{Question.count} questions."
