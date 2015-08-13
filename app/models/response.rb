class Response < ActiveRecord::Base
  validate :respondent_has_not_already_answered_question
  validate :does_not_respond_to_own_poll

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

  def does_not_respond_to_own_poll
    if question.poll.author_id  == respondent_id
      errors[:author] << "Cannot respond to own poll."
    end
  end

  private

  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(['responses.respondent_id != ?', id])
      errors[:respondent] << "Has already answered the question"
    end
  end

  def sibling_responses
    question.responses.where('responses.id != ? AND ? IS NOT NULL', id, id)
  end
end
