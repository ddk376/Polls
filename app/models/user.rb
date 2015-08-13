class User < ActiveRecord::Base
  validates :user_name, uniqueness: true
  validates :user_name, presence: true

  has_many :authored_polls,
    class_name: 'Poll',
    foreign_key: :author_id,
    primary_key: :id

  has_many :responses,
    class_name: 'Response',
    foreign_key: :respondent_id,
    primary_key: :id

  def completed_polls
    Poll.find_by_sql(<<-SQL)
      SELECT
        polls.*, COUNT(DISTINCT(questions.id)) AS questions_count, COUNT(users_responses.id) AS responses_count
      FROM
        polls
      INNER JOIN
        questions ON polls.id = questions.poll_id
      INNER JOIN
        answer_choices ON questions.id = answer_choices.question_id
      LEFT OUTER JOIN
        ( SELECT
            responses.*
          FROM
            responses
          WHERE
            responses.respondent_id = 1
        ) AS users_responses
      ON users_responses.answer_choice_id = answer_choices.id
      GROUP BY
        polls.id
      HAVING
        COUNT(questions.id) = COUNT(users_responses.id)

    SQL
  end
end

# 
# execute (<<-SQL)
#   SELECT
#     polls.*, COUNT(DISTINCT(questions.id)) AS questions_count, COUNT(users_responses.id) AS responses_count
#   FROM
#     polls
#   INNER JOIN
#     questions ON polls.id = questions.poll_id
#   INNER JOIN
#     answer_choices ON questions.id = answer_choices.question_id
#   LEFT OUTER JOIN
#     ( SELECT
#         responses.*
#       FROM
#         responses
#       WHERE
#         responses.respondent_id = 1
#     ) AS users_responses
#   ON users_responses.answer_choice_id = answer_choices.id
#   GROUP BY
#     polls.id
#   HAVING
#     COUNT(questions.id) = COUNT(users_responses.id)
#
# SQL
#
# execute (<<-SQL)
#   SELECT
#     polls.*, COUNT(DISTINCT(questions.id)) AS questions_count, COUNT(users_responses.id) AS responses_count
#   FROM
#     polls
#   INNER JOIN
#     questions ON polls.id = questions.poll_id
#   INNER JOIN
#     answer_choices ON questions.id = answer_choices.question_id
#   LEFT OUTER JOIN
#     ( SELECT
#         responses.*
#       FROM
#         responses
#       WHERE
#         responses.respondent_id = 1
#     ) AS users_responses ON users_responses.answer_choice_id = answer_choices.id
#   GROUP BY
#     polls.id
#
# SQL
