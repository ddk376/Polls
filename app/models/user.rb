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

  def completed_polls_activerecord
    completed = users_polls
      .having("COUNT(questions.id) = COUNT(users_responses.id)")

    completed.map { |c| [c, c.questions_count]}
  end

  def uncompleted_polls_activerecord
    completed = users_polls
      .having("COUNT(questions.id) != COUNT(users_responses.id)")

    completed.map { |c| [c, c.questions_count] }
  end

  def users_polls
    Poll
      .joins(:questions)
      .joins("INNER JOIN answer_choices ON answer_choices.question_id = questions.id")
      .joins("LEFT OUTER JOIN ( #{Response.where("respondent_id = ?", self.id).to_sql} ) AS users_responses
              ON users_responses.answer_choice_id = answer_choices.id")
      .group("polls.id")
      .select("polls.*, COUNT(DISTINCT(questions.id)) AS questions_count")
  end

  def completed_polls
    Poll.find_by_sql(<<-SQL, self.id)
      SELECT
        polls.*,
        COUNT(DISTINCT(questions.id)) AS questions_count,
        COUNT(users_responses.id) AS responses_count
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
