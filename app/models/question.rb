class Question < ActiveRecord::Base
  validates :text, presence: true

  belongs_to :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id

  has_many :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id

  has_many :responses,
    through: :answer_choices,
    source: :responses

  def results
    answer_choices
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .group("answer_choices.id")
      .select("answer_choices.*, COUNT(responses.id) AS responses_count")
    # answers = answer_choices.includes(:responses)
    # answer_counts = {}
    #
    # answers.each do |answer|
    #   answer_counts[answer] = answer.responses.length
    # end
    #
    # answer_counts
  end

end
