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

  def generate_pg_query(uid, number = nil)
    @number ||= 0
    number = @number if number.nil?

    "SELECT #{uid}__db_a__table_a.field_a " \
    "FROM #{uid}__db_a__table_a " \
    "INNER JOIN #{uid}__db_b__table_b ON (#{uid}__db_a__table_a.id = #{uid}__db_b__table_b.id) "\
    "WHERE #{uid}__db_b__table_b.field_b > #{number};"
  end

  def generate_query_spec
    {
      'db_a' => {
        'table_a' => {
          'field_a' => 'character varying',
          'id' => 'integer'
        }
      },
      'db_b' => {
        'table_b' => {
          'id' => 'integer',
          'field_b' => 'character varying'
        }
      }
    }
  end
end
