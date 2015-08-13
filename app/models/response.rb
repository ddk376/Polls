class Response < ActiveRecord::Base
  validate :respondent_has_not_already_answered_question

  belongs_to :answer_choice,
    class_name: 'AnswerChoice',
    foreign_key: :answer_choice_id,
    primary_key: :id

  belongs_to :respondent,
    class_name: 'User',
    foreign_key: :respondent_id,
    primary_key: :id

  has_one :question,
    through: :answer_choice,
    source: :question

  def respondent_has_not_already_answered_question
    !sibling_responses.exists?(['responses.respondent_id != ?', id])
  end

  def sibling_responses
    question.responses.where('responses.id != ? AND ? IS NOT NULL', id, id)
  end
end
