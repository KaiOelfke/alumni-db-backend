class AddTsvectorColumns < ActiveRecord::Migration
  def up
    add_column :users, :tsv, :tsvector
    add_index :users, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON users FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', first_name, last_name, country,
        city, institution, country_of_participation,
        student_company_name, university_name, current_company_name,
        current_job_position, alumni_position, short_bio
      );
    SQL

    now = Time.current.to_s(:db)
    execute "UPDATE users SET updated_at='#{now}';"
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON users
    SQL

    remove_index :users, :tsv
    remove_column :users, :tsv
  end
end
