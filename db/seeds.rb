questions_data = [
  {
    body: "What is Hannah's due date?",
    question_type: :date,
    position: 11,
    answers: [
      { text: "10/3/2026", is_correct: true }
    ]
  },
  {
    body: "What was the most popular toy the year Hannah was born?",
    question_type: :multiple,
    position: 12,
    answers: [
      { text: "Trolls", is_correct: true },
      { text: "Lite Brite", is_correct: false },
      { text: "Tickle Me Elmo", is_correct: false },
      { text: "Cabbage Patch Kids", is_correct: false }
    ]
  },
  {
    body: "What was the most popular toy the year Patrick was born?",
    question_type: :multiple,
    position: 13,
    answers: [
      { text: "Koosh Balls", is_correct: false },
      { text: "Game Boy", is_correct: false },
      { text: "Super Soaker", is_correct: false },
      { text: "Teenage Mutant Ninja Turtles", is_correct: true }
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
    question_type: :multiple,
    position: 18,
    answers: [
      { text: "206", is_correct: false },
      { text: "260", is_correct: false },
      { text: "300", is_correct: true },
      { text: "180", is_correct: false }
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
  },
  {
    body: "What is Baby Campbell's Sex?",
    question_type: :multiple,
    position: 21,
    answers: [
      { text: "Boy", is_correct: false },
      { text: "Girl", is_correct: false },
      { text: "Both (It's Twins!)", is_correct: false },
      { text: "It's a Surprise", is_correct: true }
    ]
  },
  {
    body: "Name one of Baby Campbell's Four-Legged Siblings",
    question_type: :blank,
    position: 22,
    answers: [
      { text: "Kelpie", is_correct: true },
      { text: "Tuesday", is_correct: true },
      { text: "Penny", is_correct: true },
      { text: "Penelope", is_correct: true }
    ]
  }
]

questions_data.each do |data|
  q = Question.find_or_initialize_by(body: data[:body])
  q.question_type = data[:question_type]
  q.position      = data[:position]
  q.answers       = data[:answers].map { |a| { "text" => a[:text], "is_correct" => a[:is_correct] } }
  q.save!
end

puts "Seeded #{Question.count} questions."
