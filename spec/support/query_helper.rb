# frozen_string_literal: true

module QueryHelper
  def generate_query(number = nil)
    @number ||= 0
    number = @number if number.nil?

    'SELECT db_a.table_a.field_a ' \
    'FROM db_a.table_a ' \
    'INNER JOIN db_b.table_b ON (db_a.table_a.id = db_b.table_b.id) '\
    "WHERE db_b.table_b.field_b > #{number};"
  end

  def generate_pg_query(number = nil)
    @number ||= 0
    number = @number if number.nil?

    'SELECT db_a_table_a.field_a ' \
    'FROM db_a_table_a ' \
    'INNER JOIN db_b_table_b ON (db_a_table_a.id = db_b_table_b.id) '\
    "WHERE db_b_table_b.field_b > #{number};"
  end

  def generate_query_spec
    {
      'db_a' => {
        'table_a' => %w[
          field_a
          id
        ]
      },
      'db_b' => {
        'table_b' => %w[
          id
          field_b
        ]
      }
    }
  end
end
