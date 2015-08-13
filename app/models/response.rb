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

  has_one :poll,
    through: :question,
    source: :poll

  has_many :responses,
    through: :question,
    source: :responses

  def does_not_respond_to_own_poll
    if poll.author_id  == respondent_id
      errors[:author] << "Cannot respond to own poll."
    end
  end

  private

  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(['responses.respondent_id = ?', respondent_id])
      errors[:respondent] << "Has already answered the question"
    end
  end

  def sibling_responses
    responses.where('responses.id != ? AND ? IS NOT NULL', id, id)
  end
end
