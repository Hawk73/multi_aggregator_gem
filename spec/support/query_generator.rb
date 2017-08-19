# frozen_string_literal: true

class QueryGenerator
  def self.call(number = nil)
    @number ||= 0
    number = @number if number.nil?

    'SELECT db_a.table_a.field_a ' \
    'FROM db_a.table_a ' \
    'INNER JOIN db_b.table_b ON (db_a.table_a.id = db_b.table_b.id) '\
    "WHERE db_b.table_b.field_b > #{number};"
  end
end
