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

  def result_joins
    answer_choices_with_count = answer_choices
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .group("answer_choices.id")
      .select("answer_choices.*, COUNT(responses.id) AS responses_count")

    answer_choices_with_count.map do |answer_choice|
      [answer_choice, answer_choice.responses_count]
    end
  end

  def result_includes
    answers = answer_choices.includes(:responses)
    answer_counts = {}

    answers.each do |answer|
      answer_counts[answer] = answer.responses.length
    end

    answer_counts
  end

  def result_improved
    AnswerChoices.find_by_sql(<<-SQL, self.id)
      SELECT
        answer_choices.*, COALESCE(COUNT(answer_choices.id), 0 ) AS choice_count
      FROM
        answer_choices
      LEFT OUTER JOIN
        responses ON answer_choices.id = responses.answer_choice_id
      WHERE
        answer_choice.question_id = (?)
      GROUP BY
        answer_choices.id
    SQL
  end

end
